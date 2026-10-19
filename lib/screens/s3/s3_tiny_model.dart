import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/toy_transformer.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 3 · "A tiny model, step by step".
/// Walks a real (toy-sized) transformer forward pass for "why is the sky" → "blue":
/// tokens → embeddings → attention → mixing → feed-forward → scores → probabilities.
class S3TinyModelScreen extends StatelessWidget {
  const S3TinyModelScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's3_tiny_model',
        children: [_Walkthrough(), _ScaleNote()],
      );
}

class _Step {
  const _Step(this.title, this.caption);
  final String title;
  final String caption;
}

const _steps = [
  _Step('1 · Tokens', 'The question is chopped into [[tokens|token]]. Each gets an ID number from the model\'s [[vocabulary]].'),
  _Step('2 · Embeddings', 'Each token is looked up as a list of numbers: its [[embedding]] ("address on a map of meaning"). Real models use thousands of numbers; ours uses 4.'),
  _Step('3 · Attention', 'Every token asks "which earlier words matter to me?" Brighter = listens more. Look at the last row: what "sky" pays [[attention]] to.'),
  _Step('4 · Mixing', 'Each token\'s numbers are blended with the words it listened to, so "sky" now carries a hint of "why" and "the".'),
  _Step('5 · Feed-forward', 'The [[feed-forward layer]] transforms the result using learned knowledge. Neurons that don\'t fire (negative) are switched off (shown dim).'),
  _Step('6 · Scores', 'The final numbers are turned into one raw score for every word in the vocabulary: the [[logits]].'),
  _Step('7 · Probabilities', '[[Softmax]] turns the scores into chances that add up to 100%. The model would most likely say…'),
];

class _Walkthrough extends StatefulWidget {
  const _Walkthrough();

  @override
  State<_Walkthrough> createState() => _WalkthroughState();
}

class _WalkthroughState extends State<_Walkthrough> {
  final model = ToyTransformer();
  late final ToyRun run = model.run();
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final s = _steps[_step];
    return DemoCard(
      title: 'Inside one prediction',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final t in run.tokens) _chip(context, t, c.magenta),
              _chip(context, '?', c.textDim, dashed: true),
            ],
          ),
          const SizedBox(height: Gap.l),
          Text(s.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: c.magenta, fontWeight: FontWeight.w800)),
          const SizedBox(height: Gap.xs),
          TermText(s.caption, key: ValueKey('tiny-caption-$_step')),
          const SizedBox(height: Gap.l),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: KeyedSubtree(key: ValueKey(_step), child: _body(context)),
          ),
          const SizedBox(height: Gap.l),
          StepControls(
            key: const ValueKey('tiny-steps'),
            step: _step,
            count: _steps.length,
            onStep: (i) => setState(() => _step = i),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String t, Color color, {bool dashed = false}) {
    final c = AppColors.of(context);
    final id = model.tokenId(t);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: dashed ? Colors.transparent : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t, style: TextStyle(color: c.text, fontWeight: FontWeight.w700)),
          if (_step == 0 && id >= 0) Text('#$id', style: AppText.mono.copyWith(fontSize: 11, color: color)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    final c = AppColors.of(context);
    switch (_step) {
      case 0:
        return Text('Vocabulary of this toy: ${ToyTransformer.vocab.length} words. Llama 3 knows about 128,000 tokens.',
            style: TextStyle(color: c.textDim));
      case 1:
        return _Matrix(rows: run.tokens, values: run.embeddings, color: c.magenta);
      case 2:
        return _AttentionGrid(tokens: run.tokens, attn: run.attention);
      case 3:
        return _Matrix(rows: run.tokens, values: run.mixed, color: c.violet);
      case 4:
        return _Matrix(rows: const ['sky'], values: [run.ffHidden.last], color: c.cyan, dimNonPositive: true);
      case 5:
        final entries = run.logits.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        final lo = entries.map((e) => e.value).reduce(math.min);
        return CompareBars(
          color: c.amber,
          items: [for (final e in entries) BarItem(e.key, e.value - lo + 0.05, display: e.value.toStringAsFixed(2))],
        );
      default:
        final probs = run.probabilities();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CompareBars(
              highlight: 0,
              color: c.magenta,
              items: [
                for (final e in probs.take(6)) BarItem(e.key, e.value, display: '${(e.value * 100).toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: Gap.m),
            Center(
              child: Text('“why is the sky ${probs.first.key}”',
                  key: const ValueKey('tiny-answer'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: c.magenta, fontStyle: FontStyle.italic)),
            ),
          ],
        );
    }
  }
}

