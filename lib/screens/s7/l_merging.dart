import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Mixing models: two fine-tunes of one base drawn as arrows (task vectors) in weight space, merged by averaging,
/// task arithmetic, SLERP or negation; then TIES vs DARE on twelve made-up parameter changes.
class LMergingScreen extends StatelessWidget {
  const LMergingScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
    lessonId: 'l_merging',
    children: [
      _Arrows(),
      _Sparsify(),
      FactCard(
        value: 'weights − base',
        label: 'a task vector: what fine-tuning changed. Add them to combine skills',
        factId: 'CU-TASKVEC',
      ),
      FactCard(
        value: '90-99%',
        label: 'of the changes can be dropped at random (DARE) when the rest are scaled up',
        factId: 'CU-DARE',
      ),
    ],
  );
}

enum _Method { average, arithmetic, slerp, negate }

class _Arrows extends StatefulWidget {
  const _Arrows();

  @override
  State<_Arrows> createState() => _ArrowsState();
}

class _ArrowsState extends State<_Arrows> {
  _Method _m = _Method.average;
  double _t = 0.5;

  // Task vectors in a made-up 2-D "weight space" (real ones have billions of dimensions).
  static const _a = Offset(0.75, -0.35), _b = Offset(0.2, -0.8);

  Offset get _merged => switch (_m) {
    _Method.average => (_a + _b) / 2,
    _Method.arithmetic => (_a + _b) * _t,
    _Method.slerp => _slerp(_a, _b, _t),
    _Method.negate => _a - _b * _t,
  };

  static Offset _slerp(Offset p, Offset q, double t) {
    final a1 = math.atan2(p.dy, p.dx), a2 = math.atan2(q.dy, q.dx);
    final r = p.distance + (q.distance - p.distance) * t;
    final ang = a1 + (a2 - a1) * t;
    return Offset(math.cos(ang), math.sin(ang)) * r;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(7);
    final hasT = _m != _Method.average;
    final note = switch (_m) {
      _Method.average => 'Average: halfway between the two fine-tunes. Simple, and often surprisingly good.',
      _Method.arithmetic => 'Task arithmetic: base + λ × (A + B). Both skills at once; λ controls how strongly.',
      _Method.slerp =>
        'SLERP: walk along the arc between A and B instead of the straight line, keeping the "length" of the change.',
      _Method.negate =>
        'Negation: base + A − λ × B. Subtracting a task vector removes that behaviour (e.g. a style or a bias).',
    };
    return DemoCard(
      title: 'Two fine-tunes of the same base',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 220,
            child: CustomPaint(
              key: const ValueKey('merge-plot'),
              painter: _ArrowPainter(
                a: _a,
                b: _b,
                m: _merged,
                ca: c.cyan,
                cb: c.magenta,
                cm: accent,
                grid: c.line,
                text: c.textDim,
              ),
            ),
          ),
          Wrap(
            spacing: Gap.xs,
            runSpacing: Gap.xs,
            children: [
              for (final (m, label) in [
                (_Method.average, 'Average'),
                (_Method.arithmetic, 'Task arithmetic'),
                (_Method.slerp, 'SLERP'),
                (_Method.negate, 'Negate B'),
              ])
                ChoiceChip(
                  key: ValueKey('merge-${m.name}'),
                  label: Text(label),
                  selected: _m == m,
                  selectedColor: accent.withValues(alpha: 0.3),
                  onSelected: (_) => setState(() => _m = m),
                ),
            ],
          ),
          if (hasT)
            LabeledSlider(
              key: const ValueKey('merge-t'),
              label: _m == _Method.slerp ? 't (from A to B)' : 'λ',
              value: _t,
              min: 0,
              max: 1,
              divisions: 10,
              format: (v) => v.toStringAsFixed(1),
              color: accent,
              onChanged: (v) => setState(() => _t = v),
            ),
          Text(note, key: const ValueKey('merge-note')),
          const SizedBox(height: Gap.xs),
          Text(
            'Only works for models fine-tuned from the same base model: same architecture, same starting weights.',
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter({
    required this.a,
    required this.b,
    required this.m,
    required this.ca,
    required this.cb,
    required this.cm,
    required this.grid,
    required this.text,
  });
  final Offset a, b, m;
  final Color ca, cb, cm, grid, text;

  @override
  void paint(Canvas canvas, Size size) {
    final o = Offset(size.width * 0.25, size.height * 0.85);
    final scale = math.min(size.width * 0.6, size.height * 0.75);
    Offset p(Offset v) => o + Offset(v.dx, v.dy) * scale;
    final g = Paint()..color = grid;
    canvas.drawLine(Offset(0, o.dy), Offset(size.width, o.dy), g);
    canvas.drawLine(Offset(o.dx, 0), Offset(o.dx, size.height), g);
    _arrow(canvas, o, p(a), ca, 'A: math fine-tune');
    _arrow(canvas, o, p(b), cb, 'B: code fine-tune');
    _arrow(canvas, o, p(m), cm, 'merged', width: 4);
    canvas.drawCircle(o, 6, Paint()..color = text);
    _label(canvas, 'base model', o + const Offset(-30, 8), text);
  }

  void _arrow(Canvas canvas, Offset from, Offset to, Color color, String label, {double width = 3}) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, paint);
    final d = to - from;
    if (d.distance > 1) {
      final u = d / d.distance;
      final n = Offset(-u.dy, u.dx);
      final path = Path()
        ..moveTo(to.dx, to.dy)
        ..lineTo((to - u * 12 + n * 6).dx, (to - u * 12 + n * 6).dy)
        ..lineTo((to - u * 12 - n * 6).dx, (to - u * 12 - n * 6).dy)
        ..close();
      canvas.drawPath(path, Paint()..color = color);
    }
    _label(canvas, label, to + const Offset(6, -16), color);
  }

