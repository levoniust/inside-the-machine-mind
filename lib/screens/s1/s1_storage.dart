import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Section 1 · Lesson 2: HDD vs SSD.
/// A spinning hard-drive platter next to a flash chip, then a race to load a 16 GB model file
/// from a hard drive, a SATA SSD and two NVMe SSDs (real speeds, time sped up 8×), and a
/// random-access demo: the HDD head hops over 5 random tracks while the SSD answers instantly.
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
        const _RandomAccessDemo(),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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

// Random-access demo constants. The simulated times come from facts.dart:
// HW-HDD-SEEK (~4–10 ms per random access; ~8 ms is used here) and HW-NVME-LAT (~0.1 ms per SSD read).
const _raTracks = 8; // circular tracks drawn on the platter
const _raCells = 8; // flash cells per side of the grid
const _raJumps = 5; // random pieces of data to fetch
const _raHddSec = 0.008; // simulated seconds per head seek
const _raSsdSec = 0.0001; // simulated seconds per flash read

/// Fraction of the platter radius for track [t] (0 = innermost ring, _raTracks - 1 = outermost).
double _raRadius(num t) => 0.42 + 0.53 * t / (_raTracks - 1);

/// Seconds shown as milliseconds, with one decimal only when it matters (8 ms, 0.5 ms, 40 ms).
String _raMs(double sec) {
  final ms = sec * 1000;
  return ms >= 10 || ms == ms.roundToDouble() ? '${ms.toStringAsFixed(0)} ms' : '${ms.toStringAsFixed(1)} ms';
}

/// "Random access": one tap fetches 5 scattered pieces. The HDD head hops between 5 random tracks —
/// each hop takes a real second to watch but stands for a ~8 ms seek (shown in slow motion) —
/// while the SSD lights its 5 random cells all at once, ~0.1 ms per read.
class _RandomAccessDemo extends StatefulWidget {
  const _RandomAccessDemo();

  @override
  State<_RandomAccessDemo> createState() => _RandomAccessDemoState();
}

