import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s2/s2_attention.dart';

import '../helpers.dart';

void main() {
  test('attention rows are causal and sum to 1', () {
    for (final head in attnWeights) {
      for (var i = 0; i < head.length; i++) {
        expect(head[i].length, i + 1);
        expect(head[i].fold<double>(0, (a, b) => a + b), closeTo(1, 1e-9));
      }
    }
  });

  test('pronoun head: "it" in the new sentence listens most to "robot"', () {
    expect(attnSentences[2], ['The', 'robot', 'said', 'it', 'was', 'happy']);
    final itRow = attnWeights[2][3]; // the row for "it"
    var top = 0;
    for (var i = 1; i < itRow.length; i++) {
      if (i != 3 && itRow[i] > itRow[top]) top = i;
    }
    expect(attnSentences[2][top], 'robot');
    expect(itRow[top], greaterThan(0.5));
  });

  testWidgets('s2_attention: "scatters" listens to "light"; tapping "blue" shows "sky"', (tester) async {
    await pumpApp(tester, home: const S2AttentionScreen());
    await scrollTo(tester, find.byKey(const ValueKey('attn-status')));
    expect(find.textContaining('listens most to "light"'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('attn-word-3')));
    await pumpFrames(tester, 3);
    expect(find.textContaining('"blue" listens most to "sky"'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s2_attention: pronoun head shows "The robot said it was happy" with "it" -> "robot"', (tester) async {
    await pumpApp(tester, home: const S2AttentionScreen());
    await tapVisible(tester, find.byKey(const ValueKey('attn-head-2')));
    await pumpFrames(tester, 3);
    expect(find.text('robot'), findsOneWidget);
    expect(find.text('happy'), findsOneWidget);
    expect(find.text('scatters'), findsNothing);
    expect(find.textContaining('"it" listens most to "robot"'), findsOneWidget);
    // Tapping another word of the new sentence changes what is shown.
    await tapVisible(tester, find.byKey(const ValueKey('attn-word-5')));
    await pumpFrames(tester, 3);
    expect(find.textContaining('"happy" listens most to "said"'), findsOneWidget);
    // Back to the meaning head restores the original sentence and its default word.
    await tapVisible(tester, find.byKey(const ValueKey('attn-head-0')));
    await pumpFrames(tester, 3);
    expect(find.textContaining('listens most to "light"'), findsOneWidget);
    expect(find.text('robot'), findsNothing);
    expectNoErrors(tester);
  });

  // NOTE: at 360 dp *and* 1.3x text the shared Bit bubble (lib/widgets/bit.dart, out of scope here)
  // already overflows on every lesson's first frame, so these two checks are split the way the
  // rest of the suite runs them: phone width at normal text, large text at the default width.
  testWidgets('s2_attention: pronoun head fits a 360 dp phone', (tester) async {
    await pumpApp(tester, home: const S2AttentionScreen(), size: const Size(360, 780));
    await tapVisible(tester, find.byKey(const ValueKey('attn-head-2')));
    await pumpFrames(tester, 3);
    expect(find.textContaining('"it" listens most to "robot"'), findsOneWidget);
    expect(find.text('happy'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s2_attention: pronoun head works at 1.3x large text', (tester) async {
    await pumpApp(tester, home: const S2AttentionScreen(), textScale: 1.3, brightness: Brightness.light);
    await tapVisible(tester, find.byKey(const ValueKey('attn-head-2')));
    await pumpFrames(tester, 3);
    expect(find.textContaining('"it" listens most to "robot"'), findsOneWidget);
    expect(find.text('happy'), findsOneWidget);
    expectNoErrors(tester);
  });
}
