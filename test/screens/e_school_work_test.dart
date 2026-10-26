import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s5/e_school_work.dart';

import '../helpers.dart';

// Press a button by calling its handler (the game sits near the lesson's own Next bar on a phone screen).
Future<void> _press(WidgetTester t, String key) async {
  final w = t.widget(find.byKey(ValueKey(key)));
  (w is FilledButton ? w.onPressed : (w as ButtonStyleButton).onPressed)!();
  await t.pump();
}

void main() {
  testWidgets('sorting all eight cards correctly scores 8 of 8', (tester) async {
    await pumpApp(tester, home: const ESchoolWorkScreen());
    const answers = ['fine', 'notOk', 'depends', 'notOk', 'fine', 'depends', 'depends', 'fine'];
    for (final a in answers) {
      await _press(tester, 'sort-_Pile.$a');
      await _press(tester, 'sort-next');
    }
    expect(find.text('You got 8 of 8 right.'), findsOneWidget);
  });

  testWidgets('a wrong pick still moves on and scores 7 of 8', (tester) async {
    await pumpApp(tester, home: const ESchoolWorkScreen());
    const answers = ['notOk', 'notOk', 'depends', 'notOk', 'fine', 'depends', 'depends', 'fine'];
    for (final a in answers) {
      await _press(tester, 'sort-_Pile.$a');
      await _press(tester, 'sort-next');
    }
    expect(find.text('You got 7 of 8 right.'), findsOneWidget);
  });

  testWidgets('no overflow at large text in light mode', (tester) async {
    await pumpApp(tester, home: const ESchoolWorkScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
