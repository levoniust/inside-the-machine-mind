import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s1/s1_storage.dart';

import '../helpers.dart';

void main() {
  testWidgets('s1_storage renders and the load race runs to completion', (tester) async {
    await pumpApp(tester, home: const S1StorageScreen());
    expect(find.text('Race: load a 16 GB model'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('race-start')));
    await tester.pump(const Duration(seconds: 11)); // slowest drive: 80 s real / 8 = 10 s
    await tester.pump();
    expect(find.textContaining('done in'), findsNWidgets(4));
    expectNoErrors(tester);
  });

  testWidgets('s1_storage random access: the SSD answers at once, the HDD counts its seeks', (tester) async {
    await pumpApp(tester, home: const S1StorageScreen());
    final startBtn = find.byKey(const ValueKey('random-access-start'));
    await scrollTo(tester, startBtn);
    expect(find.text('Random access'), findsOneWidget);
    await tapVisible(tester, startBtn);
    // The SSD has all 5 pieces right away: 5 × ~0.1 ms, no arm movement.
    expect(find.text('reads 5/5 · 0.5 ms'), findsOneWidget);
    // After one slow-motion second the head lands its first seek: 8 ms.
    await tester.pump(const Duration(milliseconds: 1100));
    expect(find.textContaining('seeks 1/5'), findsOneWidget);
    // The last four hops take 1 s each: 5 seeks × ~8 ms = 40 ms in total.
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
    expect(find.text('seeks 5/5 · 40 ms'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s1_storage random access runs at large text in light mode without errors', (tester) async {
    await pumpApp(tester, home: const S1StorageScreen(), textScale: 1.3, brightness: Brightness.light);
    final startBtn = find.byKey(const ValueKey('random-access-start'));
    await scrollTo(tester, startBtn);
    await tapVisible(tester, startBtn);
    await pumpFrames(tester, 20); // mid-seek frames at 1.3× text
    expect(find.text('reads 5/5 · 0.5 ms'), findsOneWidget);
    expect(find.textContaining('seeks 1/5'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s1_storage has no overflow at large text and in light mode', (tester) async {
    await pumpApp(tester, home: const S1StorageScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
