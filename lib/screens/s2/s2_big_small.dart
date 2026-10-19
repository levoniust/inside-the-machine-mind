import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/bit.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Section 2 · Lesson 20: Big models and small models.
/// Compares model sizes (1B to 405B+) using a radar chart and live stats.
/// Highlights that bigger models know more but are slower and more expensive.
class S2BigSmallScreen extends StatefulWidget {
  const S2BigSmallScreen({super.key});

  @override
  State<S2BigSmallScreen> createState() => _S2BigSmallScreenState();
}

class _S2BigSmallScreenState extends State<S2BigSmallScreen> with SingleTickerProviderStateMixin {
  static const models = [
    _Model('Phi-3-mini', 3.8, 'Tiny', 0.05, 0.9, 0.4, 0.2, 0.9),
    _Model('Llama 3 8B', 8.0, 'Small', 0.1, 0.8, 0.5, 0.3, 0.8),
    _Model('Llama 3 70B', 70.0, 'Medium', 0.4, 0.5, 0.8, 0.5, 0.4),
    _Model('Llama 3 405B', 405.0, 'Giant', 0.9, 0.2, 1.0, 0.9, 0.1),
    _Model('Frontier', -1, 'Frontier', 1.0, 0.1, 1.0, 1.0, 0.0),
  ];

