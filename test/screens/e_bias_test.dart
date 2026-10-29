import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s5/e_bias.dart';

import '../helpers.dart';

void main() {
  testWidgets('e_bias: picking the slanted answers explains each and scores', (tester) async {
    await pumpApp(tester, home: const EBiasScreen());
    // Slanted: B, A, B, B, A. Miss pair 0 by picking A.
    const picks = ['a', 'a', 'b', 'b', 'a'];
    for (var i = 0; i < picks.length; i++) {
      await scrollTo(tester, find.byKey(ValueKey('bias-$i-${picks[i]}')));
      await tapVisible(tester, find.byKey(ValueKey('bias-$i-${picks[i]}')));
      await tester.pump();
      expect(find.byKey(ValueKey('bias-why-$i')), findsOneWidget);
    }
    expect(find.textContaining('Missed it'), findsOneWidget);
    expect(find.textContaining('Spotted 4 of 5'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('e_bias has no overflow on a small phone at large text in light mode', (tester) async {
    await pumpApp(
      tester,
      home: const EBiasScreen(),
      size: const Size(360, 740),
      textScale: 1.3,
      brightness: Brightness.light,
    );
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
