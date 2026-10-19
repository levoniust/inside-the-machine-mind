import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 1 · Lesson 3: System RAM.
/// The desk metaphor: papers are live data that blow away without power; memory channels are
/// lanes whose count you dial up to grow the bandwidth bar; a tap-race compares the ~80–100 ns
/// [[RAM]] answer with the ~100 µs SSD answer.
/// Facts: HW-DDR5-CH, HW-DDR5-SERVER, HW-DRAM-LAT, HW-NVME-LAT.
class S1RamScreen extends StatelessWidget {
  const S1RamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(1);
    return LessonScaffold(
      lessonId: 's1_ram',
      children: [
        const _DeskDemo(),
        const _ChannelDemo(),
        Row(
          children: [
            Expanded(
              child: FactCard(
                value: '44.8 GB/s',
                label: 'One 64-bit [[DDR5]]-5600 channel carries this much per second',
                comparison: 'one lane of the memory highway',
                factId: 'HW-DDR5-CH',
                color: accent,
              ),
            ),
            const SizedBox(width: Gap.m),
            Expanded(
              child: FactCard(
                value: '614 GB/s',
                label: 'A 12-lane server [[memory]] setup reaches this',
                comparison: '12 × 51.2 GB/s of DDR5-6400',
                factId: 'HW-DDR5-SERVER',
                color: c.violet,
              ),
            ),
          ],
        ),
        const _LatencyDemo(),
        Row(
          children: [
            Expanded(
              child: FactCard(
                value: '~80–100 ns',
                label: 'What [[RAM]] takes to answer one request',
                comparison: 'a thousand times quicker than reaching the shelf',
                factId: 'HW-DRAM-LAT',
                color: accent,
              ),
            ),
            const SizedBox(width: Gap.m),
            Expanded(
              child: FactCard(
                value: '~100 µs',
                label: 'What an [[SSD]] takes to answer the same request',
                comparison: '100,000 ns — about 1,000× the desk',
                factId: 'HW-NVME-LAT',
                color: c.amber,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Demo 1 · the desk (volatile memory)
// ---------------------------------------------------------------------------

class _DeskPaper {
  const _DeskPaper(this.x, this.y, this.w, this.h, this.rot, this.hot);
  final double x, y, w, h, rot;
  final bool hot;
}

final List<_DeskPaper> _deskPapers = () {
  final rnd = math.Random(7);
  return List<_DeskPaper>.generate(
    9,
    (i) => _DeskPaper(
      0.08 + rnd.nextDouble() * 0.74,
      0.10 + rnd.nextDouble() * 0.56,
      0.075 + rnd.nextDouble() * 0.06,
      0.11 + rnd.nextDouble() * 0.09,
      (rnd.nextDouble() - 0.5) * 0.5,
      i < 2,
    ),
  );
}();

/// A desk of papers the chip keeps grabbing. Flip the power and everything drifts away.
class _DeskDemo extends StatefulWidget {
  const _DeskDemo();

  @override
  State<_DeskDemo> createState() => _DeskDemoState();
}

class _DeskDemoState extends State<_DeskDemo> with TickerProviderStateMixin {
  late final AnimationController _t = AnimationController(vsync: this, duration: const Duration(seconds: 6));
  late final AnimationController _power = AnimationController(vsync: this, duration: const Duration(milliseconds: 700), value: 1);
  bool _on = true;

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
    _power.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(1);
    return DemoCard(
      title: 'The desk that forgets',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1.7,
            child: RepaintBoundary(
              child: Semantics(
                label: _on
                    ? 'A desk scattered with papers while a purple chip grabs one after another. Power is on.'
                    : 'An empty desk: all the papers have drifted away. Power is off, so the data is gone.',
                child: AnimatedBuilder(
                  animation: Listenable.merge([_t, _power]),
                  builder: (_, _) => CustomPaint(painter: _DeskPainter(t: _t.value, power: _power.value, c: c)),
                ),
              ),
            ),
          ),
          const SizedBox(height: Gap.m),
          TermText(
            _on
                ? 'This desk is [[RAM]]. The papers are the numbers the [[CPU]] is working with right now — close enough to grab in a blink.'
                : 'Power cut, papers gone. [[RAM]] is volatile: it holds data only while the power hums.',
            style: TextStyle(color: c.textDim, fontSize: 14),
          ),
          const SizedBox(height: Gap.s),
          Row(
            children: [
              Expanded(child: Text('Power', style: TextStyle(color: c.textDim))),
              SwitchTheme(
                data: SwitchThemeData(
                  thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? accent : c.textDim),
                  trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? accent.withValues(alpha: 0.45) : c.surfaceHi),
                ),
                child: Switch(
                  key: const ValueKey('ram-power'),
                  value: _on,
                  onChanged: (v) {
                    setState(() => _on = v);
                    if (v) {
                      _power.forward();
                    } else {
                      _power.reverse();
                    }
                  },
                ),
              ),
            ],
          ),
          Text(
            _on ? 'Power on — the mind is live.' : 'Power off — the desk was cleared.',
            style: TextStyle(color: _on ? accent : c.red, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _DeskPainter extends CustomPainter {
  _DeskPainter({required this.t, required this.power, required this.c});
  final double t;
  final double power;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final on = power;

    // The desk surface.
    final desk = RRect.fromRectAndRadius(Rect.fromLTWH(2, 2, w - 4, h - 4), const Radius.circular(18));
    canvas.drawRRect(desk, Paint()..color = c.amber.withValues(alpha: 0.07 + 0.05 * on));
    canvas.drawRRect(desk, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = c.amber.withValues(alpha: 0.5));

    // Papers = the data in use. When power drops they drift off and fade out.
    for (var i = 0; i < _deskPapers.length; i++) {
      final p = _deskPapers[i];
      final drop = 1 - on;
      final cx = p.x * w + drop * w * (i.isEven ? 0.05 + 0.012 * i : -(0.05 + 0.012 * i));
      final cy = p.y * h + drop * h * (0.24 + 0.028 * i);
      final pw = p.w * w, ph = p.h * h;
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(p.rot + drop * (i.isEven ? 0.8 : -0.8));
      final rect = Rect.fromCenter(center: Offset.zero, width: pw, height: ph);
      final rr = RRect.fromRectAndRadius(rect, Radius.circular(pw * 0.1));
      canvas.drawRRect(rr, Paint()..color = (p.hot ? c.cyan : c.surfaceHi).withValues(alpha: 0.95 * on));
      canvas.drawRRect(rr, Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = (p.hot ? c.cyan : c.line).withValues(alpha: 0.9 * on));
      final rule = Paint()..color = c.textDim.withValues(alpha: 0.45 * on)..strokeWidth = 1;
      for (var l = 1; l <= 3; l++) {
        final ly = -ph / 2 + ph * (l + 1) / 6;
        canvas.drawLine(Offset(-pw * 0.32, ly), Offset(pw * 0.32, ly), rule);
      }
      if (p.hot && on > 0.05) {
        canvas.drawRRect(RRect.fromRectAndRadius(rect.inflate(2), Radius.circular(pw * 0.14)),
            Paint()..color = c.cyan.withValues(alpha: 0.28 * on)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
      }
      canvas.restore();
    }

    // The processor at the desk edge, with pins.
    final chipW = w * 0.15;
    final chipC = Offset(w / 2, h - h * 0.05 - chipW / 2);
    final pin = Paint()..color = c.violet.withValues(alpha: 0.9)..strokeWidth = 2.5;
    for (var i = 0; i < 5; i++) {
      final px = chipC.dx - chipW / 2 + chipW * (i + 0.5) / 5;
      canvas.drawLine(Offset(px, chipC.dy + chipW / 2), Offset(px, chipC.dy + chipW / 2 + h * 0.04), pin);
    }
    final chip = RRect.fromRectAndRadius(Rect.fromCenter(center: chipC, width: chipW, height: chipW), const Radius.circular(7));
    canvas.drawRRect(chip, Paint()..color = c.violet);
    if (on > 0.02) {
      canvas.drawRRect(chip, Paint()..color = c.cyan.withValues(alpha: 0.4 * on)..maskFilter = MaskFilter.blur(BlurStyle.normal, 9 * on));
    }

    // The "grab": zips from the chip to a hot paper and back, over and over.
    if (on > 0.02) {
      final hots = _deskPapers.where((p) => p.hot).toList();
      final target = hots[(t * 4).floor() % hots.length];
      final k = math.sin(t * 4 % 1 * math.pi);
      final pos = Offset.lerp(Offset(chipC.dx, chipC.dy - chipW / 2), Offset(target.x * w, target.y * h), k)!;
      canvas.drawCircle(pos, 6, Paint()..color = c.cyan.withValues(alpha: 0.25 * on)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      canvas.drawCircle(pos, 3.4, Paint()..color = c.cyan.withValues(alpha: 0.95 * on));
    }
  }

  @override
  bool shouldRepaint(_DeskPainter old) => old.t != t || old.power != power;
}

// ---------------------------------------------------------------------------
// Demo 2 · memory channels as lanes (bandwidth)
// ---------------------------------------------------------------------------

class _LanePreset {
  const _LanePreset(this.channels, this.gb, this.formula);
  final int channels;
  final double gb;
  final String formula;

  String get display => gb == gb.roundToDouble() ? gb.toStringAsFixed(0) : gb.toStringAsFixed(1);
}

const List<_LanePreset> _lanePresets = [
  _LanePreset(1, 44.8, '1 lane × 44.8 GB/s — one DDR5-5600 channel'),
  _LanePreset(2, 89.6, '2 lanes × 44.8 GB/s — what a desktop has'),
  _LanePreset(8, 358.4, '8 lanes × 44.8 GB/s — a workstation board'),
  _LanePreset(12, 614.0, '12 lanes × 51.2 GB/s — server chips run DDR5-6400'),
];

const double _laneMaxGb = 614.0;

/// A DDR stick painted as a highway: slide the channel count, watch the lanes and the bar grow.
class _ChannelDemo extends StatefulWidget {
  const _ChannelDemo();

  @override
  State<_ChannelDemo> createState() => _ChannelDemoState();
}

class _ChannelDemoState extends State<_ChannelDemo> with SingleTickerProviderStateMixin {
  static const _rows = 12;
  late final AnimationController _flow = AnimationController(vsync: this, duration: const Duration(seconds: 5));
  int _i = 1; // a desktop default: two channels

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _flow.stop();
    } else if (!_flow.isAnimating) {
      _flow.repeat();
    }
  }

  @override
  void dispose() {
    _flow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(1);
    final p = _lanePresets[_i];
    return DemoCard(
      title: 'More lanes, more bandwidth',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TermText(
            'One [[DDR5]] channel is a 64-bit lane that carries 44.8 GB/s — [[bandwidth]] is how many lanes run at once.',
            style: TextStyle(color: c.textDim, fontSize: 14),
          ),
          const SizedBox(height: Gap.m),
          AspectRatio(
            aspectRatio: 2.3,
            child: RepaintBoundary(
              child: Semantics(
                label: 'A memory stick painted as a highway: ${p.channels} of $_rows lanes glowing, carrying '
                    '${p.display} gigabytes per second.',
                child: AnimatedBuilder(
                  animation: _flow,
                  builder: (_, _) => CustomPaint(painter: _DdrPainter(t: _flow.value, lanes: p.channels, c: c)),
                ),
              ),
            ),
          ),
          const SizedBox(height: Gap.xs),
          Text(
            'bright lanes = channels in use · dim lanes = empty slots on the stick',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.textDim, fontSize: 11),
          ),
          const SizedBox(height: Gap.s),
          Row(
            children: [
              Expanded(child: Text('Memory channels', style: TextStyle(color: c.textDim))),
              Text('${p.channels} lanes', style: AppText.mono.copyWith(fontWeight: FontWeight.w700, color: accent)),
            ],
          ),
          Slider(
            key: const ValueKey('ram-channels-slider'),
            value: _i.toDouble(),
            min: 0,
            max: (_lanePresets.length - 1).toDouble(),
            divisions: _lanePresets.length - 1,
            label: '${p.channels} lanes',
            semanticFormatterCallback: (v) => '${_lanePresets[v.round()].channels} memory channels',
            onChanged: (v) => setState(() => _i = v.round()),
          ),
          const SizedBox(height: Gap.s),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text('${p.display} GB/s',
                      key: const ValueKey('ram-bandwidth-value'),
                      style: AppText.mono.copyWith(fontSize: 30, fontWeight: FontWeight.w800, color: accent, height: 1.1)),
                ),
              ),
              Text('  per second', style: TextStyle(color: c.textDim, fontSize: 12)),
            ],
          ),
          const SizedBox(height: Gap.s),
          LayoutBuilder(
            builder: (context, box) => Stack(
              children: [
                Container(height: 14, decoration: BoxDecoration(color: c.surfaceHi, borderRadius: BorderRadius.circular(7))),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  height: 14,
                  width: box.maxWidth * p.gb / _laneMaxGb,
                  decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(7),
                      boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.5), blurRadius: 12)]),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.xs),
          Text(p.formula, style: AppText.mono.copyWith(fontSize: 12, color: c.textDim)),
        ],
      ),
    );
  }
}

