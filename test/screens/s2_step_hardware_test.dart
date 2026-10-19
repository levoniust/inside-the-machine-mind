import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s2/s2_step_hardware.dart';

import '../helpers.dart';

void main() {
  testWidgets('s2_step_hardware: stepping walks through all seven phases', (tester) async {
    await pumpApp(tester, home: const S2StepHardwareScreen());
    expect(find.text('1 · Load a batch'), findsOneWidget);
    for (var i = 0; i < 6; i++) {
      await tapVisible(tester, find.byTooltip('Next step'));
      await pumpFrames(tester, 3);
    }
    expect(find.text('7 · Save game (sometimes)'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s2_step_hardware: large text + light mode', (tester) async {
    await pumpApp(tester, home: const S2StepHardwareScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
