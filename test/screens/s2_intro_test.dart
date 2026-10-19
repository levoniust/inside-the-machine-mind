import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s2/s2_intro.dart';

import '../helpers.dart';

void main() {
  testWidgets('s2_intro: the toggle switches between school and the job', (tester) async {
    await pumpApp(tester, home: const S2IntroScreen());
    await scrollTo(tester, find.byKey(const ValueKey('intro-caption')));
    expect(find.textContaining('At school'), findsOneWidget);
    await tapVisible(tester, find.text('The job (inference)'));
    await pumpFrames(tester, 4);
    expect(find.textContaining('On the job'), findsOneWidget);
    expectNoErrors(tester);
  });
}
