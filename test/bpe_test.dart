import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/core/bpe.dart';
import 'package:machine_mind/screens/s2/s2_tokens.dart';

void main() {
  test('merging the top pair always reduces the token count, until words are whole', () {
    final b = BpeState(bpeCorpus);
    var count = b.tokenCount;
    while (b.pairCounts().isNotEmpty) {
      b.merge(b.pairCounts().first.key);
      expect(b.tokenCount, lessThan(count));
      count = b.tokenCount;
    }
    expect(b.tokenCount, bpeCorpus.split(' ').length);
    expect(b.vocabulary, contains(' blue'));
  });
}
