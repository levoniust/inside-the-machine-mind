import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 3 · "Minds for science and the world": proteins, weather, materials, medicine.
/// Facts: TL-ALPHAFOLD, TL-GRAPHCAST, TL-ECMWF, TL-GNOME, TL-FDA.
class S3ScienceScreen extends StatelessWidget {
  const S3ScienceScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's3_science',
        children: [_Gallery()],
      );
}

enum _Field { protein, weather, materials, medicine }

class _Story {
  const _Story(this.field, this.title, this.headline, this.text, this.factIds, this.colorOf);
  final _Field field;
  final String title, headline, text;
  final List<String> factIds;
  final Color Function(AppColors) colorOf;
}

final _stories = [
  _Story(_Field.protein, 'Reading the shapes of life', '200 million+ protein structures, free',
      'Proteins are the tiny machines in every living cell, and their shape decides what they do. Working out one shape used to '
          'take years in a lab. AlphaFold predicts it in minutes, and its makers shared over 200 million predictions with '
          'every scientist on Earth. It won the 2024 Nobel Prize in Chemistry.',
      ['TL-ALPHAFOLD'], (c) => c.violet),
  _Story(_Field.weather, 'Forecasting the sky', '10-day forecast in under a minute',
      'GraphCast learned from decades of weather records and makes a 10-day global forecast in under a minute on one chip, '
          'beating the leading traditional system on 90% of 1,380 measures. In 2025 Europe\'s weather centre put its own AI '
          'forecasts into daily operation next to its physics model, helping people prepare for storms and heat.',
      ['TL-GRAPHCAST', 'TL-ECMWF'], (c) => c.cyan),
  _Story(_Field.materials, 'Inventing new materials', '2.2 million new crystals predicted',
      'Better batteries, solar panels and chips all start with new materials. Google DeepMind\'s GNoME predicted 2.2 million new '
          'crystal structures, about 380,000 of them stable enough to be worth making, many more than people had found in history.',
      ['TL-GNOME'], (c) => c.amber),
  _Story(_Field.medicine, 'Helping doctors', '1,600+ AI medical devices authorized',
      'The U.S. FDA has authorized more than 1,600 AI-enabled medical devices: tools that help spot problems in scans, '
          'heart rhythms and more, so doctors can catch things earlier.',
      ['TL-FDA'], (c) => c.lime),
];

