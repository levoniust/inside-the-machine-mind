import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s3/s3_loop.dart';

import '../helpers.dart';

void main() {
  test('cache turns triangle work into linear work', () {
    expect(workWithoutCache(6, 14), 6 * 14 + 91);
    expect(workWithCache(6, 14), 19);
  });

  testWidgets('s3_loop: words get added until the loop stops', (tester) async {
    await pumpApp(tester, home: const S3LoopScreen());
    await tapVisible(tester, find.byKey(const ValueKey('loop-next')));
    expect(find.text('Air'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('loop-all')));
    await pumpFrames(tester, 3);
    expect(find.textContaining('loop ends'), findsOneWidget);
    expectNoErrors(tester);
  });
}
