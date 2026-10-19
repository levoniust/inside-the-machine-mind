import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 1 · Lesson 4: the memory family.
/// A picker showing where each memory (SRAM cache, DDR5, LPDDR5X, GDDR6X, HBM3e) physically sits
/// relative to the chip, a race that streams 140 GB of model weights at real [[bandwidth]], and a
/// close-up of an HBM stack lying beside the GPU die.
/// Facts: HW-CACHE-LAT, HW-DDR5-CH, HW-LPDDR-M4MAX, HW-GDDR-4090, HW-HBM-H200, HW-HBM-STACK.
class S1MemoryTypesScreen extends StatelessWidget {
  const S1MemoryTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(1);
    return LessonScaffold(
      lessonId: 's1_memory_types',
      children: [
        const _MemoryExplorer(),
        Row(children: [
          Expanded(child: FactCard(
            value: '1,008 GB/s',
            label: 'Top [[GDDR6X]] on a flagship gaming [[GPU]]',
            comparison: '11× a whole desktop (89.6 GB/s)',
            factId: 'HW-GDDR-4090',
            color: c.amber,
          )),
          const SizedBox(width: Gap.m),
          Expanded(child: FactCard(
            value: '4.8 TB/s',
            label: '[[HBM3e]] right beside the H200 GPU die',
            comparison: '5× the RTX 4090, 54× DDR5 sticks',
            factId: 'HW-HBM-H200',
            color: c.magenta,
          )),
        ]),
        const _HbmStackCard(),
        Row(children: [
          Expanded(child: FactCard(
            value: '1024-bit',
            label: 'How wide one [[HBM]] stack talks to the GPU',
            comparison: '16× the lanes of one DDR5 stick (64-bit)',
            factId: 'HW-HBM-STACK',
            color: accent,
          )),
          const SizedBox(width: Gap.m),
          Expanded(child: FactCard(
            value: '546 GB/s',
            label: 'Apple M4 Max [[unified memory]] — LPDDR on the package',
            factId: 'HW-LPDDR-M4MAX',
            color: c.violet,
          )),
        ]),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// The family data
// ---------------------------------------------------------------------------

enum _Kind { cache, ddr5, lpddr, gddr, hbm }

class _Mem {
  _Mem(this.kind, this.name, this.racer, this.where, this.pill, this.bwText, this.gb, this.desc,
      this.colorOf, this.factId);
  final _Kind kind;
  final String name; // pill title
  final String racer; // leaderboard label
  final String where; // distance from the chip (StatTile)
  final String pill; // pill sub-line
  final String bwText; // displayed bandwidth
  final double? gb; // GB/s, or null for cache (too small to stream weights from)
  final String desc; // caption under the diagram
  final Color Function(AppColors) colorOf;
  final String factId;
  bool get canRace => gb != null;
}

final List<_Mem> _mems = [
  _Mem(_Kind.cache, 'SRAM cache', '—', 'inside the die', 'L1 ~1 ns', 'far too small', null,
      '[[Cache]] lives inside the processor itself — your pocket. L1 answers in about 1 nanosecond, but it is only megabytes big: nowhere near enough to hold model [[weights]].',
      (c) => c.lime, 'HW-CACHE-LAT'),
  _Mem(_Kind.ddr5, 'DDR5', 'Desktop · DDR5-5600', 'on a stick, across the board', '89.6 GB/s',
      '89.6 GB/s', 89.6,
      '[[DDR5]] sits on sticks centimeters from the chip and answers in about 80–100 ns. Two 64-bit lanes carry 89.6 GB/s together.',
      (c) => c.section(1), 'HW-DDR5-CH'),
  _Mem(_Kind.lpddr, 'LPDDR5X', 'Apple M4 Max · LPDDR5X', 'on the same package', '546 GB/s',
      '546 GB/s', 546,
      'LPDDR chips are soldered onto the same package as the processor, giving [[unified memory]] that the CPU and GPU share — 546 GB/s inside an M4 Max.',
      (c) => c.violet, 'HW-LPDDR-M4MAX'),
  _Mem(_Kind.gddr, 'GDDR6X', 'RTX 4090 · GDDR6X', 'ringing the GPU on the card', '1,008 GB/s',
      '1,008 GB/s', 1008,
      '[[GDDR6X]] chips flank the [[GPU]] on the card — close, cheap and fast: an RTX 4090 moves 1,008 GB/s.',
      (c) => c.amber, 'HW-GDDR-4090'),
  _Mem(_Kind.hbm, 'HBM3e', 'H200 · HBM3e', 'stacked beside the GPU die', '4,800 GB/s', '4,800 GB/s',
      4800,
      '[[HBM3e]] is a skyscraper of DRAM laid beside the [[GPU]] die on the same package: a 1024-bit link per stack, 4,800 GB/s on an H200.',
      (c) => c.magenta, 'HW-HBM-H200'),
];

/// The four memories that can stream weights, fastest first (for the leaderboard).
final List<_Mem> _racers = _mems.where((m) => m.canRace).toList()
  ..sort((a, b) => b.gb!.compareTo(a.gb!));

// ---------------------------------------------------------------------------
// Shared paint helpers
// ---------------------------------------------------------------------------

void _rr(Canvas cv, Rect r, double rad, Paint p) =>
    cv.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(rad)), p);

void _board(Canvas cv, Size size, AppColors c) {
  final r = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
  _rr(cv, r, 14, Paint()..color = c.surfaceHi);
  _rr(cv, r, 14, Paint()..style = PaintingStyle.stroke..color = c.line);
}

/// A channel between two points with [n] small packets gliding along it.
void _link(Canvas cv, Offset a, Offset b, double w, double t, Color col, {int n = 3}) {
  cv.drawLine(a, b, Paint()..strokeWidth = w..strokeCap = StrokeCap.round..color = col.withValues(alpha: 0.28));
  for (var i = 0; i < n; i++) {
    final f = (t + i / n) % 1.0;
    cv.drawCircle(Offset.lerp(a, b, f)!, (w * 0.28).clamp(1.5, 4.0), Paint()..color = col.withValues(alpha: 0.95));
  }
}

/// The processor die: a violet square with an inner grid.
void _die(Canvas cv, Rect r, AppColors c) {
  _rr(cv, r, r.width * 0.12, Paint()..color = c.violet);
  final g = Paint()..color = c.bg.withValues(alpha: 0.35)..strokeWidth = 1;
  for (var i = 1; i < 3; i++) {
    cv.drawLine(Offset(r.left + r.width * i / 3, r.top + 3), Offset(r.left + r.width * i / 3, r.bottom - 3), g);
    cv.drawLine(Offset(r.left + 3, r.top + r.height * i / 3), Offset(r.right - 3, r.top + r.height * i / 3), g);
  }
}

/// A memory block drawn in the shape typical for its kind (used in the race scene).
void _memBlock(Canvas cv, _Kind kind, double cx, double cy, double w, double h, Color col) {
  void slab(double top, double hh, double inset) => _rr(
      cv, Rect.fromLTWH(cx - w / 2 + inset, cy - h / 2 + top, w - 2 * inset, hh), 3,
      Paint()..color = col.withValues(alpha: 0.75));
  switch (kind) {
    case _Kind.hbm:
      const n = 10;
      final sh = h / (n * 1.35);
      for (var i = 0; i < n; i++) {
        slab(i * (sh * 1.35), sh, i == n - 1 ? -w * 0.12 : 0);
      }
    case _Kind.gddr:
      for (var i = 0; i < 3; i++) {
        slab(i * (h / 3) + h * 0.02, h / 3 - h * 0.04, w * 0.1);
      }
    case _Kind.lpddr:
      for (var i = 0; i < 3; i++) {
        slab(i * (h / 3) + h * 0.05, h / 3 - h * 0.1, w * 0.18);
      }
    case _Kind.ddr5:
    case _Kind.cache:
      _rr(cv, Rect.fromCenter(center: Offset(cx, cy), width: w, height: h), 5,
          Paint()..color = col.withValues(alpha: 0.45));
      final fin = Paint()..color = col.withValues(alpha: 0.9)..strokeWidth = 1;
      for (var i = 1; i < 4; i++) {
        final x = cx - w / 2 + w * i / 4;
        cv.drawLine(Offset(x, cy - h / 2 + 3), Offset(x, cy + h / 2 - 3), fin);
      }
  }
}

// ---------------------------------------------------------------------------
// Demo 1 + 2 · the family picker (where it lives) and the weight race
// ---------------------------------------------------------------------------

class _MemoryExplorer extends StatefulWidget {
  const _MemoryExplorer();

