import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s7/l_notes_helper.dart';

import '../helpers.dart';

void main() {
  testWidgets('l_notes_helper: tapping a pipeline step shows what it does', (tester) async {
    await pumpApp(tester, home: const LNotesHelperScreen());
    await scrollTo(tester, find.byKey(const ValueKey('nh-step-4')));
    await tapVisible(tester, find.byKey(const ValueKey('nh-step-4')));
    await tester.pump();
    expect(find.byKey(const ValueKey('nh-what-4')), findsOneWidget);
    expect(find.textContaining('best 6 of the 10'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('l_notes_helper: a wrong pick explains why; the real fix shows the measurement and moves on', (
    tester,
  ) async {
    await pumpApp(tester, home: const LNotesHelperScreen());
    await scrollTo(tester, find.byKey(const ValueKey('nh-opt-0-0')));
    await tapVisible(tester, find.byKey(const ValueKey('nh-opt-0-0')));
    await tester.pump();
    expect(find.textContaining('Try another'), findsOneWidget);
    for (final (round, real) in [(0, 1), (1, 2), (2, 0)]) {
      await scrollTo(tester, find.byKey(ValueKey('nh-opt-$round-$real')));
      await tapVisible(tester, find.byKey(ValueKey('nh-opt-$round-$real')));
      await tester.pump();
      expect(find.textContaining('Measured:'), findsOneWidget);
      if (round < 2) {
        await tapVisible(tester, find.byKey(const ValueKey('nh-next')));
        await tester.pump();
      }
    }
    expect(find.textContaining('Median 65 s → 20 s'), findsOneWidget);
    expect(find.textContaining('first time: 2 of 3'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('l_notes_helper has no overflow on a small phone at large text in light mode', (tester) async {
    await pumpApp(
      tester,
      home: const LNotesHelperScreen(),
      size: const Size(360, 740),
      textScale: 1.3,
      brightness: Brightness.light,
    );
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