class _DdrPainter extends CustomPainter {
  _DdrPainter({required this.t, required this.lanes, required this.c});
  final double t;
  final int lanes;
  final AppColors c;

  static const _rows = 12;
  static const _packetsPerLane = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final body = Rect.fromLTWH(3, 3, size.width - 6, size.height - 6);
    canvas.drawRRect(RRect.fromRectAndRadius(body, const Radius.circular(12)), Paint()..color = c.surfaceHi);
    canvas.drawRRect(RRect.fromRectAndRadius(body, const Radius.circular(12)),
        Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = c.line);

    // Gold edge connector with teeth and a keying notch.
    final conn = Rect.fromLTRB(body.left + 8, body.bottom - body.height * 0.15, body.right - 8, body.bottom - 6);
    canvas.drawRRect(RRect.fromRectAndRadius(conn, const Radius.circular(4)), Paint()..color = c.amber.withValues(alpha: 0.75));
    final gap = Paint()..color = c.surfaceHi;
    for (var x = conn.left + 3; x < conn.right - 3; x += 9) {
      canvas.drawRect(Rect.fromLTRB(x, conn.top + 2, x + 2.5, conn.bottom - 2), gap);
    }
    canvas.drawRect(Rect.fromLTWH(conn.left + conn.width * 0.62, conn.top, 6, conn.height), gap);