  @override
  State<_MemoryExplorer> createState() => _MemoryExplorerState();
}

class _MemoryExplorerState extends State<_MemoryExplorer> with TickerProviderStateMixin {
  static const payloadGb = 140.0; // a 70B-parameter model at 2 bytes per knob: 70 × 2 = 140 GB
  static const slowestGb = 89.6; // desktop DDR5 — used to scale the animation

  late final AnimationController _t = AnimationController(vsync: this, duration: const Duration(seconds: 4));
  late final AnimationController _race = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..addListener(() => setState(() {}));

  int _sel = 4; // HBM3e by default

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
    _race.dispose();
    super.dispose();
  }

  double _realSec(_Mem m) => payloadGb / m.gb!;

  /// Animation time compresses the huge speed spread (sqrt) so every race is watchable.
  void _go(_Mem m) {
    final k = math.sqrt(_realSec(m) / (payloadGb / slowestGb));
    _race.duration = Duration(milliseconds: (300 + 3200 * k).round());
    _race.forward(from: 0);
  }

  void _select(int i) {
    setState(() => _sel = i);
    _race.stop();
    _race.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final m = _mems[_sel];
    final col = m.colorOf(c);
    final real = m.canRace ? _realSec(m) : 0.0;
    final frac = _race.value;
    final done = _race.isCompleted && m.canRace;
    final gbNow = payloadGb * frac;
    final ddrRatio = m.canRace ? (payloadGb / slowestGb) / real : 0.0;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      DemoCard(
        title: 'The memory family: closer to the chip = faster',
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Wrap(
            spacing: Gap.s,
            runSpacing: Gap.s,
            children: [for (var i = 0; i < _mems.length; i++) _pill(_mems[i], i == _sel, c, i)],
          ),
          const SizedBox(height: Gap.m),
          AspectRatio(
            aspectRatio: 1.55,
            child: RepaintBoundary(
              child: Semantics(
                label: 'Diagram: ${m.name} sits ${m.where}.',
                child: AnimatedBuilder(
                  animation: _t,
                  builder: (_, _) => CustomPaint(painter: _FamilyPainter(kind: m.kind, col: col, t: _t.value, c: c)),
                ),
              ),
            ),
          ),
          const SizedBox(height: Gap.s),
          TermText(m.desc, style: TextStyle(color: c.textDim, fontSize: 14)),
          const SizedBox(height: Gap.m),
          Row(children: [
            Expanded(child: StatTile(label: 'distance from the chip', value: m.where, color: col)),
            const SizedBox(width: Gap.s),
            Expanded(child: StatTile(label: 'bandwidth', value: m.bwText, color: col)),
          ]),
        ]),
      ),
      const SizedBox(height: Gap.l),
      DemoCard(
        title: 'Race: stream 140 GB of weights',
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TermText(
            'A 70-billion-parameter model keeps 2 bytes per knob: 70 × 2 = **140 GB** of [[weights]]. '
            'Pick a memory above, press GO, and watch it pour in at that real speed.',
            style: TextStyle(color: c.textDim, fontSize: 14),
          ),
          const SizedBox(height: Gap.m),
          if (m.canRace) ...[
            AspectRatio(
              aspectRatio: 2.0,
              child: RepaintBoundary(
                child: Semantics(
                  label: 'Streaming ${gbNow.round()} of 140 gigabytes of model weights from ${m.name} into the GPU chip.',
                  child: CustomPaint(painter: _StreamPainter(kind: m.kind, gb: m.gb!, frac: frac, col: col, c: c)),
                ),
              ),
            ),
            const SizedBox(height: Gap.s),
            Row(children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text('${gbNow.toStringAsFixed(gbNow < 10 ? 1 : 0)} / 140 GB',
                      style: AppText.mono.copyWith(fontSize: 22, fontWeight: FontWeight.w800, color: col)),
                ),
              ),
              Text('⏱ ${humanSeconds(real * frac)}', style: AppText.mono.copyWith(color: c.textDim, fontSize: 14)),
            ]),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Gap.l),
              child: TermText(
                '[[Cache]] holds megabytes — nowhere near 140 GB. It keeps the handful of numbers the chip '
                'touches every step, not the weights. Pick one of the streaming memories below.',
                style: TextStyle(color: c.textDim, fontSize: 14),
              ),
            ),
          const SizedBox(height: Gap.s),
          Row(children: [
            Expanded(
              child: Text('animation slowed so you can watch · times are real',
                  style: TextStyle(color: c.textDim, fontSize: 11)),
            ),
            const SizedBox(width: Gap.s),
            FilledButton.icon(
              key: const ValueKey('race-go'),
              onPressed: m.canRace ? () => _go(m) : null,
              icon: Icon(_race.isCompleted ? Icons.replay : Icons.play_arrow),
              label: Text(_race.isCompleted ? 'Again' : 'GO'),
            ),
          ]),
          if (done) ...[
            const SizedBox(height: Gap.s),
            Text(
              'done in ${humanSeconds(real)}'
              '${ddrRatio > 1.05 ? ' · ${(ddrRatio >= 10 ? ddrRatio.round() : double.parse(ddrRatio.toStringAsFixed(1)))}× the DDR5 sticks' : ''}',
              key: const ValueKey('race-result'),
              style: TextStyle(color: col, fontWeight: FontWeight.w800),
            ),
          ],
          const SizedBox(height: Gap.l),
          Text('Real bandwidth of the racers:', style: TextStyle(color: c.textDim, fontSize: 13)),
          const SizedBox(height: Gap.xs),
          CompareBars(
            log: true,
            highlight: m.canRace ? _racers.indexOf(m) : null,
            items: [for (final r in _racers) BarItem(r.racer, r.gb!, display: r.bwText, color: r.colorOf(c))],
          ),
        ]),
      ),
    ]);
  }

  Widget _pill(_Mem m, bool sel, AppColors c, int i) {
    final col = m.colorOf(c);
    return InkWell(
      key: ValueKey('mem-pick-${m.kind.name}'),
      onTap: () => _select(i),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Gap.m, vertical: Gap.s),
        decoration: BoxDecoration(
          color: sel ? col.withValues(alpha: 0.14) : c.surfaceHi,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sel ? col : c.line, width: sel ? 2 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 9, height: 9, decoration: BoxDecoration(color: col, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(m.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
          const SizedBox(height: 2),
          Text(m.pill, style: AppText.mono.copyWith(fontSize: 11, color: c.textDim)),
        ]),
      ),
    );
  }
}

