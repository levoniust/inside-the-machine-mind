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
}
