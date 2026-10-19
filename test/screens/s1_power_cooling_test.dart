import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s1/s1_power_cooling.dart';

import '../helpers.dart';

void main() {
  testWidgets('s1_power_cooling: heat chain and PUE presets', (tester) async {
    await pumpApp(tester, home: const S1PowerCoolingScreen());
    await tapVisible(tester, find.text('Heat out'));
    await tapVisible(tester, find.byKey(const ValueKey('pc-stage-3')));
    await pumpFrames(tester, 3);
    expect(find.text('Cooling towers'), findsOneWidget);
    await tapVisible(tester, find.text('Best sites ~1.1'));
    await pumpFrames(tester, 3);
    await scrollTo(tester, find.byKey(const ValueKey('pc-overhead')));
    expect(find.textContaining('0.10 W more'), findsOneWidget);
    expectNoErrors(tester);
  });
}