/// Where the selected memory physically lives, relative to the chip.
class _FamilyPainter extends CustomPainter {
  _FamilyPainter({required this.kind, required this.col, required this.t, required this.c});
  final _Kind kind;
  final Color col;
  final double t;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height, u = size.shortestSide;
    _board(canvas, size, c);
    final d = u * 0.38;
    final dieC = Offset(w * 0.38, h * 0.52);
    final die = Rect.fromCenter(center: dieC, width: d, height: d);

    switch (kind) {
      case _Kind.cache:
        break; // everything happens inside the die, drawn after it
      case _Kind.ddr5:
        final stick = Rect.fromLTWH(w * 0.74, h * 0.10, u * 0.13, h * 0.8);
        _rr(canvas, stick, 6, Paint()..color = col.withValues(alpha: 0.3));
        _rr(canvas, stick, 6, Paint()..style = PaintingStyle.stroke..color = col);
        _link(canvas, Offset(stick.left, stick.center.dy), Offset(die.right, dieC.dy), 5, t, col, n: 5);
      case _Kind.lpddr:
        final pkg = die.inflate(u * 0.15);
        _rr(canvas, pkg, 16, Paint()..color = col.withValues(alpha: 0.08));
        _rr(canvas, pkg, 16, Paint()..style = PaintingStyle.stroke..color = col.withValues(alpha: 0.6));
        final pads = [
          Rect.fromCenter(center: Offset(dieC.dx, pkg.top + u * 0.05), width: u * 0.17, height: u * 0.08),
          Rect.fromCenter(center: Offset(pkg.right - u * 0.05, dieC.dy), width: u * 0.08, height: u * 0.17),
          Rect.fromCenter(center: Offset(dieC.dx, pkg.bottom - u * 0.05), width: u * 0.17, height: u * 0.08),
        ];
        final ends = [Offset(dieC.dx, die.top), Offset(die.right, dieC.dy), Offset(dieC.dx, die.bottom)];
        for (var i = 0; i < pads.length; i++) {
          _rr(canvas, pads[i], 4, Paint()..color = col.withValues(alpha: 0.85));
          _link(canvas, pads[i].center, ends[i], 5, t + i * 0.33, col, n: 2);
        }
      case _Kind.gddr:
        final cw = u * 0.11, ch = u * 0.15;
        for (final dy in [-1.0, 0.0, 1.0]) {
          final cy = dieC.dy + dy * d * 0.42;
          final l = Rect.fromCenter(center: Offset(die.left - u * 0.16 - cw / 2, cy), width: cw, height: ch);
          final r = Rect.fromCenter(center: Offset(die.right + u * 0.16 + cw / 2, cy), width: cw, height: ch);
          for (final chip in [l, r]) {
            _rr(canvas, chip, 4, Paint()..color = col.withValues(alpha: 0.8));
          }
          _link(canvas, Offset(l.right, cy), Offset(die.left, cy), 4, t + dy, col, n: 2);
          _link(canvas, Offset(r.left, cy), Offset(die.right, cy), 4, t + dy, col, n: 2);
        }
      case _Kind.hbm:
        final tw = u * 0.15, slabH = u * 0.042, gap = u * 0.009;
        final th = 8 * (slabH + gap);
        for (var i = 0; i < 3; i++) {
          final x = die.right + u * 0.10 + i * (tw + u * 0.055);
          for (var j = 0; j < 8; j++) {
            final y = dieC.dy - th / 2 + j * (slabH + gap);
            _rr(canvas, Rect.fromLTWH(x, y, tw, slabH), 2, Paint()..color = col.withValues(alpha: 0.45 + 0.06 * j));
          }
        }
        _link(canvas, Offset(die.right + u * 0.10, dieC.dy), Offset(die.right, dieC.dy), u * 0.10, t, col, n: 4);
    }

