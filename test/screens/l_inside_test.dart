import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s7/l_inside.dart';

import '../helpers.dart';

void main() {
  testWidgets('l_inside: untangling the neuron shows features', (tester) async {
    await pumpApp(tester, home: const LInsideScreen());
    await scrollTo(tester, find.byKey(const ValueKey('ins-split')));
    expect(find.byKey(const ValueKey('ins-neuron')), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('ins-split')));
    await pumpFrames(tester);
    expect(find.byKey(const ValueKey('ins-features')), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('l_inside: guessing and revealing scores the sentences', (tester) async {
    await pumpApp(tester, home: const LInsideScreen());
    for (final i in [0, 2, 1]) {
      await scrollTo(tester, find.byKey(ValueKey('ins-sent-$i')));
      await tapVisible(tester, find.byKey(ValueKey('ins-sent-$i')));
      await tester.pump();
    }
    await scrollTo(tester, find.byKey(const ValueKey('ins-reveal')));
    await tapVisible(tester, find.byKey(const ValueKey('ins-reveal')));
    await tester.pump();
    // Fire: 0, 2, 3, 5. Guessed 0, 2, 1 → right on 0, 2, 4; wrong on 1, 3, 5.
    expect(find.text('3 of 6 right.'), findsOneWidget);
    expect(find.byKey(const ValueKey('ins-bar-3')), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('l_inside: the dial at 10× shows Golden Gate Claude', (tester) async {
    await pumpApp(tester, home: const LInsideScreen());
    await scrollTo(tester, find.byKey(const ValueKey('ins-dial')));
    final s = tester.widget<Slider>(
      find.descendant(of: find.byKey(const ValueKey('ins-dial')), matching: find.byType(Slider)),
    );
    s.onChanged!(10);
    await tester.pump();
    expect(find.byKey(const ValueKey('ins-reply-true')), findsOneWidget);
    expect(find.textContaining('paying the toll'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('l_inside has no overflow on a small phone at large text in light mode', (tester) async {
    await pumpApp(
      tester,
      home: const LInsideScreen(),
      size: const Size(360, 740),
      textScale: 1.3,
      brightness: Brightness.light,
    );
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