  void _label(Canvas canvas, String t, Offset at, Color color) {
    (TextPainter(
      text: TextSpan(
        text: t,
        style: TextStyle(fontSize: 11, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout()).paint(canvas, at);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.m != m || old.ca != ca;
}

/// Twelve made-up parameter changes from two fine-tunes: TIES keeps the big ones and the agreeing sign;
/// DARE drops changes at random and scales up the survivors.
class _Sparsify extends StatefulWidget {
  const _Sparsify();

  @override
  State<_Sparsify> createState() => _SparsifyState();
}

class _SparsifyState extends State<_Sparsify> {
  static const _da = [0.8, -0.1, 0.5, 0.05, -0.6, 0.3, 0.02, -0.4, 0.7, -0.05, 0.2, 0.9];
  static const _db = [0.6, 0.4, -0.5, 0.1, -0.7, -0.08, 0.3, -0.3, 0.1, 0.5, -0.6, 0.8];
  bool _dare = false;

  List<double> get _merged {
    if (_dare) {
      // drop half of each model's changes (fixed pattern for the demo), scale survivors by 1/(1-0.5) = 2, then average
      final keepA = [1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1], keepB = [0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1];
      return [for (var i = 0; i < 12; i++) (_da[i] * keepA[i] * 2 + _db[i] * keepB[i] * 2) / 2];
    }
    // TIES: trim to the largest |change| (≥ 0.25), elect the sign of the larger total, average the agreeing values
    return [
      for (var i = 0; i < 12; i++)
        () {
          final vals = [_da[i], _db[i]].where((v) => v.abs() >= 0.25).toList();
          if (vals.isEmpty) return 0.0;
          final sign = vals.fold<double>(0, (s, v) => s + v) >= 0 ? 1 : -1;
          final agree = vals.where((v) => v.sign == sign).toList();
          return agree.fold<double>(0, (s, v) => s + v) / agree.length;
        }(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(7);
    return DemoCard(
      title: 'Cleaning up before merging',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<bool>(
            key: const ValueKey('merge-sparsify'),
            segments: const [
              ButtonSegment(value: false, label: Text('TIES')),
              ButtonSegment(value: true, label: Text('DARE')),
            ],
            selected: {_dare},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _dare = s.first),
          ),
          const SizedBox(height: Gap.s),
          SizedBox(
            height: 150,
            child: CustomPaint(
              painter: _BarsPainter(rows: [_da, _db, _merged], colors: [c.cyan, c.magenta, accent], zero: c.line),
              size: Size.infinite,
            ),
          ),
          Wrap(
            spacing: Gap.m,
            children: [
              Text('■ A', style: TextStyle(color: c.cyan)),
              Text('■ B', style: TextStyle(color: c.magenta)),
              Text('■ merged', style: TextStyle(color: accent)),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text(
            _dare
                ? 'DARE: drop changes at random (here half of them), double the survivors so the total effect stays the same, '
                      'then merge. With real models even 90-99% can go.'
                : 'TIES: 1) trim the small changes, 2) elect one sign per parameter, 3) average only the values that agree. '
                      'Conflicting tugs no longer cancel each other out.',
            key: const ValueKey('merge-sparsify-note'),
          ),
        ],
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({required this.rows, required this.colors, required this.zero});
  final List<List<double>> rows;
  final List<Color> colors;
  final Color zero;

  @override
  void paint(Canvas canvas, Size size) {
    final n = rows.first.length;
    final rh = size.height / rows.length;
    final cw = size.width / n;
    for (var r = 0; r < rows.length; r++) {
      final mid = rh * r + rh / 2;
      canvas.drawLine(Offset(0, mid), Offset(size.width, mid), Paint()..color = zero);
      for (var i = 0; i < n; i++) {
        final v = rows[r][i].clamp(-1.0, 1.0);
        final h = v * (rh / 2 - 4);
        canvas.drawRect(
          Rect.fromLTRB(i * cw + 3, mid - (h > 0 ? h : 0), (i + 1) * cw - 3, mid + (h < 0 ? -h : 0)),
          Paint()..color = colors[r].withValues(alpha: 0.85),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BarsPainter old) => true;
}
