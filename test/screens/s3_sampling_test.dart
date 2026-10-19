import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/core/toy_transformer.dart';
import 'package:machine_mind/screens/s3/s3_sampling.dart';

import '../helpers.dart';

void main() {
  final logits = ToyTransformer().run().logits;

  test('top-p keeps only the likeliest words and renormalizes', () {
    final all = shapedProbabilities(logits, 1, 1);
    expect(all.fold<double>(0, (s, e) => s + e.value), closeTo(1, 1e-9));
    final narrow = shapedProbabilities(logits, 1, 0.3);
    expect(narrow.where((e) => e.value > 0).length, lessThan(all.where((e) => e.value > 0).length));
    expect(narrow.fold<double>(0, (s, e) => s + e.value), closeTo(1, 1e-9));
  });

  test('cold temperature makes "blue" dominant', () {
    expect(shapedProbabilities(logits, 0.1, 1).first.value, greaterThan(0.95));
  });

  testWidgets('s3_sampling: rolling 100 times shows a tally', (tester) async {
    await pumpApp(tester, home: const S3SamplingScreen());
    await tapVisible(tester, find.byKey(const ValueKey('sampling-roll100')));
    await pumpFrames(tester, 4);
    await scrollTo(tester, find.byKey(const ValueKey('sampling-tally')));
    expect(find.text('Tally after 100 rolls:'), findsOneWidget);
    expectNoErrors(tester);
  });
}
