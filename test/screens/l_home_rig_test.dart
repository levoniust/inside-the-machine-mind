import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/core/progress.dart';
import 'package:machine_mind/screens/s6/l_home_rig.dart';

import '../helpers.dart';

void main() {
  testWidgets('stepping through tuning updates the note; a timeline item opens', (tester) async {
    await pumpApp(tester, home: const LHomeRigScreen());
    await tester.scrollUntilVisible(find.byKey(const ValueKey('rig-step-note')), 300);
    String note() => tester.widget<Text>(find.byKey(const ValueKey('rig-step-note'))).data!;
    expect(note(), startsWith('Most experts'));
    await tester.ensureVisible(find.byTooltip('Next step'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next step'));
    await tester.pump();
    expect(note(), startsWith('A few expert layers'));
    await tester.scrollUntilVisible(find.byKey(const ValueKey('rig-tl-2')), 300);
    await tester.ensureVisible(find.byKey(const ValueKey('rig-tl-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('rig-tl-2')));
    await tester.pump();
    expect(find.textContaining('Secure Boot back on'), findsOneWidget);
  });

  testWidgets('tapping the fan 7 times finds the egg', (tester) async {
    final store = await pumpApp(tester, home: const LHomeRigScreen());
    await tester.ensureVisible(find.byKey(const ValueKey('rig-fan')));
    await tester.pumpAndSettle();
    for (var i = 0; i < 7; i++) {
      await tester.tap(find.byKey(const ValueKey('rig-fan')));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byKey(const ValueKey('rig-egg')), findsOneWidget);
    expect(store.foundEgg('rig'), isTrue);
    expect(store, isA<ProgressStore>());
  });

  testWidgets('no overflow at large text in light mode', (tester) async {
    await pumpApp(tester, home: const LHomeRigScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
