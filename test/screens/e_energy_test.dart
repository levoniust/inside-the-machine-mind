import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s11/e_energy.dart';

import '../helpers.dart';

void main() {
  testWidgets('e_energy: a wrong tap is explained; the right order completes the line-up', (tester) async {
    await pumpApp(tester, home: const EEnergyScreen());
    // Cards: 0 home year, 1 ChatGPT, 2 US all, 3 TV, 4 GPT-3, 5 Gemini, 6 data centres, 7 home day, 8 US electricity.
    await scrollTo(tester, find.byKey(const ValueKey('nrg-card-2')));
    await tapVisible(tester, find.byKey(const ValueKey('nrg-card-2')));
    await tester.pump();
    expect(find.byKey(const ValueKey('nrg-note')), findsOneWidget);
    for (final i in [5, 1, 3, 7, 0, 4, 6, 8, 2]) {
      await scrollTo(tester, find.byKey(ValueKey('nrg-card-$i')));
      await tapVisible(tester, find.byKey(ValueKey('nrg-card-$i')));
      await tester.pump();
    }
    expect(find.textContaining('with 1 wrong tap.'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('e_energy: zooming out climbs to the whole USA in TWh', (tester) async {
    await pumpApp(tester, home: const EEnergyScreen());
    for (var i = 0; i < 4; i++) {
      await scrollTo(tester, find.byKey(const ValueKey('nrg-zoom-out')));
      await tapVisible(tester, find.byKey(const ValueKey('nrg-zoom-out')));
      await pumpFrames(tester);
    }
    expect(find.byKey(const ValueKey('nrg-meaning-4')), findsOneWidget);
    expect(find.text('176 TWh'), findsWidgets);
    expect(find.text('27,600 TWh'), findsOneWidget);
    expect(find.text('4,200 TWh'), findsWidgets);
    expectNoErrors(tester);
  });

  testWidgets('e_energy has no overflow on a small phone at large text in light mode', (tester) async {
    await pumpApp(
      tester,
      home: const EEnergyScreen(),
      size: const Size(360, 740),
      textScale: 1.3,
      brightness: Brightness.light,
    );
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
