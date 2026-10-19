import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/core/mini_tokenizer.dart';

void main() {
  final t = MiniTokenizer();
  test('common words are single tokens with their leading space', () {
    expect(t.encode('Why is the sky blue?').map((e) => e.$1).toList(), ['Why', ' is', ' the', ' sky', ' blue', '?']);
  });
  test('rare words split into pieces', () {
    expect(t.encode('unbelievably').map((e) => e.$1).toList(), ['un', 'believ', 'ably']);
  });
  test('every character is covered (unknown symbols become ? tokens)', () {
    final toks = t.encode('tea 🍵');
    expect(toks.map((e) => e.$1).join(), 'tea 🍵');
    expect(toks.last.$2, -1);
  });
  test('emoji stay whole: no piece holds half a surrogate pair', () {
    final toks = t.encode('The cat had tea 🍵🤖');
    expect(toks.map((e) => e.$1).where((p) => p.runes.length == 1 && p.runes.first > 0xFFFF), hasLength(2));
    for (final (p, _) in toks) {
      expect(p.runes.any((r) => r >= 0xD800 && r <= 0xDFFF), isFalse, reason: 'lone surrogate in "$p"');
    }
  });
}