    // The lanes: 12 slots, the first `lanes` of them carrying traffic.
    final area = Rect.fromLTRB(body.left + 12, body.top + 10, body.right - 12, conn.top - 8);
    final rowH = area.height / _rows;
    for (var i = 0; i < _rows; i++) {
      final cy = area.top + (i + 0.5) * rowH;
      final active = i < lanes;
      canvas.drawLine(Offset(area.left, cy), Offset(area.right, cy), Paint()
        ..strokeWidth = rowH * 0.42
        ..strokeCap = StrokeCap.round
        ..color = active ? c.cyan.withValues(alpha: 0.28) : c.line.withValues(alpha: 0.45));
      for (var j = 0; j < _packetsPerLane; j++) {
        final f = (t + i * 0.11 + j / _packetsPerLane) % 1.0;
        final px = area.left + f * area.width;
        final ph = (rowH * 0.34).clamp(2.0, 6.0);
        final dot = Rect.fromCenter(center: Offset(px, cy), width: active ? rowH * 1.4 : rowH * 0.8, height: ph);
        if (active) {
          canvas.drawRRect(RRect.fromRectAndRadius(dot.inflate(1.6), Radius.circular(ph)),
              Paint()..color = c.cyan.withValues(alpha: 0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
        }
        canvas.drawRRect(RRect.fromRectAndRadius(dot, Radius.circular(ph / 2)),
            Paint()..color = active ? c.cyan.withValues(alpha: 0.95) : c.textDim.withValues(alpha: 0.3));
      }
    }
  }

  @override
  bool shouldRepaint(_DdrPainter old) => old.t != t || old.lanes != lanes;
}

// ---------------------------------------------------------------------------
// Demo 3 · latency: reach the desk or walk to the shelf
// ---------------------------------------------------------------------------

/// Tap an errand: fetching from the RAM desk (~100 ns) or the SSD shelf (~100 µs).
class _LatencyDemo extends StatefulWidget {
  const _LatencyDemo();

