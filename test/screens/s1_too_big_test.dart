import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s1/s1_too_big.dart';

import '../helpers.dart';

void main() {
  test('GPU counts: 70B BF16 needs 2 to hold, 405B needs 11', () {
    expect(gpusToHold(70e9, 2), 2);
    expect(gpusToHold(405e9, 2), 11);
    expect(gpusToHold(8e9, 2), 1);
    expect(gpusToHold(70e9, 16), 14);
  });

  testWidgets('s1_too_big: FP4 makes 70B fit on one GPU', (tester) async {
    await pumpApp(tester, home: const S1TooBigScreen());
    await scrollTo(tester, find.byKey(const ValueKey('big-verdict')));
    expect(find.textContaining('Too big'), findsOneWidget);
    await tapVisible(tester, find.text('FP4'));
    await pumpFrames(tester, 3);
    await scrollTo(tester, find.byKey(const ValueKey('big-verdict')));
    expect(find.textContaining('It fits'), findsOneWidget);
    expectNoErrors(tester);
  });
}
