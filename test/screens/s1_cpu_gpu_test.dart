import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s1/s1_cpu_gpu.dart';

import '../helpers.dart';

void main() {
  testWidgets('s1_cpu_gpu renders and the showdown changes the output', (tester) async {
    await pumpApp(tester, home: const S1CpuGpuScreen(), animations: true);
    // The DemoCard title is below the fold; scroll it into view first.
    await scrollTo(tester, find.text('Showdown: fill a 24×24 grid'));
    expect(find.text('Showdown: fill a 24×24 grid'), findsOneWidget);
    expect(find.text('CPU — the master chefs'), findsOneWidget);
    expect(find.text('GPU — the army of cooks'), findsOneWidget);

    // Start the showdown at the default 4×4 blocks: 36 swings for the GPU.
    await tapVisible(tester, find.byKey(const ValueKey('showdown-start')));
    await tester.pump(const Duration(seconds: 11));
    await tester.pump();
    expect(find.textContaining('GPU done in 36 swings'), findsOneWidget);
    expect(find.textContaining('108 more swings: 4× longer'), findsOneWidget);
    // The CPU moved too: 36 swings × 4 cells = 144 cells, and the panel says so.
    expect(find.bySemanticsLabel(RegExp('CPU grid: 144 of 576 cells filled')), findsOneWidget);
    expect(find.text('144 / 576 cells'), findsOneWidget);
    expect(find.text('576 / 576 cells ✓'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s1_cpu_gpu: bigger blocks reset the race and finish in fewer swings', (tester) async {
    await pumpApp(tester, home: const S1CpuGpuScreen(), animations: true);
    await scrollTo(tester, find.byKey(const ValueKey('gpu-block-slider')));
    await tapVisible(tester, find.byKey(const ValueKey('showdown-start')));
    await tester.pump(const Duration(seconds: 2)); // mid-race
    expect(find.text('Swing 0'), findsNothing);
    // Slide right to the biggest blocks: the race resets so the grids match the new setting.
    await tester.drag(find.descendant(of: find.byKey(const ValueKey('gpu-block-slider')), matching: find.byType(Slider)),
        const Offset(600, 0));
    await tester.pump();
    expect(find.text('12×12 = 144 cells'), findsOneWidget);
    expect(find.text('Swing 0'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('GPU grid: 0 of 576 cells filled')), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('showdown-start')));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.textContaining('GPU done in 4 swings'), findsOneWidget);
    expect(find.textContaining('36× longer'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s1_cpu_gpu: with reduce motion the showdown jumps to the finish', (tester) async {
    await pumpApp(tester, home: const S1CpuGpuScreen());
    await scrollTo(tester, find.byKey(const ValueKey('showdown-start')));
    await tapVisible(tester, find.byKey(const ValueKey('showdown-start')));
    expect(find.textContaining('GPU done in 36 swings'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s1_cpu_gpu has no overflow at large text and in light mode', (tester) async {
    await pumpApp(tester, home: const S1CpuGpuScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
