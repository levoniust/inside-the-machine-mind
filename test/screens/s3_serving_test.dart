import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s3/s3_serving.dart';

import '../helpers.dart';

void main() {
  test('batching divides the weight reads', () {
    expect(weightReads(64, 1), 64);
    expect(weightReads(64, 32), 2);
  });

  testWidgets('s3_serving: a bigger batch means fewer model reads', (tester) async {
    await pumpApp(tester, home: const S3ServingScreen());
    await scrollTo(tester, find.byKey(const ValueKey('serve-reads')));
    expect(find.descendant(of: find.byKey(const ValueKey('serve-reads')), matching: find.text('64')), findsOneWidget);
    await tester.drag(find.descendant(of: find.byKey(const ValueKey('serve-batch')), matching: find.byType(Slider)), const Offset(500, 0));
    await pumpFrames(tester, 3);
    expect(find.descendant(of: find.byKey(const ValueKey('serve-reads')), matching: find.text('1')), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s3_serving: the caption under the road follows the batch size', (tester) async {
    await pumpApp(tester, home: const S3ServingScreen());
    await scrollTo(tester, find.byKey(const ValueKey('serve-caption')));
    expect(find.text('64 solo cars — the model is read 64 times'), findsOneWidget);
    await tester.drag(find.descendant(of: find.byKey(const ValueKey('serve-batch')), matching: find.byType(Slider)), const Offset(500, 0));
    await pumpFrames(tester, 3);
    expect(find.text('One bus for everyone — the model is read once'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s3_serving: the road and caption fit a 360 dp phone', (tester) async {
    await pumpApp(tester, home: const S3ServingScreen(), size: const Size(360, 740), brightness: Brightness.light);
    final handle = tester.ensureSemantics();
    await scrollTo(tester, find.byKey(const ValueKey('serve-batch')));
    expect(find.text('Carpooling for computers'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('road to a GPU building', caseSensitive: false)), findsOneWidget);
    expect(find.text('64 solo cars — the model is read 64 times'), findsOneWidget);
    handle.dispose();
    // Grab the track away from the thumb so the batch stops mid-range (neither solo cars nor one full bus).
    await tester.drag(find.descendant(of: find.byKey(const ValueKey('serve-batch')), matching: find.byType(Slider)), const Offset(40, 0));
    await pumpFrames(tester, 3);
    expect(find.textContaining('carry up to'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s3_serving: no errors at text scale 1.3 in light mode', (tester) async {
    await pumpApp(tester, home: const S3ServingScreen(), textScale: 1.3, brightness: Brightness.light);
    await scrollTo(tester, find.byKey(const ValueKey('serve-caption')));
    await tester.drag(find.descendant(of: find.byKey(const ValueKey('serve-batch')), matching: find.byType(Slider)), const Offset(500, 0));
    await pumpFrames(tester, 3);
    expect(find.text('One bus for everyone — the model is read once'), findsOneWidget);
    expectNoErrors(tester);
  });
}
