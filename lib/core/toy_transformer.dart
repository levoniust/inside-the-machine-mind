import 'dart:math' as math;

/// A deliberately tiny transformer (one layer, one attention head, 4 numbers per token) whose
/// arithmetic is real: every value shown on screen is computed here. The weights are hand-set
/// (seeded random, with the output layer nudged) so that "why is the sky" → "blue" comes out on top.
class ToyTransformer {
  ToyTransformer() {
    final r = math.Random(42);
    double w() => (r.nextDouble() * 2 - 1) * 0.9;
    List<List<double>> mat(int rows, int cols) => List.generate(rows, (_) => List.generate(cols, (_) => w()));
    embed = {for (final t in vocab) t: List.generate(d, (_) => w())};
    wq = mat(d, d);
    wk = mat(d, d);
    wv = mat(d, d);
    w1 = mat(d, hidden);
    w2 = mat(hidden, d);
    // Output layer ("unembedding"): one row of scores per vocabulary word.
    unembed = {for (final t in vocab) t: List.generate(d, (_) => w() * 0.6)};
    // Nudge the answer words toward what the context points at, so the toy behaves like a trained model.
    final h = _forward(prompt).out.last;
    final n = math.sqrt(h.fold<double>(0, (s, v) => s + v * v));
    void aim(String word, double strength) =>
        unembed[word] = [for (var i = 0; i < d; i++) unembed[word]![i] * 0.3 + strength * h[i] / n];
    aim('blue', 2.2);
    aim('grey', 1.5);
    aim('dark', 1.1);
    aim('falling', 0.7);
  }

  static const d = 4;
  static const hidden = 6;
  static const vocab = ['why', 'is', 'the', 'sky', 'blue', 'grey', 'dark', 'falling', 'green', 'cat', 'tea', 'happy'];
  static const prompt = ['why', 'is', 'the', 'sky'];

  late final Map<String, List<double>> embed;
  late final List<List<double>> wq, wk, wv, w1, w2;
  late final Map<String, List<double>> unembed;

  int tokenId(String t) => vocab.indexOf(t);

  ToyRun run([List<String> tokens = prompt]) => _forward(tokens);

  ToyRun _forward(List<String> tokens) {
    final x = [for (final t in tokens) List.of(embed[t]!)];
    // Position information: a small, fixed wave added to each slot.
    for (var p = 0; p < x.length; p++) {
      for (var i = 0; i < d; i++) {
        x[p][i] += 0.15 * math.sin((p + 1) * (i + 1) * 0.7);
      }
    }
    final q = [for (final v in x) _mul(v, wq)];
    final k = [for (final v in x) _mul(v, wk)];
    final vv = [for (final v in x) _mul(v, wv)];
    final n = x.length;
    final scale = 1 / math.sqrt(d);
    // Causal attention: each token can only look at itself and earlier tokens.
    final scores = List.generate(n, (i) => List.generate(n, (j) => j <= i ? _dot(q[i], k[j]) * scale : double.negativeInfinity));
    final attn = [for (final row in scores) softmax(row)];
    final mixed = List.generate(n, (i) => List.generate(d, (c) {
          var s = 0.0;
          for (var j = 0; j < n; j++) {
            s += attn[i][j] * vv[j][c];
          }
          return s;
        }));
    final afterAttn = [for (var i = 0; i < n; i++) _add(x[i], mixed[i])];
    final ffHidden = [for (final v in afterAttn) _mul(v, w1).map((e) => math.max(0.0, e)).toList()];
    final ffOut = [for (final h in ffHidden) _mul(h, w2)];
    final out = [for (var i = 0; i < n; i++) _add(afterAttn[i], ffOut[i])];
    final last = out.last;
    final logits = {for (final t in vocab) t: _dot(last, unembed[t]!)};
    return ToyRun(
      tokens: tokens,
      embeddings: x,
      attention: attn,
      mixed: afterAttn,
      ffHidden: ffHidden,
      out: out,
      logits: logits,
    );
  }

  static List<double> softmax(List<double> v, {double temperature = 1}) {
    final t = temperature.clamp(0.05, 10.0);
    final m = v.where((e) => e.isFinite).fold<double>(-double.infinity, math.max);
    final e = [for (final x in v) x.isFinite ? math.exp((x - m) / t) : 0.0];
    final s = e.fold<double>(0, (a, b) => a + b);
    return [for (final x in e) x / s];
  }

  static List<double> _mul(List<double> v, List<List<double>> m) =>
      List.generate(m[0].length, (c) {
        var s = 0.0;
        for (var r = 0; r < v.length; r++) {
          s += v[r] * m[r][c];
        }
        return s;
      });

  static double _dot(List<double> a, List<double> b) {
    var s = 0.0;
    for (var i = 0; i < a.length; i++) {
      s += a[i] * b[i];
    }
    return s;
  }

  static List<double> _add(List<double> a, List<double> b) => [for (var i = 0; i < a.length; i++) a[i] + b[i]];
}

/// Every intermediate value of one forward pass.
class ToyRun {
  ToyRun({
    required this.tokens,
    required this.embeddings,
    required this.attention,
    required this.mixed,
    required this.ffHidden,
    required this.out,
    required this.logits,
  });
  final List<String> tokens;
  final List<List<double>> embeddings; // [token][d]
  final List<List<double>> attention; // [query token][key token], rows sum to 1
  final List<List<double>> mixed; // after attention + residual
  final List<List<double>> ffHidden; // feed-forward hidden layer (after ReLU)
  final List<List<double>> out; // final vectors
  final Map<String, double> logits; // score for every vocabulary word

  /// Vocabulary words sorted by probability (highest first).
  List<MapEntry<String, double>> probabilities({double temperature = 1}) {
    final words = logits.keys.toList();
    final p = ToyTransformer.softmax([for (final w in words) logits[w]!], temperature: temperature);
    final list = [for (var i = 0; i < words.length; i++) MapEntry(words[i], p[i])];
    list.sort((a, b) => b.value.compareTo(a.value));
    return list;
  }
}