    _die(canvas, die, c);

    if (kind == _Kind.cache) {
      // Stripes of SRAM on the die, handing numbers to the core next door.
      final st = Rect.fromLTWH(die.left + d * 0.15, die.top + d * 0.16, d * 0.7, d * 0.13);
      _rr(canvas, st, 3, Paint()..color = col.withValues(alpha: 0.5 + 0.3 * math.sin(t * 2 * math.pi)));
      for (var i = 1; i < 3; i++) {
        _rr(canvas, st.shift(Offset(0, d * (0.16 + 0.11 * i))), 3, Paint()..color = col.withValues(alpha: 0.35));
      }
      _link(canvas, Offset(st.center.dx, st.bottom), dieC + Offset(d * 0.12, d * 0.18), 3, t, col);
    }
  }

  @override
  bool shouldRepaint(_FamilyPainter old) => old.kind != kind || old.t != t || old.col != col;
}

/// Memory block on the left, GPU die on the right, a pipe whose width is the bandwidth,
/// filling to the streamed fraction with packets riding along.
class _StreamPainter extends CustomPainter {
  _StreamPainter({required this.kind, required this.gb, required this.frac, required this.col, required this.c});
  final _Kind kind;
  final double gb;
  final double frac;
  final Color col;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height, u = size.shortestSide;
    _board(canvas, size, c);

