import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s6/l_moe_home.dart';

import '../helpers.dart';

String _tile(WidgetTester t, String key) => t
    .widgetList<Text>(find.descendant(of: find.byKey(ValueKey(key)), matching: find.byType(Text)))
    .map((w) => w.data)
    .join(' ');

void main() {
  testWidgets('next token moves the router to a new word', (tester) async {
    await pumpApp(tester, home: const LMoeHomeScreen());
    expect(find.text('"Why"'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('moe-next')));
    await pumpFrames(tester);
    expect(find.text('"is"'), findsOneWidget);
  });

  testWidgets('--cpu-moe fits a 24 GB card; all of gpt-oss-120b on the GPU does not', (
    tester,
  ) async {
    await pumpApp(tester, home: const LMoeHomeScreen());
    await tester.scrollUntilVisible(find.byKey(const ValueKey('moe-cmd')), 300);
    expect(find.text('llama-server -m model.gguf -ngl 99 --cpu-moe'), findsOneWidget);
    expect(_tile(tester, 'moe-vram'), contains('/ 24 GB'));
    expect(_tile(tester, 'moe-speed'), contains('tok/s'));
    final slider = find.descendant(of: find.byKey(const ValueKey('moe-layers')), matching: find.byType(Slider));
    tester.widget<Slider>(slider).onChanged!(10);
    await tester.pump();
    expect(find.text('llama-server -m model.gguf -ngl 99 --n-cpu-moe 38'), findsOneWidget);
    // Qwen3 30B-A3B fits completely in 24 GB at Q4_K_M; gpt-oss-120b does not.
    tester.widget<Slider>(slider).onChanged!(48);
    await tester.pump();
    expect(_tile(tester, 'moe-speed'), contains('tok/s'));
    await tester.ensureVisible(find.byKey(const ValueKey('moe-model-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('moe-model-1')));
    await tester.pump();
    tester.widget<Slider>(find.descendant(of: find.byKey(const ValueKey('moe-layers')), matching: find.byType(Slider)))
        .onChanged!(36);
    await tester.pump();
    expect(_tile(tester, 'moe-speed'), contains('too big for VRAM'));
  });

  testWidgets('no overflow at large text in light mode', (tester) async {
    await pumpApp(tester, home: const LMoeHomeScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
