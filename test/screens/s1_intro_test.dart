import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s1/s1_intro.dart';

import '../helpers.dart';

void main() {
  testWidgets('s1_intro renders and tapping a part previews its lesson', (tester) async {
    await pumpApp(tester, home: const S1IntroScreen());
    expect(find.text('Where does a thought live?'), findsOneWidget);
    expect(find.textContaining('Which of these holds a thought?'), findsOneWidget);

    // Tap the RAM part directly on the cut-away.
    await tapVisible(tester, find.byKey(const ValueKey('intro-hit-ram')));
    expect(find.text('Everyday word: your desk'), findsOneWidget);
    expect(find.text('89.6 GB/s'), findsOneWidget);
    expect(find.textContaining('Which of these holds a thought?'), findsNothing);

    // Tap the GPU chip: the preview swaps to the GPU's lesson.
    await tapVisible(tester, find.byKey(const ValueKey('intro-part-gpu')));
    expect(find.textContaining('Everyday word: an army of line cooks'), findsOneWidget);
    expect(find.text('16,896'), findsOneWidget);
    expect(find.text('Everyday word: your desk'), findsNothing);
    expectNoErrors(tester);
  });

  testWidgets('s1_intro tour button toggles between Tour and Pause', (tester) async {
    await pumpApp(tester, home: const S1IntroScreen());
    expect(find.text('Tour'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('intro-tour')));
    expect(find.text('Pause'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('intro-tour')));
    expect(find.text('Tour'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s1_intro has no overflow at large text and in light mode', (tester) async {
    await pumpApp(tester, home: const S1IntroScreen(), textScale: 1.3, brightness: Brightness.light);
    await tapVisible(tester, find.byKey(const ValueKey('intro-part-network')));
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
