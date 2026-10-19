import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s3/s3_embeddings.dart';

import '../helpers.dart';

void main() {
  test('king − man + woman lands on queen', () {
    final p = wordMap['king']! - wordMap['man']! + wordMap['woman']!;
    expect(nearest(p).first.key, 'queen');
  });

  testWidgets('s3_embeddings: the arithmetic button reports queen', (tester) async {
    await pumpApp(tester, home: const S3EmbeddingsScreen());
    await tapVisible(tester, find.byKey(const ValueKey('emb-math')));
    await pumpFrames(tester, 4);
    await scrollTo(tester, find.byKey(const ValueKey('emb-status')));
    expect(find.textContaining('"queen"'), findsOneWidget);
    expectNoErrors(tester);
  });
}
