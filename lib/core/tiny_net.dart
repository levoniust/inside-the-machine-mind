import 'dart:math' as math;

/// A labelled 2-D point for the tiny classifier (label 0 or 1).
class Sample {
  const Sample(this.x, this.y, this.label);
  final double x, y;
  final int label;
}

/// Two classes the network has to separate: an inner disc (label 1) inside a ring (label 0).
/// A straight line can't do it, so the hidden layer has to learn a curved boundary.
List<Sample> ringDataset({int n = 160, int seed = 3}) {
  final r = math.Random(seed);
  final out = <Sample>[];
  for (var i = 0; i < n; i++) {
    final inner = i.isEven;
    final radius = inner ? r.nextDouble() * 0.38 : 0.62 + r.nextDouble() * 0.33;
    final a = r.nextDouble() * math.pi * 2;
    out.add(Sample(radius * math.cos(a), radius * math.sin(a), inner ? 1 : 0));
  }
  return out;
}

/// A real (tiny) neural network: 2 inputs → [hidden] tanh neurons → 1 sigmoid output.
/// Trained with full-batch gradient descent on binary cross-entropy, exactly the same recipe
/// (forward pass → loss → backpropagation → nudge every weight) used for giant models.
class TinyNet {
  TinyNet({this.hidden = 8, int seed = 1}) {
    final r = math.Random(seed);
    double rnd() => (r.nextDouble() * 2 - 1) * 1.0;
    w1 = List.generate(hidden, (_) => [rnd(), rnd()]);
    b1 = List.generate(hidden, (_) => rnd() * 0.5);
    w2 = List.generate(hidden, (_) => rnd());
    b2 = 0;
  }

  final int hidden;
  late List<List<double>> w1; // [hidden][2]
  late List<double> b1; // [hidden]
  late List<double> w2; // [hidden]
  late double b2;
  int steps = 0;

  // Adam/momentum state (optional "rolling ball" mode).
  List<List<double>>? _mw1;
  List<double>? _mb1, _mw2;
  double _mb2 = 0;

  /// Number of adjustable knobs (weights + biases).
  int get parameterCount => hidden * 2 + hidden + hidden + 1;

  static double _sigmoid(double z) => 1 / (1 + math.exp(-z));

  /// Probability that (x, y) is label 1.
  double predict(double x, double y) {
    var z = b2;
    for (var j = 0; j < hidden; j++) {
      z += w2[j] * _tanh(w1[j][0] * x + w1[j][1] * y + b1[j]);
    }
    return _sigmoid(z);
  }

  static double _tanh(double v) {
    final e = math.exp(2 * v.clamp(-20, 20));
    return (e - 1) / (e + 1);
  }

  /// Average binary cross-entropy ("wrongness score") over [data].
  double loss(List<Sample> data) {
    var total = 0.0;
    for (final s in data) {
      final p = predict(s.x, s.y).clamp(1e-7, 1 - 1e-7);
      total += s.label == 1 ? -math.log(p) : -math.log(1 - p);
    }
    return total / data.length;
  }

  double accuracy(List<Sample> data) =>
      data.where((s) => (predict(s.x, s.y) >= 0.5 ? 1 : 0) == s.label).length / data.length;

  /// One training step: forward pass on all samples, backpropagate the error, update every weight.
  /// [momentum] > 0 adds a rolling-ball velocity term. Returns the loss before the update.
  double trainStep(List<Sample> data, double learningRate, {double momentum = 0}) {
    final gw1 = List.generate(hidden, (_) => [0.0, 0.0]);
    final gb1 = List.filled(hidden, 0.0);
    final gw2 = List.filled(hidden, 0.0);
    var gb2 = 0.0;
    var total = 0.0;
    final h = List.filled(hidden, 0.0);
    for (final s in data) {
      // Forward.
      var z = b2;
      for (var j = 0; j < hidden; j++) {
        h[j] = _tanh(w1[j][0] * s.x + w1[j][1] * s.y + b1[j]);
        z += w2[j] * h[j];
      }
      final p = _sigmoid(z);
      final pc = p.clamp(1e-7, 1 - 1e-7);
      total += s.label == 1 ? -math.log(pc) : -math.log(1 - pc);
      // Backward: dLoss/dz for sigmoid + cross-entropy is simply (p - label).
      final dz = p - s.label;
      gb2 += dz;
      for (var j = 0; j < hidden; j++) {
        gw2[j] += dz * h[j];
        final dh = dz * w2[j] * (1 - h[j] * h[j]); // blame passed back through tanh
        gb1[j] += dh;
        gw1[j][0] += dh * s.x;
        gw1[j][1] += dh * s.y;
      }
    }
    final n = data.length.toDouble();
    if (momentum > 0) {
      _mw1 ??= List.generate(hidden, (_) => [0.0, 0.0]);
      _mb1 ??= List.filled(hidden, 0.0);
      _mw2 ??= List.filled(hidden, 0.0);
    }
    double upd(double grad, double Function() getV, void Function(double) setV) {
      if (momentum <= 0) return learningRate * grad / n;
      final v = momentum * getV() + learningRate * grad / n;
      setV(v);
      return v;
    }

    for (var j = 0; j < hidden; j++) {
      for (var k = 0; k < 2; k++) {
        w1[j][k] -= upd(gw1[j][k], () => _mw1![j][k], (v) => _mw1![j][k] = v);
      }
      b1[j] -= upd(gb1[j], () => _mb1![j], (v) => _mb1![j] = v);
      w2[j] -= upd(gw2[j], () => _mw2![j], (v) => _mw2![j] = v);
    }
    b2 -= upd(gb2, () => _mb2, (v) => _mb2 = v);
    steps++;
    return total / n;
  }
}
