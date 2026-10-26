import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s9/l_leaderboards.dart';
import 'package:machine_mind/screens/s9/l_sota_hardware.dart';
import 'package:machine_mind/screens/s9/l_sota_models.dart';
import 'package:machine_mind/screens/s9/l_sota_techniques.dart';
import 'package:machine_mind/screens/s9/l_this_year.dart';

import '../helpers.dart';

Future<void> _tap(WidgetTester t, Finder f) async {
  await t.ensureVisible(f);
  await t.pumpAndSettle();
  await t.tap(f);
  await t.pump();
}

void main() {
  testWidgets('models: the open-weights filter hides closed models; a card opens', (tester) async {
    await pumpApp(tester, home: const LSotaModelsScreen());
    expect(find.text('Claude Opus 5.5'), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('sota-filter-open')));
    expect(find.text('Claude Opus 5.5'), findsNothing);
    expect(find.text('Kimi K3'), findsOneWidget);
    await _tap(tester, find.text('Kimi K3'));
    expect(find.textContaining('896 experts'), findsOneWidget);
  });

  testWidgets('hardware: switching to memory changes the note', (tester) async {
    await pumpApp(tester, home: const LSotaHardwareScreen());
    await _tap(tester, find.text('Memory'));
    expect(tester.widget<Text>(find.byKey(const ValueKey('hw-note'))).data, startsWith('Memory decides'));
  });

  testWidgets('techniques: a card flips open', (tester) async {
    await pumpApp(tester, home: const LSotaTechniquesScreen());
    await _tap(tester, find.byKey(const ValueKey('trick-1')));
    expect(find.textContaining('Nearly every large open-weight model'), findsOneWidget);
  });

  testWidgets('leaderboards: showing uncertainty explains the tie', (tester) async {
    await pumpApp(tester, home: const LLeaderboardsScreen());
    await _tap(tester, find.byKey(const ValueKey('lb-ranges')));
    expect(tester.widget<Text>(find.byKey(const ValueKey('lb-note'))).data, startsWith('Models A, B and C overlap'));
  });

  testWidgets('this year: tapping an event shows its source', (tester) async {
    await pumpApp(tester, home: const LThisYearScreen());
    await _tap(tester, find.byKey(const ValueKey('year-7')));
    expect(find.textContaining('Introducing Claude Opus 5.5'), findsOneWidget);
  });

  for (final (name, screen) in [
    ('models', const LSotaModelsScreen()),
    ('hardware', const LSotaHardwareScreen()),
    ('techniques', const LSotaTechniquesScreen()),
    ('leaderboards', const LLeaderboardsScreen()),
    ('this year', const LThisYearScreen()),
  ]) {
    testWidgets('$name: no overflow at large text in light mode', (tester) async {
      await pumpApp(tester, home: screen, textScale: 1.3, brightness: Brightness.light);
      await pumpFrames(tester);
      expectNoErrors(tester);
    });
  }
}
