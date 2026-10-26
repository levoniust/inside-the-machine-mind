import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s7/l_lora.dart';

import '../helpers.dart';

String _tile(WidgetTester t, String key) => t
    .widgetList<Text>(find.descendant(of: find.byKey(ValueKey(key)), matching: find.byType(Text)))
    .map((w) => w.data)
    .join(' ');

void main() {
  testWidgets('rank 8 trains 65.5 k numbers = 0.39% of a 4096² matrix; rank 1 is 0.05%', (tester) async {
    await pumpApp(tester, home: const LLoraScreen());
    await tester.scrollUntilVisible(find.byKey(const ValueKey('lora-params')), 300);
    expect(_tile(tester, 'lora-params'), contains('65.5 k · 0.39%'));
    final slider = find.descendant(of: find.byKey(const ValueKey('lora-rank')), matching: find.byType(Slider));
    tester.widget<Slider>(slider).onChanged!(0);
    await tester.pump();
    expect(_tile(tester, 'lora-params'), contains('8.2 k · 0.05%'));
  });

  testWidgets('switching to QLoRA explains the 4-bit base', (tester) async {
    await pumpApp(tester, home: const LLoraScreen());
    await tester.scrollUntilVisible(find.byKey(const ValueKey('lora-mode')), 300);
    await tester.ensureVisible(find.text('QLoRA').last);
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byKey(const ValueKey('lora-mode')), matching: find.text('QLoRA')));
    await tester.pump();
    expect(tester.widget<Text>(find.byKey(const ValueKey('lora-note'))).data, startsWith('QLoRA'));
  });

  testWidgets('no overflow at large text in light mode', (tester) async {
    await pumpApp(tester, home: const LLoraScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
