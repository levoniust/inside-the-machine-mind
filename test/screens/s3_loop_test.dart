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

  testWidgets('s3_loop: loop diagram sits above the chips and tracks the loop state', (tester) async {
    await pumpApp(tester, home: const S3LoopScreen());
    final handle = tester.ensureSemantics();
    await pumpFrames(tester, 2);
    final diagram = find.byKey(const ValueKey('loop-diagram'));
    await scrollTo(tester, diagram);
    expect(diagram, findsOneWidget);
    // The diagram is above the token chips.
    await scrollTo(tester, find.byKey(const ValueKey('loop-chips')));
    expect(
      tester.getTopLeft(diagram).dy,
      lessThan(tester.getTopLeft(find.byKey(const ValueKey('loop-chips'))).dy),
    );
    expect(find.bySemanticsLabel(RegExp('loops back over the top into the model input')), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('loop-all')));
    await pumpFrames(tester, 3);
    expect(find.bySemanticsLabel(RegExp('the loop has ended')), findsOneWidget);
    handle.dispose();
    expectNoErrors(tester);
  });

  testWidgets('s3_loop: no overflow at large text in light mode', (tester) async {
    await pumpApp(tester, home: const S3LoopScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
