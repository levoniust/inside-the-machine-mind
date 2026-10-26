import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s6/l_frontends.dart';
import 'package:machine_mind/screens/s7/l_datasets.dart';

import '../helpers.dart';

Future<void> _tap(WidgetTester t, Finder f) async {
  if (f.evaluate().isEmpty) await t.scrollUntilVisible(f, 300, scrollable: find.byType(Scrollable).first);
  await t.ensureVisible(f);
  await t.pumpAndSettle();
  await t.tap(f);
  await t.pump();
}

void main() {
  testWidgets('frontends: RAG search finds the two router notes and builds the prompt', (tester) async {
    await pumpApp(tester, home: const LFrontendsScreen());
    await _tap(tester, find.byKey(const ValueKey('rag-search')));
    final prompt = tester
        .widget<Text>(find.descendant(of: find.byKey(const ValueKey('rag-prompt')), matching: find.byType(Text)))
        .data!;
    expect(prompt, contains('hold the reset button'));
    expect(prompt, contains('lights stay red'));
    expect(prompt, isNot(contains('kitchen')));
  });

  testWidgets('frontends: agent steps forward', (tester) async {
    await pumpApp(tester, home: const LFrontendsScreen());
    for (var i = 0; i < 3; i++) {
      await _tap(tester, find.byKey(const ValueKey('agent-step')));
    }
    expect(find.textContaining('about 25 °C'), findsOneWidget);
  });

  testWidgets('datasets: tapping a block shows its raw text; the bad row is found', (tester) async {
    await pumpApp(tester, home: const LDatasetsScreen());
    await _tap(tester, find.byKey(const ValueKey('tpl-0')));
    expect(tester.widget<Text>(find.byKey(const ValueKey('tpl-raw'))).data, '<|begin_of_text|>');
    await _tap(tester, find.byKey(const ValueKey('bad-1')));
    expect(tester.widget<Text>(find.byKey(const ValueKey('bad-result'))).data, startsWith('Right.'));
  });

  for (final (name, screen) in [('frontends', const LFrontendsScreen()), ('datasets', const LDatasetsScreen())]) {
    testWidgets('$name: no overflow at large text in light mode', (tester) async {
      await pumpApp(tester, home: screen, textScale: 1.3, brightness: Brightness.light);
      await pumpFrames(tester);
      expectNoErrors(tester);
    });
  }
}
