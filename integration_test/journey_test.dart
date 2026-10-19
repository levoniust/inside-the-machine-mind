// Full journey on a real device/emulator: every lesson of every section via "Next", each quiz answered
// correctly, then both Easter eggs. Run: flutter test integration_test -d emulator-5554
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:machine_mind/app/app.dart';
import 'package:machine_mind/content/lessons.dart';
import 'package:machine_mind/content/quizzes.dart';
import 'package:machine_mind/core/progress.dart';

Future<void> settle(WidgetTester t, [int frames = 12]) async {
  for (var i = 0; i < frames; i++) {
    await t.pump(const Duration(milliseconds: 60));
  }
}

Future<void> tapCentered(WidgetTester t, Finder f) async {
  if (f.evaluate().isEmpty) {
    await t.scrollUntilVisible(f, 300, scrollable: find.byType(Scrollable).first);
  }
  await Scrollable.ensureVisible(t.element(f.first), alignment: 0.5);
  await settle(t, 4);
  await t.tap(f.first);
  await settle(t);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('walk the whole journey', (t) async {
    final store = ProgressStore();
    await t.pumpWidget(MachineMindApp(progress: store));
    await settle(t, 30);

    for (final s in sections) {
      await tapCentered(t, find.byKey(ValueKey('section-card-${s.number}')));
      await tapCentered(t, find.byKey(const ValueKey('hub-continue')));
      for (final l in s.lessons) {
        expect(t.takeException(), isNull, reason: 'exception on ${l.id}');
        expect(find.text(l.title), findsWidgets, reason: 'title of ${l.id}');
        await t.tap(find.byKey(const ValueKey('lesson-next')));
        await settle(t);
      }
      // Quiz: answer everything correctly.
      for (final q in quizzes[s.quizId]!) {
        await tapCentered(t, find.byKey(ValueKey('quiz-option-${q.answer}')));
        await tapCentered(t, find.byKey(const ValueKey('quiz-next')));
      }
      expect(store.quizScore(s.quizId), quizzes[s.quizId]!.length);
      await tapCentered(t, find.text('Back to the journey'));
      await t.pageBack();
      await settle(t);
    }
    expect(store.doneCount, allLessons.length);

    // Easter eggs (the home list may still be scrolled down from the section cards).
    final bit = find.byKey(const ValueKey('home-bit'));
    if (bit.evaluate().isEmpty) {
      await t.scrollUntilVisible(bit, -300, scrollable: find.byType(Scrollable).first);
    }
    await Scrollable.ensureVisible(t.element(bit), alignment: 0.3);
    await settle(t, 4);
    for (var i = 0; i < 5; i++) {
      await t.tap(find.byKey(const ValueKey('home-bit')));
      await t.pump(const Duration(milliseconds: 120));
    }
    await settle(t, 20);
    expect(find.text('Bit\'s secret logbook'), findsOneWidget);
    await t.pageBack();
    await settle(t);
    await t.scrollUntilVisible(find.byKey(const ValueKey('chip-3060')), 300, scrollable: find.byType(Scrollable).first);
    await t.longPress(find.byKey(const ValueKey('chip-3060')));
    await settle(t, 30);
    expect(find.text('The 3060 Gallery'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
