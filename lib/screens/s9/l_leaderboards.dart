import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Reading the leaderboards: a made-up arena-style ranking with uncertainty ranges, and the traps behind the numbers.
class LLeaderboardsScreen extends StatelessWidget {
  const LLeaderboardsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const LessonScaffold(lessonId: 'l_leaderboards', children: [_Board(), _Traps()]);
}

// Made-up models and scores, to show how uncertainty ranges overlap (not real results).
const _rows = [
  ('Model A', 1412, 9),
  ('Model B', 1408, 7),
  ('Model C', 1401, 11),
  ('Model D', 1377, 8),
  ('Model E', 1350, 6),
];

class _Board extends StatefulWidget {
  const _Board();

  @override
  State<_Board> createState() => _BoardState();
}

class _BoardState extends State<_Board> {
  bool _ranges = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(9);
    const lo = 1330.0, hi = 1430.0;
    return DemoCard(
      title: 'A made-up arena leaderboard',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _rows.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.s),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${i + 1}',
                      style: AppText.mono.copyWith(fontWeight: FontWeight.w800, color: accent),
                    ),
                  ),
                  SizedBox(width: 72, child: Text(_rows[i].$1)),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, box) {
                        double x(num v) => (v - lo) / (hi - lo) * box.maxWidth;
                        final (_, score, err) = _rows[i];
                        return SizedBox(
                          height: 20,
                          child: Stack(
                            children: [
                              if (_ranges)
                                Positioned(
                                  left: x(score - err),
                                  width: x(score + err) - x(score - err),
                                  top: 6,
                                  height: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: accent.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              Positioned(
                                left: x(score) - 5,
                                top: 5,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text(
                      '${_rows[i].$2}',
                      textAlign: TextAlign.right,
                      style: AppText.mono.copyWith(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          SwitchListTile(
            key: const ValueKey('lb-ranges'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Show the uncertainty'),
            value: _ranges,
            onChanged: (v) => setState(() => _ranges = v),
          ),
          Text(
            _ranges
                ? 'Models A, B and C overlap: with this many votes, nobody can say which of them is really best. They are tied, '
                      'whatever the order says.'
                : 'Looks like a clear winner. Arena scores come from people voting between two answers; switch on the uncertainty.',
            key: const ValueKey('lb-note'),
          ),
        ],
      ),
    );
  }
}

class _Traps extends StatelessWidget {
  const _Traps();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    const traps = [
      (
        'Contamination',
        'If a test\'s questions were on the internet, a model may have seen them in training: it remembers instead of reasons.',
      ),
      (
        'Saturation',
        'When the top models all score near 100%, a test can no longer tell them apart. New, harder tests replace it.',
      ),
      (
        'Style over substance',
        'In human votes, longer, confident, nicely formatted answers tend to win, even when they are not more correct.',
      ),
      (
        'Self-reported numbers',
        'Scores in a launch post are measured by the maker, with their own settings. Independent re-tests often differ.',
      ),
      (
        'One number for everything',
        'A model can lead at coding and trail at writing. Check the test that matches what you need.',
      ),
    ];
    return DemoCard(
      title: 'Five traps',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (t, d) in traps)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 18, color: c.amber),
                  const SizedBox(width: Gap.s),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$t. ',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: d),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Text(
            'Best test of all: try your own real tasks on the two or three models that look best.',
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
