import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s2/s2_big_small.dart';

import '../helpers.dart';

void main() {
  testWidgets('s2_big_small: picking a model updates the stats; frontier size is not invented', (tester) async {
    await pumpApp(tester, home: const S2BigSmallScreen());
    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Llama 3 70B'));
    await pumpFrames(tester, 6);
    await scrollTo(tester, find.text('At a glance'));
    expect(find.text('140 GB'), findsOneWidget);
    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Frontier'));
    await pumpFrames(tester, 6);
    await scrollTo(tester, find.text('At a glance'));
    expect(find.text('not public'), findsOneWidget);
    expectNoErrors(tester);
  });
}
