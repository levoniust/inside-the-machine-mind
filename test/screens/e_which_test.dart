import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s5/e_which.dart';

import '../helpers.dart';

void main() {
  testWidgets('a task shows its tool kind, apps and watch-out', (tester) async {
    await pumpApp(tester, home: const EWhichScreen());
    // Write is selected first: chat assistant.
    expect(find.textContaining('The tool that fits: chat assistant'), findsOneWidget);
    expect(find.textContaining('GitHub Copilot'), findsNothing);
    // Code shows the coding assistant instead.
    await tapVisible(tester, find.byKey(const ValueKey('which-task-4')));
    expect(find.textContaining('coding assistant'), findsOneWidget);
    expect(find.textContaining('GitHub Copilot'), findsOneWidget);
    expect(find.textContaining('confident bugs'), findsOneWidget);
    // Picture is an image generator, and never ranks the apps.
    await tapVisible(tester, find.byKey(const ValueKey('which-task-2')));
    expect(find.textContaining('The tool that fits: image generator'), findsOneWidget);
    expect(find.textContaining('Meta AI'), findsOneWidget);
  });

  testWidgets('tapping the wheel itself selects a wedge', (tester) async {
    await pumpApp(tester, home: const EWhichScreen());
    final wheel = find.byKey(const ValueKey('which-wheel'));
    await scrollTo(tester, wheel);
    final center = tester.getCenter(wheel);
    await tester.tapAt(center + const Offset(0, 60)); // bottom wedge = Talk
    await tester.pump();
    expect(find.textContaining('The tool that fits: voice mode'), findsOneWidget);
  });

  testWidgets('no overflow at large text in light mode', (tester) async {
    await pumpApp(tester, home: const EWhichScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
