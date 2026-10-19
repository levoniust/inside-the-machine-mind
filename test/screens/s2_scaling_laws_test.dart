import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s2/s2_scaling_laws.dart';

import '../helpers.dart';

void main() {
  test('the illustrative curve has its optimum at 20 tokens per knob', () {
    const c = 5.76e23;
    final best = optimalParams(c);
    final at = illustrativeLoss(best, c / 6 / best);
    expect(illustrativeLoss(best * 2, c / 6 / (best * 2)), greaterThan(at));
    expect(illustrativeLoss(best / 2, c / 6 / (best / 2)), greaterThan(at));
    expect((c / 6 / best) / best, closeTo(20, 1e-6));
  });

  testWidgets('s2_scaling_laws: a giant model is under-fed; the sweet-spot button fixes it', (tester) async {
    await pumpApp(tester, home: const S2ScalingLawsScreen());
    await scrollTo(tester, find.byKey(const ValueKey('sl-verdict')));
    expect(find.textContaining('Too big for the budget'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('sl-best')));
    await pumpFrames(tester, 3);
    await scrollTo(tester, find.byKey(const ValueKey('sl-verdict')));
    expect(find.textContaining('sweet spot'), findsWidgets);
    expectNoErrors(tester);
  });
}
