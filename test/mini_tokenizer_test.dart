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
}
