import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s11/e_agents.dart';

import '../helpers.dart';

void main() {
  testWidgets('e_agents: tapping a loop step shows what happens there', (tester) async {
    await pumpApp(tester, home: const EAgentsScreen());
    await scrollTo(tester, find.byKey(const ValueKey('agent-step-2')));
    await tapVisible(tester, find.byKey(const ValueKey('agent-step-2')));
    await tester.pump();
    expect(find.byKey(const ValueKey('agent-step-text-2')), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('e_agents: ten calls give feedback each time and a score', (tester) async {
    await pumpApp(tester, home: const EAgentsScreen());
    // Sensible: allow 0, 1, 3, 8; stop the rest. Allow #2 (the injection) by mistake.
    const allow = {0, 1, 2, 3, 8};
    for (var i = 0; i < 10; i++) {
      await scrollTo(tester, find.byKey(ValueKey('agent-ask-$i')));
      await tapVisible(tester, find.byKey(ValueKey(allow.contains(i) ? 'agent-allow' : 'agent-stop')));
      await tester.pump();
      expect(find.byKey(ValueKey('agent-result-$i')), findsOneWidget);
      if (i == 2) expect(find.textContaining('prompt injection'), findsWidgets);
    }
    expect(find.text('Sensible calls: 9 of 10.'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('e_agents has no overflow on a small phone at large text in light mode', (tester) async {
    await pumpApp(
      tester,
      home: const EAgentsScreen(),
      size: const Size(360, 740),
      textScale: 1.3,
      brightness: Brightness.light,
    );
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
