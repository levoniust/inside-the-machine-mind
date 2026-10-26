// Full journey on a real device/emulator: first launch, every track (Everyday + Lab) via "Next", each quiz answered
// correctly, then the Easter eggs. Run: flutter test integration_test -d emulator-5554
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

  // One track: open its card, walk every lesson with Next, answer its quiz correctly (if it has one), go back.
  Future<void> walkTrack(WidgetTester t, ProgressStore store, String cardKey, int number) async {
    final s = sections[number - 1];
    await tapCentered(t, find.byKey(ValueKey(cardKey)));
    await tapCentered(t, find.byKey(const ValueKey('hub-continue')));
    for (final l in s.lessons) {
      expect(t.takeException(), isNull, reason: 'exception on ${l.id}');
      expect(find.text(l.title), findsWidgets, reason: 'title of ${l.id} in track $number');
      await t.tap(find.byKey(const ValueKey('lesson-next')));
      await settle(t);
    }
    if (s.quizId.isNotEmpty) {
      for (final q in quizzes[s.quizId]!) {
        await tapCentered(t, find.byKey(ValueKey('quiz-option-${q.answer}')));
        await tapCentered(t, find.byKey(const ValueKey('quiz-next')));
      }
      expect(store.quizScore(s.quizId), quizzes[s.quizId]!.length);
      await tapCentered(t, find.text('Back to the journey'));
    }
    await t.pageBack(); // hub → home / Lab
    await settle(t);
  }

  testWidgets('walk the whole app: front door, every Lab track, every egg', (t) async {
    final store = ProgressStore();
    await t.pumpWidget(MachineMindApp(progress: store));
    await settle(t, 30);

    // First launch: the question.
    await tapCentered(t, find.byKey(const ValueKey('welcome-everyday')));
    expect(store.audience, 1);

    // Front door: the two Everyday tracks.
    for (final s in everydayTracks) {
      await walkTrack(t, store, 'section-card-${s.number}', s.number);
    }

    // Through the Lab door: Foundations, then the Lab tracks.
    await tapCentered(t, find.byKey(const ValueKey('home-lab-door')));
    for (final s in [...foundations, ...labTracks]) {
      await walkTrack(t, store, 'track-card-${s.number}', s.number);
    }
    expect(store.doneCount, allLessons.length);

    // Lab egg: long-press the "as of" date.
    final asof = find.byKey(const ValueKey('lab-asof'));
    if (asof.evaluate().isEmpty) {
      await t.scrollUntilVisible(asof, -300, scrollable: find.byType(Scrollable).first);
    }
    await Scrollable.ensureVisible(t.element(asof), alignment: 0.3);
    await settle(t, 4);
    await t.longPress(asof);
    await settle(t, 30);
    expect(find.text('Bit\'s Workbench'), findsOneWidget);
    await t.pageBack();
    await settle(t);
    await t.pageBack(); // Lab → front door
    await settle(t);

    // Front-door eggs (the home list may still be scrolled down).
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
