import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/progress.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// A real home rig (anonymized case study of the lab this app was built on): what it runs, what tuning bought,
/// and an honest timeline of what went wrong. Easter egg: tap the GPU fan 7 times.
class LHomeRigScreen extends StatelessWidget {
  const LHomeRigScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
    lessonId: 'l_home_rig',
    children: [
      _Rig(),
      _Tuning(),
      _Timeline(),
      FactCard(
        value: '14 → 21.7 tok/s',
        label: 'from placing experts smartly, a draft head, then faster RAM',
        factId: 'RIG-TUNE',
      ),
      FactCard(
        value: '−15 W',
        label: 'per GPU from an undervolt, at the same speed; overclocking added ~1%',
        factId: 'RIG-OC',
      ),
    ],
  );
}

/// The two machines, drawn; the left GPU's fan is the egg.
class _Rig extends StatefulWidget {
  const _Rig();

  @override
  State<_Rig> createState() => _RigState();
}

class _RigState extends State<_Rig> with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  int _taps = 0;
  bool _egg = false;

  void _tapFan() {
    _taps++;
    if (_taps >= 7 && !_egg) {
      setState(() => _egg = true);
      AppScope.read(context).markEgg('rig');
      if (!MediaQuery.of(context).disableAnimations) _spin.repeat();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(6);
    return DemoCard(
      title: 'The lab this app was built on',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Box(
                  title: 'Workstation',
                  lines: const [
                    '2 × 24 GB GPU (RTX 3090)',
                    '256 GB DDR5 RAM',
                    'big mixture-of-experts model, 8-bit',
                    'experts mostly in RAM',
                  ],
                  color: accent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        key: const ValueKey('rig-fan'),
                        onTap: _tapFan,
                        child: RotationTransition(
                          turns: _spin,
                          child: _Fan(color: _egg ? c.red : accent),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _Fan(color: accent),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: Gap.s),
              Expanded(
                child: _Box(
                  title: 'Small server',
                  lines: const ['1 × 16 GB GPU', '27B-class model', '~55 tokens/s, 96K context'],
                  color: c.cyan,
                  child: _Fan(color: c.cyan),
                ),
              ),
            ],
          ),
          if (_egg) ...[
            const SizedBox(height: Gap.s),
            Container(
              key: const ValueKey('rig-egg'),
              padding: const EdgeInsets.all(Gap.s),
              decoration: BoxDecoration(color: c.red.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: const Text(
                'Whoa, easy! This fan already did a 10-hour shift once. Nobody was watching that night, '
                'which is exactly why the lab now has a watchdog.',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Fan extends StatelessWidget {
  const _Fan({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(size: const Size(44, 44), painter: _FanPainter(color));
}

class _FanPainter extends CustomPainter {
  _FanPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    for (var i = 0; i < 5; i++) {
      final a = i * 2 * math.pi / 5;
      final p = Path()
        ..moveTo(c.dx, c.dy)
        ..quadraticBezierTo(
          c.dx + math.cos(a) * r * 0.9,
          c.dy + math.sin(a) * r * 0.9,
          c.dx + math.cos(a + 0.9) * r * 0.75,
          c.dy + math.sin(a + 0.9) * r * 0.75,
        )
        ..close();
      canvas.drawPath(p, Paint()..color = color.withValues(alpha: 0.7));
    }
    canvas.drawCircle(c, r * 0.18, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_FanPainter old) => old.color != color;
}

class _Box extends StatelessWidget {
  const _Box({required this.title, required this.lines, required this.color, required this.child});
  final String title;
  final List<String> lines;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(Gap.s),
      decoration: BoxDecoration(
        color: c.surfaceHi,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(height: Gap.xs),
          Center(child: child),
          const SizedBox(height: Gap.xs),
          for (final l in lines) Text('· $l', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

/// What each tuning step bought, as measured on the workstation.
class _Tuning extends StatefulWidget {
  const _Tuning();

  @override
  State<_Tuning> createState() => _TuningState();
}

class _TuningState extends State<_Tuning> {
  int _step = 0;
  static const _steps = [
    ('Out of the box', 14.0, 'Most experts in system RAM, defaults everywhere.'),
    (
      'Smarter placement + draft head',
      20.5,
      'A few expert layers moved onto the GPUs, plus a multi-token-prediction draft for speculative decoding.',
    ),
    ('Faster RAM (4,400 → 5,200 MT/s)', 21.7, 'The experts live in RAM, so faster RAM means faster tokens.'),
    (
      'GPU overclock',
      22.0,
      'Barely moves: the GPUs were not the bottleneck. An undervolt instead kept 21.7 with ~15 W less per card.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(6);
    return DemoCard(
      title: 'What tuning bought',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CompareBars(
            items: [for (final s in _steps) BarItem(s.$1, s.$2, display: '${s.$2} tok/s', color: accent)],
            highlight: _step,
          ),
          const SizedBox(height: Gap.s),
          Text(_steps[_step].$3, key: const ValueKey('rig-step-note')),
          const SizedBox(height: Gap.s),
          StepControls(step: _step, count: _steps.length, onStep: (s) => setState(() => _step = s)),
          const SizedBox(height: Gap.xs),
          Text(
            'Lesson: find the real bottleneck first. Here it was system RAM bandwidth, not the GPUs.',
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// What went wrong, honestly: tap an item for what happened and what was learned.
class _Timeline extends StatefulWidget {
  const _Timeline();

  @override
  State<_Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<_Timeline> {
  int? _open;
  static const _items = [
    (
      'The 10-hour burn',
      'A stress test with too much memory overclock hung a GPU. The stuck test kept it at about 397 W and 83 °C '
          'for roughly 10 hours, overnight, until someone noticed the heat.',
      'Every stress test now has a hard time limit and a watchdog '
          'that stops on driver errors or high temperatures. Memory overclock stays well below where it failed.',
    ),
    (
      'Hot memory on the back',
      'At stock settings, one card\'s memory hit 104 °C in about 2.5 minutes of stress while the core read only '
          '75 °C. Half of an RTX 3090\'s memory chips sit on the back, cooled only by the backplate.',
      'Watch memory temperature, '
          'not just the core. Normal AI use runs much cooler than a stress test, but long jobs deserve a fan pointed at the backplate.',
    ),
    (
      'The power cut',
      'A tripped breaker reset the BIOS and quietly switched Secure Boot back on. The NVIDIA driver was then refused '
          'at boot and the GPUs vanished.',
      'Save a BIOS profile with your settings, set "restore power" behaviour, and after any outage '
          'check that the GPUs are still there.',
    ),
    (
      'The real bottleneck',
      'Overclocking the GPUs for an evening bought about 1% more speed.',
      'With a mixture-of-experts model '
          'living in RAM, memory bandwidth decides speed. Measure before you tune.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DemoCard(
      title: 'What went wrong (so you can skip it)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.s),
              child: InkWell(
                key: ValueKey('rig-tl-$i'),
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() => _open = _open == i ? null : i),
                child: Container(
                  padding: const EdgeInsets.all(Gap.s),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: c.amber.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: c.amber, size: 18),
                          const SizedBox(width: Gap.s),
                          Expanded(
                            child: Text(_items[i].$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                          ),
                          Icon(_open == i ? Icons.expand_less : Icons.expand_more, color: c.textDim),
                        ],
                      ),
                      if (_open == i) ...[
                        const SizedBox(height: Gap.xs),
                        Text(_items[i].$2),
                        const SizedBox(height: Gap.xs),
                        Text('Lesson: ${_items[i].$3}', style: TextStyle(color: c.lime)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
