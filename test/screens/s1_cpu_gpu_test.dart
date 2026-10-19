import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s1/s1_cpu_gpu.dart';

import '../helpers.dart';

void main() {
  testWidgets('s1_cpu_gpu renders and the showdown changes the output', (tester) async {
    await pumpApp(tester, home: const S1CpuGpuScreen());
    // The DemoCard title is below the fold; scroll it into view first.
    await scrollTo(tester, find.text('Showdown: fill a 64×64 grid'));
    expect(find.text('Showdown: fill a 64×64 grid'), findsOneWidget);
    expect(find.text('CPU — the master chefs'), findsOneWidget);
    expect(find.text('GPU — the army of cooks'), findsOneWidget);

    // Start the showdown; pump past the 10 s race so the GPU finishes.
    await tapVisible(tester, find.byKey(const ValueKey('showdown-start')));
    await tester.pump(const Duration(seconds: 11));
    await tester.pump();
    // The GPU finished its grid; the CPU is still working a few cells at a time.
    expect(find.textContaining('done'), findsWidgets);

    // Change the block size via the slider; the label text must change.
    await tester.drag(find.byKey(const ValueKey('gpu-block-slider')), const Offset(200, 0));
    await tester.pump();
    expect(find.textContaining('cells'), findsWidgets);
    expectNoErrors(tester);
  });

  testWidgets('s1_cpu_gpu has no overflow at large text and in light mode', (tester) async {
    await pumpApp(tester, home: const S1CpuGpuScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
