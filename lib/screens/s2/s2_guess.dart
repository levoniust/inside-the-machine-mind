import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 2 · "Step 1: guess the next word". The whole training task: hide the next word, guess it.
/// The user guesses first, then compares an untrained model (random, flat guesses) with a trained one.
/// Probabilities are illustrations (labelled on screen).
class S2GuessScreen extends StatelessWidget {
  const S2GuessScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's2_guess',
        children: [_Game()],
      );
}

class GuessExample {
  const GuessExample(this.context, this.answer, this.trained);
  final String context, answer;
  final Map<String, double> trained;
}

const guessExamples = [
  GuessExample('The sky is', 'blue', {'blue': 0.62, 'clear': 0.14, 'dark': 0.09, 'falling': 0.03, 'green': 0.01, 'tea': 0.002}),
  GuessExample('Once upon a', 'time', {'time': 0.93, 'hill': 0.02, 'star': 0.01, 'blue': 0.005, 'tea': 0.002, 'clear': 0.001}),
  GuessExample('I would like a cup of', 'tea', {'tea': 0.45, 'coffee': 0.38, 'water': 0.08, 'sugar': 0.02, 'blue': 0.001, 'time': 0.001}),
  GuessExample('Two plus two equals', 'four', {'four': 0.84, 'five': 0.06, 'three': 0.03, 'fourteen': 0.02, 'tea': 0.002, 'blue': 0.001}),
];

/// An untrained model's guesses: nearly uniform with random wobble (fixed seed per example).
Map<String, double> untrainedGuesses(GuessExample e) {
  final r = math.Random(e.context.length);
  final raw = {for (final w in e.trained.keys) w: 1 + r.nextDouble() * 0.6};
  final sum = raw.values.fold<double>(0, (a, b) => a + b);
  return {for (final kv in raw.entries) kv.key: kv.value / sum};
}

/// The guess-the-word game. The probability bars grow out from zero whenever the shown
/// distribution changes: revealing the answer, or switching untrained <-> trained.
class _Game extends StatefulWidget {
  const _Game();

  @override
  State<_Game> createState() => _GameState();
}

class _GameState extends State<_Game> with SingleTickerProviderStateMixin {
  int _ex = 0;
  String? _userGuess;
  bool _trained = false;

  late final AnimationController _grow =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 650));

  @override
  void dispose() {
    _grow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final e = guessExamples[_ex];
    final probs = _trained ? e.trained : untrainedGuesses(e);
    final sorted = probs.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final options = e.trained.keys.take(4).toList()..shuffle(math.Random(_ex));
    return DemoCard(
      title: 'Guess the hidden word',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: '${e.context} ', style: TextStyle(color: c.text)),
                TextSpan(
                  text: _userGuess == null ? '_____' : e.answer,
                  style: TextStyle(color: _userGuess == null ? c.textDim : c.lime, fontWeight: FontWeight.w800),
                ),
              ]),
              key: const ValueKey('guess-sentence'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: Gap.m),
          if (_userGuess == null) ...[
            Text('Your guess first:', style: TextStyle(color: c.textDim)),
            const SizedBox(height: Gap.xs),
            Wrap(
              spacing: Gap.s,
              runSpacing: Gap.s,
              children: [
                for (final o in options)
                  ActionChip(
                    key: ValueKey('guess-$o'),
                    label: Text(o),
                    onPressed: () {
                      setState(() => _userGuess = o);
                      _grow.forward(from: 0);
                    },
                  ),
              ],
            ),
          ] else ...[
            Text(
              _userGuess == e.answer ? 'You got it! Your brain is a trained model too.' : 'The hidden word was "${e.answer}".',
              key: const ValueKey('guess-result'),
              style: TextStyle(color: _userGuess == e.answer ? c.lime : c.amber, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: Gap.m),
            SegmentedButton<bool>(
              key: const ValueKey('guess-model'),
              segments: const [
                ButtonSegment(value: false, label: Text('Untrained model')),
                ButtonSegment(value: true, label: Text('Trained model')),
              ],
              selected: {_trained},
              showSelectedIcon: false,
              onSelectionChanged: (s) {
                setState(() => _trained = s.first);
                _grow.forward(from: 0);
              },
            ),
            const SizedBox(height: Gap.m),
            AnimatedBuilder(
              animation: _grow,
              builder: (context, _) => _GrowBars(
                key: const ValueKey('guess-bars'),
                items: sorted,
                answer: e.answer,
                grow: Curves.easeOutCubic.transform(_grow.value),
              ),
            ),
            const SizedBox(height: Gap.s),
            Text(
              _trained
                  ? 'After training, the model puts most of its chance on sensible words.'
                  : 'Before training, every word looks about equally likely: pure guesswork.',
              key: const ValueKey('guess-caption'),
              style: TextStyle(color: c.text),
            ),
            Text('Illustration: made-up but realistic-looking probabilities.', style: TextStyle(color: c.textDim, fontSize: 11)),
            const SizedBox(height: Gap.s),
            Center(
              child: OutlinedButton.icon(
                key: const ValueKey('guess-next'),
                onPressed: () => setState(() {
                  _ex = (_ex + 1) % guessExamples.length;
                  _userGuess = null;
                  _trained = false;
                }),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Another sentence'),
              ),
            ),
          ],
          const SizedBox(height: Gap.m),
          const TermText(
            'That\'s the entire training task: hide the next [[token]], let the model guess, check the answer. The '
            'model\'s guess is a [[forward pass]], and its output is a chance for every word in its [[vocabulary]].',
          ),
        ],
      ),
    );
  }
}

/// The guess chart. Drawn here instead of with the shared [CompareBars] because the bars must
/// grow out from zero: CompareBars renormalises to the maximum value currently shown, so
/// scaling every value by a grow factor would change nothing. This scales widths *and* the
/// printed percentages by the grow factor while normalising against the target maximum, so the
/// bars stretch out from the left edge and the numbers count up with them. Same look as
/// CompareBars: label row with a mono percentage over a 10 dp rounded track, glow on the answer.
class _GrowBars extends StatelessWidget {
  const _GrowBars({super.key, required this.items, required this.answer, required this.grow});
  final List<MapEntry<String, double>> items;
  final String answer;

  /// 0 = collapsed to zero width, 1 = the real probabilities.
  final double grow;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final maxV = items.fold<double>(0, (a, b) => math.max(a, b.value));
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(items[i].key,
                            style: TextStyle(
                                fontWeight: items[i].key == answer ? FontWeight.w800 : FontWeight.w500,
                                color: items[i].key == answer ? c.text : c.textDim))),
                    Text('${(items[i].value * 100 * grow).toStringAsFixed(1)}%',
                        style: AppText.mono.copyWith(fontSize: 13, color: c.text)),
                  ],
                ),
                const SizedBox(height: 4),
                LayoutBuilder(
                  builder: (context, box) {
                    final hi = items[i].key == answer;
                    final frac = maxV == 0 ? 0.0 : (items[i].value / maxV).clamp(0.02, 1.0);
                    return Stack(
                      children: [
                        Container(height: 10, decoration: BoxDecoration(color: c.surfaceHi, borderRadius: BorderRadius.circular(5))),
                        Container(
                          key: ValueKey('guess-bar-${items[i].key}'),
                          height: 10,
                          width: box.maxWidth * frac * grow,
                          decoration: BoxDecoration(
                            color: c.violet,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: hi ? [BoxShadow(color: c.violet.withValues(alpha: 0.5), blurRadius: 10)] : null,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}
