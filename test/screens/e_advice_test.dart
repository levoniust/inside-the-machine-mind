import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s5/e_advice.dart';

import '../helpers.dart';

void main() {
  testWidgets('e_advice: sorting all eight cases explains each and scores', (tester) async {
    await pumpApp(tester, home: const EAdviceScreen());
    const best = ['ai', 'person', 'ai', 'prepare', 'prepare', 'person', 'ai', 'person'];
    for (var i = 0; i < best.length; i++) {
      final pick = i == 1 ? 'ai' : best[i];
      await scrollTo(tester, find.byKey(ValueKey('adv-$i-$pick')));
      await tapVisible(tester, find.byKey(ValueKey('adv-$i-$pick')));
      await tester.pump();
      expect(find.byKey(ValueKey('adv-why-$i')), findsOneWidget);
    }
    expect(find.textContaining('call emergency services'), findsOneWidget);
    expect(find.textContaining('Good calls: 7 of 8'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('e_advice has no overflow on a small phone at large text in light mode', (tester) async {
    await pumpApp(
      tester,
      home: const EAdviceScreen(),
      size: const Size(360, 740),
      textScale: 1.3,
      brightness: Brightness.light,
    );
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
