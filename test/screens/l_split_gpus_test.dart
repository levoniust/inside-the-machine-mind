import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s6/l_split_gpus.dart';

import '../helpers.dart';

void main() {
  testWidgets('l_split_gpus: flipping the mode changes the picture and the explanation', (tester) async {
    await pumpApp(tester, home: const LSplitGpusScreen());
    await scrollTo(tester, find.byKey(const ValueKey('split-explain-layer')));
    expect(find.byKey(const ValueKey('split-anim-layer')), findsOneWidget);
    await tapVisible(tester, find.text('Tensor split'));
    await tester.pump();
    expect(find.byKey(const ValueKey('split-anim-tensor')), findsOneWidget);
    expect(find.byKey(const ValueKey('split-explain-tensor')), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('l_split_gpus: the starting split overfills GPU 1; 40 + 40 fits with nothing on the CPU', (tester) async {
    await pumpApp(tester, home: const LSplitGpusScreen());
    await scrollTo(tester, find.byKey(const ValueKey('split-verdict')));
    expect(find.textContaining('Out of memory on GPU 1'), findsOneWidget);
    expect(find.text('won\'t load'), findsOneWidget);

    final s1 = tester.widget<Slider>(
      find.descendant(of: find.byKey(const ValueKey('split-g1')), matching: find.byType(Slider)),
    );
    s1.onChanged!(40);
    await tester.pump();
    final s2 = tester.widget<Slider>(
      find.descendant(of: find.byKey(const ValueKey('split-g2')), matching: find.byType(Slider)),
    );
    s2.onChanged!(30);
    await tester.pump();
    expect(find.text('CPU / RAM: 10 layers'), findsOneWidget);
    expect(find.textContaining('10 layers run from system RAM'), findsOneWidget);
    // 70 layers × 0.54 GB ÷ 936 + 10 × 0.54 ÷ 62 = 0.128 s → 7.8 tok/s
    expect(find.text('≤ 7.8 tok/s'), findsOneWidget);

    final s2b = tester.widget<Slider>(
      find.descendant(of: find.byKey(const ValueKey('split-g2')), matching: find.byType(Slider)),
    );
    s2b.onChanged!(40);
    await tester.pump();
    expect(find.text('CPU / RAM: 0 layers'), findsOneWidget);
    expect(find.textContaining('All 80 layers on the GPUs'), findsOneWidget);
    expect(find.text('≤ 22 tok/s'), findsOneWidget);
    expect(find.text('23.9 / 24 GB'), findsNWidgets(2));
    expectNoErrors(tester);
  });

  testWidgets('l_split_gpus has no overflow on a small phone at large text in light mode', (tester) async {
    await pumpApp(
      tester,
      home: const LSplitGpusScreen(),
      size: const Size(360, 740),
      textScale: 1.3,
      brightness: Brightness.light,
    );
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
