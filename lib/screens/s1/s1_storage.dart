import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Section 1 · Lesson 2: HDD vs SSD.
/// A spinning hard-drive platter next to a flash chip, then a race to load a 16 GB model file
/// from a hard drive, a SATA SSD and two NVMe SSDs (real speeds, time sped up 8×).
/// Facts: HW-HDD-SPEED, HW-HDD-SEEK, HW-SATA, HW-NVME4, HW-NVME5, HW-NVME-LAT.
class S1StorageScreen extends StatelessWidget {
  const S1StorageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return LessonScaffold(
      lessonId: 's1_storage',
      children: [
        DemoCard(
          title: 'Two ways to store a model',
          child: Row(
            children: const [
              Expanded(child: _DriveIllustration(kind: _Drive.hdd)),
              SizedBox(width: Gap.l),
              Expanded(child: _DriveIllustration(kind: _Drive.ssd)),
            ],
          ),
        ),
        const _LoadRace(),
        DemoCard(
          title: 'Finding one small piece of data',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Time to fetch a random piece of data (shorter is better):', style: TextStyle(color: c.textDim)),
              const SizedBox(height: Gap.m),
              CompareBars(
                log: true,
                items: [
                  BarItem('Hard drive (arm must move)', 0.008, display: '~4–10 ms', color: c.amber),
                  BarItem('SSD (no moving parts)', 0.0001, display: '~0.1 ms', color: c.cyan),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: const [
            Expanded(
              child: FactCard(
                value: '~285 MB/s',
                label: 'Top speed of a big modern [[hard drive]]',
                factId: 'HW-HDD-SPEED',
              ),
            ),
            SizedBox(width: Gap.m),
            Expanded(
              child: FactCard(
                value: '14.8 GB/s',
                label: 'Top speed of the fastest PCIe 5.0 [[SSD]]',
                comparison: '50× a hard drive',
                factId: 'HW-NVME5',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum _Drive { hdd, ssd }

/// Animated drawing: a spinning platter with a moving read arm, or a grid of flash cells lighting up.
class _DriveIllustration extends StatefulWidget {
  const _DriveIllustration({required this.kind});
  final _Drive kind;

  @override
  State<_DriveIllustration> createState() => _DriveIllustrationState();
}

class _DriveIllustrationState extends State<_DriveIllustration> with SingleTickerProviderStateMixin {
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
    final hdd = widget.kind == _Drive.hdd;
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Semantics(
            label: hdd
                ? 'A hard drive: a spinning disk with a moving read arm'
                : 'A solid-state drive: a grid of memory cells with no moving parts',
            child: AnimatedBuilder(
              animation: _t,
              builder: (_, _) => CustomPaint(
                painter: hdd ? _HddPainter(_t.value, c) : _SsdPainter(_t.value, c),
              ),
            ),
          ),
        ),
        const SizedBox(height: Gap.s),
        Text(hdd ? 'Hard drive (HDD)' : 'Solid-state drive (SSD)',
            textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
        Text(hdd ? 'the warehouse' : 'the instant shelf',
            textAlign: TextAlign.center, style: TextStyle(color: hdd ? c.amber : c.cyan, fontSize: 13)),
      ],
    );
  }
}

class _HddPainter extends CustomPainter {
  _HddPainter(this.t, this.c);
  final double t;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final center = Offset(size.width / 2, size.height / 2);
    final r = s * 0.42;
    // Case.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: s * 0.98, height: s * 0.98), Radius.circular(s * 0.06)),
      Paint()..color = c.surfaceHi,
    );
    // Platter with rings.
    canvas.drawCircle(center, r, Paint()
      ..shader = SweepGradient(
        colors: [c.textDim.withValues(alpha: 0.5), c.line, c.textDim.withValues(alpha: 0.6), c.line, c.textDim.withValues(alpha: 0.5)],
        transform: GradientRotation(t * math.pi * 2),
      ).createShader(Rect.fromCircle(center: center, radius: r)));
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = c.bg.withValues(alpha: 0.35);
    for (var i = 1; i < 6; i++) {
      canvas.drawCircle(center, r * i / 6, ring);
    }
    canvas.drawCircle(center, r * 0.12, Paint()..color = c.surface);
    // A data "spot" riding on the platter.
    final a = t * math.pi * 2;
    canvas.drawCircle(center + Offset(math.cos(a), math.sin(a)) * r * 0.7, s * 0.025, Paint()..color = c.amber);
    // Arm swinging slowly between tracks.
    final pivot = center + Offset(r * 0.95, r * 0.95);
    final swing = 0.35 + 0.25 * math.sin(t * math.pi * 2);
    final tip = pivot + Offset(-math.cos(swing), -math.sin(swing)) * r * 1.15;
    canvas.drawLine(pivot, tip, Paint()
      ..color = c.text.withValues(alpha: 0.8)
      ..strokeWidth = s * 0.03
      ..strokeCap = StrokeCap.round);
    canvas.drawCircle(pivot, s * 0.05, Paint()..color = c.text.withValues(alpha: 0.8));
    canvas.drawCircle(tip, s * 0.02, Paint()..color = c.amber);
  }

  @override
  bool shouldRepaint(_HddPainter old) => old.t != t;
}

class _SsdPainter extends CustomPainter {
  _SsdPainter(this.t, this.c);
  final double t;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final origin = Offset((size.width - s) / 2, (size.height - s) / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(origin & Size.square(s * 0.98), Radius.circular(s * 0.06)),
      Paint()..color = c.surfaceHi,
    );
    const n = 8;
    final cell = s * 0.82 / n;
    final start = origin + Offset(s * 0.08, s * 0.08);
    final rnd = math.Random((t * 12).floor());
    final lit = {for (var i = 0; i < 9; i++) rnd.nextInt(n * n)};
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        final on = lit.contains(y * n + x);
        final rect = Rect.fromLTWH(start.dx + x * cell, start.dy + y * cell, cell * 0.8, cell * 0.8);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(cell * 0.15)),
            Paint()..color = on ? c.cyan : c.line.withValues(alpha: 0.9));
        if (on) {
          canvas.drawRRect(RRect.fromRectAndRadius(rect.inflate(2), Radius.circular(cell * 0.2)),
              Paint()..color = c.cyan.withValues(alpha: 0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
        }
      }
    }
  }

  @override
  bool shouldRepaint(_SsdPainter old) => (old.t * 12).floor() != (t * 12).floor();
}

class _Racer {
  const _Racer(this.name, this.mbPerSec, this.colorOf);
  final String name;
  final double mbPerSec;
  final Color Function(AppColors) colorOf;
}

/// "Load the model" race: four drives load the same 16 GB file. Time runs 8× faster than real life.
class _LoadRace extends StatefulWidget {
  const _LoadRace();

