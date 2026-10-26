import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s10/l_jobs.dart';
import 'package:machine_mind/screens/s10/l_keep_up.dart';
import 'package:machine_mind/screens/s10/l_who_makes.dart';

import '../helpers.dart';

Future<void> _tap(WidgetTester t, Finder f) async {
  if (f.evaluate().isEmpty) await t.scrollUntilVisible(f, 300, scrollable: find.byType(Scrollable).first);
  await t.ensureVisible(f);
  await t.pumpAndSettle();
  await t.tap(f);
  await t.pump();
}

void main() {
  testWidgets('who makes what: tapping the bottom layer explains foundries', (tester) async {
    await pumpApp(tester, home: const LWhoMakesScreen());
    await _tap(tester, find.byKey(const ValueKey('layer-5')));
    expect(tester.widget<Text>(find.byKey(const ValueKey('layer-desc'))).data, startsWith('Designing a chip'));
  });

  testWidgets('jobs: "I come from hardware" narrows the list', (tester) async {
    await pumpApp(tester, home: const LJobsScreen());
    expect(tester.widget<Text>(find.byKey(const ValueKey('jobs-count'))).data, '9 roles');
    await _tap(tester, find.byKey(const ValueKey('jobs-hardware')));
    expect(tester.widget<Text>(find.byKey(const ValueKey('jobs-count'))).data, '2 roles');
  });

  testWidgets('keep up: ticking a habit counts it', (tester) async {
    await pumpApp(tester, home: const LKeepUpScreen());
    await _tap(tester, find.byKey(const ValueKey('keep-0')));
    expect(tester.widget<Text>(find.byKey(const ValueKey('keep-count'))).data, '1 of 6 habits ticked');
  });

  for (final (name, screen) in [('who', const LWhoMakesScreen()), ('jobs', const LJobsScreen()), ('keep', const LKeepUpScreen())]) {
    testWidgets('$name: no overflow at large text in light mode', (tester) async {
      await pumpApp(tester, home: screen, textScale: 1.3, brightness: Brightness.light);
      await pumpFrames(tester);
      expectNoErrors(tester);
    });
  }
}
