import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s1/s1_data_scale.dart';

import '../helpers.dart';

void main() {
  test('15T tokens ≈ 60 TB of text', () => expect(tokensToBytes(15e12), 60e12));

  testWidgets('s1_data_scale: the FineWeb preset shows millions of novels', (tester) async {
    await pumpApp(tester, home: const S1DataScaleScreen());
    await tapVisible(tester, find.text('FineWeb (15 trillion)'));
    await pumpFrames(tester, 3);
    await scrollTo(tester, find.byKey(const ValueKey('scale-novels')));
    expect(find.text('112 million'), findsOneWidget);
    expectNoErrors(tester);
  });
}
