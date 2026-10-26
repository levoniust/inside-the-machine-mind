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

  testWidgets('s2_safety: be the tester scores the five cards', (tester) async {
    await pumpApp(tester, home: const S2SafetyScreen());
    expect(find.text('Test 1 of 5: what is wrong with the draft answer?'), findsOneWidget);
    // Answers: made-up, unfair, dangerous, fine, made-up. Get the 2nd one wrong on purpose.
    const picks = ['madeUp', 'fine', 'dangerous', 'fine', 'madeUp'];
    for (var i = 0; i < picks.length; i++) {
      await tapVisible(tester, find.byKey(ValueKey('tester-${picks[i]}')));
      await tester.pump();
      expect(find.byKey(const ValueKey('tester-verdict')), findsOneWidget);
      if (i == 1) expect(find.textContaining('Not quite'), findsOneWidget);
      await tapVisible(tester, find.byKey(const ValueKey('tester-next')));
      await tester.pump();
    }
    expect(find.text('You caught 4 of 5.'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('tester-restart')));
    await tester.pump();
    expect(find.text('Test 1 of 5: what is wrong with the draft answer?'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s2_safety has no overflow at large text and in light mode', (tester) async {
    await pumpApp(tester, home: const S2SafetyScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
