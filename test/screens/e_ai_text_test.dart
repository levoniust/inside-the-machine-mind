import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s5/e_ai_text.dart';

import '../helpers.dart';

void main() {
  testWidgets('e_ai_text: guessing all six reveals detector scores and the truth', (tester) async {
    await pumpApp(tester, home: const EAiTextScreen());
    // Truth: human, human, AI, AI, human, AI. Guess text 3 wrong.
    const guess = ['human', 'human', 'ai', 'human', 'human', 'ai'];
    for (var i = 0; i < guess.length; i++) {
      await scrollTo(tester, find.byKey(ValueKey('det-$i-${guess[i]}')));
      await tapVisible(tester, find.byKey(ValueKey('det-$i-${guess[i]}')));
      await tester.pump();
      expect(find.byKey(ValueKey('det-reveal-$i')), findsOneWidget);
    }
    expect(find.text('88% AI'), findsOneWidget);
    expect(find.textContaining('You: 5 of 6. The detector: 2 of 6'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('e_ai_text has no overflow on a small phone at large text in light mode', (tester) async {
    await pumpApp(
      tester,
      home: const EAiTextScreen(),
      size: const Size(360, 740),
      textScale: 1.3,
      brightness: Brightness.light,
    );
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
