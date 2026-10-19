import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s2/s2_parallel.dart';

import '../helpers.dart';

void main() {
  testWidgets('s2_parallel: switching modes changes the explanation', (tester) async {
    await pumpApp(tester, home: const S2ParallelScreen());
    await scrollTo(tester, find.byKey(const ValueKey('par-title')));
    expect(find.textContaining('Many kitchens'), findsOneWidget);
    await tapVisible(tester, find.text('Pipeline'));
    await pumpFrames(tester, 3);
    await scrollTo(tester, find.byKey(const ValueKey('par-title')));
    expect(find.textContaining('assembly line'), findsWidgets);
    expectNoErrors(tester);
  });
}
