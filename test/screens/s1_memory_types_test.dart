import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s1/s1_memory_types.dart';

import '../helpers.dart';

void main() {
  testWidgets('s1_memory_types renders the family and the race', (tester) async {
    await pumpApp(tester, home: const S1MemoryTypesScreen());
    expect(find.text('The memory family: closer to the chip = faster'), findsOneWidget);
    expect(find.text('Race: stream 140 GB of weights'), findsOneWidget);
    // HBM3e is selected by default.
    expect(find.textContaining('1024-bit link per stack'), findsOneWidget);
    expect(find.text('H200 · HBM3e'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s1_memory_types picking a memory changes the picture and the race result',
      (tester) async {
    await pumpApp(tester, home: const S1MemoryTypesScreen());

    // Pick the desktop DDR5 sticks: the diagram caption changes to the DDR5 story.
    await tapVisible(tester, find.byKey(const ValueKey('mem-pick-ddr5')));
    expect(find.textContaining('centimeters from the chip'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('race-go')));
    await tester.pump(const Duration(seconds: 4)); // slowest racer: 3.5 s of animation
    await tester.pump();
    expect(find.textContaining('done in 1.6 s'), findsOneWidget); // 140 GB ÷ 89.6 GB/s

    // HBM3e streams the same 140 GB in 29 ms.
    await tapVisible(tester, find.byKey(const ValueKey('mem-pick-hbm')));
    expect(find.textContaining('done in 1.6 s'), findsNothing);
    await tapVisible(tester, find.byKey(const ValueKey('race-go')));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump();
    expect(find.textContaining('done in 29 ms'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s1_memory_types has no overflow at large text and in light mode', (tester) async {
    await pumpApp(tester,
        home: const S1MemoryTypesScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });

  testWidgets('s1_memory_types fits a 360 dp phone', (tester) async {
    await pumpApp(tester, home: const S1MemoryTypesScreen(), size: const Size(360, 740));
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
