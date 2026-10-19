/// Byte-pair encoding, the real algorithm in miniature: start from single characters, repeatedly merge the
/// most frequent adjacent pair into a new token.
class BpeState {
  BpeState(String corpus)
      : words = [
          for (final w in corpus.split(' ').where((w) => w.isNotEmpty)) [for (final ch in ' $w'.split('')) ch],
        ];

  /// Each word as a list of current tokens (a leading space marks the word start, like real tokenizers).
  final List<List<String>> words;
  final List<String> merges = [];

  int get tokenCount => words.fold(0, (n, w) => n + w.length);

  Set<String> get vocabulary => {for (final w in words) ...w};

  /// Adjacent pairs and how often they occur, most frequent first.
  List<MapEntry<(String, String), int>> pairCounts() {
    final m = <(String, String), int>{};
    for (final w in words) {
      for (var i = 0; i + 1 < w.length; i++) {
        final p = (w[i], w[i + 1]);
        m[p] = (m[p] ?? 0) + 1;
      }
    }
    final list = m.entries.toList()
      ..sort((a, b) => b.value != a.value ? b.value.compareTo(a.value) : '${a.key.$1}${a.key.$2}'.compareTo('${b.key.$1}${b.key.$2}'));
    return list;
  }

  /// Merge every occurrence of [pair] into one token.
  void merge((String, String) pair) {
    for (final w in words) {
      for (var i = 0; i + 1 < w.length; i++) {
        if (w[i] == pair.$1 && w[i + 1] == pair.$2) {
          w[i] = pair.$1 + pair.$2;
          w.removeAt(i + 1);
        }
      }
    }
    merges.add(pair.$1 + pair.$2);
  }
}
