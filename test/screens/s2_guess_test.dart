import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s2/s2_guess.dart';

import '../helpers.dart';

void main() {
  test('untrained guesses are nearly flat and sum to 1', () {
    final u = untrainedGuesses(guessExamples[0]);
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
}