class _RandomAccessDemoState extends State<_RandomAccessDemo> with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(
    vsync: this,
    duration: const Duration(seconds: _raJumps), // 1 s per hop, watched in slow motion
  )..addListener(() => setState(() {}));

  final math.Random _rnd = math.Random();
  int _run = 0;
  double _fromTrack = 0; // where the head rests before the current run
  List<int> _targets = const []; // the 5 random tracks, picked on each tap
  Set<int> _lit = const {}; // the 5 random flash cells, lit the instant the run starts

  int get _done => (_t.value * _raJumps).floor();

  /// Continuous track position of the read head: eases from track to track across the run.
  double get _headTrack {
    if (_targets.isEmpty) return _fromTrack;
    final pos = (_t.value * _raJumps).clamp(0.0, _raJumps.toDouble());
    final i = math.min(pos.floor(), _raJumps - 1);
    final f = Curves.easeInOutCubic.transform((pos - i).clamp(0.0, 1.0));
    final from = i == 0 ? _fromTrack : _targets[i - 1].toDouble();
    return from + (_targets[i] - from) * f;
  }

  int? get _targetRing => _targets.isEmpty ? null : _targets[math.min(_done, _raJumps - 1)];

  void _start() {
    final from = _targets.isEmpty ? 0.0 : _targets.last.toDouble();
    final lit = <int>{};
    while (lit.length < _raJumps) {
      lit.add(_rnd.nextInt(_raCells * _raCells));
    }
    setState(() {
      _fromTrack = from;
      _targets = List.generate(_raJumps, (_) => _rnd.nextInt(_raTracks));
      _lit = lit;
      _run++;
    });
    _t.forward(from: 0);
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final done = _done;
    final started = _run > 0;
    final running = _t.isAnimating;
    return DemoCard(
      title: 'Random access',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'A model file is stored in scattered pieces. Fetch 5 random pieces: the HDD must move its '
            'arm once per piece; the SSD just reads its cells.',
            style: TextStyle(color: c.textDim),
          ),
          const SizedBox(height: Gap.l),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Semantics(
                        label: 'Hard drive platter with $_raTracks circular tracks; the read head '
                            'is on seek $done of $_raJumps',
                        child: CustomPaint(
                          painter: _SeekPainter(_headTrack, _targetRing, running, c),
                        ),
                      ),
                    ),
                    const SizedBox(height: Gap.s),
                    const Text('Hard drive',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'seeks $done/$_raJumps · ${_raMs(done * _raHddSec)}',
                        style: AppText.mono
                            .copyWith(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.amber),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Gap.m),
              Expanded(
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Semantics(
                        label: 'Solid-state drive grid; ${started ? _raJumps : 0} of $_raJumps cells '
                            'lit at once',
                        child: CustomPaint(painter: _FlashPainter(started ? _lit : const {}, _run, c)),
                      ),
                    ),
                    const SizedBox(height: Gap.s),
                    const Text('SSD',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        started
                            ? 'reads $_raJumps/$_raJumps · ${_raMs(_raJumps * _raSsdSec)}'
                            : 'reads 0/$_raJumps · —',
                        style: AppText.mono
                            .copyWith(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.cyan),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.m),
          Text(
            'Slow motion: 1 s of watching = ${_raMs(_raHddSec)} of seeking',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
          const SizedBox(height: Gap.s),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                key: const ValueKey('random-access-start'),
                onPressed: _start,
                icon: Icon(running ? Icons.hourglass_top : Icons.play_arrow),
                label: Text(running ? 'Fetching…' : (started ? 'Again' : 'Fetch $_raJumps pieces')),
              ),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text(
            '$_raJumps × ~${_raMs(_raHddSec)} = ${_raMs(_raJumps * _raHddSec)} on the HDD · '
            '$_raJumps × ~${_raMs(_raSsdSec)} = ${_raMs(_raJumps * _raSsdSec)} on the SSD — '
            '${((_raHddSec / _raSsdSec).round())}× less waiting',
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// A static platter with track rings; the read arm slides radially so its head lands on [track].
class _SeekPainter extends CustomPainter {
  _SeekPainter(this.track, this.target, this.seeking, this.c);
  final double track; // continuous head position, 0.._raTracks - 1
  final int? target; // ring being sought (highlighted), null when idle
  final bool seeking;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final center = Offset(size.width / 2, size.height / 2);
    final r = s * 0.44;
    // Case.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: s * 0.98, height: s * 0.98), Radius.circular(s * 0.06)),
      Paint()..color = c.surfaceHi,
    );
    // Platter with track rings.
    canvas.drawCircle(center, r, Paint()..color = c.bg.withValues(alpha: 0.85));
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = c.line.withValues(alpha: 0.9);
    for (var i = 0; i < _raTracks; i++) {
      canvas.drawCircle(center, r * _raRadius(i), ring);
    }
    canvas.drawCircle(center, r * 0.16, Paint()..color = c.surfaceHi); // hub
    if (target != null) {
      canvas.drawCircle(
        center,
        r * _raRadius(target!),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.018
          ..color = c.amber.withValues(alpha: seeking ? 0.9 : 0.45),
      );
    }
    // Read head on its track, arm reaching from a fixed pivot outside the platter.
    const a = -math.pi * 0.78;
    final head = center + Offset(math.cos(a), math.sin(a)) * r * _raRadius(track);
    final pivot = center + Offset(s * 0.40, s * 0.40);
    canvas.drawLine(pivot, head, Paint()
      ..color = c.text.withValues(alpha: 0.8)
      ..strokeWidth = s * 0.028
      ..strokeCap = StrokeCap.round);
    canvas.drawCircle(pivot, s * 0.045, Paint()..color = c.text.withValues(alpha: 0.8));
    if (seeking) {
      canvas.drawCircle(head, s * 0.055, Paint()
        ..color = c.amber.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    }
    canvas.drawCircle(head, s * 0.022, Paint()..color = c.amber);
  }

  @override
  bool shouldRepaint(_SeekPainter old) =>
      old.track != track || old.target != target || old.seeking != seeking || old.c != c;
}

/// A flash grid with the [lit] cells glowing.
class _FlashPainter extends CustomPainter {
  _FlashPainter(this.lit, this.run, this.c);
  final Set<int> lit;
  final int run;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final origin = Offset((size.width - s) / 2, (size.height - s) / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(origin & Size.square(s * 0.98), Radius.circular(s * 0.06)),
      Paint()..color = c.surfaceHi,
    );
    final cell = s * 0.82 / _raCells;
    final start = origin + Offset(s * 0.08, s * 0.08);
    for (var y = 0; y < _raCells; y++) {
      for (var x = 0; x < _raCells; x++) {
        final on = lit.contains(y * _raCells + x);
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
  bool shouldRepaint(_FlashPainter old) => old.run != run || old.c != c;
}
