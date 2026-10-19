import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s2/s2_guess.dart';

import '../helpers.dart';

/// Let the 650 ms bar-grow animation finish.
Future<void> settleGrow(WidgetTester tester) => tester.pump(const Duration(milliseconds: 900));

void main() {
  test('untrained guesses are nearly flat and sum to 1', () {
    final u = untrainedGuesses(guessExamples[0]);
    expect(u.values.fold<double>(0, (a, b) => a + b), closeTo(1, 1e-9));
    expect(u.values.reduce((a, b) => a > b ? a : b), lessThan(0.25));
  });

  test('there are four examples, and the "two plus two" one can guess "four"', () {
    expect(guessExamples.length, 4);
    final e = guessExamples[3];
    expect(e.context, 'Two plus two equals');
    expect(e.trained.keys, contains(e.answer));
    expect(e.trained[e.answer], greaterThan(0.5));
    // Its untrained guesses are a flat distribution over the same words, like the others.
    final u = untrainedGuesses(e);
    expect(u.values.fold<double>(0, (a, b) => a + b), closeTo(1, 1e-9));
    expect(u.values.reduce((a, b) => a > b ? a : b), lessThan(0.25));
  });

  testWidgets('s2_guess: guessing reveals the answer and the trained model is confident', (tester) async {
    await pumpApp(tester, home: const S2GuessScreen());
    await tapVisible(tester, find.byKey(const ValueKey('guess-blue')));
    await pumpFrames(tester, 3);
    expect(find.textContaining('You got it'), findsOneWidget);
    await tapVisible(tester, find.text('Trained model'));
    await pumpFrames(tester, 3);
    await scrollTo(tester, find.byKey(const ValueKey('guess-caption')));
    expect(find.textContaining('After training'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s2_guess: with reduce motion the bars appear at full length at once', (tester) async {
    await pumpApp(tester, home: const S2GuessScreen());
    await tapVisible(tester, find.byKey(const ValueKey('guess-blue')));
    await tapVisible(tester, find.text('Trained model'));
    await tester.pump();
    expect(find.text('62.0%'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s2_guess: the bars grow from zero when switching untrained <-> trained', (tester) async {
    await pumpApp(tester, home: const S2GuessScreen(), animations: true);
    await tapVisible(tester, find.byKey(const ValueKey('guess-blue')));
    await settleGrow(tester);
    // Untrained view is settled: no word comes anywhere near the trained model's 62%.
    expect(find.text('62.0%'), findsNothing);

    await tapVisible(tester, find.text('Trained model'));
    // Just after the switch the bars are still close to zero, so "blue" is nowhere near 62.0%.
    final early = tester.getSize(find.byKey(const ValueKey('guess-bar-blue'))).width;
    expect(find.text('62.0%'), findsNothing);

    // Once the grow animation ends, the bar is at full length and the number has counted up to it.
    await settleGrow(tester);
    final full = tester.getSize(find.byKey(const ValueKey('guess-bar-blue'))).width;
    expect(early, lessThan(full * 0.4));
    expect(find.text('62.0%'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s2_guess: the fourth example "Two plus two equals" can be played', (tester) async {
    await pumpApp(tester, home: const S2GuessScreen());
    // Cycle through the first three sentences to reach the new one.
    for (var i = 0; i < 3; i++) {
      await tapVisible(tester, find.byType(ActionChip).first);
      await settleGrow(tester);
      await tapVisible(tester, find.byKey(const ValueKey('guess-next')));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.textContaining('Two plus two equals'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('guess-four')));
    expect(find.textContaining('You got it'), findsOneWidget);
    await tapVisible(tester, find.text('Trained model'));
    await settleGrow(tester);
    expect(find.text('84.0%'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s2_guess: fits a 360 dp phone', (tester) async {
    await pumpApp(tester, home: const S2GuessScreen(), size: const Size(360, 740));
    await tapVisible(tester, find.byKey(const ValueKey('guess-blue')));
    await tapVisible(tester, find.text('Trained model'));
    await settleGrow(tester);
    await scrollTo(tester, find.byKey(const ValueKey('guess-bars')));
    expect(find.byKey(const ValueKey('guess-bars')), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s2_guess: no errors at text scale 1.3 in light mode', (tester) async {
    await pumpApp(tester, home: const S2GuessScreen(), textScale: 1.3, brightness: Brightness.light);
    await tapVisible(tester, find.byKey(const ValueKey('guess-blue')));
    await tapVisible(tester, find.text('Trained model'));
    await settleGrow(tester);
    await scrollTo(tester, find.byKey(const ValueKey('guess-caption')));
    expect(find.textContaining('After training'), findsOneWidget);
    expectNoErrors(tester);
  });
}
