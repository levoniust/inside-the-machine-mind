import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s2/s2_cleaning.dart';

import '../helpers.dart';

void main() {
  testWidgets('s2_cleaning: running all filters removes junk and masks personal info', (tester) async {
    await pumpApp(tester, home: const S2CleaningScreen());
    expect(find.text('Lines kept: 9 of 9'), findsOneWidget);
    for (var i = 0; i < 5; i++) {
      await tapVisible(tester, find.byKey(const ValueKey('clean-next')));
      await tester.pump(const Duration(milliseconds: 400));
    }
    await scrollTo(tester, find.byKey(const ValueKey('clean-left')));
    expect(find.text('Lines kept: 4 of 9'), findsOneWidget);
    expect(find.textContaining('[PHONE]'), findsOneWidget);
    expectNoErrors(tester);
  });
}
