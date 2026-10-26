import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s7/l_steering.dart';

import '../helpers.dart';

void main() {
  testWidgets('finding the direction toggles the button', (tester) async {
    await pumpApp(tester, home: const LSteeringScreen());
    await tester.ensureVisible(find.byKey(const ValueKey('steer-find')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('steer-find')));
    await tester.pump();
    expect(find.text('Hide the direction'), findsOneWidget);
  });

  testWidgets('the knob changes the tone of the answer', (tester) async {
    await pumpApp(tester, home: const LSteeringScreen());
    await tester.scrollUntilVisible(find.byKey(const ValueKey('steer-out')), 300);
    String out() => tester.widget<Text>(find.byKey(const ValueKey('steer-out'))).data!;
    expect(out(), startsWith('Cloudy with a chance'));
    final s = find.descendant(of: find.byKey(const ValueKey('steer-k')), matching: find.byType(Slider));
    tester.widget<Slider>(s).onChanged!(2);
    await tester.pump();
    expect(out(), startsWith('What a lovely'));
    tester.widget<Slider>(s).onChanged!(-2);
    await tester.pump();
    expect(out(), startsWith('Grey again'));
  });

  testWidgets('no overflow at large text in light mode', (tester) async {
    await pumpApp(tester, home: const LSteeringScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
