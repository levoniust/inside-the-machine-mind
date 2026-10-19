import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s2/s2_safety.dart';

import '../helpers.dart';

void main() {
  testWidgets('s2_safety renders and picking the risky request reveals the careful answer', (tester) async {
    await pumpApp(tester, home: const S2SafetyScreen());
    expect(find.text('Spot the problem with a risky request'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('pick-risky')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('prompt injection', findRichText: true), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s2_safety has no overflow at large text and in light mode', (tester) async {
    await pumpApp(tester, home: const S2SafetyScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
