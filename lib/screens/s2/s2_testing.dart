import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 2 · "Exams along the way" (benchmarks, held-out data, emergent abilities).
/// Charts are illustrations of typical shapes (labelled on screen); the cited facts are TR-EMERGENT and TR-KAPLAN.
class S2TestingScreen extends StatelessWidget {
  const S2TestingScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's2_testing',
        children: [_HeldOut(), _Emergence()],
      );
}

/// Practice loss keeps falling; held-out (never-seen) loss falls too, unless the model starts memorizing.
class _HeldOut extends StatefulWidget {
  const _HeldOut();

  @override
  State<_HeldOut> createState() => _HeldOutState();
}

class _HeldOutState extends State<_HeldOut> {
  double _progress = 0.6;
  bool _repeat = false;

  static double practice(double x) => 0.25 + 0.75 * math.exp(-4 * x);
  static double heldOut(double x, bool repeat) {
    final base = 0.3 + 0.7 * math.exp(-3.6 * x);
    return repeat ? base + 0.5 * math.max(0, x - 0.45) * math.max(0, x - 0.45) * 4 : base;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final gap = heldOut(_progress, _repeat) - practice(_progress);
    final memorizing = _repeat && _progress > 0.55;
    return DemoCard(
      title: 'Practice questions vs the real exam',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TermText(
            'Engineers keep some text aside that the model never trains on: the "held-out" exam. If the model only '
            'memorized its practice pages, it would ace practice and fail the exam.',
            style: TextStyle(color: c.textDim),
          ),
          const SizedBox(height: Gap.m),
          AspectRatio(
            aspectRatio: 1.6,
            child: Semantics(
              label: 'Chart of practice loss and exam loss over training',
              child: CustomPaint(painter: _CurvesPainter(_progress, _repeat, c)),
            ),
          ),
          const SizedBox(height: Gap.xs),
          Wrap(
            spacing: Gap.l,
            children: [
              _legend(c.violet, 'practice (training data)'),
              _legend(c.amber, 'exam (held-out data)'),
            ],
          ),
          Text('Illustration: typical shapes, not real measurements.', style: TextStyle(color: c.textDim, fontSize: 11)),
          LabeledSlider(
            key: const ValueKey('testing-progress'),
            label: 'Training progress',
            value: _progress,
            min: 0,
            max: 1,
            color: c.violet,
            format: (v) => '${(v * 100).round()}%',
            onChanged: (v) => setState(() => _progress = v),
          ),
          SwitchListTile(
            key: const ValueKey('testing-repeat'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Show it the same small library over and over'),
            value: _repeat,
            activeThumbColor: c.violet,
            onChanged: (v) => setState(() => _repeat = v),
          ),
          Text(
            memorizing
                ? 'Uh-oh: practice keeps improving but the exam gets worse. The model is memorizing instead of learning. '
                    'This is why huge, varied datasets matter.'
                : (gap < 0.12 ? 'Practice and exam improve together: the model is learning patterns, not pages.' : 'Both still improving.'),
            key: const ValueKey('testing-verdict'),
            style: TextStyle(color: memorizing ? c.red : c.lime, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _legend(Color col, String label) => Text.rich(TextSpan(children: [
        WidgetSpan(alignment: PlaceholderAlignment.middle, child: Container(width: 14, height: 4, color: col)),
        TextSpan(text: '  $label', style: const TextStyle(fontSize: 12)),
      ]));
}

class _CurvesPainter extends CustomPainter {
  _CurvesPainter(this.progress, this.repeat, this.c);
  final double progress;
  final bool repeat;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final axis = Paint()
      ..color = c.line
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), axis);
    canvas.drawLine(Offset.zero, Offset(0, size.height), axis);
    Path curve(double Function(double) f) {
      final p = Path();
      for (var i = 0; i <= 100; i++) {
        final x = i / 100 * progress;
        final pt = Offset(x * size.width, size.height - f(x).clamp(0.0, 1.2) / 1.2 * size.height * 0.95);
        i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
      }
      return p;
    }

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(curve(_HeldOutState.practice), line..color = c.violet);
    canvas.drawPath(curve((x) => _HeldOutState.heldOut(x, repeat)), line..color = c.amber);
    final tp = TextPainter(
      text: TextSpan(text: 'loss (lower is better)', style: TextStyle(fontFamily: 'Roboto', fontSize: 10, color: c.textDim)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, const Offset(6, 2));
  }

  @override
  bool shouldRepaint(_CurvesPainter old) => old.progress != progress || old.repeat != repeat || old.c != c;
}

/// Emergence: smooth improvement in next-word loss vs a skill that seems to switch on past a size.
class _Emergence extends StatefulWidget {
  const _Emergence();

  @override
  State<_Emergence> createState() => _EmergenceState();
}

class _EmergenceState extends State<_Emergence> {
  double _size = 0.3; // 0..1 on a log scale of model size

  static double smooth(double x) => 0.15 + 0.8 * x; // general skill grows steadily
  static double sudden(double x) => 0.95 / (1 + math.exp(-22 * (x - 0.62))); // near zero, then a jump

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final on = sudden(_size) > 0.5;
    return DemoCard(
      title: 'Skills that seem to switch on',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1.6,
            child: Semantics(
              label: 'Chart: a smooth skill curve and a sudden skill curve over model size',
              child: CustomPaint(painter: _EmergencePainter(_size, c)),
            ),
          ),
          const SizedBox(height: Gap.xs),
          Wrap(
            spacing: Gap.l,
            children: [
              _legend(c.cyan, 'everyday text prediction'),
              _legend(c.magenta, 'multi-step arithmetic'),
            ],
          ),
          Text('Illustration of the pattern, not real data.', style: TextStyle(color: c.textDim, fontSize: 11)),
          LabeledSlider(
            key: const ValueKey('testing-size'),
            label: 'Model size (small → huge)',
            value: _size,
            min: 0,
            max: 1,
            color: c.magenta,
            format: (v) => v < 0.33 ? 'small' : (v < 0.66 ? 'medium' : 'huge'),
            onChanged: (v) => setState(() => _size = v),
          ),
          Text(
            on ? 'Switched on! At this size the model can suddenly do multi-step arithmetic.' : 'Not yet: the arithmetic skill stays near zero.',
            key: const ValueKey('testing-emergent'),
            style: TextStyle(color: on ? c.lime : c.textDim, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: Gap.m),
          const TermText(
            'Researchers call these [[emergent abilities|emergent ability]]. Some argue the jump is partly an illusion '
            'of all-or-nothing scoring: graded more gently, the skill often grows more smoothly. Either way, bigger '
            'models reliably get better at a growing list of tasks.',
          ),
          const SizedBox(height: Gap.m),
          const FactCard(
            value: '2022',
            label: '"Emergent Abilities of Large Language Models" described skills appearing only past a certain scale',
            factId: 'TR-EMERGENT',
          ),
        ],
      ),
    );
  }

