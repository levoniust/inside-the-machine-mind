import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s5/e_asking.dart';

import '../helpers.dart';

void main() {
  testWidgets('e_asking renders the prompt builder and the checklist', (tester) async {
    await pumpApp(tester, home: const EAskingScreen());
    expect(find.text('Ask it to be more specific'), findsOneWidget);
    // The checklist card is further down the list; scroll to it before expecting.
    final checklist = find.text('A few habits that help');
    await scrollTo(tester, checklist);
    expect(checklist, findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('e_asking: toggling chips changes the built prompt and the answer', (tester) async {
    await pumpApp(tester, home: const EAskingScreen());
    // Before any chip: the prompt is just the base request.
    expect(find.text('Write an email'), findsOneWidget);
    expect(find.text('The model is guessing — it has no idea who this is for.'), findsOneWidget);

    // Toggle the "Goal" chip.
    await tapVisible(tester, find.byKey(const ValueKey('chip-goal')));
    // The prompt now includes the goal clause.
    expect(
      find.text('Write an email, to get a meeting this week'),
      findsOneWidget,
    );
    // The answer preview changed to the 1-chip variant.
    expect(find.textContaining('I wanted to reach out and check in'), findsOneWidget);

    // Toggle the "Tone" chip as well.
    await tapVisible(tester, find.byKey(const ValueKey('chip-tone')));
    expect(
      find.text('Write an email, to get a meeting this week, in a warm, professional tone'),
      findsOneWidget,
    );
    expectNoErrors(tester);
  });

  testWidgets('e_asking: the checklist toggles when tapped', (tester) async {
    await pumpApp(tester, home: const EAskingScreen());
    final first = find.byKey(const ValueKey('checklist-0'));
    await scrollTo(tester, first);
    expect(find.text('Ask it to ask you questions first — let it fill the gaps before it writes.'), findsOneWidget);
    await tapVisible(tester, first);
    // After tapping, the first checkbox is now checked.
    final checkbox = find.byType(Checkbox);
    expect(checkbox, findsNWidgets(3));
    expect(tester.widget<Checkbox>(checkbox.first).value, isTrue);
    expectNoErrors(tester);
  });

  testWidgets('e_asking has no overflow at large text and in light mode', (tester) async {
    await pumpApp(tester, home: const EAskingScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
