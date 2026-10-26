import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Picking a quant: llama.cpp's measured Llama 3 8B scoreboard as a size-vs-damage curve (KL divergence, log scale),
/// with and without an importance matrix, then the Llama 2 vs Llama 3 surprise.
class LQuantPickScreen extends StatelessWidget {
  const LQuantPickScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
    lessonId: 'l_quant_pick',
    children: [
      _Curve(),
      _L2L3(),
      FactCard(
        value: '91.9%',
        label: 'of next tokens unchanged by Q4_K_M on Llama 3 8B (97.7% at Q8_0, 71.1% at Q2_K)',
        factId: 'RUN-QP-TABLE',
      ),
      FactCard(
        value: '0.031 → 0.028',
        label: 'KL divergence of Q4_K_M without and with an importance matrix: same size, less damage',
        factId: 'RUN-QP-IMATRIX',
      ),
    ],
  );
}

class _Q {
  const _Q(this.name, this.gib, this.kld, this.kldImatrix, this.dppl);
  final String name;
  final double gib, kld, dppl;
  final double? kldImatrix;
}

// Llama 3 8B, llama.cpp perplexity scoreboard (SRC-LLAMACPP-PPL): size GiB, mean KLD (no imatrix / with WT imatrix), ΔPPL.
const _qs = [
  _Q('IQ1_S', 1.88, 2.211278, null, 51.866),
  _Q('IQ2_XXS', 2.24, 0.812022, null, 7.860),
  _Q('Q2_K', 2.96, 0.445132, 0.331393, 3.520),
  _Q('IQ3_XXS', 3.05, 0.183625, null, 1.227),
  _Q('Q3_K_M', 3.74, 0.101913, 0.084358, 0.657),
  _Q('IQ4_XS', 4.14, 0.036334, null, 0.228),
  _Q('Q4_K_M', 4.58, 0.031273, 0.028152, 0.175),
  _Q('Q5_K_M', 5.33, 0.010762, null, 0.057),
  _Q('Q6_K', 6.14, 0.005452, null, 0.022),
  _Q('Q8_0', 7.96, 0.001355, null, 0.003),
  _Q('F16', 14.97, 0.000551, null, 0.002),
];

String _band(double kld) => kld < 0.01
    ? 'very hard to tell apart from the original'
    : kld < 0.05
    ? 'small differences: the usual sweet spot'
    : kld < 0.2
    ? 'noticeably different answers'
    : 'starts to fall apart';

class _Curve extends StatefulWidget {
  const _Curve();

  @override
  State<_Curve> createState() => _CurveState();
}

class _CurveState extends State<_Curve> {
  int _i = 6; // Q4_K_M
  bool _imatrix = false;