class _Gallery extends StatefulWidget {
  const _Gallery();

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> with SingleTickerProviderStateMixin {
  int _open = 0;
  late final AnimationController _t = AnimationController(vsync: this, duration: const Duration(seconds: 6));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _t.value = 0.3;
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
    final s = _stories[_open];
    final col = s.colorOf(c);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatGrid(
          children: [
            for (var i = 0; i < _stories.length; i++)
              InkWell(
                key: ValueKey('science-$i'),
                borderRadius: BorderRadius.circular(14),
                onTap: () => setState(() => _open = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(Gap.m),
                  decoration: BoxDecoration(
                    color: i == _open ? _stories[i].colorOf(c).withValues(alpha: 0.15) : c.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: i == _open ? _stories[i].colorOf(c) : c.line, width: i == _open ? 2 : 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(const [Icons.biotech, Icons.cloud_outlined, Icons.diamond_outlined, Icons.monitor_heart_outlined][i],
                          color: _stories[i].colorOf(c)),
                      const SizedBox(height: Gap.xs),
                      Text(_stories[i].title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: Gap.l),
        DemoCard(
          key: ValueKey('science-card-$_open'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1.6,
                child: Semantics(
                  label: s.title,
                  child: AnimatedBuilder(
                    animation: _t,
                    builder: (_, _) => CustomPaint(painter: _SciencePainter(s.field, _t.value, col, c)),
                  ),
                ),
              ),
              const SizedBox(height: Gap.m),
              Text(s.headline,
                  key: const ValueKey('science-headline'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: col, fontWeight: FontWeight.w800)),
              const SizedBox(height: Gap.s),
              TermText(s.text),
              const SizedBox(height: Gap.s),
              Wrap(
                spacing: Gap.s,
                children: [
                  for (final f in s.factIds)
                    TextButton.icon(
                      onPressed: () => showFactSource(context, f),
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('Source'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SciencePainter extends CustomPainter {
  _SciencePainter(this.field, this.t, this.col, this.c);
  final _Field field;
  final double t;
  final Color col;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide * 0.38;
    switch (field) {
      case _Field.protein:
        // A twisting ribbon (helix) that slowly rotates.
        final path = Path();
        for (var i = 0; i <= 160; i++) {
          final x = size.width * 0.1 + size.width * 0.8 * i / 160;
          final y = center.dy + math.sin(i / 160 * math.pi * 6 + t * math.pi * 2) * r * 0.55;
          i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
        }
        canvas.drawPath(path, Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..color = col);
        final path2 = Path();
        for (var i = 0; i <= 160; i++) {
          final x = size.width * 0.1 + size.width * 0.8 * i / 160;
          final y = center.dy - math.sin(i / 160 * math.pi * 6 + t * math.pi * 2) * r * 0.55;
          i == 0 ? path2.moveTo(x, y) : path2.lineTo(x, y);
        }
        canvas.drawPath(path2, Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = c.magenta.withValues(alpha: 0.6));
      case _Field.weather:
        canvas.drawCircle(center, r, Paint()..color = col.withValues(alpha: 0.18));
        canvas.drawCircle(center, r, Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = col);
        // A rotating storm swirl.
        for (var arm = 0; arm < 3; arm++) {
          final p = Path();
          for (var i = 0; i < 60; i++) {
            final a = arm * 2 * math.pi / 3 + i * 0.12 + t * math.pi * 2;
            final rr = i / 60 * r * 0.55;
            final pt = center + Offset(math.cos(a), math.sin(a)) * rr + Offset(r * 0.2, -r * 0.1);
            i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
          }
          canvas.drawPath(p, Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = Colors.white.withValues(alpha: 0.7));
        }
      case _Field.materials:
        // A crystal lattice that gently rotates.
        final a = t * math.pi * 2;
        final pts = <Offset>[];
        for (var x = -2; x <= 2; x++) {
          for (var y = -2; y <= 2; y++) {
            final px = x * r * 0.32, py = y * r * 0.32;
            pts.add(center + Offset(px * math.cos(a) - py * math.sin(a) * 0.5, py * 0.8 + px * math.sin(a) * 0.3));
          }
        }
        for (var i = 0; i < pts.length; i++) {
          for (var j = i + 1; j < pts.length; j++) {
            if ((pts[i] - pts[j]).distance < r * 0.36) {
              canvas.drawLine(pts[i], pts[j], Paint()
                ..color = col.withValues(alpha: 0.5)
                ..strokeWidth = 1.5);
            }
          }
        }
        for (final p in pts) {
          canvas.drawCircle(p, 6, Paint()..color = col);
        }
      case _Field.medicine:
        // A heartbeat line scrolling across.
        final p = Path();
        for (var i = 0; i <= 200; i++) {
          final x = i / 200 * size.width;
          final phase = (i / 200 + t) % 0.5 / 0.5;
          var y = center.dy;
          if (phase > 0.4 && phase < 0.45) y -= r * 0.9 * math.sin((phase - 0.4) / 0.05 * math.pi);
          if (phase > 0.45 && phase < 0.5) y += r * 0.4 * math.sin((phase - 0.45) / 0.05 * math.pi);
          i == 0 ? p.moveTo(x, y) : p.lineTo(x, y);
        }
        canvas.drawPath(p, Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = col);
    }
  }

  @override
  bool shouldRepaint(_SciencePainter old) => old.t != t || old.field != field || old.col != col;
}
