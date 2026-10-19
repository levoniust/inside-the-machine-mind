import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s1/s1_precision.dart';

import '../helpers.dart';

void main() {
  test('π in each format', () {
    expect(roundToMantissa(math.pi, 7), 3.140625); // BF16
    expect(roundToMantissa(math.pi, 3), 3.25); // FP8 (E4M3)
    expect(roundToMantissa(math.pi, 1), 3.0); // FP4 (E2M1)
    expect(roundToMantissa(math.pi, 23), closeTo(math.pi, 1e-6));
  });

  testWidgets('s1_precision: FP4 rounds π to 3.0 and shrinks the model', (tester) async {
    await pumpApp(tester, home: const S1PrecisionScreen());
    expect(find.text('3.140625'), findsOneWidget);
    await tapVisible(tester, find.text('FP4'));
    await pumpFrames(tester, 3);
    expect(find.text('3.0'), findsOneWidget);
    await scrollTo(tester, find.byKey(const ValueKey('prec-gb')));
    expect(find.textContaining('In FP4: 35 GB'), findsOneWidget);
    expectNoErrors(tester);
  });
}
