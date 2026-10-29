import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s11/e_thinking.dart';

import '../helpers.dart';

void main() {
  testWidgets('e_thinking: every pick is explained and the score adds up', (tester) async {
    await pumpApp(tester, home: const EThinkingScreen());
    const best = [false, true, false, true, false, true, false, true];
    for (var i = 0; i < best.length; i++) {
      final pick = i == 0 ? true : best[i];
      await scrollTo(tester, find.byKey(ValueKey('think-$i-$pick')));
      await tapVisible(tester, find.byKey(ValueKey('think-$i-$pick')));
      await tester.pump();
      expect(find.byKey(ValueKey('think-why-$i')), findsOneWidget);
    }
    expect(find.textContaining('Good calls: 7 of 8'), findsOneWidget);
    expect(find.textContaining('it\'s 5 cents'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('e_thinking has no overflow on a small phone at large text in light mode', (tester) async {
    await pumpApp(
      tester,
      home: const EThinkingScreen(),
      size: const Size(360, 740),
      textScale: 1.3,
      brightness: Brightness.light,
    );
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
