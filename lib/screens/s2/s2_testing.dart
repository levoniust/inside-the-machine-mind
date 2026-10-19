import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Section 2 · Lesson 3: Exams along the way.
/// A slider through training progress drives a live benchmark chart whose scores climb,
/// and a custom-painted curve where an [[emergent ability]] switches on at scale.
/// Facts: TR-KAPLAN, TR-CHINCHILLA, TR-EMERGENT.
class S2TestingScreen extends StatelessWidget {
  const S2TestingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return LessonScaffold(
      lessonId: 's2_testing',
      children: [
        const _BenchmarkDemo(),
        const _EmergentDemo(),
        StatGrid(
          columns: 2,
          children: [
            StatTile(
              label: 'Loss falls smoothly as you scale',
              value: 'power law',
              color: c.violet,
              icon: Icons.trending_down,
            ),
            StatTile(
              label: 'Compute-optimal data',
              value: '20 tokens / parameter',
              color: c.lime,
              icon: Icons.scale,
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: FactCard(
                value: '70B',
                label: 'The [[Chinchilla]] model that beat much larger models',
                comparison: 'trained on 1.4T tokens',
                factId: 'TR-CHINCHILLA',
              ),
            ),
            const SizedBox(width: Gap.m),
            Expanded(
              child: FactCard(
                value: 'emergent',
                label: '[[Emergent abilities|emergent ability]] appear only past a certain scale',
                factId: 'TR-EMERGENT',
              ),
            ),
          ],
        ),
        FactCard(
          value: 'smoothly',
          label: 'Loss falls as a [[scaling law]] power law as you scale [[parameters]], data and [[compute]]',
          comparison: 'Kaplan et al. (2020)',
          factId: 'TR-KAPLAN',
        ),
      ],
    );
  }
}

/// Interactive demo: drag the slider through training progress. Benchmark scores climb
/// (a smooth curve, like the [[scaling law]]), and live numbers update.
class _BenchmarkDemo extends StatefulWidget {
  const _BenchmarkDemo();

  @override
  State<_BenchmarkDemo> createState() => _BenchmarkDemoState();
}

class _BenchmarkDemoState extends State<_BenchmarkDemo> {
  double _progress = 0.0; // 0..1 fraction of training done

