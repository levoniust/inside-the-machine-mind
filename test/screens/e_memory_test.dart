import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s11/e_memory.dart';

import '../helpers.dart';

void main() {
  testWidgets('e_memory: sending all messages slides the window; guessing is checked', (tester) async {
    await pumpApp(tester, home: const EMemoryScreen());
    for (var i = 0; i < 6; i++) {
      await scrollTo(tester, find.byKey(const ValueKey('mem-send')));
      await tapVisible(tester, find.byKey(const ValueKey('mem-send')));
      await tester.pump();
    }
    expect(find.text('off the notepad'), findsNWidgets(5));
    // Guess the garden party (5) and the allergy (2).
    for (final i in [5, 2]) {
      await scrollTo(tester, find.byKey(ValueKey('mem-fact-$i')));
      await tapVisible(tester, find.byKey(ValueKey('mem-fact-$i')));
      await tester.pump();
    }
    await tapVisible(tester, find.byKey(const ValueKey('mem-reveal')));
    await tester.pump();
    // Facts: name, date, allergy, budget (off) + garden party, rain (on). Right: name, date, budget, garden = 4 of 6.
    expect(find.textContaining('4 of 6 right'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('e_memory: turning memory off changes the new chat', (tester) async {
    await pumpApp(tester, home: const EMemoryScreen());
    await scrollTo(tester, find.byKey(const ValueKey('mem-switch')));
    expect(find.byKey(const ValueKey('mem-new-true')), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('mem-switch')));
    await tester.pump();
    expect(find.byKey(const ValueKey('mem-new-false')), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('e_memory has no overflow on a small phone at large text in light mode', (tester) async {
    await pumpApp(
      tester,
      home: const EMemoryScreen(),
      size: const Size(360, 740),
      textScale: 1.3,
      brightness: Brightness.light,
    );
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