/// A grid of numbers coloured by sign and size (positive = accent, negative = red).
class _Matrix extends StatelessWidget {
  const _Matrix({required this.rows, required this.values, required this.color, this.dimNonPositive = false});
  final List<String> rows;
  final List<List<double>> values;
  final Color color;
  final bool dimNonPositive;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final maxAbs = values.expand((r) => r).fold<double>(0.01, (m, v) => math.max(m, v.abs()));
    return Semantics(
      label: 'Table of numbers, one row per token',
      child: Column(
        children: [
          for (var r = 0; r < rows.length; r++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  SizedBox(width: 44, child: Text(rows[r], style: TextStyle(color: c.textDim, fontSize: 13))),
                  for (final v in values[r])
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: (dimNonPositive && v <= 0)
                              ? c.surfaceHi
                              : (v >= 0 ? color : c.red).withValues(alpha: 0.15 + 0.6 * (v.abs() / maxAbs)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: FittedBox(
                          child: Text(v.toStringAsFixed(2),
                              style: AppText.mono.copyWith(fontSize: 12, color: (dimNonPositive && v <= 0) ? c.textDim : c.text)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AttentionGrid extends StatelessWidget {
  const _AttentionGrid({required this.tokens, required this.attn});
  final List<String> tokens;
  final List<List<double>> attn;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Semantics(
      label: 'Attention grid: how much each word listens to each earlier word',
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 44),
              for (final t in tokens)
                Expanded(child: Center(child: Text(t, style: TextStyle(color: c.textDim, fontSize: 12)))),
            ],
          ),
          const SizedBox(height: 4),
          for (var i = 0; i < tokens.length; i++)
            Row(
              children: [
                SizedBox(
                    width: 44,
                    child: Text(tokens[i],
                        style: TextStyle(
                            color: i == tokens.length - 1 ? c.magenta : c.textDim,
                            fontWeight: i == tokens.length - 1 ? FontWeight.w800 : FontWeight.w400,
                            fontSize: 13))),
                for (var j = 0; j < tokens.length; j++)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: j > i ? c.surface : c.magenta.withValues(alpha: 0.1 + 0.85 * attn[i][j]),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: i == tokens.length - 1 ? c.magenta.withValues(alpha: 0.6) : c.line),
                      ),
                      child: Text(j > i ? '–' : '${(attn[i][j] * 100).round()}%',
                          style: AppText.mono.copyWith(fontSize: 11, color: j > i ? c.textDim : c.text)),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: Gap.s),
          Text('Rows add up to 100%. "–" = a word can\'t peek at words that come after it.',
              style: TextStyle(color: c.textDim, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ScaleNote extends StatelessWidget {
  const _ScaleNote();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DemoCard(
      title: 'Now imagine it big',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CompareBars(
            log: true,
            color: c.magenta,
            items: [
              BarItem('Numbers per token: this toy', 4, display: '4'),
              BarItem('Numbers per token: Llama 3 405B', 16384, display: '16,384'),
              BarItem('Layers: this toy', 1, display: '1'),
              BarItem('Layers: Llama 3 405B', 126, display: '126'),
            ],
          ),
          const SizedBox(height: Gap.m),
          const TermText(
            'A real model repeats steps 3–5 in every [[layer]] (126 times in Llama 3 405B), with 128 attention '
            '"heads" looking for different kinds of clues at once. The math is the same as here, just vastly bigger.',
          ),
          const SizedBox(height: Gap.s),
          const FactCard(value: '~810 billion', label: 'math steps per token for a 405B-parameter model (2 × parameters)', factId: 'HW-MATMUL-PER-TOKEN'),
        ],
      ),
    );
  }
}
