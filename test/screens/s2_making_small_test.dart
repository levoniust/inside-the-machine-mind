import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s2/s2_making_small.dart';

import '../helpers.dart';

void main() {
  testWidgets('s2_making_small: all three tricks work', (tester) async {
    await pumpApp(tester, home: const S2MakingSmallScreen());
    await scrollTo(tester, find.byKey(const ValueKey('small-progress')));
    await tester.drag(find.descendant(of: find.byKey(const ValueKey('small-progress')), matching: find.byType(Slider)), const Offset(500, 0));
    await pumpFrames(tester, 3);
    await scrollTo(tester, find.byKey(const ValueKey('small-distill-note')));
    expect(find.textContaining('almost exactly like the teacher'), findsOneWidget);

    await tapVisible(tester, find.text('Fewer bits'));
    await pumpFrames(tester, 3);
    await scrollTo(tester, find.byKey(const ValueKey('small-size')));
    expect(find.text('70 GB'), findsOneWidget);

    await tapVisible(tester, find.text('Specialists'));
    await pumpFrames(tester, 3);
    await tapVisible(tester, find.byKey(const ValueKey('small-token-3')));
    await scrollTo(tester, find.byKey(const ValueKey('small-moe-note')));
    expect(find.textContaining('"blue" → experts'), findsOneWidget);
    expectNoErrors(tester);
  });
}
