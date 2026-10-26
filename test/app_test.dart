import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/content/glossary.dart';
import 'package:machine_mind/content/lessons.dart';
import 'package:machine_mind/content/narration.dart';
import 'package:machine_mind/screens/screen_registry.dart';
import 'package:machine_mind/content/quizzes.dart';
import 'package:machine_mind/screens/extras/quiz_screen.dart';
import 'package:machine_mind/screens/home/lab_home.dart';
import 'package:machine_mind/screens/home/section_hub.dart';
import 'package:machine_mind/widgets/term_text.dart';

import 'helpers.dart';

void main() {
  testWidgets('front door shows the title, the two Everyday tracks and the Lab door', (tester) async {
    await pumpApp(tester);
    expect(find.text('Machine Mind'), findsOneWidget);
    for (final n in [4, 5]) {
      await tester.scrollUntilVisible(find.byKey(ValueKey('section-card-$n')), 200);
      expect(find.byKey(ValueKey('section-card-$n')), findsOneWidget);
    }
    await tester.scrollUntilVisible(find.byKey(const ValueKey('home-lab-door')), 200);
    await tester.ensureVisible(find.byKey(const ValueKey('home-lab-door')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('home-lab-door')));
    await pumpFrames(tester, 20);
    expect(find.byType(LabHome), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('first launch asks once; "I tinker" opens the Lab with Foundations and every Lab track', (tester) async {
    final store = await pumpApp(tester, audience: 0);
    expect(find.byKey(const ValueKey('welcome-lab')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('welcome-lab')));
    await pumpFrames(tester, 10);
    expect(store.audience, 2);
    for (final n in [1, 2, 3, 6, 7, 8, 9, 10]) {
      await tester.scrollUntilVisible(find.byKey(ValueKey('track-card-$n')), 200);
      expect(find.byKey(ValueKey('track-card-$n')), findsOneWidget);
    }
    expectNoErrors(tester);
  });

  testWidgets('a lesson reused in the short journey stays in that track for Next and the header', (tester) async {
    await pumpApp(tester, home: const SectionHub(number: 4));
    await tester.tap(find.byKey(const ValueKey('hub-continue')));
    await pumpFrames(tester, 20);
    expect(find.textContaining('THE SHORT JOURNEY · 1 / 17'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('lesson-next')));
    await pumpFrames(tester, 20);
    // s1_intro → s1_cpu_gpu (in Section 1 the next lesson would be s1_storage)
    expect(find.textContaining('THE SHORT JOURNEY · 2 / 17'), findsOneWidget);
    expect(find.text(lessonById('s1_cpu_gpu')!.title), findsWidgets);
  });

  testWidgets('tapping Bit five times opens the build-story Easter egg', (tester) async {
    final store = await pumpApp(tester);
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byKey(const ValueKey('home-bit')));
      await tester.pump(const Duration(milliseconds: 100));
    }
    await pumpFrames(tester, 20);
    expect(find.text('Bit\'s secret logbook'), findsOneWidget);
    expect(store.foundEgg('built'), isTrue);
  });

  testWidgets('long-pressing the 3060 chip opens the gallery Easter egg', (tester) async {
    final store = await pumpApp(tester);
    await tester.scrollUntilVisible(find.byKey(const ValueKey('chip-3060')), 300);
    await tester.longPress(find.byKey(const ValueKey('chip-3060')));
    await pumpFrames(tester, 20);
    expect(find.text('The 3060 Gallery'), findsOneWidget);
    expect(store.foundEgg('gallery'), isTrue);
  });

  testWidgets('section hub lists every lesson and Next walks through lessons', (tester) async {
    final store = await pumpApp(tester, home: const SectionHub(number: 1));
    expect(find.text(sections[0].lessons.first.title), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('hub-continue')));
    await pumpFrames(tester, 20);
    await tester.tap(find.byKey(const ValueKey('lesson-next')));
    await pumpFrames(tester, 20);
    expect(store.isDone(sections[0].lessons.first.id), isTrue);
    expectNoErrors(tester);
  });

  testWidgets('quiz scores answers and records the best score', (tester) async {
    final store = await pumpApp(tester, home: const QuizScreen(quizId: 'quiz_s1'));
    final qs = quizzes['quiz_s1']!;
    for (final q in qs) {
      await tester.tap(find.byKey(ValueKey('quiz-option-${q.answer}')));
      await pumpFrames(tester, 4);
      await tapVisible(tester, find.byKey(const ValueKey('quiz-next')));
      await pumpFrames(tester, 4);
    }
    expect(find.text('${qs.length} / ${qs.length}'), findsOneWidget);
    expect(store.quizScore('quiz_s1'), qs.length);
  });

  testWidgets('a finished section offers the next section', (tester) async {
    final store = await pumpApp(tester, home: const SectionHub(number: 1));
    for (final l in sections[0].lessons) {
      store.markDone(l.id);
    }
    await pumpFrames(tester, 3);
    await tapVisible(tester, find.byKey(const ValueKey('hub-next-section')));
    await pumpFrames(tester, 10);
    expect(find.text('How the Mind Grew'), findsWidgets);
    expectNoErrors(tester);
  });

  test('lesson ids are unique and every lesson has a section', () {
    final ids = allLessons.map((l) => l.id).toList();
    expect(ids.toSet().length, ids.length);
    for (final l in allLessons) {
      expect(sections[l.section - 1].lessons.contains(l), isTrue);
    }
  });

  test('glossary terms are unique and quiz answers are in range', () {
    final names = glossary.map((g) => g.term.toLowerCase()).toList();
    expect(names.toSet().length, names.length);
    for (final qs in quizzes.values) {
      for (final q in qs) {
        expect(q.answer, inInclusiveRange(0, q.options.length - 1));
      }
    }
  });

  // Release gate: `flutter test --dart-define=RELEASE=true` demands every lesson be finished. Day to day, lessons still
  // being built may be placeholders, but every lesson that has a screen must have its narration.
  test('every lesson has narration, a key idea and a real screen', () {
    const release = bool.fromEnvironment('RELEASE');
    for (final l in allLessons.where((l) => release || screenBuilders.containsKey(l.id))) {
      expect(narration[l.id]?.intro, isNotEmpty, reason: 'narration for ${l.id}');
      expect(narration[l.id]?.keyIdea, isNotEmpty, reason: 'key idea for ${l.id}');
    }
    final missing = allLessons.where((l) => !screenBuilders.containsKey(l.id)).map((l) => l.id).toList();
    if (release) expect(missing, isEmpty, reason: 'placeholder lessons: $missing');
  });

  test('TermText markup is stripped to plain text', () {
    expect(TermText.plain('A [[GPU]] has **many** [[cores|core]].'), 'A GPU has many cores.');
  });
}
