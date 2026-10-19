import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 2 · "Step 2: how wrong was it?": the loss (cross-entropy) = −ln(probability given to the right word).
/// A slider sets that probability; the curve and a "wrongness meter" show the loss.
class S2LossScreen extends StatelessWidget {
  const S2LossScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's2_loss',
        children: [_LossDemo(), _Batch()],
      );
}

double crossEntropy(double p) => -math.log(p.clamp(1e-6, 1.0));

class _LossDemo extends StatefulWidget {
  const _LossDemo();

  @override
  State<_LossDemo> createState() => _LossDemoState();
}

class _LossDemoState extends State<_LossDemo> {
  double _p = 0.5;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final loss = crossEntropy(_p);
    final mood = _p > 0.8
        ? 'Confident and right: tiny loss.'
        : _p > 0.3
            ? 'Unsure: medium loss.'
            : 'Confidently wrong: the loss shoots up, and the model gets a big push to change.';
    return DemoCard(
      title: '"The sky is ___"  (right answer: blue)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledSlider(
            key: const ValueKey('loss-p'),
            label: 'Chance the model gave to "blue"',
            value: _p,
            min: 0.01,
            max: 0.99,
            color: c.violet,
            format: (v) => '${(v * 100).round()}%',
            onChanged: (v) => setState(() => _p = v),
          ),
          AspectRatio(
            aspectRatio: 1.7,
            child: Semantics(
              label: 'Loss curve; current loss ${loss.toStringAsFixed(2)}',
              child: CustomPaint(painter: _CurvePainter(_p, c)),
            ),
          ),
          const SizedBox(height: Gap.m),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  key: const ValueKey('loss-value'),
                  label: 'Loss (wrongness score)',
                  value: loss.toStringAsFixed(2),
                  color: loss < 0.3 ? c.lime : (loss < 1.5 ? c.amber : c.red),
                ),
              ),
              const SizedBox(width: Gap.s),
              Expanded(child: _Meter(loss: loss)),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text(mood, key: const ValueKey('loss-mood'), style: TextStyle(color: c.text, fontWeight: FontWeight.w600)),
          const SizedBox(height: Gap.s),
          TermText(
            'The formula is loss = −log(chance of the right word), also called [[cross-entropy|loss]]. Being 99% sure and right '
            'costs almost nothing (0.01); being 1% sure costs a lot (4.6). Training tries to make this number as small as possible.',
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _Meter extends StatelessWidget {
  const _Meter({required this.loss});
  final double loss;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final frac = (loss / 4.6).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(Gap.m),
      decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.line)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Wrongness meter', style: TextStyle(color: c.textDim, fontSize: 12)),
          const SizedBox(height: Gap.s),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: frac,
              minHeight: 14,
              color: Color.lerp(c.lime, c.red, frac),
              backgroundColor: c.surfaceHi,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurvePainter extends CustomPainter {
  _CurvePainter(this.p, this.c);
  final double p;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    const maxLoss = 4.8;
    Offset pt(double prob) => Offset(prob * size.width, size.height - crossEntropy(prob) / maxLoss * size.height);
    final axis = Paint()
      ..color = c.line
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), axis);
    canvas.drawLine(Offset.zero, Offset(0, size.height), axis);
    final path = Path()..moveTo(pt(0.01).dx, pt(0.01).dy);
    for (var i = 2; i <= 100; i++) {
      final q = pt(i / 100);
      path.lineTo(q.dx, q.dy);
    }
    canvas.drawPath(path, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = c.violet);
    final dot = pt(p);
    canvas.drawLine(Offset(dot.dx, size.height), dot, Paint()..color = c.textDim.withValues(alpha: 0.5));
    canvas.drawCircle(dot, 8, Paint()..color = c.magenta);
    void label(String s, Offset at) {
      final tp = TextPainter(
          text: TextSpan(text: s, style: TextStyle(fontFamily: 'Roboto', fontSize: 10, color: c.textDim)),
          textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, at);
    }

    label('loss', const Offset(4, 2));
    label('chance of the right word →', Offset(size.width - 150, size.height - 14));
  }

  @override
  bool shouldRepaint(_CurvePainter old) => old.p != p || old.c != c;
}

class _Batch extends StatelessWidget {
  const _Batch();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    const guesses = [('blue', 0.62), ('time', 0.93), ('tea', 0.45), ('Paris', 0.81), ('rain', 0.12)];
    final avg = guesses.fold<double>(0, (s, g) => s + crossEntropy(g.$2)) / guesses.length;
    return DemoCard(
      title: 'One number for a whole batch',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TermText('Training checks thousands of guesses at once (a [[batch]]) and averages their losses:',
              style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.s),
          for (final (w, p) in guesses)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(child: Text('right word "$w", chance ${(p * 100).round()}%')),
                  Text(crossEntropy(p).toStringAsFixed(2), style: AppText.mono.copyWith(color: c.violet)),
                ],
              ),
            ),
          const Divider(),
          Row(
            children: [
              const Expanded(child: Text('Average loss', style: TextStyle(fontWeight: FontWeight.w800))),
              Text(avg.toStringAsFixed(2),
                  key: const ValueKey('loss-avg'), style: AppText.mono.copyWith(fontWeight: FontWeight.w800, color: c.violet)),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text('Example numbers. This one number is what the next step, backpropagation, tries to push down.',
              style: TextStyle(color: c.textDim, fontSize: 12)),
        ],
      ),
    );
  }
}
