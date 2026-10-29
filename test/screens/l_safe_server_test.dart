import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s6/l_safe_server.dart';

import '../helpers.dart';

void main() {
  testWidgets('l_safe_server: judging every spot scores holes and wrong calls', (tester) async {
    await pumpApp(tester, home: const LSafeServerScreen());
    // Risky spots: 0, 1, 3, 5, 6, 8. Call spot 2 (fine) risky by mistake.
    const risky = {0, 1, 3, 5, 6, 8};
    for (var i = 0; i < 9; i++) {
      await scrollTo(tester, find.byKey(ValueKey('safe-spot-$i')));
      await tapVisible(tester, find.byKey(ValueKey('safe-spot-$i')));
      await tester.pump();
      expect(find.byKey(ValueKey('safe-what-$i')), findsOneWidget);
      final sayRisky = risky.contains(i) || i == 2;
      await tapVisible(tester, find.byKey(ValueKey(sayRisky ? 'safe-risky' : 'safe-fine')));
      await tester.pump();
      expect(find.byKey(const ValueKey('safe-verdict')), findsOneWidget);
      if (i == 2) expect(find.textContaining('Not quite'), findsOneWidget);
    }
    expect(find.text('Holes found: 6 of 6 · wrong calls: 1'), findsOneWidget);
    expect(find.textContaining('Check the amber ones'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('l_safe_server has no overflow on a small phone at large text in light mode', (tester) async {
    await pumpApp(
      tester,
      home: const LSafeServerScreen(),
      size: const Size(360, 740),
      textScale: 1.3,
      brightness: Brightness.light,
    );
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
