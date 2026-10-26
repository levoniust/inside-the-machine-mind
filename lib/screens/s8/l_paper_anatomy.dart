import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// How to read a paper: a page drawn with its parts (tap for what each is for and how long to spend), the three-pass
/// method, and red flags in results tables.
class LPaperAnatomyScreen extends StatelessWidget {
  const LPaperAnatomyScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const LessonScaffold(lessonId: 'l_paper_anatomy', children: [_Anatomy(), _ThreePasses(), _RedFlags()]);
}

class _Part {
  const _Part(this.name, this.what, this.time, this.flex, {this.figure = false});
  final String name, what, time;
  final int flex;
  final bool figure;
}

const _parts = [
  _Part(
    'Title & authors',
    'Which lab, which year. A paper from the team that built the tool you use carries inside knowledge.',
    'seconds',
    1,
  ),
  _Part('Abstract', 'The whole paper in one paragraph: problem, idea, headline result. Read it twice.', '1 minute', 2),
  _Part(
    'Figure 1',
    'Authors put their best picture first. Often it explains the idea better than the text.',
    '2 minutes',
    3,
    figure: true,
  ),
  _Part(
    'Introduction',
    'Why the problem matters and what was tried before. The last paragraph lists the contributions: read that.',
    '5 minutes',
    3,
  ),
  _Part('Method', 'How it works. Hobbyists can read the words and skip the equations on the first pass.', 'pass 2', 4),
  _Part(
    'Experiments & tables',
    'The proof. Check what they compared against and on which benchmarks.',
    'pass 2',
    3,
    figure: true,
  ),
  _Part('Related work', 'A map of the field. Skip it unless you want more papers to read.', 'skip', 1),
  _Part('Conclusion & limitations', 'What they admit does not work yet. Often the most honest part.', '2 minutes', 2),
  _Part('References & appendix', 'Details, proofs, extra results. Only when you need them.', 'skip', 2),
];

class _Anatomy extends StatefulWidget {
  const _Anatomy();

  @override
  State<_Anatomy> createState() => _AnatomyState();
}

class _AnatomyState extends State<_Anatomy> {
  int _sel = 1;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(8);
    final p = _parts[_sel];
    return DemoCard(
      title: 'Tap a part of the paper',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The page
          Container(
            width: 120,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: c.surfaceHi,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: c.line),
            ),
            child: Column(
              children: [
                for (var i = 0; i < _parts.length; i++)
                  GestureDetector(
                    key: ValueKey('anat-$i'),
                    onTap: () => setState(() => _sel = i),
                    child: Container(
                      height: 9.0 * _parts[i].flex + 6,
                      margin: const EdgeInsets.only(bottom: 3),
                      decoration: BoxDecoration(
                        color: i == _sel
                            ? accent.withValues(alpha: 0.45)
                            : _parts[i].figure
                            ? c.line.withValues(alpha: 0.5)
                            : null,
                        border: Border.all(color: i == _sel ? accent : c.line),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: _parts[i].figure
                          ? null
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                for (var l = 0; l < _parts[i].flex; l++)
                                  Container(
                                    height: 2,
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    color: c.line,
                                  ),
                              ],
                            ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: Gap.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  key: const ValueKey('anat-name'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: accent),
                ),
                const SizedBox(height: Gap.xs),
                Text(p.what),
                const SizedBox(height: Gap.s),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Gap.s, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accent),
                  ),
                  child: Text('time: ${p.time}', style: AppText.mono.copyWith(fontSize: 12, color: accent)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreePasses extends StatefulWidget {
  const _ThreePasses();

  @override
  State<_ThreePasses> createState() => _ThreePassesState();
}

class _ThreePassesState extends State<_ThreePasses> {
  int _pass = 0;
  static const _passes = [
    (
      'Pass 1 · skim (10 minutes)',
      'Title, abstract, figures and their captions, the contributions paragraph, the conclusion. '
          'Afterwards you should be able to say the one idea in a sentence. For most papers, that is enough.',
    ),
    (
      'Pass 2 · read (an hour)',
      'Method and experiments in order, skipping proofs. Note what they compared against and what '
          'they did not test. Look up the terms you do not know (the app\'s glossary helps).',
    ),
    (
      'Pass 3 · go deep (an evening)',
      'Work through the maths, the appendix, maybe the code. Only for the few papers you want '
          'to really understand or build on.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DemoCard(
      title: 'Three passes, not one',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<int>(
            key: const ValueKey('anat-pass'),
            segments: const [
              ButtonSegment(value: 0, label: Text('Skim')),
              ButtonSegment(value: 1, label: Text('Read')),
              ButtonSegment(value: 2, label: Text('Deep')),
            ],
            selected: {_pass},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _pass = s.first),
          ),
          const SizedBox(height: Gap.s),
          Text(
            _passes[_pass].$1,
            style: TextStyle(fontWeight: FontWeight.w800, color: c.section(8)),
          ),
          const SizedBox(height: Gap.xs),
          Text(_passes[_pass].$2, key: const ValueKey('anat-pass-text')),
        ],
      ),
    );
  }
}

class _RedFlags extends StatelessWidget {
  const _RedFlags();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    const flags = [
      ('Weak baselines', 'Beating an old or badly tuned competitor proves little. Who did they compare against?'),
      ('No error bars', 'A 0.5-point win from a single run may just be luck.'),
      ('Cherry-picked examples', 'Three perfect example outputs say nothing about the thousand they did not show.'),
      (
        'Benchmark leakage',
        'If test questions were on the internet, the model may have seen the answers during training.',
      ),
      ('"State of the art" on one benchmark', 'Look for wins across several tests, not one.'),
    ];
    return DemoCard(
      title: 'Red flags in results tables',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (t, d) in flags)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.flag_outlined, size: 18, color: c.red),
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
        ],
      ),
    );
  }
}