  @override
  State<_LoadRace> createState() => _LoadRaceState();
}

class _LoadRaceState extends State<_LoadRace> with SingleTickerProviderStateMixin {
  static const fileMb = 16000.0; // a 16 GB model file (an 8B-parameter model at 16-bit)
  static const speedUp = 8.0;
  static final racers = [
    _Racer('Hard drive', 200, (c) => c.amber),
    _Racer('SATA SSD', 550, (c) => c.violet),
    _Racer('NVMe SSD (PCIe 4)', 7450, (c) => c.cyan),
    _Racer('NVMe SSD (PCIe 5)', 14800, (c) => c.lime),
  ];
  static final slowest = fileMb / racers.first.mbPerSec; // real seconds

  late final AnimationController _race = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (slowest / speedUp * 1000).round()),
  )..addListener(() => setState(() {}));

  @override
  void dispose() {
    _race.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final elapsed = _race.value * slowest; // real seconds simulated
    return DemoCard(
      title: 'Race: load a 16 GB model',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('An 8-billion-parameter model is about 16 GB. Before it can think, it must be copied from storage into memory.',
              style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.l),
          for (final r in racers) ...[
            _bar(context, r, elapsed),
            const SizedBox(height: Gap.m),
          ],
          const SizedBox(height: Gap.s),
          Row(
            children: [
              Expanded(
                child: Text('⏱ ${elapsed.toStringAsFixed(1)} s',
                    style: AppText.mono.copyWith(color: c.textDim, fontSize: 16)),
              ),
              FilledButton.icon(
                key: const ValueKey('race-start'),
                onPressed: () => _race.forward(from: 0),
                icon: Icon(_race.isCompleted ? Icons.replay : Icons.play_arrow),
                label: Text(_race.isCompleted ? 'Race again' : 'Load the model'),
              ),
            ],
          ),
          const SizedBox(height: Gap.xs),
          Text('Time shown 8× faster than real life.', style: TextStyle(color: c.textDim, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _bar(BuildContext context, _Racer r, double elapsed) {
    final c = AppColors.of(context);
    final total = fileMb / r.mbPerSec;
    final frac = (elapsed / total).clamp(0.0, 1.0);
    final done = frac >= 1;
    final color = r.colorOf(c);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(r.name, style: const TextStyle(fontWeight: FontWeight.w600))),
            Text(done ? 'done in ${humanSeconds(total)}' : '${(frac * 100).round()}%',
                style: AppText.mono.copyWith(fontSize: 13, color: done ? color : c.textDim)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: frac, minHeight: 12, color: color, backgroundColor: c.surfaceHi),
        ),
      ],
    );
  }
}
