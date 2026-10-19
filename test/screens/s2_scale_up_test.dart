import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s2/s2_scale_up.dart';

import '../helpers.dart';

void main() {
  test('Llama 3 405B: 6ND ≈ 3.8e25 FLOPs and ~27M GPU-hours at 40% utilization', () {
    const run = TrainingRun(params: 405e9, tokens: 15.6e12, gpus: 16000);
    expect(run.flops, closeTo(3.79e25, 0.01e25));
    expect(run.gpuHours / 1e6, closeTo(26.6, 0.3)); // Meta reported 30.84M (real utilization varied)
    expect(run.days, closeTo(69, 2));
  });

  testWidgets('s2_scale_up: presets switch the reality-check note', (tester) async {
    await pumpApp(tester, home: const S2ScaleUpScreen());
    await scrollTo(tester, find.byKey(const ValueKey('scale-note')));
    expect(find.textContaining('30.84 million'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('scale-preset-0')));
    await pumpFrames(tester, 4);
    await scrollTo(tester, find.byKey(const ValueKey('scale-note')));
    expect(find.textContaining('V100'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s2_scale_up: large text + light mode', (tester) async {
    await pumpApp(tester, home: const S2ScaleUpScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