  double _kld(_Q q) => _imatrix && q.kldImatrix != null ? q.kldImatrix! : q.kld;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(6);
    final q = _qs[_i];
    final kld = _kld(q);
    return DemoCard(
      title: 'Size vs damage (Llama 3 8B, measured)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 200,
            child: CustomPaint(
              key: const ValueKey('qp-curve'),
              painter: _CurvePainter(
                points: [for (final x in _qs) Offset(x.gib, _kld(x))],
                selected: _i,
                line: accent,
                dot: c.text,
                grid: c.line,
                text: c.textDim,
              ),
            ),
          ),
          LabeledSlider(
            key: const ValueKey('qp-slider'),
            label: 'Quant',
            value: _i.toDouble(),
            min: 0,
            max: (_qs.length - 1).toDouble(),
            divisions: _qs.length - 1,
            format: (_) => q.name,
            color: accent,
            onChanged: (v) => setState(() => _i = v.round()),
          ),
          SwitchListTile(
            key: const ValueKey('qp-imatrix'),
            contentPadding: EdgeInsets.zero,
            title: const Text('With an importance matrix'),
            subtitle: const Text('Measured for Q2_K, Q3_K_M and Q4_K_M; the I-quants above were always made with one'),
            value: _imatrix,
            onChanged: (v) => setState(() => _imatrix = v),
          ),
          StatGrid(
            columns: 2,
            children: [
              StatTile(label: 'File size', value: '${q.gib} GiB', color: accent),
              StatTile(
                key: const ValueKey('qp-kld'),
                label: 'KL divergence',
                value: kld < 0.01 ? kld.toStringAsFixed(4) : kld.toStringAsFixed(3),
                color: c.violet,
              ),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text(
            '${q.name}: ${_band(kld)}.',
            key: const ValueKey('qp-band'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: Gap.xs),
          Text(
            'KL divergence measures how far the quantized model\'s next-token probabilities drift from the 16-bit '
            'original (0 = identical). The words for each range are a rough guide, not part of the measurement.',
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _CurvePainter extends CustomPainter {
  _CurvePainter({
    required this.points,
    required this.selected,
    required this.line,
    required this.dot,
    required this.grid,
    required this.text,
  });
  final List<Offset> points;
  final int selected;
  final Color line, dot, grid, text;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 34.0, bottom = 18.0;
    final w = size.width - left, h = size.height - bottom;
    const minX = 1.5, maxX = 16.0;
    final minY = math.log(0.0003), maxY = math.log(3.0);
    Offset p(Offset v) =>
        Offset(left + (v.dx - minX) / (maxX - minX) * w, h - (math.log(v.dy) - minY) / (maxY - minY) * h);
    final g = Paint()..color = grid;
    for (final y in [0.001, 0.01, 0.1, 1.0]) {
      final yy = p(Offset(minX, y)).dy;
      canvas.drawLine(Offset(left, yy), Offset(size.width, yy), g);
      _label(canvas, '$y', Offset(0, yy - 7));
    }
    for (final x in [2, 4, 8, 16]) {
      final xx = p(Offset(x.toDouble(), 1)).dx;
      _label(canvas, '$x GiB', Offset(xx - 12, h + 3));
    }
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final q = p(points[i]);
      i == 0 ? path.moveTo(q.dx, q.dy) : path.lineTo(q.dx, q.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(
        p(points[i]),
        i == selected ? 7 : 3.5,
        Paint()..color = i == selected ? line : dot.withValues(alpha: 0.6),
      );
    }
  }

  void _label(Canvas canvas, String t, Offset at) {
    (TextPainter(
      text: TextSpan(
        text: t,
        style: TextStyle(fontSize: 10, color: text),
      ),
      textDirection: TextDirection.ltr,
    )..layout()).paint(canvas, at);
  }

  @override
  bool shouldRepaint(_CurvePainter old) => old.selected != selected || old.points != points;
}

/// Same top token, Llama 2 7B vs Llama 3 8B at the same quants (SRC-LLAMACPP-PPL).
class _L2L3 extends StatelessWidget {
  const _L2L3();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    const rows = [
      ('Q2_K', 85.584, 71.138),
      ('Q4_K_M', 94.665, 91.901),
      ('Q6_K', 97.520, 96.031),
      ('Q8_0', 98.846, 97.674),
    ];
    return DemoCard(
      title: 'The surprise: better models squeeze worse',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'How often the quantized model still picks the same top next token as the original:',
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
          const SizedBox(height: Gap.s),
          for (final (q, l2, l3) in rows) ...[
            Text(q, style: AppText.mono.copyWith(fontWeight: FontWeight.w700)),
            CompareBars(
              items: [
                BarItem('Llama 2 7B', l2, display: '${l2.toStringAsFixed(1)}%', color: c.cyan),
                BarItem('Llama 3 8B', l3, display: '${l3.toStringAsFixed(1)}%', color: c.magenta),
              ],
            ),
            const SizedBox(height: Gap.s),
          ],
          const Text(
            'A common explanation: Llama 3 was trained on far more text, so its weights carry more information and '
            'rounding them costs more. Either way, a quant that was fine for an older model is not automatically fine for a newer one.',
          ),
        ],
      ),
    );
  }
}
