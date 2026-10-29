import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s5/e_access.dart';

import '../helpers.dart';

void main() {
  testWidgets('e_access: each person shows their story', (tester) async {
    await pumpApp(tester, home: const EAccessScreen());
    await scrollTo(tester, find.byKey(const ValueKey('acc-person-2')));
    await tapVisible(tester, find.byKey(const ValueKey('acc-person-2')));
    await tester.pump();
    expect(find.byKey(const ValueKey('acc-name-2')), findsOneWidget);
    expect(find.textContaining('happy tears'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('e_access: a day with the tools scores every moment', (tester) async {
    await pumpApp(tester, home: const EAccessScreen());
    const best = ['describe', 'captions', 'voice', 'describe', 'bank', 'captions'];
    for (var i = 0; i < best.length; i++) {
      final pick = i == 4 ? 'voice' : best[i];
      await scrollTo(tester, find.byKey(ValueKey('acc-$i-$pick')));
      await tapVisible(tester, find.byKey(ValueKey('acc-$i-$pick')));
      await tester.pump();
      expect(find.byKey(ValueKey('acc-why-$i')), findsOneWidget);
    }
    expect(find.textContaining('Right tool: 5 of 6'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('e_access has no overflow on a small phone at large text in light mode', (tester) async {
    await pumpApp(
      tester,
      home: const EAccessScreen(),
      size: const Size(360, 740),
      textScale: 1.3,
      brightness: Brightness.light,
    );
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
