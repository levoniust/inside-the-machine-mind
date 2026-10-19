import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s2/s2_descent.dart';

import '../helpers.dart';

void main() {
  test('the surface has a deep valley on the left and a shallow dip on the right', () {
    expect(lossSurface(-1.5, 0), lessThan(-0.8));
    expect(lossSurface(1.45, 0.6), lessThan(lossSurface(2.2, 1.2)));
  });

  testWidgets('without momentum the ball gets trapped; with momentum it finds the valley', (tester) async {
    await pumpApp(tester, home: const S2DescentScreen());
    await tapVisible(tester, find.byKey(const ValueKey('descent-roll')));
    await pumpFrames(tester, 140);
    expect(find.textContaining('Stuck in the shallow dip'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('descent-reset')));
    await tapVisible(tester, find.byKey(const ValueKey('descent-momentum')));
    await tapVisible(tester, find.byKey(const ValueKey('descent-roll')));
    await pumpFrames(tester, 160);
    expect(find.textContaining('deep valley'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s2_descent: large text + light mode', (tester) async {
    await pumpApp(tester, home: const S2DescentScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
