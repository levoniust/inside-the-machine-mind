import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s7/l_which_custom.dart';

import '../helpers.dart';

Future<void> _tap(WidgetTester t, String key) async {
  final f = find.byKey(ValueKey(key));
  await t.ensureVisible(f);
  await t.pumpAndSettle();
  await t.tap(f);
  await t.pump();
}

String _result(WidgetTester t) => t.widget<Text>(find.byKey(const ValueKey('wc-result'))).data!;

void main() {
  testWidgets('yes to the first question → RAG; no, then yes → fine-tune; no, no → prompt', (tester) async {
    await pumpApp(tester, home: const LWhichCustomScreen());
    await _tap(tester, 'wc-q0-yes');
    expect(_result(tester), 'Retrieval (RAG)');
    await _tap(tester, 'wc-q0-no');
    await _tap(tester, 'wc-q1-yes');
    expect(_result(tester), 'Fine-tune (LoRA)');
    await _tap(tester, 'wc-q1-no');
    expect(_result(tester), 'Just prompt it');
  });

  testWidgets('scenarios answer the questions', (tester) async {
    await pumpApp(tester, home: const LWhichCustomScreen());
    await _tap(tester, 'wc-scenario-1');
    expect(_result(tester), 'Fine-tune (LoRA)');
    await _tap(tester, 'wc-scenario-0');
    expect(_result(tester), 'Retrieval (RAG)');
  });

  testWidgets('no overflow at large text in light mode', (tester) async {
    await pumpApp(tester, home: const LWhichCustomScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
