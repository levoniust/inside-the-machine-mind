import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 2 · "Bigger = smarter?": with a fixed compute budget (≈ 6 × knobs × tokens), how should you split it
/// between model size and data? An illustrative loss curve, shaped so the sweet spot sits at Chinchilla's
/// ~20 tokens per knob (labelled on screen). Facts: TR-KAPLAN, TR-CHINCHILLA, TR-6ND.
class S2ScalingLawsScreen extends StatelessWidget {
  const S2ScalingLawsScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's2_scaling_laws',
        children: [_Budget()],
      );
}

// Illustrative loss: L = E + A/N^a + B/D^a. With equal exponents the optimum is D/N = (B/A)^(1/a) = 20.
const _e = 1.7, _a = 0.3, _aCoef = 400.0;
final _bCoef = _aCoef * math.pow(20, _a);

double illustrativeLoss(double n, double d) => _e + _aCoef / math.pow(n, _a) + _bCoef / math.pow(d, _a);

/// Best model size for compute [c] (FLOPs): N = sqrt(C / (6 × 20)).
double optimalParams(double c) => math.sqrt(c / 6 / 20);

class _Budget extends StatefulWidget {
  const _Budget();

  @override
  State<_Budget> createState() => _BudgetState();
}

class _BudgetState extends State<_Budget> {
  double _cExp = math.log(5.76e23) / math.ln10; // Chinchilla-sized budget
  double _nExp = math.log(280e9) / math.ln10; // start with a big, under-trained model

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final compute = math.pow(10, _cExp).toDouble();
    final n = math.pow(10, _nExp).toDouble();
    final d = compute / (6 * n);
    final loss = illustrativeLoss(n, d);
    final nBest = optimalParams(compute);
    final lossBest = illustrativeLoss(nBest, 20 * nBest);
    final ratio = d / n;
    final verdict = ratio < 8
        ? 'Too big for the budget: a huge model that barely got to read. It hasn\'t finished learning.'
        : ratio > 50
            ? 'Too small: lots of reading, but not enough knobs to store what it learns.'
            : 'Close to the sweet spot: about 20 tokens per knob.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          title: 'Spend a fixed budget wisely',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TermText(
                'Your [[compute]] budget is fixed. A bigger model can read less; a smaller one can read more. Where is the best loss?',
                style: TextStyle(color: c.textDim),
              ),
              const SizedBox(height: Gap.m),
              LabeledSlider(
                key: const ValueKey('sl-compute'),
                label: 'Compute budget (FLOPs)',
                value: _cExp,
                min: 21,
                max: 26,
                color: c.amber,
                format: (v) => '10^${v.toStringAsFixed(1)}',
                onChanged: (v) => setState(() => _cExp = v),
              ),
              LabeledSlider(
                key: const ValueKey('sl-size'),
                label: 'Model size (knobs)',
                value: _nExp,
                min: 8.5,
                max: 12,
                color: c.violet,
                format: (v) => humanNumber(math.pow(10, v).toDouble(), digits: 0),
                onChanged: (v) => setState(() => _nExp = v),
              ),
              AspectRatio(
                aspectRatio: 1.7,
                child: Semantics(
                  label: 'Loss versus model size for a fixed budget',
                  child: CustomPaint(painter: _UPainter(compute, _nExp, c)),
                ),
              ),
              Text('Illustration shaped like the Chinchilla finding; real curves come from many training runs.',
                  style: TextStyle(color: c.textDim, fontSize: 11)),
              const SizedBox(height: Gap.m),
              StatGrid(
                columns: 3,
                children: [
                  StatTile(label: 'Tokens it reads', value: humanNumber(d, digits: 0), color: c.cyan),
                  StatTile(key: const ValueKey('sl-ratio'), label: 'Tokens per knob', value: ratio < 10 ? ratio.toStringAsFixed(1) : ratio.round().toString(), color: c.violet),
                  StatTile(label: 'Loss', value: loss.toStringAsFixed(3), color: (loss - lossBest) < 0.01 ? c.lime : c.amber),
                ],
              ),
              const SizedBox(height: Gap.s),
              Text(verdict, key: const ValueKey('sl-verdict'), style: TextStyle(color: c.text, fontWeight: FontWeight.w600)),
              const SizedBox(height: Gap.s),
              Center(
                child: OutlinedButton.icon(
                  key: const ValueKey('sl-best'),
                  onPressed: () => setState(() => _nExp = math.log(nBest) / math.ln10),
                  icon: const Icon(Icons.my_location),
                  label: Text('Jump to the sweet spot (${humanNumber(nBest, digits: 0)} knobs)'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
        DemoCard(
          title: 'The bigger-is-better rule',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TermText(
                'In 2020, researchers found that the [[loss]] falls in a smooth, predictable curve as you add knobs, data and compute '
                'together: a [[scaling law]]. That predictability is why companies dared to build ever bigger datacenters. In 2022, '
                'Chinchilla showed many big models had been under-fed: a 70B model trained on 1.4 trillion tokens beat much larger ones.',
              ),
              const SizedBox(height: Gap.m),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: FactCard(value: '~20', label: 'tokens per knob for the best use of compute', factId: 'TR-CHINCHILLA')),
                  SizedBox(width: Gap.m),
                  Expanded(child: FactCard(value: '2020', label: 'scaling laws: loss falls smoothly as models, data and compute grow', factId: 'TR-KAPLAN')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UPainter extends CustomPainter {
  _UPainter(this.compute, this.nExp, this.c);
  final double compute, nExp;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    const lo = 8.5, hi = 12.0;
    final pts = <Offset>[];
    var minL = double.infinity, maxL = -double.infinity;
    final ls = <double>[];
    for (var i = 0; i <= 120; i++) {
      final e = lo + (hi - lo) * i / 120;
      final n = math.pow(10, e).toDouble();
      final l = illustrativeLoss(n, compute / (6 * n));
      ls.add(l);
      minL = math.min(minL, l);
      maxL = math.max(maxL, l);
    }
    maxL = math.min(maxL, minL + 1.2);
    double y(double l) => size.height * 0.05 + (1 - ((l - minL) / (maxL - minL)).clamp(0.0, 1.0)) * size.height * 0.9;
    for (var i = 0; i <= 120; i++) {
      pts.add(Offset(i / 120 * size.width, y(ls[i])));
    }
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), Paint()..color = c.line);
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = c.violet);
    final bestE = math.log(optimalParams(compute)) / math.ln10;
    final bx = (bestE - lo) / (hi - lo) * size.width;
    canvas.drawLine(Offset(bx, 0), Offset(bx, size.height), Paint()..color = c.lime.withValues(alpha: 0.5)..strokeWidth = 1.5);
    final cx = (nExp - lo) / (hi - lo) * size.width;
    final cn = math.pow(10, nExp).toDouble();
    final cl = illustrativeLoss(cn, compute / (6 * cn));
    canvas.drawCircle(Offset(cx, y(cl)), 8, Paint()..color = c.magenta);
    void label(String s, Offset at, Color col) {
      final tp = TextPainter(text: TextSpan(text: s, style: TextStyle(fontFamily: 'Roboto', fontSize: 10, color: col)), textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, at);
    }

    label('lower loss = better ↓', const Offset(4, 2), c.textDim);
    label('sweet spot', Offset((bx + 4).clamp(0, size.width - 60), size.height - 14), c.lime);
  }

  @override
  bool shouldRepaint(_UPainter old) => old.compute != compute || old.nExp != nExp || old.c != c;
}
