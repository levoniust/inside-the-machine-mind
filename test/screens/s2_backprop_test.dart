import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s2/s2_backprop.dart';

import '../helpers.dart';

void main() {
  test('one backprop update lowers the loss', () {
    final net = BackpropExample();
    final before = net.loss();
    net.update(1.0);
    expect(net.loss(), lessThan(before));
  });

  test('analytic gradient matches numerical gradient for a first-layer weight', () {
    final net = BackpropExample();
    const eps = 1e-6;
    final w = net.w1[1][0];
    net.w1[1][0] = w + eps;
    final up = net.loss();
    net.w1[1][0] = w - eps;
    final down = net.loss();
    net.w1[1][0] = w;
    expect(net.grads().gw1[1][0], closeTo((up - down) / (2 * eps), 1e-6));
  });

  testWidgets('s2_backprop: stepping to the end lowers the loss on screen', (tester) async {
    await pumpApp(tester, home: const S2BackpropScreen());
    for (var i = 0; i < 6; i++) {
      await tapVisible(tester, find.byTooltip('Next step'));
      await pumpFrames(tester, 4);
    }
    expect(find.byKey(const ValueKey('bp-improved')), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s2_backprop: large text + light mode', (tester) async {
    await pumpApp(tester, home: const S2BackpropScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