  @override
  State<_LatencyDemo> createState() => _LatencyDemoState();
}

class _LatencyDemoState extends State<_LatencyDemo> with SingleTickerProviderStateMixin {
  int _which = -1; // -1 = none, 0 = desk (RAM), 1 = shelf (SSD)
  bool _done = false;

  late final AnimationController _run = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..addListener(() => setState(() {}))
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) setState(() => _done = true);
    });

  void _go(int i) {
    setState(() {
      _which = i;
      _done = false;
    });
    _run.duration = i == 0 ? const Duration(milliseconds: 600) : const Duration(milliseconds: 1400);
    _run.forward(from: 0);
  }

  @override
  void dispose() {
    _run.dispose();
    super.dispose();
  }

  Widget _side(int i, IconData icon, String title, String sub, Color col) {
    final c = AppColors.of(context);
    final selected = _which == i;
    return Container(
      decoration: BoxDecoration(
        color: selected ? col.withValues(alpha: 0.10) : null,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? col : c.line, width: selected ? 2 : 1),
      ),
      child: Material(
        color: c.surface.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey(i == 0 ? 'lat-ram-btn' : 'lat-ssd-btn'),
          onTap: () => _go(i),
          child: Padding(
            padding: const EdgeInsets.all(Gap.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: col),
                    const SizedBox(width: Gap.xs),
                    Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
                  ],
                ),
                Text(sub, style: TextStyle(color: c.textDim, fontSize: 12)),
                const SizedBox(height: Gap.s),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(value: selected ? _run.value : 0, minHeight: 8, color: col, backgroundColor: c.surfaceHi),
                ),
                const SizedBox(height: Gap.xs),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(selected ? '${(_run.value * 100).round()} ${i == 0 ? 'ns' : 'µs'}' : 'tap to time it',
                      style: AppText.mono.copyWith(fontSize: 12, color: selected ? col : c.textDim, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(1);
    return DemoCard(
      title: 'Tap to time the errand: RAM vs SSD',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TermText(
            'One number can sit on the desk ([[RAM]]) or on the shelf ([[SSD]]). Tap where it lives and watch the clock until it arrives.',
            style: TextStyle(color: c.textDim, fontSize: 14),
          ),
          const SizedBox(height: Gap.m),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _side(0, Icons.article_outlined, 'The desk', 'system RAM', accent)),
              const SizedBox(width: Gap.m),
              Expanded(child: _side(1, Icons.shelves, 'The shelf', 'NVMe SSD', c.amber)),
            ],
          ),
          if (_done) ...[
            const SizedBox(height: Gap.m),
            TermText(
              _which == 0
                  ? 'The desk hands it over in about 80–100 ns — invisible to you. That is [[RAM]] [[latency]].'
                  : 'The shelf took ~100 µs: 100,000 ns, about 1,000× the desk. That is why spilling work out of [[RAM]] makes a model sluggish.',
              style: TextStyle(color: c.textDim, fontSize: 14),
            ),
          ],
          const SizedBox(height: Gap.l),
          Text('Time until the first number arrives (shorter is better):', style: TextStyle(color: c.textDim, fontSize: 13)),
          const SizedBox(height: Gap.s),
          CompareBars(
            log: true,
            highlight: _which,
            items: [
              BarItem('System RAM — the desk', 9e-8, display: '~80–100 ns', color: accent),
              BarItem('SSD — the shelf', 1e-4, display: '~100 µs', color: c.amber),
            ],
          ),
        ],
      ),
    );
  }
}
