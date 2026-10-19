import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s2/s2_testing.dart';

import '../helpers.dart';

void main() {
  testWidgets('s2_testing renders and the slider changes the shown score', (tester) async {
    await pumpApp(tester, home: const S2TestingScreen());
    expect(find.text('Benchmark exams along the way'), findsOneWidget);
    // The live score at 0% progress.
    expect(find.text('0 / 100'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('training-progress-slider')));
    await tester.drag(find.byKey(const ValueKey('training-progress-slider')), const Offset(200, 0));
    await tester.pump();
    // The score must now be strictly greater than 0.
    expect(find.text('0 / 100'), findsNothing);
    expectNoErrors(tester);
  });

  testWidgets('s2_testing has no overflow at large text and in light mode', (tester) async {
    await pumpApp(tester, home: const S2TestingScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
