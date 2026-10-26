import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s5/e_privacy.dart';

import '../helpers.dart';

Future<void> _tap(WidgetTester t, Finder f) async {
  if (f.evaluate().isEmpty) await t.scrollUntilVisible(f, 300, scrollable: find.byType(Scrollable).first);
  await t.ensureVisible(f);
  await t.pumpAndSettle();
  await t.tap(f);
  await t.pump();
}

double _trainOpacity(WidgetTester t) => t.widget<Opacity>(find.byKey(const ValueKey('priv-gate-train'))).opacity;

void main() {
  testWidgets('ChatGPT trains by default; switching training off greys the gate; Claude starts off', (tester) async {
    await pumpApp(tester, home: const EPrivacyScreen());
    expect(_trainOpacity(tester), 1);
    await _tap(tester, find.byKey(const ValueKey('priv-switch')));
    expect(_trainOpacity(tester), lessThan(1));
    await _tap(tester, find.byKey(const ValueKey('priv-app-3')));
    expect(_trainOpacity(tester), lessThan(1));
    expect(find.textContaining('Incognito chats are never used'), findsOneWidget);
  });

  testWidgets('no overflow at large text in light mode', (tester) async {
    await pumpApp(tester, home: const EPrivacyScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
