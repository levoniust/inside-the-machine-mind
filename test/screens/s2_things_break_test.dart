import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s2/s2_things_break.dart';

import '../helpers.dart';

void main() {
  test('interruption counts match the Llama 3 paper', () {
    final e = interruptions();
    expect(e.length, 466);
    expect(e.where((x) => x.$2 == Cause.planned).length, 47);
    expect(e.where((x) => x.$2 == Cause.gpu).length, 246);
  });

  testWidgets('s2_things_break: filters and the checkpoint rewind', (tester) async {
    await pumpApp(tester, home: const S2ThingsBreakScreen());
    await scrollTo(tester, find.byKey(const ValueKey('break-shown')));
    expect(find.text('Showing 466'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('break-planned')));
    await pumpFrames(tester, 2);
    expect(find.text('Showing 419'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('break-next')));
    await tapVisible(tester, find.byKey(const ValueKey('break-next')));
    await pumpFrames(tester, 2);
    expect(find.byKey(const ValueKey('break-stage-2')), findsOneWidget);
    expectNoErrors(tester);
  });
}
