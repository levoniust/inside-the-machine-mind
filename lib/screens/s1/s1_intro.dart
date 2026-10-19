import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 1 · Lesson 1: Where does a thought live?
/// A cut-away computer with labelled parts; a glowing "?" (one thought) tours the machine.
/// Tapping a part previews what its lesson covers and shows its headline numbers.
/// Facts: HW-HDD-SEEK, HW-NVME5, HW-DDR5-CH, HW-DRAM-LAT, HW-CACHE-LAT, HW-CPU-CORES,
/// HW-H100-CORES, HW-HBM-H100, HW-NVLINK4, HW-IB, DC-MODEL-MEM, DC-COLOSSUS1.
class S1IntroScreen extends StatelessWidget {
  const S1IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LessonScaffold(
      lessonId: 's1_intro',
      children: [
        _GuidedTour(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FactCard(
                value: '140 GB',
                label: 'Memory a 70-billion-parameter [[model]] needs just to sit still',
                comparison: 'more than the 80 GB in one H100 [[GPU]]',
                factId: 'DC-MODEL-MEM',
              ),
            ),
            SizedBox(width: Gap.m),
            Expanded(
              child: FactCard(
                value: '~100,000',
                label: 'H100 [[GPU]]s working as one [[datacenter]] (Colossus, Memphis)',
                comparison: 'a city block of chips, the first tranche built in ~4 months',
                factId: 'DC-COLOSSUS1',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum _Kind { storage, ram, cpu, gpu, network }

/// One labelled place a thought can live, with its preview text and numbers.
class _PartDef {
  const _PartDef({
    required this.id,
    required this.name,
    required this.chip,
    required this.everyday,
    required this.icon,
    required this.kind,
    required this.align,
    required this.blurb,
    required this.statA,
    required this.statB,
    required this.comingUp,
    this.ladder,
  });
  final String id, name, chip, everyday;
  final IconData icon;
  final _Kind kind;
  final Alignment align;
  final String blurb;
  final (String, String) statA, statB;
  final String comingUp;
  final int? ladder; // row highlighted in the speed-ladder chart
}

const _parts = [
  _PartDef(
    id: 'storage',
    name: 'Storage — hard drives & SSDs',
    chip: 'Storage',
    everyday: 'the warehouse',
    icon: Icons.storage_outlined,
    kind: _Kind.storage,
    align: Alignment(-0.56, 0.60),
    blurb: 'The model sleeps here: huge and cheap, but slow to search — a [[hard drive]] slides an arm '
        'over spinning platters to find anything. Before a thought can happen, everything gets copied '
        'out of the warehouse and upstairs.',
    statA: ('SSD top speed', '14.8 GB/s'),
    statB: ('Hard-drive seek', '~4–10 ms'),
    comingUp: 'Up next · Lesson 2 — The warehouse and the shelf',
    ladder: 0,
  ),
  _PartDef(
    id: 'ram',
    name: 'System RAM — the desk',
    chip: 'RAM',
    everyday: 'your desk',
    icon: Icons.grid_view_outlined,
    kind: _Kind.ram,
    align: Alignment(-0.70, -0.16),
    blurb: 'Whatever is being thought about right now is spread out here, tens of thousands of times '
        '(or more) quicker to reach than the warehouse. But the desk is small, and it goes blank when the power '
        'is cut — [[RAM]] is temporary by design.',
    statA: ('Desktop DDR5 bandwidth', '89.6 GB/s'),
    statB: ('Time to fetch', '~80–100 ns'),
    comingUp: 'Next stop · Lesson 3 — Your desk',
    ladder: 2,
  ),
  _PartDef(
    id: 'cpu',
    name: 'CPU — the master chefs',
    chip: 'CPU',
    everyday: 'a few master chefs',
    icon: Icons.restaurant_outlined,
    kind: _Kind.cpu,
    align: Alignment(0.0, 0.12),
    blurb: 'A handful of brilliant [[core]]s doing one clever thing after another, and running '
        'everything else in the machine. For an AI flood of numbers the [[CPU]] is the wrong tool — '
        'but it sets the table that the GPU eats at.',
    statA: ('Top desktop cores', '16'),
    statB: ('L1 cache wait', '~1 ns'),
    comingUp: 'Ahead · Lesson 5 — Master chefs vs an army of cooks',
    ladder: 3,
  ),
  _PartDef(
    id: 'gpu',
    name: 'GPU — the army of cooks',
    chip: 'GPU',
    everyday: 'an army of line cooks',
    icon: Icons.bolt_outlined,
    kind: _Kind.gpu,
    align: Alignment(0.62, -0.12),
    blurb: 'Thousands of simple workers that all do the same sum at once — the [[core|Core]] army — '
        'with memory ([[HBM]]) stacked right next door. This is where most of an LLM\'s thinking '
        'actually happens.',
    statA: ('Cores in one H100', '16,896'),
    statB: ('HBM bandwidth', '3.35 TB/s'),
    comingUp: 'Ahead · Lesson 5 — Master chefs vs an army of cooks',
    ladder: 2,
  ),
  _PartDef(
    id: 'network',
    name: 'The network — the nervous system',
    chip: 'Network',
    everyday: 'the datacenter\'s nervous system',
    icon: Icons.hub_outlined,
    kind: _Kind.network,
    align: Alignment(0.0, -0.70),
    blurb: 'One chip is never enough. [[NVLink]] cables inside a box and [[InfiniBand]] across the '
        'hall tie thousands of chips into one mind — the story of the rest of this section.',
    statA: ('NVLink, one GPU', '900 GB/s'),
    statB: ('InfiniBand port', '400 Gb/s'),
    comingUp: 'Ahead · Lesson 8 — Highways between the parts',
  ),
];

/// The interactive cut-away: painter + tap targets + chips + preview + speed ladder.
class _GuidedTour extends StatefulWidget {
  const _GuidedTour();

  @override
  State<_GuidedTour> createState() => _GuidedTourState();
}

const _cpu = 2; // part index the bus lines radiate from
const _tour = [0, 1, 2, 3, 4]; // parts visited by the thought, in order

class _GuidedTourState extends State<_GuidedTour> with SingleTickerProviderStateMixin {
  late final AnimationController _t =
      AnimationController(vsync: this, duration: const Duration(seconds: 16));
  bool _auto = false; // auto-start the tour only once
  bool _playing = false;
  int? _selected; // tapped part; pauses the tour there

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_auto) return;
    _auto = true;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return;
    _t.repeat();
    _playing = true;
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  void _select(int i) {
    _t.stop();
    setState(() {
      _playing = false;
      _selected = i;
    });
  }

  void _toggleTour() {
    setState(() {
      if (_t.isAnimating) {
        _t.stop();
        _playing = false;
      } else {
        _selected = null;
        _t.repeat();
        _playing = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(1);
    final sel = _selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          title: 'Follow one thought through the machine',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TermText(
                'A thought — like the words forming in your head right now — is numbers on the move. '
                'Tap any part of the cut-away to preview its lesson.',
                style: TextStyle(color: c.textDim),
              ),
              const SizedBox(height: Gap.m),
              AspectRatio(
                aspectRatio: 1.08,
                child: Semantics(
                  label: 'Cut-away of a computer: storage, RAM, a CPU, a GPU and a network link. '
                      'A glowing question-mark thought visits each part in turn.',
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: RepaintBoundary(
                          child: AnimatedBuilder(
                            animation: _t,
                            builder: (_, _) => CustomPaint(
                              painter: _MachinePainter(_t.value, sel, accent, c),
                            ),
                          ),
                        ),
                      ),
                      for (var i = 0; i < _parts.length; i++)
                        Align(
                          alignment: _parts[i].align,
                          child: GestureDetector(
                            key: ValueKey('intro-hit-${_parts[i].id}'),
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _select(i),
                            child: Semantics(
                              button: true,
                              label: 'Preview the lesson about ${_parts[i].name}',
                              child: const SizedBox(width: 46, height: 46),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Gap.m),
              Wrap(
                spacing: Gap.s,
                runSpacing: Gap.s,
                children: [for (var i = 0; i < _parts.length; i++) _chip(context, i, accent)],
              ),
              const SizedBox(height: Gap.s),
              Row(
                children: [
                  Expanded(
                    child: Text('The glowing "?" is one thought making the rounds.',
                        style: TextStyle(color: c.textDim, fontSize: 12)),
                  ),
                  FilledButton.tonalIcon(
                    key: const ValueKey('intro-tour'),
                    onPressed: _toggleTour,
                    icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
                    label: Text(_playing ? 'Pause' : 'Tour'),
                  ),
                ],
              ),
              const SizedBox(height: Gap.m),
              _preview(context, sel, accent),
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
        DemoCard(
          title: 'How long a thought waits',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Time until one small piece of data answers (shorter is better). The part you picked above is highlighted:',
                  style: TextStyle(color: c.textDim)),
              const SizedBox(height: Gap.m),
              CompareBars(
                log: true,
                highlight: sel == null ? null : _parts[sel].ladder,
                items: [
                  BarItem('Hard drive (arm must move)', 0.008, display: '~4–10 ms', color: c.amber),
                  BarItem('SSD answers', 0.0001, display: '~0.1 ms', color: c.violet),
                  BarItem('System RAM answers', 9e-8, display: '~80–100 ns', color: c.cyan),
                  BarItem('Cache inside the chip', 1e-9, display: 'L1 ~1 ns', color: c.lime),
                ],
              ),
              const SizedBox(height: Gap.s),
              const TermText(
                'From the slowest shelf to the chip\'s pocket is a gap of millions of times. '
                'That is why builders keep the thinking where the data already is.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(BuildContext context, int i, Color accent) {
    final c = AppColors.of(context);
    final p = _parts[i];
    final on = _selected == i;
    return ChoiceChip(
      key: ValueKey('intro-part-${p.id}'),
      selected: on,
      showCheckmark: false,
      avatar: Icon(p.icon, size: 18, color: on ? accent : c.textDim),
      label: Text(p.chip),
      labelStyle: TextStyle(color: on ? accent : c.text, fontWeight: on ? FontWeight.w800 : FontWeight.w500),
      selectedColor: accent.withValues(alpha: 0.14),
      backgroundColor: c.surfaceHi,
      side: BorderSide(color: on ? accent : c.line),
      onSelected: (_) => _select(i),
    );
  }

  Widget _preview(BuildContext context, int? sel, Color accent) {
    final c = AppColors.of(context);
    if (sel == null) {
      return Container(
        padding: const EdgeInsets.all(Gap.l),
        decoration: BoxDecoration(
          color: c.surfaceHi,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.line),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.help_outline, color: accent),
            const SizedBox(width: Gap.m),
            const Expanded(
              child: TermText('Which of these holds a thought? All of them, in relay — tap a part above to preview its lesson.'),
            ),
          ],
        ),
      );
    }
    final p = _parts[sel];
    return Container(
      key: ValueKey('intro-preview-${p.id}'),
      padding: const EdgeInsets.all(Gap.l),
      decoration: BoxDecoration(
        color: c.surfaceHi,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(p.icon, color: accent),
              const SizedBox(width: Gap.s),
              Expanded(child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
            ],
          ),
          const SizedBox(height: Gap.xs),
          Text('Everyday word: ${p.everyday}', style: TextStyle(color: c.lime, fontWeight: FontWeight.w700)),
          const SizedBox(height: Gap.s),
          TermText(p.blurb),
          const SizedBox(height: Gap.m),
          Row(
            children: [
              Expanded(child: StatTile(label: p.statA.$1, value: p.statA.$2, color: accent)),
              const SizedBox(width: Gap.s),
              Expanded(child: StatTile(label: p.statB.$1, value: p.statB.$2, color: accent)),
            ],
          ),
          const SizedBox(height: Gap.m),
          Row(
            children: [
              Icon(Icons.arrow_forward, size: 16, color: c.textDim),
              const SizedBox(width: Gap.xs),
              Expanded(child: Text(p.comingUp, style: TextStyle(color: c.textDim, fontSize: 13))),
            ],
          ),
        ],
      ),
    );
  }
}

/// Draws the machine case, bus lines, the five parts and the travelling "?" thought.
class _MachinePainter extends CustomPainter {
  _MachinePainter(this.t, this.selected, this.accent, this.c);
  final double t; // 0..1 tour loop
  final int? selected;
  final Color accent;
  final AppColors c;

  Offset _at(Size size, int i) => Offset(
        (_parts[i].align.x + 1) / 2 * size.width,
        (_parts[i].align.y + 1) / 2 * size.height,
      );

  /// Where the thought is, and which part it is sitting at / leaving.
  (Offset, int) _packet(Size size) {
    if (selected != null) return (_at(size, selected!), selected!);
    final n = _tour.length;
    final f = (t % 1.0) * n;
    final seg = f.floor() % n;
    final local = f - f.floor();
    const move = 0.62; // share of a segment spent travelling
    final a = _tour[seg], b = _tour[(seg + 1) % n];
    if (local < move) {
      final u = Curves.easeInOutCubic.transform(local / move);
      return (Offset.lerp(_at(size, a), _at(size, b), u)!, a);
    }
    return (_at(size, b), b);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    // Machine case.
    final box = Rect.fromLTWH(size.width * 0.02, size.height * 0.03, size.width * 0.96, size.height * 0.94);
    final caseR = RRect.fromRectAndRadius(box, const Radius.circular(18));
    canvas.drawRRect(caseR, Paint()..color = c.surfaceHi);
    canvas.drawRRect(
      caseR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = c.line,
    );

    // Bus lines from the CPU to every other part.
    final bus = Paint()
      ..color = c.line.withValues(alpha: 0.85)
      ..strokeWidth = 1.6;
    for (var i = 0; i < _parts.length; i++) {
      if (i != _cpu) canvas.drawLine(_at(size, _cpu), _at(size, i), bus);
    }

    // A few decorative solder pads.
    final rnd = math.Random(5);
    final pad = Paint()..color = c.line;
    for (var i = 0; i < 12; i++) {
      canvas.drawCircle(Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height), 1.6, pad);
    }

    final (packet, park) = _packet(size);
    final r = s * 0.075;
    for (var i = 0; i < _parts.length; i++) {
      _drawPart(canvas, _at(size, i), r, _parts[i].kind, lit: i == park || i == selected);
    }

    // The thought: a glowing packet carrying a "?".
    final pulse = 0.5 + 0.5 * math.sin(t * math.pi * 12);
    canvas.drawCircle(
      packet,
      s * (0.05 + 0.014 * pulse),
      Paint()
        ..color = accent.withValues(alpha: 0.3 + 0.15 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(packet, s * 0.03, Paint()..color = accent);
    final q = TextPainter(
      text: TextSpan(text: '?', style: TextStyle(color: c.bg, fontWeight: FontWeight.w900, fontSize: s * 0.042)),
      textDirection: TextDirection.ltr,
    )..layout();
    q.paint(canvas, packet - Offset(q.width / 2, q.height / 2));
  }

  void _drawPart(Canvas canvas, Offset at, double r, _Kind kind, {required bool lit}) {
    final col = lit ? accent : c.textDim;
    if (lit) {
      canvas.drawCircle(
        at,
        r * 1.9,
        Paint()
          ..color = accent.withValues(alpha: 0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
    final plate = RRect.fromRectAndRadius(Rect.fromCircle(center: at, radius: r), Radius.circular(r * 0.3));
    canvas.drawRRect(plate, Paint()..color = c.surface);
    canvas.drawRRect(
      plate,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = lit ? 2.2 : 1.4
        ..color = lit ? accent : c.line,
    );
    final g = Paint()..color = col;
    final stroke = Paint()
      ..color = col
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    switch (kind) {
      case _Kind.storage: // platter + arm
        canvas.drawCircle(at, r * 0.45, stroke);
        canvas.drawCircle(at, r * 0.09, g);
        canvas.drawLine(
          at + Offset(r * 0.5, r * 0.5),
          at + Offset(r * 0.08, r * 0.08),
          Paint()
            ..color = col
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round,
        );
      case _Kind.ram: // memory cells on a stick
        for (var i = -1; i <= 1; i++) {
          canvas.drawRect(
            Rect.fromLTWH(at.dx - r * 0.58 + (i + 1) * r * 0.42, at.dy - r * 0.28, r * 0.32, r * 0.56),
            g,
          );
        }
      case _Kind.cpu: // chip with pins
        canvas.drawRect(Rect.fromCenter(center: at, width: r * 0.84, height: r * 0.84), stroke);
        final pin = Paint()
          ..color = col
          ..strokeWidth = 1.8;
        for (var i = -1; i <= 1; i++) {
          canvas.drawLine(at + Offset(i * r * 0.45, -r * 0.88), at + Offset(i * r * 0.45, -r * 0.62), pin);
          canvas.drawLine(at + Offset(i * r * 0.45, r * 0.62), at + Offset(i * r * 0.45, r * 0.88), pin);
          canvas.drawLine(at + Offset(-r * 0.88, i * r * 0.45), at + Offset(-r * 0.62, i * r * 0.45), pin);
          canvas.drawLine(at + Offset(r * 0.62, i * r * 0.45), at + Offset(r * 0.88, i * r * 0.45), pin);
        }
      case _Kind.gpu: // grid of little cores
        final cell = r * 0.2;
        for (var gx = -1; gx <= 1; gx++) {
          for (var gy = -1; gy <= 1; gy++) {
            canvas.drawRect(
              Rect.fromCenter(center: at + Offset(gx * r * 0.44, gy * r * 0.44), width: cell, height: cell),
              g,
            );
          }
        }
      case _Kind.network: // broadcast arcs
        final arc = Paint()
          ..color = col
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round;
        final src = at + Offset(0, r * 0.38);
        for (var k = 1; k <= 3; k++) {
          canvas.drawArc(Rect.fromCircle(center: src, radius: r * 0.26 * k), -2.5, 1.9, false, arc);
        }
    }
  }

  @override
  bool shouldRepaint(_MachinePainter old) => old.t != t || old.selected != selected || old.accent != accent;
}
