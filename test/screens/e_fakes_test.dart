import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s5/e_fakes.dart';

import '../helpers.dart';

void main() {
  testWidgets('finding all three red flags in story 1 reveals the habit card', (tester) async {
    await pumpApp(tester, home: const EFakesScreen());
    expect(find.textContaining('2 a.m.'), findsOneWidget);
    // The bait: the voice sounding right is not a red flag — it is the trick.
    await tapVisible(tester, find.byKey(const ValueKey('fake-beat-0-0')));
    expect(find.textContaining('That is the trick, not the proof'), findsOneWidget);
    expect(find.textContaining('call him back on the number'), findsNothing);
    await tapVisible(tester, find.byKey(const ValueKey('fake-beat-0-1')));
    await tapVisible(tester, find.byKey(const ValueKey('fake-beat-0-2')));
    expect(find.textContaining('call him back on the number'), findsNothing); // one flag still missing
    await tapVisible(tester, find.byKey(const ValueKey('fake-beat-0-3')));
    expect(find.byKey(const ValueKey('fake-habit-0')), findsOneWidget);
    expect(find.textContaining('All 3 red flags found'), findsOneWidget);
  });

  testWidgets('story switching shows the other strips', (tester) async {
    await pumpApp(tester, home: const EFakesScreen());
    await tapVisible(tester, find.byKey(const ValueKey('fake-story-2')));
    expect(find.textContaining('Final notice'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('fake-story-1')));
    expect(find.textContaining('investment app'), findsOneWidget);
  });

  testWidgets('no overflow at large text in light mode', (tester) async {
    await pumpApp(tester, home: const EFakesScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