    final s = u * 0.52;
    final die = Rect.fromCenter(center: Offset(w * 0.845, h * 0.5), width: s, height: s);
    _die(canvas, die, c);
    if (frac > 0.02) {
      _rr(canvas, die, s * 0.12,
          Paint()..color = col.withValues(alpha: 0.55 * frac)..maskFilter = MaskFilter.blur(BlurStyle.normal, 14 * frac));
    }

    final bwW = u * 0.24;
    _memBlock(canvas, kind, w * 0.04 + bwW / 2, h * 0.5, bwW, u * 0.78, col);

    // Pipe: width grows with log(bandwidth) — a fatter road for faster memory.
    final logk = math.log(gb / 89.6) / math.ln10 / (math.log(4800 / 89.6) / math.ln10);
    final tw = u * (0.05 + 0.16 * logk).clamp(0.05, 0.21);
    final x0 = w * 0.04 + bwW + 4, x1 = die.left - 4;
    final cy = h * 0.5;
    _rr(canvas, Rect.fromLTWH(x0, cy - tw / 2, x1 - x0, tw), tw / 2, Paint()..color = col.withValues(alpha: 0.12));
    if (frac > 0.005) {
      _rr(canvas, Rect.fromLTWH(x0, cy - tw / 2, (x1 - x0) * frac, tw), tw / 2,
          Paint()..color = col.withValues(alpha: 0.32));
    }
    final rows = (tw / (u * 0.035)).floor().clamp(1, 6);
    for (var i = 0; i < rows; i++) {
      final f = (frac * 3 + i / rows) % 1.0;
      final px = x0 + f * (x1 - x0) * frac;
      final py = cy + (i + 0.5) / rows * tw - tw / 2;
      canvas.drawCircle(Offset(px, py), (tw / rows * 0.3).clamp(1.5, 4.5), Paint()..color = col.withValues(alpha: 0.95));
    }
  }

  @override
  bool shouldRepaint(_StreamPainter old) => old.kind != kind || old.gb != gb || old.frac != frac || old.col != col;
}

