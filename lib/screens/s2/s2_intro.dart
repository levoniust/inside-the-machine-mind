import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/bit.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 2 · "School vs the job": training vs inference, as a toggle between Bit studying and Bit working,
/// plus a side-by-side comparison. Facts: TR-LLAMA3-TOKENS, IN-ENERGY-QUERY.
class S2IntroScreen extends StatelessWidget {
  const S2IntroScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's2_intro',
        children: [_SchoolOrJob()],
      );
}

const _rows = [
  ('What happens', 'Reads trillions of words and adjusts its knobs', 'Uses its knobs to answer you'),
  ('The knobs', 'Change billions of times', 'Frozen: they don\'t change'),
  ('How long', 'Months, once', 'Seconds, every time you ask'),
  ('Hardware', 'Thousands of GPUs working together', 'A few GPUs, shared by many people'),
  ('Data', 'A giant library (trillions of tokens)', 'Just your question'),
  ('Cost', 'One enormous bill', 'A tiny cost per answer, times billions'),
];

class _SchoolOrJob extends StatefulWidget {
  const _SchoolOrJob();

  @override
  State<_SchoolOrJob> createState() => _SchoolOrJobState();
}

class _SchoolOrJobState extends State<_SchoolOrJob> with SingleTickerProviderStateMixin {
  bool _school = true;
  late final AnimationController _t = AnimationController(vsync: this, duration: const Duration(seconds: 3));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _t.stop();
    } else if (!_t.isAnimating) {
      _t.repeat();
    }
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<bool>(
                key: const ValueKey('intro-toggle'),
                segments: const [
                  ButtonSegment(value: true, label: Text('School (training)'), icon: Icon(Icons.school_outlined)),
                  ButtonSegment(value: false, label: Text('The job (inference)'), icon: Icon(Icons.work_outline)),
                ],
                selected: {_school},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _school = s.first),
              ),
              const SizedBox(height: Gap.m),
              AspectRatio(
                aspectRatio: 1.6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _t,
                          builder: (_, _) => CustomPaint(painter: _ScenePainter(_school, _t.value, c)),
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0, 0.35),
                        child: BitAvatar(size: 80, mood: _school ? BitMood.think : BitMood.talk),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Gap.m),
              Text(
                _school
                    ? 'At school, Bit reads a mountain of books, guessing each next word and correcting itself, over and over.'
                    : 'On the job, Bit just answers. Nothing new is learned; it uses what it already knows.',
                key: const ValueKey('intro-caption'),
                style: TextStyle(color: c.text, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
        DemoCard(
          title: 'Side by side',
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(flex: 3, child: SizedBox()),
                  Expanded(
                      flex: 4,
                      child: Text('Training', style: TextStyle(color: c.violet, fontWeight: FontWeight.w800))),
                  Expanded(
                      flex: 4,
                      child: Text('Inference', style: TextStyle(color: c.magenta, fontWeight: FontWeight.w800))),
                ],
              ),
              const Divider(),
              for (final (label, train, infer) in _rows)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: Text(label, style: TextStyle(color: c.textDim, fontSize: 13))),
                      Expanded(
                        flex: 4,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: _school ? 1 : 0.45,
                          child: Text(train, style: const TextStyle(fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: Gap.s),
                      Expanded(
                        flex: 4,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: _school ? 0.45 : 1,
                          child: Text(infer, style: const TextStyle(fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
        const Row(
          children: [
            Expanded(child: FactCard(value: '15.6T', label: 'tokens Llama 3 405B read at "school"', factId: 'TR-LLAMA3-TOKENS')),
            SizedBox(width: Gap.m),
            Expanded(child: FactCard(value: '~0.24 Wh', label: 'energy for one typical chatbot answer', comparison: '9 seconds of TV', factId: 'IN-ENERGY-QUERY')),
          ],
        ),
        const SizedBox(height: Gap.s),
        const TermText('From here on, the [[training]] story: how the library is gathered, and how billions of knobs get tuned.'),
      ],
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.school, this.t, this.c);
  final bool school;
  final double t;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = c.surfaceHi);
    final rnd = math.Random(3);
    if (school) {
      // Stacks of books on both sides, pages flying toward Bit.
      for (var s = 0; s < 2; s++) {
        final x0 = s == 0 ? size.width * 0.06 : size.width * 0.74;
        for (var i = 0; i < 9; i++) {
          final col = [c.violet, c.cyan, c.magenta, c.amber, c.lime][(i + s) % 5];
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(x0 + rnd.nextDouble() * 6, size.height * (0.85 - i * 0.085), size.width * 0.2, size.height * 0.07),
                const Radius.circular(3)),
            Paint()..color = col.withValues(alpha: 0.75),
          );
        }
      }
      for (var k = 0; k < 6; k++) {
        final p = (t + k / 6) % 1.0;
        final from = Offset(k.isEven ? size.width * 0.2 : size.width * 0.8, size.height * (0.2 + 0.1 * k % 0.6));
        final to = Offset(size.width / 2, size.height * 0.55);
        final pos = Offset.lerp(from, to, p)!;
        canvas.drawRect(Rect.fromCenter(center: pos, width: 14, height: 10), Paint()..color = Colors.white.withValues(alpha: 1 - p));
      }
    } else {
      // Chat bubbles: a question arrives, an answer leaves.
      final p = t;
      final q = Rect.fromLTWH(size.width * 0.05, size.height * (0.15 + 0.05 * math.sin(p * math.pi * 2)), size.width * 0.32, size.height * 0.18);
      canvas.drawRRect(RRect.fromRectAndRadius(q, const Radius.circular(12)), Paint()..color = c.cyan.withValues(alpha: 0.35));
      final a = Rect.fromLTWH(size.width * 0.63, size.height * (0.2 - 0.05 * math.sin(p * math.pi * 2)), size.width * 0.32, size.height * 0.22);
      canvas.drawRRect(RRect.fromRectAndRadius(a, const Radius.circular(12)), Paint()..color = c.magenta.withValues(alpha: 0.35));
      for (var i = 0; i < 3; i++) {
        final w = (p * 3 - i).clamp(0.0, 1.0);
        canvas.drawLine(Offset(a.left + 10, a.top + 14 + i * 12), Offset(a.left + 10 + (a.width - 20) * w, a.top + 14 + i * 12),
            Paint()
              ..color = Colors.white.withValues(alpha: 0.8)
              ..strokeWidth = 4
              ..strokeCap = StrokeCap.round);
      }
      canvas.drawLine(Offset(q.left + 10, q.top + 18), Offset(q.right - 18, q.top + 18), Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(_ScenePainter old) => old.t != t || old.school != school || old.c != c;
}
