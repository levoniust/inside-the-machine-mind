import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s2/s2_train_it.dart';

import '../helpers.dart';

void main() {
  testWidgets('s2_train_it: one step and training advance the step counter', (tester) async {
    await pumpApp(tester, home: const S2TrainItScreen());
    expect(find.text('Teach it: middle dots vs ring dots'), findsOneWidget);
    expect(find.text('0'), findsWidgets);
    await tapVisible(tester, find.byKey(const ValueKey('train-step')));
    expect(find.text('1'), findsWidgets);
    await tapVisible(tester, find.byKey(const ValueKey('train-play')));
    await pumpFrames(tester, 10);
    await tapVisible(tester, find.byKey(const ValueKey('train-play')));
    expect(find.text('1'), findsNothing);
    expectNoErrors(tester);
  });

  testWidgets('s2_train_it: large text + light mode', (tester) async {
    await pumpApp(tester, home: const S2TrainItScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
