import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/home/lab_home.dart';
import 'package:machine_mind/screens/s5/e_at_home.dart';

import '../helpers.dart';

String _feel(WidgetTester t, String size) =>
    t.widget<Text>(find.descendant(of: find.byKey(ValueKey('home-feel-$size')), matching: find.byType(Text))).data!;

void main() {
  testWidgets('gaming PC: small and medium fit fast, large is slow; a laptop cannot fit the large one', (tester) async {
    await pumpApp(tester, home: const EAtHomeScreen());
    await tester.scrollUntilVisible(find.byKey(const ValueKey('home-feel-Large model')), 300);
    expect(_feel(tester, 'Small model'), 'Faster than you can read');
    expect(_feel(tester, 'Medium model'), 'Faster than you can read');
    expect(_feel(tester, 'Large model'), 'Slow, but usable');
    await tester.ensureVisible(find.byKey(const ValueKey('home-machine-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-machine-0')));
    await tester.pump();
    expect(_feel(tester, 'Large model'), 'Doesn\'t fit');
  });

  testWidgets('the big button opens the Lab', (tester) async {
    await pumpApp(tester, home: const EAtHomeScreen());
    await tester.scrollUntilVisible(find.byKey(const ValueKey('home-to-lab')), 300);
    await tester.ensureVisible(find.byKey(const ValueKey('home-to-lab')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-to-lab')));
    await pumpFrames(tester, 20);
    expect(find.byType(LabHome), findsOneWidget);
  });

  testWidgets('no overflow at large text in light mode', (tester) async {
    await pumpApp(tester, home: const EAtHomeScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
