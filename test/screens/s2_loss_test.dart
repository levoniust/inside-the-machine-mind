import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s2/s2_loss.dart';

import '../helpers.dart';

void main() {
  test('cross-entropy values', () {
    expect(crossEntropy(0.99), closeTo(0.01, 0.001));
    expect(crossEntropy(0.5), closeTo(0.693, 0.001));
    expect(crossEntropy(0.01), closeTo(4.605, 0.001));
  });

  testWidgets('s2_loss: moving the slider to "sure" lowers the loss', (tester) async {
    await pumpApp(tester, home: const S2LossScreen());
    expect(find.text('0.69'), findsOneWidget);
    await tester.drag(find.descendant(of: find.byKey(const ValueKey('loss-p')), matching: find.byType(Slider)), const Offset(400, 0));
    await pumpFrames(tester, 3);
    expect(find.text('0.01'), findsOneWidget);
    await scrollTo(tester, find.byKey(const ValueKey('loss-mood')));
    expect(find.textContaining('Confident and right'), findsOneWidget);
    expectNoErrors(tester);
  });
}
