import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s5/e_good_bad.dart';

import '../helpers.dart';

Future<void> _tapVisible(WidgetTester t, Finder f) async {
  await t.scrollUntilVisible(f, 300);
  await t.ensureVisible(f);
  await t.pumpAndSettle();
  await t.tap(f);
  await t.pump();
}

void main() {
  testWidgets('a card flips open with its example', (tester) async {
    await pumpApp(tester, home: const EGoodBadScreen());
    await _tapVisible(tester, find.byKey(const ValueKey('gb-card-4')));
    expect(find.textContaining('small town get its library'), findsOneWidget);
  });

  testWidgets('three rounds: catching every fake scores 3 of 3', (tester) async {
    await pumpApp(tester, home: const EGoodBadScreen());
    for (final fake in [1, 2, 1]) {
      await _tapVisible(tester, find.byKey(ValueKey('gb-line-$fake')));
      expect(find.text('You caught it!'), findsOneWidget);
      await _tapVisible(tester, find.byKey(const ValueKey('gb-next')));
    }
    await tester.scrollUntilVisible(find.byKey(const ValueKey('gb-score')), 300);
    expect(find.text('You found 3 of 3'), findsOneWidget);
  });

  testWidgets('no overflow at large text in light mode', (tester) async {
    await pumpApp(tester, home: const EGoodBadScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
