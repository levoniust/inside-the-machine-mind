import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s2/s2_memory_budget.dart';

import '../helpers.dart';

void main() {
  test('training state is 16 bytes per knob', () => expect(bytesPerParam, 16));

  testWidgets('s2_memory_budget: more GPUs makes a 70B model fit', (tester) async {
    await pumpApp(tester, home: const S2MemoryBudgetScreen());
    // 70B × 16 bytes = 1.12 TB of training state; on 8 GPUs that's 140 GB each → doesn't fit in 80 GB.
    await scrollTo(tester, find.byKey(const ValueKey('mem-verdict')));
    expect(find.textContaining('Doesn\'t fit'), findsOneWidget);
    await scrollTo(tester, find.byKey(const ValueKey('mem-gpus')));
    await tester.drag(find.descendant(of: find.byKey(const ValueKey('mem-gpus')), matching: find.byType(Slider)), const Offset(400, 0));
    await pumpFrames(tester, 4);
    await scrollTo(tester, find.byKey(const ValueKey('mem-verdict')));
    expect(find.textContaining('Fits'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s2_memory_budget: large text + light mode', (tester) async {
    await pumpApp(tester, home: const S2MemoryBudgetScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
