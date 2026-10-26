import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s6/l_quant_pick.dart';

import '../helpers.dart';

String _kld(WidgetTester t) => t
    .widgetList<Text>(find.descendant(of: find.byKey(const ValueKey('qp-kld')), matching: find.byType(Text)))
    .map((w) => w.data)
    .join(' ');

void main() {
  testWidgets('Q4_K_M reads 0.031, the imatrix brings it to 0.028; Q2_K falls apart', (tester) async {
    await pumpApp(tester, home: const LQuantPickScreen());
    await tester.scrollUntilVisible(find.byKey(const ValueKey('qp-band')), 300);
    expect(_kld(tester), contains('0.031'));
    await tester.ensureVisible(find.byKey(const ValueKey('qp-imatrix')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('qp-imatrix')));
    await tester.pump();
    expect(_kld(tester), contains('0.028'));
    final s = find.descendant(of: find.byKey(const ValueKey('qp-slider')), matching: find.byType(Slider));
    tester.widget<Slider>(s).onChanged!(2);
    await tester.pump();
    expect(tester.widget<Text>(find.byKey(const ValueKey('qp-band'))).data, 'Q2_K: starts to fall apart.');
  });

  testWidgets('no overflow at large text in light mode', (tester) async {
    await pumpApp(tester, home: const LQuantPickScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
