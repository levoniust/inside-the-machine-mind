import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s1/s1_ram.dart';

import '../helpers.dart';

void main() {
  testWidgets('s1_ram renders the desk and the power switch wipes it clean', (tester) async {
    await pumpApp(tester, home: const S1RamScreen());
    expect(find.text('The desk that forgets'), findsOneWidget);
    expect(find.text('Power on — the mind is live.'), findsOneWidget);

    await tapVisible(tester, find.byKey(const ValueKey('ram-power')));
    await tester.pump(const Duration(milliseconds: 900)); // the 700 ms power-down finishes
    await tester.pump();
    expect(find.textContaining('desk was cleared'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s1_ram channel slider grows the bandwidth readout', (tester) async {
    await pumpApp(tester, home: const S1RamScreen());
    final value = find.byKey(const ValueKey('ram-bandwidth-value'));
    final slider = find.byKey(const ValueKey('ram-channels-slider'));
    expect(tester.widget<Text>(value).data, '89.6 GB/s'); // desktop default: 2 channels

    await tester.ensureVisible(slider);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.drag(slider, const Offset(60, 0));
    await tester.pump();
    expect(tester.widget<Text>(value).data, '358.4 GB/s'); // 8 channels

    await tester.drag(slider, const Offset(120, 0));
    await tester.pump();
    expect(tester.widget<Text>(value).data, '614 GB/s'); // 12-channel server
    expectNoErrors(tester);
  });

  testWidgets('s1_ram has no overflow at large text and in light mode', (tester) async {
    await pumpApp(tester, home: const S1RamScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
