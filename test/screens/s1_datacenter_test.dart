import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s1/s1_datacenter.dart';

import '../helpers.dart';

void main() {
  test('plan math: 100,000 GPUs ≈ 1,389 racks, ~282 MW at PUE 1.54', () {
    final p = DatacenterPlan(100000);
    expect(p.racks, 1389);
    expect(p.facilityKw / 1000, closeTo(282.4, 0.5));
    expect(p.homes, closeTo(235300, 500));
    expect(DatacenterPlan(100000, efficient: true).facilityKw, lessThan(p.facilityKw));
  });

  testWidgets('s1_datacenter: presets change the scale description and power', (tester) async {
    await pumpApp(tester, home: const S1DatacenterScreen());
    await tapVisible(tester, find.text('Stargate'));
    await pumpFrames(tester, 4);
    expect(find.textContaining('gigawatt campus'), findsOneWidget);
    await tapVisible(tester, find.text('1 rack'));
    await pumpFrames(tester, 4);
    expect(find.textContaining('single rack'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s1_datacenter: large text + light mode', (tester) async {
    await pumpApp(tester, home: const S1DatacenterScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
