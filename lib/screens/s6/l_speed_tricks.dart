import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Guess ahead, check fast: speculative decoding rounds (draft guesses, big model checks in one pass), and the
/// paper's formula for how many tokens each pass yields and the real speed-up.
class LSpeedTricksScreen extends StatelessWidget {
  const LSpeedTricksScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
    lessonId: 'l_speed_tricks',
    children: [
      _Rounds(),
      _Formula(),
      FactCard(
        value: '2-3×',
        label: 'faster on T5-XXL with a draft model, with identical outputs',
        factId: 'RUN-SPEC-T5',
      ),
      FactCard(
        value: '85-90%',
        label: 'of DeepSeek-V3\'s extra "next-but-one" guesses (MTP) are accepted: about 1.8× the tokens per second',
        factId: 'RUN-MTP-DSV3',
      ),
      FactCard(
        value: '> 2.2×',
        label: 'Medusa: guessing heads built into the model itself, no separate draft model',
        factId: 'RUN-MEDUSA',
      ),
    ],
  );
}

enum _Mark { draft, ok, rejected, fixed }

/// Animated rounds: the draft writes 4 grey tokens; the big model accepts a prefix (green), rejects the first wrong one
/// (red) and adds its own token (blue). Outputs are exactly what the big model alone would have written.
class _Rounds extends StatefulWidget {
  const _Rounds();

  @override
  State<_Rounds> createState() => _RoundsState();
}

class _RoundsState extends State<_Rounds> {
  static const _text = [
    'The',
    'sky',
    'looks',
    'blue',
    'because',
    'air',
    'scatters',
    'blue',
    'light',
    'more',
    'than',
    'red',
    'light',
    ',',
    'so',
    'blue',
    'reaches',
    'your',
    'eyes',
    'from',
    'every',
    'direction',
    '.',
  ];
  static const _gamma = 4;
  final _rng = math.Random(3);
  final List<(String, _Mark)> _out = [];
  int _passes = 0;
  double _alpha = 0.7;

  void _round() {
    if (_done) return;
    final start = _out.where((t) => t.$2 != _Mark.rejected).length;
    var accepted = 0;
    while (accepted < _gamma && start + accepted < _text.length && _rng.nextDouble() < _alpha) {
      accepted++;
    }
    setState(() {
      for (var i = 0; i < accepted; i++) {
        _out.add((_text[start + i], _Mark.ok));
      }
      final next = start + accepted;
      if (accepted < _gamma && next < _text.length) {
        _out.add(('???', _Mark.rejected));
      }
      // The big model's own token comes free with the check.
      if (next < _text.length) {
        _out.add((_text[next], _Mark.fixed));
      }
      _passes++;
    });
  }

  bool get _done => _out.where((t) => t.$2 != _Mark.rejected).length >= _text.length;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(6);
    final produced = _out.where((t) => t.$2 != _Mark.rejected).length;
    Color col(_Mark m) => switch (m) {
      _Mark.ok => c.lime,
      _Mark.rejected => c.red,
      _Mark.fixed => c.cyan,
      _Mark.draft => c.textDim,
    };
    return DemoCard(
      title: 'A small model guesses, the big one checks',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 90),
            padding: const EdgeInsets.all(Gap.s),
            decoration: BoxDecoration(color: c.surfaceHi, borderRadius: BorderRadius.circular(8)),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final (w, m) in _out)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: col(m).withValues(alpha: 0.18),
                      border: Border.all(color: col(m)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      w,
                      style: AppText.mono.copyWith(
                        fontSize: 12,
                        decoration: m == _Mark.rejected ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Gap.s),
          Wrap(
            spacing: Gap.m,
            children: [
              _Key(color: c.lime, text: 'draft guess accepted'),
              _Key(color: c.red, text: 'rejected'),
              _Key(color: c.cyan, text: 'big model\'s own token'),
            ],
          ),
          const SizedBox(height: Gap.s),
          LabeledSlider(
            key: const ValueKey('spec-alpha'),
            label: 'How often the draft guesses right',
            value: _alpha,
            min: 0.3,
            max: 0.95,
            divisions: 13,
            format: (v) => '${(v * 100).round()}%',
            color: accent,
            onChanged: (v) => setState(() => _alpha = v),
          ),
          Text(
            '$produced tokens in $_passes big-model passes'
            '${_passes == 0 ? '' : ' = ${(produced / _passes).toStringAsFixed(1)} per pass (1.0 without the trick)'}',
            key: const ValueKey('spec-count'),
            style: AppText.mono.copyWith(color: accent),
          ),
          const SizedBox(height: Gap.s),
          Wrap(
            spacing: Gap.s,
            children: [
              FilledButton.icon(
                key: const ValueKey('spec-round'),
                style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: c.bg),
                onPressed: _done ? null : _round,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Run a round'),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _out.clear();
                  _passes = 0;
                }),
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.color, required this.text});
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
      ),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(fontSize: 12, color: AppColors.of(context).textDim)),
    ],
  );
}

/// The paper's formula: tokens per pass E = (1 − α^(γ+1)) / (1 − α); speed-up = E / (γ·c + 1).
class _Formula extends StatefulWidget {
  const _Formula();

  @override
  State<_Formula> createState() => _FormulaState();
}

class _FormulaState extends State<_Formula> {
  double _alpha = 0.8, _gamma = 4, _c = 0.05;

  static double tokensPerPass(double a, int g) => (1 - math.pow(a, g + 1)) / (1 - a);

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(6);
    final g = _gamma.round();
    final e = tokensPerPass(_alpha, g);
    final speed = e / (g * _c + 1);
    return DemoCard(
      title: 'The math from the paper',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledSlider(
            label: 'Acceptance rate α',
            value: _alpha,
            min: 0.3,
            max: 0.95,
            divisions: 13,
            format: (v) => '${(v * 100).round()}%',
            color: accent,
            onChanged: (v) => setState(() => _alpha = v),
          ),
          LabeledSlider(
            key: const ValueKey('spec-gamma'),
            label: 'Tokens drafted per round γ',
            value: _gamma,
            min: 1,
            max: 8,
            divisions: 7,
            format: (v) => '${v.round()}',
            color: accent,
            onChanged: (v) => setState(() => _gamma = v),
          ),
          LabeledSlider(
            label: 'Draft cost vs big model c',
            value: _c,
            min: 0,
            max: 0.3,
            divisions: 6,
            format: (v) => v == 0 ? '0 (built-in heads)' : '${(v * 100).round()}%',
            color: accent,
            onChanged: (v) => setState(() => _c = v),
          ),
          const SizedBox(height: Gap.s),
          StatGrid(
            columns: 2,
            children: [
              StatTile(
                key: const ValueKey('spec-e'),
                label: 'Tokens per big pass',
                value: e.toStringAsFixed(2),
                color: accent,
              ),
              StatTile(
                key: const ValueKey('spec-speed'),
                label: 'Speed-up',
                value: '${speed.toStringAsFixed(2)}×',
                color: c.cyan,
              ),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text(
            'E = (1 − α^(γ+1)) ÷ (1 − α)     speed-up = E ÷ (γ·c + 1)',
            style: AppText.mono.copyWith(fontSize: 12, color: c.textDim),
          ),
          const SizedBox(height: Gap.xs),
          Text(
            'Drafting more tokens only pays off when the guesses are usually right and the draft is cheap. '
            'MTP and Medusa make the draft nearly free by building it into the model.',
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
