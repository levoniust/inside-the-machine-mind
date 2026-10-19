import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s2/s2_testing.dart';

import '../helpers.dart';

void main() {
  testWidgets('s2_testing: repeating data shows memorizing; big models switch on the skill', (tester) async {
    await pumpApp(tester, home: const S2TestingScreen());
    await tapVisible(tester, find.byKey(const ValueKey('testing-repeat')));
    await pumpFrames(tester, 3);
    await scrollTo(tester, find.byKey(const ValueKey('testing-verdict')));
    expect(find.textContaining('memorizing'), findsOneWidget);
    await scrollTo(tester, find.byKey(const ValueKey('testing-emergent')));
    expect(find.textContaining('Not yet'), findsOneWidget);
    await scrollTo(tester, find.byKey(const ValueKey('testing-size')));
    await tester.drag(find.descendant(of: find.byKey(const ValueKey('testing-size')), matching: find.byType(Slider)), const Offset(400, 0));
    await pumpFrames(tester, 3);
    await scrollTo(tester, find.byKey(const ValueKey('testing-emergent')));
    expect(find.textContaining('Switched on'), findsOneWidget);
    expectNoErrors(tester);
  });
}
