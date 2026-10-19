import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s3/s3_embeddings.dart';

import '../helpers.dart';

void main() {
  test('king − man + woman lands on queen', () {
    final p = wordMap['king']! - wordMap['man']! + wordMap['woman']!;
    expect(nearest(p).first.key, 'queen');
  });

  test('Paris − France + Italy lands on Rome', () {
    final p = wordMap['Paris']! - wordMap['France']! + wordMap['Italy']!;
    expect(nearest(p).first.key, 'Rome');
  });

  testWidgets('s3_embeddings: the arithmetic button reports queen', (tester) async {
    await pumpApp(tester, home: const S3EmbeddingsScreen());
    await tapVisible(tester, find.byKey(const ValueKey('emb-math')));
    await pumpFrames(tester, 4);
    await scrollTo(tester, find.byKey(const ValueKey('emb-status')));
    expect(find.textContaining('"queen"'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s3_embeddings: the geography button reports Rome', (tester) async {
    await pumpApp(tester, home: const S3EmbeddingsScreen());
    await tapVisible(tester, find.byKey(const ValueKey('emb-math2')));
    await pumpFrames(tester, 4);
    await scrollTo(tester, find.byKey(const ValueKey('emb-status')));
    expect(find.textContaining('"Rome"'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s3_embeddings: the second analogy replaces the first in the status line', (tester) async {
    await pumpApp(tester, home: const S3EmbeddingsScreen());
    await tapVisible(tester, find.byKey(const ValueKey('emb-math')));
    await pumpFrames(tester, 4);
    await tapVisible(tester, find.byKey(const ValueKey('emb-math2')));
    await pumpFrames(tester, 4);
    await scrollTo(tester, find.byKey(const ValueKey('emb-status')));
    expect(find.textContaining('"Rome"'), findsOneWidget);
    expect(find.textContaining('"queen"'), findsNothing);
    expectNoErrors(tester);
  });

  testWidgets('s3_embeddings: tapping the map leaves the analogy', (tester) async {
    await pumpApp(tester, home: const S3EmbeddingsScreen());
    await tapVisible(tester, find.byKey(const ValueKey('emb-math2')));
    await pumpFrames(tester, 4);
    await scrollTo(tester, find.byKey(const ValueKey('emb-map')));
    // Tap the bottom-right corner (the tech cluster), far from the geography words.
    final box = tester.getRect(find.byKey(const ValueKey('emb-map')));
    await tester.tapAt(Offset(box.right - 8, box.bottom - 8));
    await tester.pump();
    expect(find.textContaining('"Rome"'), findsNothing);
    expect(find.textContaining('is closest to'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s3_embeddings: both analogies run at 360 dp, text scale 1.3, light', (tester) async {
    await pumpApp(
      tester,
      home: const S3EmbeddingsScreen(),
      size: const Size(360, 780),
      textScale: 1.3,
      brightness: Brightness.light,
    );
    await tapVisible(tester, find.byKey(const ValueKey('emb-math')));
    await pumpFrames(tester, 4);
    await scrollTo(tester, find.byKey(const ValueKey('emb-status')));
    expect(find.textContaining('"queen"'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('emb-math2')));
    await pumpFrames(tester, 4);
    await scrollTo(tester, find.byKey(const ValueKey('emb-status')));
    expect(find.textContaining('"Rome"'), findsOneWidget);
    expectNoErrors(tester);
  });
}