// ---------------------------------------------------------------------------
// Demo 3 · the HBM stack beside the GPU die
// ---------------------------------------------------------------------------

class _HbmStackCard extends StatefulWidget {
  const _HbmStackCard();

  @override
  State<_HbmStackCard> createState() => _HbmStackCardState();
}

class _HbmStackCardState extends State<_HbmStackCard> with SingleTickerProviderStateMixin {
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
    return DemoCard(
      title: 'Why HBM is a skyscraper',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AspectRatio(
          aspectRatio: 1.6,
          child: RepaintBoundary(
            child: Semantics(
              label: 'Cross-section: a tower of ten memory slabs standing beside a GPU die on one package, '
                  'with pulses flowing through a wide link into the GPU.',
              child: AnimatedBuilder(
                animation: _t,
                builder: (_, _) => CustomPaint(painter: _StackPainter(t: _t.value, c: c)),
              ),
            ),
          ),
        ),
        const SizedBox(height: Gap.s),
        TermText(
          'Each slab is a wafer of DRAM, stacked and laid flat right beside the [[GPU]] die — a few '
          'millimeters apart. Every layer drops straight down into a 1024-bit-wide link: **16× the '
          'lanes** of one DDR5 stick (1024 ÷ 64), each running short and easy.',
          style: TextStyle(color: c.textDim, fontSize: 14),
        ),
        const SizedBox(height: Gap.s),
        Text('distance ≈ 1 mm · the board road to a DDR5 stick ≈ 100 mm',
            style: AppText.mono.copyWith(color: c.magenta, fontSize: 12)),
      ]),
    );
  }
}

class _StackPainter extends CustomPainter {
  _StackPainter({required this.t, required this.c});
  final double t;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height, u = size.shortestSide;
    final col = c.magenta;
    _board(canvas, size, c);

    // GPU die.
    final s = u * 0.6;
    final dieC = Offset(w * 0.28, h * 0.56);
    _die(canvas, Rect.fromCenter(center: dieC, width: s, height: s), c);

    // The stack: 10 DRAM slabs with a glowing pulse running down them.
    const n = 10;
    final sw = u * 0.26, slabH = u * 0.055, gap = u * 0.012;
    final total = n * (slabH + gap);
    final sx = w * 0.68;
    final top = dieC.dy - total / 2;
    for (var i = 0; i < n; i++) {
      final y = top + i * (slabH + gap);
      final pulse = 0.55 + 0.35 * math.sin(t * 2 * math.pi - i * 0.55);
      _rr(canvas, Rect.fromLTWH(sx, y, sw, slabH), 2, Paint()..color = col.withValues(alpha: 0.35 + 0.35 * pulse));
    }
    // TSV: the straight down-pipe through the tower.
    canvas.drawLine(Offset(sx + sw / 2, top), Offset(sx + sw / 2, top + total),
        Paint()..color = c.cyan.withValues(alpha: 0.6)..strokeWidth = 2);
    canvas.drawCircle(Offset(sx + sw / 2, top + (t % 1.0) * total), 3.4,
        Paint()..color = c.cyan.withValues(alpha: 0.95));
    // Logic base slab, a bit wider, feeding the link.
    final base = Rect.fromLTWH(sx - sw * 0.08, top + total + gap, sw * 1.16, u * 0.065);
    _rr(canvas, base, 3, Paint()..color = c.lime.withValues(alpha: 0.85));

    // The wide, short link into the GPU die.
    _link(canvas, Offset(sx - sw * 0.08, base.center.dy), Offset(dieC.dx + s * 0.1, dieC.dy + s * 0.38), u * 0.16, t,
        col, n: 5);
  }

  @override
  bool shouldRepaint(_StackPainter old) => old.t != t;
}
