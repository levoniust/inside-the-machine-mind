import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s2/s2_post_training.dart';

import '../helpers.dart';

void main() {
  testWidgets('s2_post_training renders and rating changes the output', (tester) async {
    await pumpApp(tester, home: const S2PostTrainingScreen());
    expect(find.text('Play the rater: pick the better answer'), findsOneWidget);
    expect(find.text('Stage: SFT (examples)'), findsOneWidget);
    // The first question is "Which city is closer to London: Manchester or Edinburgh?".
    // Its good answer is "Manchester is in England, so it is closer to London than Edinburgh."
    await scrollTo(tester, find.text('Manchester is in England, so it is closer to London than Edinburgh.'));
    await tester.tap(find.text('Manchester is in England, so it is closer to London than Edinburgh.'));
    await tester.pump();
    // Tapping the text doesn't rate; tap the thumb-up button next to it.
    await tester.tap(find.byTooltip('This is the better answer'));
    await tester.pump();
    expect(find.text('You rated 1 answer(s) correctly.'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s2_post_training advances stage via the Next stage button', (tester) async {
    await pumpApp(tester, home: const S2PostTrainingScreen());
    await tapVisible(tester, find.byKey(const ValueKey('stage-next')));
    await tester.pump();
    expect(find.text('Stage: RLHF (thumbs up/down)'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s2_post_training has no overflow at large text and in light mode', (tester) async {
    await pumpApp(tester, home: const S2PostTrainingScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
