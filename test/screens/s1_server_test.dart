import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s1/s1_server.dart';

import '../helpers.dart';

void main() {
  testWidgets('s1_server: tapping parts and switching models', (tester) async {
    await pumpApp(tester, home: const S1ServerScreen());
    await tapVisible(tester, find.byKey(const ValueKey('server-cpu-CPU 1')));
    await pumpFrames(tester, 3);
    expect(find.text('2 CPUs'), findsOneWidget);
    await tapVisible(tester, find.text('DGX B200'));
    await pumpFrames(tester, 3);
    await scrollTo(tester, find.byKey(const ValueKey('server-kw')));
    expect(find.text('14.3 kW'), findsOneWidget);
    expectNoErrors(tester);
  });
}
