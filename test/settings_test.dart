import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/extras/settings_screen.dart';

import 'helpers.dart';

void main() {
  testWidgets('settings change theme and reset progress', (tester) async {
    final store = await pumpApp(tester, home: const SettingsScreen());
    store.markDone('s1_intro');
    await tester.tap(find.text('Light'));
    await pumpFrames(tester, 4);
    expect(store.theme, 2);
    expect(Theme.of(tester.element(find.text('Settings').first)).brightness, Brightness.light);
    await tester.tap(find.byKey(const ValueKey('settings-motion')));
    await pumpFrames(tester, 4);
    expect(store.reduceMotion, isTrue);
    await tapVisible(tester, find.byKey(const ValueKey('settings-reset')));
    await pumpFrames(tester, 6);
    await tester.tap(find.text('Start over').last);
    await pumpFrames(tester, 6);
    expect(store.doneCount, 0);
    expect(store.theme, 2, reason: 'settings survive a progress reset');
  });
}
