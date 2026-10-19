import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s1/s1_rack.dart';

import '../helpers.dart';

void main() {
  testWidgets('s1_rack: switching to air cooling changes the caption', (tester) async {
    await pumpApp(tester, home: const S1RackScreen());
    await scrollTo(tester, find.byKey(const ValueKey('rack-caption')));
    expect(find.textContaining('Cold liquid'), findsOneWidget);
    await tapVisible(tester, find.text('Air cooling'));
    await pumpFrames(tester, 3);
    await scrollTo(tester, find.byKey(const ValueKey('rack-caption')));
    expect(find.textContaining('Fans alone'), findsOneWidget);
    expectNoErrors(tester);
  });
}