  Widget _legend(Color col, String label) => Text.rich(TextSpan(children: [
        WidgetSpan(alignment: PlaceholderAlignment.middle, child: Container(width: 14, height: 4, color: col)),
        TextSpan(text: '  $label', style: const TextStyle(fontSize: 12)),
      ]));
}

class _EmergencePainter extends CustomPainter {
  _EmergencePainter(this.size01, this.c);
  final double size01;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final axis = Paint()
      ..color = c.line
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), axis);
    canvas.drawLine(Offset.zero, Offset(0, size.height), axis);
    void plot(double Function(double) f, Color col) {
      final p = Path();
      for (var i = 0; i <= 120; i++) {
        final x = i / 120;
        final pt = Offset(x * size.width, size.height - f(x) * size.height * 0.95);
        i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(p, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = col);
      final dot = Offset(size01 * size.width, size.height - f(size01) * size.height * 0.95);
      canvas.drawCircle(dot, 6, Paint()..color = col);
    }

    plot(_EmergenceState.smooth, c.cyan);
    plot(_EmergenceState.sudden, c.magenta);
    canvas.drawLine(Offset(size01 * size.width, 0), Offset(size01 * size.width, size.height),
        Paint()..color = c.textDim.withValues(alpha: 0.4));
  }

  @override
  bool shouldRepaint(_EmergencePainter old) => old.size01 != size01 || old.c != c;
}
