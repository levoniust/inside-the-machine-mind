import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/content/glossary.dart';
import 'package:machine_mind/screens/s2/s2_decoder.dart';

import '../helpers.dart';

/// Reads the current round's everyday phrase off the quiz prompt and finds which engineering term
/// it belongs to. Exact match on purpose: "the library" is a substring of "one read-through of the
/// library", so a contains() lookup could map an Epoch prompt to Dataset.
String answerTerm(WidgetTester tester) {
  final p = tester.widget<Text>(find.byKey(const ValueKey('decoder-prompt'))).data!;
  final inner = p.substring(1, p.length - 1); // strip the “smart quotes” around the phrase
  return decoderTerms.firstWhere((t) => findTerm(t)!.everyday == inner);
}

/// The term shown on choice button [i] of the current round.
String choiceText(WidgetTester tester, int i) => tester
    .widget<Text>(find.descendant(of: find.byKey(ValueKey('decoder-choice-$i')), matching: find.byType(Text)))
    .data!;

/// Enter quiz mode, answer one round correctly, advance, then switch back to the browse deck.
Future<void> runOneRoundAndGoBack(WidgetTester tester) async {
  await enterQuiz(tester);
  await tapVisible(tester, find.text(answerTerm(tester)));
  await tester.pump(const Duration(milliseconds: 100));
  expect(find.text('Correct!'), findsOneWidget);
  await tapVisible(tester, find.byKey(const ValueKey('decoder-next')));
  await tester.pump(const Duration(milliseconds: 100));
  expect(find.text('Round 2 / 8'), findsOneWidget);
  // Switching back shows the untouched browse deck.
  await tapVisible(tester, find.text('Decode cards'));
  await tester.pump(const Duration(milliseconds: 100));
  expect(find.text('0 / 16 decoded'), findsOneWidget);
}

/// Toggle into "Test yourself" mode and wait for round 1.
Future<void> enterQuiz(WidgetTester tester) async {
  await tapVisible(tester, find.text('Test yourself'));
  await tester.pump(const Duration(milliseconds: 100));
  await scrollTo(tester, find.byKey(const ValueKey('decoder-prompt')));
  expect(find.text('Round 1 / 8'), findsOneWidget);
}

void main() {
  test('every decoder term exists in the glossary', () {
    for (final t in decoderTerms) {
      expect(findTerm(t), isNotNull, reason: t);
    }
  });

  testWidgets('s2_decoder: flipping a card and "flip all" update the counter', (tester) async {
    await pumpApp(tester, home: const S2DecoderScreen());
    await tapVisible(tester, find.byKey(const ValueKey('decoder-0')));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('going to school'), findsOneWidget);
    expect(find.text('1 / 16 decoded'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('decoder-all')));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('16 / 16 decoded'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s2_decoder: Test yourself scores a perfect run 8 / 8', (tester) async {
    await pumpApp(tester, home: const S2DecoderScreen());
    await enterQuiz(tester);
    for (var r = 0; r < 8; r++) {
      await scrollTo(tester, find.byKey(const ValueKey('decoder-prompt')));
      await tapVisible(tester, find.text(answerTerm(tester)));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Correct!'), findsOneWidget);
      expect(find.text('Score: ${r + 1}'), findsOneWidget);
      await tapVisible(tester, find.byKey(const ValueKey('decoder-next')));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Score: 8 / 8'), findsOneWidget);
    // "Play again" starts a fresh game.
    await tapVisible(tester, find.byKey(const ValueKey('decoder-replay')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Round 1 / 8'), findsOneWidget);
    expect(find.text('Score: 0'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s2_decoder: a wrong pick is marked, locks the choices and costs a point', (tester) async {
    await pumpApp(tester, home: const S2DecoderScreen());
    await enterQuiz(tester);
    final answer = answerTerm(tester);
    final wrong = [0, 1, 2].firstWhere((i) => choiceText(tester, i) != answer);
    await tapVisible(tester, find.byKey(ValueKey('decoder-choice-$wrong')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Not quite'), findsOneWidget);
    expect(find.text('Score: 0'), findsOneWidget);
    // The choices are locked once answered: tapping the right one changes nothing.
    final right = [0, 1, 2].firstWhere((i) => choiceText(tester, i) == answer);
    await tapVisible(tester, find.byKey(ValueKey('decoder-choice-$right')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Correct!'), findsNothing);
    expect(find.text('Not quite'), findsOneWidget);
    // The remaining seven rounds answered correctly: 7 / 8.
    for (var r = 1; r < 8; r++) {
      await tapVisible(tester, find.byKey(const ValueKey('decoder-next')));
      await tester.pump(const Duration(milliseconds: 100));
      await scrollTo(tester, find.byKey(const ValueKey('decoder-prompt')));
      await tapVisible(tester, find.text(answerTerm(tester)));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Correct!'), findsOneWidget);
    }
    await tapVisible(tester, find.byKey(const ValueKey('decoder-next')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Score: 7 / 8'), findsOneWidget);
    expectNoErrors(tester);
  });

  // Note: Bit's speech bubble in the shared bit.dart overflows at 360 dp **and** 1.3 text on every
  // lesson (pre-existing, e.g. s2_guess), so — repo convention — the two stress axes are tested apart.

  testWidgets('s2_decoder: quiz fits a 360 dp phone', (tester) async {
    await pumpApp(tester, home: const S2DecoderScreen(), size: const Size(360, 740));
    await runOneRoundAndGoBack(tester);
    expectNoErrors(tester);
  });

  testWidgets('s2_decoder: no errors at text scale 1.3 in light mode', (tester) async {
    await pumpApp(tester, home: const S2DecoderScreen(), textScale: 1.3, brightness: Brightness.light);
    await runOneRoundAndGoBack(tester);
    expectNoErrors(tester);
  });
}
