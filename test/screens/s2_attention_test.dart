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

  testWidgets('s2_attention: "scatters" listens to "light"; tapping "blue" shows "sky"', (tester) async {
    await pumpApp(tester, home: const S2AttentionScreen());
    await scrollTo(tester, find.byKey(const ValueKey('attn-status')));
    expect(find.textContaining('listens most to "light"'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('attn-word-3')));
    await pumpFrames(tester, 3);
    expect(find.textContaining('"blue" listens most to "sky"'), findsOneWidget);
    expectNoErrors(tester);
  });
}
