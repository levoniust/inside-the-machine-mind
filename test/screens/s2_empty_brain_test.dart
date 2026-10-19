import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s2/s2_empty_brain.dart';

import '../helpers.dart';

void main() {
  test('12·L·w² rule matches GPT-3 and Llama 3 405B', () {
    expect(approxParams(96, 12288) / 1e9, closeTo(174, 1));
    expect(approxParams(126, 16384) / 1e9, closeTo(406, 1));
  });

  testWidgets('s2_empty_brain: tapping parts changes the caption; presets change the knob count', (tester) async {
    await pumpApp(tester, home: const S2EmptyBrainScreen());
    await tapVisible(tester, find.byKey(const ValueKey('brain-part-2')));
    await pumpFrames(tester, 3);
    expect(find.textContaining('looking it up in memory'), findsOneWidget);
    await tapVisible(tester, find.text('Llama 3 405B'));
    await pumpFrames(tester, 3);
    await scrollTo(tester, find.byKey(const ValueKey('brain-params')));
    expect(find.text('≈ 406 billion knobs'), findsOneWidget);
    expectNoErrors(tester);
  });
}
