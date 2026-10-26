import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s6/l_speed_tricks.dart';

import '../helpers.dart';

String _tile(WidgetTester t, String key) => t
    .widgetList<Text>(find.descendant(of: find.byKey(ValueKey(key)), matching: find.byType(Text)))
    .map((w) => w.data)
    .join(' ');

void main() {
  testWidgets('a round produces at least one token per big-model pass', (tester) async {
    await pumpApp(tester, home: const LSpeedTricksScreen());
    await tester.ensureVisible(find.byKey(const ValueKey('spec-round')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('spec-round')));
    await tester.pump();
    final text = tester.widget<Text>(find.byKey(const ValueKey('spec-count'))).data!;
    expect(RegExp(r'^(\d+) tokens in 1 big-model passes').firstMatch(text), isNotNull);
    expect(int.parse(text.split(' ').first), greaterThanOrEqualTo(1));
  });

  testWidgets('the paper formula: α 80%, γ 4, c 5% → 3.36 tokens per pass, 2.80× faster', (tester) async {
    await pumpApp(tester, home: const LSpeedTricksScreen());
    await tester.scrollUntilVisible(find.byKey(const ValueKey('spec-speed')), 300);
    expect(_tile(tester, 'spec-e'), contains('3.36'));
    expect(_tile(tester, 'spec-speed'), contains('2.80×'));
    final g = find.descendant(of: find.byKey(const ValueKey('spec-gamma')), matching: find.byType(Slider));
    tester.widget<Slider>(g).onChanged!(1);
    await tester.pump();
    expect(_tile(tester, 'spec-e'), contains('1.80'));
  });

  testWidgets('no overflow at large text in light mode', (tester) async {
    await pumpApp(tester, home: const LSpeedTricksScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
