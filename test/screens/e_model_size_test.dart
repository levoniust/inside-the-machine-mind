import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s5/e_model_size.dart';

import '../helpers.dart';

void main() {
  testWidgets('e_model_size: picking a maker shows its line-up, biggest first', (tester) async {
    await pumpApp(tester, home: const EModelSizeScreen());
    await scrollTo(tester, find.byKey(const ValueKey('size-tier-GPT-6 Astra')));
    expect(find.byKey(const ValueKey('size-tier-GPT-6 Luna')), findsOneWidget);
    expect(find.text('\$10 in / \$50 out per million tokens'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('size-maker-1')));
    await tester.pump();
    expect(find.byKey(const ValueKey('size-tier-Claude Fable 5.1')), findsOneWidget);
    expect(find.byKey(const ValueKey('size-tier-Claude Haiku 5.5')), findsOneWidget);
    expect(find.byKey(const ValueKey('size-tier-GPT-6 Astra')), findsNothing);
    await tapVisible(tester, find.byKey(const ValueKey('size-maker-3')));
    await tester.pump();
    expect(find.text('One size'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('e_model_size: matching jobs explains each pick and scores at the end', (tester) async {
    await pumpApp(tester, home: const EModelSizeScreen());
    const picks = ['small', 'big', 'middle', 'middle', 'big'];
    for (var i = 0; i < picks.length; i++) {
      await tapVisible(tester, find.byKey(ValueKey('size-job-$i-${picks[i]}')));
      await tester.pump();
      expect(find.byKey(ValueKey('size-why-$i')), findsOneWidget);
    }
    expect(find.textContaining('Hmm: best is "Small & fast"'), findsOneWidget);
    expect(find.textContaining('Sensible picks: 4 of 5'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('e_model_size has no overflow on a small phone at large text in light mode', (tester) async {
    await pumpApp(tester, home: const EModelSizeScreen(), size: const Size(360, 740), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
