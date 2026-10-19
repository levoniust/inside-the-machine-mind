import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 1 · "Highways between the parts": the links that connect chips, compared as roads.
/// Facts: HW-SATA, HW-PCIE4, HW-PCIE5, HW-DDR5-CH, HW-IB, HW-NVLINK4, HW-NVLINK5.
class S1LinksScreen extends StatelessWidget {
  const S1LinksScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's1_links',
        children: [_Roads()],
      );
}

class Link {
  const Link(this.name, this.connects, this.gbs, this.factId);
  final String name, connects, factId;
  final double gbs; // GB/s, one direction
}

const links = [
  Link('SATA', 'old-style drives ↔ computer', 0.6, 'HW-SATA'),
  Link('PCIe 4.0 ×16', 'CPU ↔ GPU or SSD', 32, 'HW-PCIE4'),
  Link('PCIe 5.0 ×16', 'CPU ↔ GPU or SSD (newer)', 64, 'HW-PCIE5'),
  Link('InfiniBand 800 Gb/s', 'server ↔ server across the datacenter', 100, 'HW-IB'),
  Link('DDR5 (2 channels)', 'CPU ↔ system RAM', 89.6, 'HW-DDR5-CH'),
  Link('NVLink (H100)', 'GPU ↔ GPU inside a server', 900, 'HW-NVLINK4'),
  Link('NVLink 5 (Blackwell)', 'GPU ↔ GPU, up to 72 in a rack', 1800, 'HW-NVLINK5'),
];

class _Roads extends StatefulWidget {
  const _Roads();

  @override
  State<_Roads> createState() => _RoadsState();
}

class _RoadsState extends State<_Roads> with SingleTickerProviderStateMixin {
  int _sel = 5;
  late final AnimationController _t = AnimationController(vsync: this, duration: const Duration(seconds: 4));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _t.value = 0.5;
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
    final l = links[_sel];
    final secsFor80GB = 80 / l.gbs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          title: 'Pick a road',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: Gap.s,
                runSpacing: Gap.s,
                children: [
                  for (var i = 0; i < links.length; i++)
                    ChoiceChip(
                      key: ValueKey('link-$i'),
                      label: Text(links[i].name),
                      selected: _sel == i,
                      selectedColor: c.cyan.withValues(alpha: 0.25),
                      onSelected: (_) => setState(() => _sel = i),
                    ),
                ],
              ),
              const SizedBox(height: Gap.m),
              AspectRatio(
                aspectRatio: 2.4,
                child: Semantics(
                  label: '${l.name} drawn as a road with ${_lanes(l.gbs)} lanes',
                  child: AnimatedBuilder(
                    animation: _t,
                    builder: (_, _) => CustomPaint(painter: _RoadPainter(_lanes(l.gbs), l.gbs, _t.value, c)),
                  ),
                ),
              ),
              const SizedBox(height: Gap.m),
              Text(l.name, style: TextStyle(color: c.cyan, fontWeight: FontWeight.w800, fontSize: 16)),
              Text('Connects: ${l.connects}', style: TextStyle(color: c.text)),
              const SizedBox(height: Gap.s),
              StatGrid(
                children: [
                  StatTile(key: const ValueKey('link-speed'), label: 'Speed (one way)', value: '${_fmt(l.gbs)} GB/s', color: c.cyan),
                  StatTile(label: 'Time to move 80 GB', value: humanSeconds(secsFor80GB), color: c.amber),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => showFactSource(context, l.factId),
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Source'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
        DemoCard(
          title: 'All the roads',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CompareBars(
                log: true,
                highlight: _sel,
                items: [for (final x in links) BarItem(x.name, x.gbs, display: '${_fmt(x.gbs)} GB/s')],
              ),
              const SizedBox(height: Gap.m),
              const TermText(
                '[[Bandwidth]] is how wide the road is. The fastest roads are the shortest ones: [[NVLink]] runs between GPUs a few '
                'centimetres apart. Between servers across the datacenter, [[InfiniBand]] cables do the job.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  static int _lanes(double gbs) => (math.log(gbs * 10) / math.ln10 * 2).round().clamp(1, 9);
  static String _fmt(double v) => v < 10 ? v.toStringAsFixed(1) : v.round().toString();
}

class _RoadPainter extends CustomPainter {
  _RoadPainter(this.lanes, this.gbs, this.t, this.c);
  final int lanes;
  final double gbs, t;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final roadH = size.height * (0.25 + 0.75 * lanes / 9);
    final top = (size.height - roadH) / 2;
    canvas.drawRect(Rect.fromLTWH(0, top, size.width, roadH), Paint()..color = c.surfaceHi);
    final laneH = roadH / lanes;
    final dash = Paint()
      ..color = c.line
      ..strokeWidth = 1.5;
    for (var l = 1; l < lanes; l++) {
      for (var x = 0.0; x < size.width; x += 18) {
        canvas.drawLine(Offset(x, top + l * laneH), Offset(x + 9, top + l * laneH), dash);
      }
    }
    final speed = 0.3 + math.log(gbs * 10) / math.ln10 * 0.5;
    for (var l = 0; l < lanes; l++) {
      for (var k = 0; k < 4; k++) {
        final x = ((t * speed + k / 4 + l * 0.13) % 1.0) * (size.width + 30) - 30;
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x, top + l * laneH + laneH * 0.22, 24, laneH * 0.56), const Radius.circular(3)),
          Paint()..color = c.cyan.withValues(alpha: 0.85),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_RoadPainter old) => old.t != t || old.lanes != lanes || old.c != c;
}