  int _selected = 0;
  late final AnimationController _radarAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
    value: 1, // show the radar immediately (also when animations are off)
  );

  @override
  void dispose() {
    _radarAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(2);
    final model = models[_selected];

    return LessonScaffold(
      lessonId: 's2_big_small',
      children: [
        DemoCard(
          title: 'Two Bits: Giant and Tiny',
          child: Row(
            children: [
              Expanded(
                child: _ModelVisual(label: 'Tiny (3.8B)', size: 0.3, color: c.lime, isHighlighted: _selected == 0),
              ),
              SizedBox(width: Gap.l),
              Expanded(
                child: _ModelVisual(label: 'Giant (405B)', size: 0.8, color: c.violet, isHighlighted: _selected == 3),
              ),
            ],
          ),
        ),
        DemoCard(
          title: 'Capability Radar',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select a model size. The radar shows relative capability.',
                style: TextStyle(color: c.textDim, fontSize: 13),
              ),
              const SizedBox(height: Gap.m),
              AspectRatio(
                aspectRatio: 1.0,
                child: Semantics(
                  label: 'Radar chart showing capabilities of ${model.name}',
                  child: AnimatedBuilder(
                    animation: _radarAnim,
                    builder: (context, child) => CustomPaint(
                      painter: _RadarPainter(
                        values: model.values,
                        progress: _radarAnim.value,
                        accent: accent,
                        colors: c,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Gap.l),
              Wrap(
                spacing: Gap.s,
                runSpacing: Gap.s,
                children: [
                  for (var i = 0; i < models.length; i++)
                    ChoiceChip(
                      label: Text(models[i].name),
                      selected: i == _selected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selected = i;
                          });
                          _radarAnim.forward(from: 0);
                        }
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        DemoCard(
          title: 'At a glance',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StatGrid(
                columns: 2,
                children: [
                  StatTile(
                    label: 'Parameters',
                    value: model.paramsB < 0 ? 'not public' : '${model.paramsB.toStringAsFixed(1)}B',
                    color: accent,
                    icon: Icons.developer_board,
                  ),
                  StatTile(
                    label: 'Memory (16-bit)',
                    value: model.paramsB < 0 ? 'unknown' : '${(model.paramsB * 2).toStringAsFixed(0)} GB',
                    color: c.amber,
                    icon: Icons.memory,
                  ),
                  StatTile(
                    label: 'Speed (relative)',
                    value: '${(model.speed * 100).round()}',
                    color: c.lime,
                    icon: Icons.speed,
                  ),
                  StatTile(
                    label: 'Knowledge (relative)',
                    value: '${(model.knowledge * 100).round()}',
                    color: c.violet,
                    icon: Icons.school,
                  ),
                ],
              ),
              const SizedBox(height: Gap.s),
              Text(
                'Speed and knowledge are rough, relative illustrations, not benchmark results. The newest frontier models\' sizes '
                'often aren\'t published.',
                style: TextStyle(color: c.textDim, fontSize: 12),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: FactCard(
                value: '3.8B',
                label: 'Phi-3-mini: small enough to run on a phone',
                factId: 'TR-PHI3',
                color: c.lime,
              ),
            ),
            SizedBox(width: Gap.m),
            Expanded(
              child: FactCard(
                value: '126 layers',
                label: 'Llama 3 405B architecture',
                factId: 'TR-LLAMA3-ARCH',
                color: c.violet,
              ),
            ),
          ],
        ),
        FactCard(
          value: '20 tokens/param',
          label: 'Compute-optimal ratio (Chinchilla)',
          comparison: 'Bigger isn\'t always better',
          factId: 'TR-CHINCHILLA',
          color: accent,
        ),
      ],
    );
  }
}

class _Model {
  const _Model(this.name, this.paramsB, this.type, this.memory, this.speed, this.knowledge, this.context, this.cost);
  final String name;
  final double paramsB;
  final String type;
  final double memory;
  final double speed;
  final double knowledge;
  final double context;
  final double cost;

  List<double> get values => [memory, speed, knowledge, context, cost];
}

class _ModelVisual extends StatelessWidget {
  const _ModelVisual({required this.label, required this.size, required this.color, required this.isHighlighted});
  final String label;
  final double size;
  final Color color;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.0,
          child: Center(child: BitAvatar(size: 40 + 100 * size, mood: isHighlighted ? BitMood.happy : BitMood.idle)),
        ),
        const SizedBox(height: Gap.s),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
            color: isHighlighted ? color : c.textDim,
          ),
        ),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({required this.values, required this.progress, required this.accent, required this.colors});
  final List<double> values;
  final double progress;
  final Color accent;
  final AppColors colors;

  static const labels = ['Memory', 'Speed', 'Knowledge', 'Context', 'Cost'];

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final center = Offset(size.width / 2, size.height / 2);
    final r = s * 0.4;
    final n = values.length;
    final angleStep = math.pi * 2 / n;

    // Draw Grid (Concentric Polygons)
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = colors.line.withValues(alpha: 0.5);
    for (var i = 1; i <= 4; i++) {
      final rr = r * i / 4;
      final path = Path();
      for (var j = 0; j < n; j++) {
        final angle = j * angleStep - math.pi / 2;
        final point = center + Offset(math.cos(angle), math.sin(angle)) * rr;
        if (j == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw Axes
    final axisPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = colors.line.withValues(alpha: 0.8);
    for (var j = 0; j < n; j++) {
      final angle = j * angleStep - math.pi / 2;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * r;
      canvas.drawLine(center, point, axisPaint);
    }

    // Draw Data Polygon
    final dataPath = Path();
    for (var j = 0; j < n; j++) {
      final angle = j * angleStep - math.pi / 2;
      final val = values[j] * progress;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * r * val;
      if (j == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();

    canvas.drawPath(dataPath, Paint()..color = accent.withValues(alpha: 0.2));
    canvas.drawPath(
      dataPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = accent,
    );

    // Draw Points
    for (var j = 0; j < n; j++) {
      final angle = j * angleStep - math.pi / 2;
      final val = values[j] * progress;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * r * val;
      canvas.drawCircle(point, 4, Paint()..color = accent);
    }

    // Draw Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var j = 0; j < n; j++) {
      final angle = j * angleStep - math.pi / 2;
      final labelPos = center + Offset(math.cos(angle), math.sin(angle)) * (r + 15);
      textPainter.text = TextSpan(
        text: labels[j],
        style: TextStyle(color: colors.textDim, fontSize: 10, fontWeight: FontWeight.w600),
      );
      textPainter.layout();
      final offset = Offset(-textPainter.width / 2, -textPainter.height / 2);
      textPainter.paint(canvas, labelPos + offset);
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.progress != progress || old.values != values;
}