  /// Benchmark score for a given progress, in the 0..100 range.
  double _score(double p) => 100 * (1 - math.exp(-3.0 * p));

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(2);
    final score = _score(_progress);
    final trained = _progress * 1.4e12; // tokens, up to 1.4T (Chinchilla's data)
    return DemoCard(
      title: 'Benchmark exams along the way',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Same standardized [[benchmark]] questions every time. As training goes further, the scores climb.',
            style: TextStyle(color: c.textDim),
          ),
          const SizedBox(height: Gap.l),
          LabeledSlider(
            key: const ValueKey('training-progress-slider'),
            label: 'Training progress',
            value: _progress,
            min: 0,
            max: 1,
            divisions: 100,
            color: accent,
            format: (v) => '${(v * 100).round()}%',
            onChanged: (v) => setState(() => _progress = v),
          ),
          const SizedBox(height: Gap.m),
          AspectRatio(
            aspectRatio: 1.4,
            child: Semantics(
              label: 'A chart of benchmark scores rising as training progress increases',
              child: CustomPaint(
                painter: _ScoreCurvePainter(_progress, accent),
              ),
            ),
          ),
          const SizedBox(height: Gap.m),
          StatGrid(
            columns: 2,
            children: [
              StatTile(
                label: 'Benchmark score',
                value: '${score.toStringAsFixed(0)} / 100',
                color: accent,
                icon: Icons.assessment_outlined,
              ),
              StatTile(
                label: 'Data trained on',
                value: humanNumber(trained),
                color: c.cyan,
                icon: Icons.data_object,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreCurvePainter extends CustomPainter {
  _ScoreCurvePainter(this.progress, this.accent);
  final double progress;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const pad = 10.0;
    final plotW = w - pad * 2;
    final plotH = h - pad * 2;
    final origin = Offset(pad, pad);

    // Axes.
    final axis = Paint()
      ..color = accent.withValues(alpha: 0.25)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(origin.dx, h - pad), Offset(w - pad, h - pad), axis);
    canvas.drawLine(Offset(origin.dx, origin.dy), Offset(origin.dx, h - pad), axis);

    // The full curve (faint), so the user sees the shape.
    final fullPath = Path();
    const steps = 60;
    for (var i = 0; i <= steps; i++) {
      final x = i / steps;
      final y = 100 * (1 - math.exp(-3.0 * x));
      final px = origin.dx + x * plotW;
      final py = (h - pad) - (y / 100) * plotH;
      if (i == 0) {
        fullPath.moveTo(px, py);
      } else {
        fullPath.lineTo(px, py);
      }
    }
    canvas.drawPath(fullPath, Paint()
      ..color = accent.withValues(alpha: 0.2)
      ..strokeWidth = 1.5);

    // The part reached so far, drawn brightly.
    final reachedPath = Path();
    for (var i = 0; i <= steps; i++) {
      final x = i / steps;
      if (x > progress) break;
      final y = 100 * (1 - math.exp(-3.0 * x));
      final px = origin.dx + x * plotW;
      final py = (h - pad) - (y / 100) * plotH;
      if (i == 0) {
        reachedPath.moveTo(px, py);
      } else {
        reachedPath.lineTo(px, py);
      }
    }
    canvas.drawPath(reachedPath, Paint()
      ..color = accent
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round);

    // The current point, glowing.
    final y = 100 * (1 - math.exp(-3.0 * progress));
    final px = origin.dx + progress * plotW;
    final py = (h - pad) - (y / 100) * plotH;
    canvas.drawCircle(Offset(px, py), 10,
        Paint()..color = accent.withValues(alpha: 0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawCircle(Offset(px, py), 4, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(_ScoreCurvePainter old) => old.progress != progress;
}

/// Interactive demo: an [[emergent ability]] that switches on at scale.
/// A custom-painted curve with a threshold, plus live numbers that update as the
/// model grows past the threshold.
class _EmergentDemo extends StatefulWidget {
  const _EmergentDemo();

  @override
  State<_EmergentDemo> createState() => _EmergentDemoState();
}

class _EmergentDemoState extends State<_EmergentDemo> {
  double _scale = 0.3; // model size, 0..1

  static const double threshold = 0.6;

  /// Success rate of the [[emergent ability]] at a given scale.
  double _successRate(double s) =>
      s < threshold ? 0.0 : ((s - threshold) / (1.0 - threshold)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(2);
    final unlocked = _scale >= threshold;
    final rate = _successRate(_scale);
    return DemoCard(
      title: 'Something switches on at scale',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Some [[emergent abilities|emergent ability]]—like multi-step arithmetic—stay off until the model grows large enough. Then they turn on.',
            style: TextStyle(color: c.textDim),
          ),
          const SizedBox(height: Gap.l),
          LabeledSlider(
            key: const ValueKey('model-scale-slider'),
            label: 'Model size',
            value: _scale,
            min: 0,
            max: 1,
            divisions: 100,
            color: accent,
            format: (v) => '${(v * 100).round()}%',
            onChanged: (v) => setState(() => _scale = v),
          ),
          const SizedBox(height: Gap.m),
          AspectRatio(
            aspectRatio: 1.4,
            child: Semantics(
              label:
                  'A curve of emergent ability success rate that is zero until the model passes a size threshold, then rises',
              child: CustomPaint(
                painter: _EmergentPainter(_scale, threshold, accent),
              ),
            ),
          ),
          const SizedBox(height: Gap.m),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'Ability success rate',
                  value: unlocked ? '${(rate * 100).round()}%' : '0%',
                  color: unlocked ? accent : c.textDim,
                  icon: Icons.toggle_on,
                ),
              ),
              const SizedBox(width: Gap.m),
              Expanded(
                child: StatTile(
                  label: 'Threshold reached?',
                  value: unlocked ? 'Yes' : 'No',
                  color: unlocked ? accent : c.textDim,
                  icon: Icons.check_circle_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text(
            unlocked
                ? 'At this size the model can suddenly do things it couldn\'t before.'
                : 'Not yet—below the threshold the ability is off.',
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _EmergentPainter extends CustomPainter {
  _EmergentPainter(this.scale, this.threshold, this.accent);
  final double scale;
  final double threshold;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const pad = 10.0;
    final plotW = w - pad * 2;
    final plotH = h - pad * 2;
    final origin = Offset(pad, pad);

    final axis = Paint()
      ..color = accent.withValues(alpha: 0.25)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(origin.dx, h - pad), Offset(w - pad, h - pad), axis);
    canvas.drawLine(Offset(origin.dx, origin.dy), Offset(origin.dx, h - pad), axis);

    // Threshold line.
    final tx = origin.dx + threshold * plotW;
    canvas.drawLine(
      Offset(tx, origin.dy),
      Offset(tx, h - pad),
      Paint()
        ..color = accent.withValues(alpha: 0.4)
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(tx, h - pad), 3, Paint()..color = accent.withValues(alpha: 0.6));

    // The curve: zero up to the threshold, then rising.
    final path = Path();
    const steps = 60;
    for (var i = 0; i <= steps; i++) {
      final x = i / steps;
      final y = x < threshold ? 0.0 : ((x - threshold) / (1.0 - threshold)).clamp(0.0, 1.0);
      final px = origin.dx + x * plotW;
      final py = (h - pad) - y * plotH;
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    canvas.drawPath(path, Paint()
      ..color = accent
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round);

    // The current point.
    final y = scale < threshold ? 0.0 : ((scale - threshold) / (1.0 - threshold)).clamp(0.0, 1.0);
    final px = origin.dx + scale * plotW;
    final py = (h - pad) - y * plotH;
    canvas.drawCircle(Offset(px, py), 10,
        Paint()..color = accent.withValues(alpha: 0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawCircle(Offset(px, py), 4, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(_EmergentPainter old) => old.scale != scale || old.threshold != threshold;
}
