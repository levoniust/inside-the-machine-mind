import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 1 · "A rack that thinks as one": the GB200 NVL72 rack (72 GPUs in one NVLink domain), air vs liquid
/// cooling toggle, and rack power vs a traditional rack. Facts: DC-NVL72, DC-NVL72-POWER, DC-WATER-VS-AIR.
class S1RackScreen extends StatelessWidget {
  const S1RackScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's1_rack',
        children: [_Rack()],
      );
}

class _Rack extends StatefulWidget {
  const _Rack();

  @override
  State<_Rack> createState() => _RackState();
}

/// Which kind of tray the user picked in the drawing or the legend.
enum _TrayKind { compute, switchTray }

class _RackState extends State<_Rack> with SingleTickerProviderStateMixin {
  bool _liquid = true;
  _TrayKind? _selected;
  late final AnimationController _t = AnimationController(vsync: this, duration: const Duration(seconds: 2));

  void _toggleKind(_TrayKind? kind) => setState(() => _selected = kind == _selected ? null : kind);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _t.value = 0.4;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          title: '72 GPUs, one giant brain',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<bool>(
                key: const ValueKey('rack-cooling'),
                segments: const [
                  ButtonSegment(value: false, label: Text('Air cooling'), icon: Icon(Icons.air)),
                  ButtonSegment(value: true, label: Text('Liquid cooling'), icon: Icon(Icons.water_drop_outlined)),
                ],
                selected: {_liquid},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _liquid = s.first),
              ),
              const SizedBox(height: Gap.m),
              Center(
                child: SizedBox(
                  width: 220,
                  child: AspectRatio(
                    aspectRatio: 0.55,
                    child: LayoutBuilder(
                      builder: (context, box) {
                        final size = Size(box.maxWidth, box.maxHeight);
                        return GestureDetector(
                          key: const ValueKey('rack-drawing'),
                          behavior: HitTestBehavior.opaque,
                          onTapUp: (d) => _toggleKind(_RackPainter.kindAt(size, d.localPosition)),
                          child: Semantics(
                            button: true,
                            label: '${_liquid ? 'Rack with coolant flowing through pipes' : 'Rack overheating with air cooling'}. '
                                'Tap a tray to identify it.',
                            child: AnimatedBuilder(
                              animation: _t,
                              builder: (_, _) => CustomPaint(painter: _RackPainter(_liquid, _t.value, c, _selected)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Gap.s),
              Row(
                children: [
                  Expanded(
                    child: _TrayChip(
                      key: const ValueKey('rack-legend-compute'),
                      color: c.cyan,
                      title: 'Compute tray',
                      detail: '4 GPUs + 2 CPUs',
                      selected: _selected == _TrayKind.compute,
                      onTap: () => _toggleKind(_TrayKind.compute),
                    ),
                  ),
                  const SizedBox(width: Gap.s),
                  Expanded(
                    child: _TrayChip(
                      key: const ValueKey('rack-legend-switch'),
                      color: c.violet,
                      title: 'Switch tray',
                      detail: 'NVLink switches',
                      selected: _selected == _TrayKind.switchTray,
                      onTap: () => _toggleKind(_TrayKind.switchTray),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Gap.s),
              TermText(
                key: const ValueKey('rack-tray-caption'),
                switch (_selected) {
                  _TrayKind.compute =>
                    'Compute tray — the workhorse of the rack: 4 GPUs and 2 CPUs in each one, and 18 × 4 = 72 GPUs all told.',
                  _TrayKind.switchTray =>
                    'Switch tray — packed with [[NVLink]] switches, the wiring that joins all 72 GPUs into one domain.',
                  null => 'Tap a tray in the drawing or a legend chip above to see what it is.',
                },
                style: TextStyle(color: c.textDim, fontSize: 13),
              ),
              const SizedBox(height: Gap.m),
              Text(
                _liquid
                    ? 'Cold liquid flows through metal plates sitting right on each chip and carries the heat away. Calm and cool.'
                    : 'Fans alone can\'t move heat fast enough with 72 hot chips packed this tightly: the chips would overheat and slow down.',
                key: const ValueKey('rack-caption'),
                style: TextStyle(color: _liquid ? c.lime : c.amber, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: Gap.m),
              Text('Power per rack', style: TextStyle(color: c.textDim)),
              const SizedBox(height: Gap.xs),
              CompareBars(
                items: [
                  BarItem('Traditional server rack', 8, display: '~5–10 kW', color: c.textDim),
                  BarItem('GB200 NVL72 AI rack', 132, display: '~120–132 kW', color: c.amber),
                ],
              ),
              const SizedBox(height: Gap.s),
              TermText(
                'All 72 GPUs share one [[NVLink]] network, so they act like a single enormous GPU with 13.4 TB of fast memory. '
                'Water carries about 3,500× more heat than the same amount of air, which is why these racks use [[liquid cooling]].',
                style: TextStyle(color: c.textDim, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
        const Row(
          children: [
            Expanded(child: FactCard(value: '130 TB/s', label: 'NVLink inside one NVL72 rack', factId: 'DC-NVL72')),
            SizedBox(width: Gap.m),
            Expanded(child: FactCard(value: '~3,500×', label: 'more heat carried by water than air, per volume', factId: 'DC-WATER-VS-AIR')),
          ],
        ),
      ],
    );
  }
}

/// A tappable legend entry: colour swatch + what that tray holds. Fills its parent width.
class _TrayChip extends StatelessWidget {
  const _TrayChip({super.key, required this.color, required this.title, required this.detail, required this.selected, required this.onTap});
  final Color color;
  final String title;
  final String detail;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Material(
      color: selected ? color.withValues(alpha: 0.14) : c.surfaceHi,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Gap.s, vertical: Gap.xs + 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? color : c.line, width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: Gap.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? color : c.text)),
                    Text(detail, style: TextStyle(fontSize: 11, color: c.textDim)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RackPainter extends CustomPainter {
  _RackPainter(this.liquid, this.t, this.c, this.selected);
  final bool liquid;
  final double t;
  final AppColors c;
  final _TrayKind? selected;

  // 18 compute trays (4 GPUs each) with 9 switch trays in the middle.
  static const int trays = 27;
  static Rect frameOf(Size size) => Rect.fromLTWH(size.width * 0.12, 0, size.width * 0.76, size.height);
  static bool isSwitchTray(int i) => i >= 9 && i < 18;
  static Rect trayRect(Size size, int i) {
    final f = frameOf(size);
    final th = (f.height - 12) / trays;
    return Rect.fromLTWH(f.left + 6, f.top + 6 + i * th, f.width - 12, th - 2);
  }

  /// Which kind of tray a tap inside the drawing landed on (null = rack background).
  static _TrayKind? kindAt(Size size, Offset p) {
    final f = frameOf(size);
    if (p.dx < f.left || p.dx > f.right || p.dy < 6) return null;
    final i = ((p.dy - 6) * trays / (f.height - 12)).floor();
    if (i < 0 || i >= trays) return null;
    return isSwitchTray(i) ? _TrayKind.switchTray : _TrayKind.compute;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final frame = frameOf(size);
    canvas.drawRRect(RRect.fromRectAndRadius(frame, const Radius.circular(8)), Paint()..color = c.surfaceHi);
    canvas.drawRRect(RRect.fromRectAndRadius(frame, const Radius.circular(8)), Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = c.line);
    for (var i = 0; i < trays; i++) {
      final isSwitch = isSwitchTray(i);
      final kind = isSwitch ? _TrayKind.switchTray : _TrayKind.compute;
      final r = trayRect(size, i);
      final heat = liquid ? 0.15 : 0.55 + 0.35 * math.sin(t * math.pi * 2 + i);
      final fade = selected != null && selected != kind ? 0.35 : 1.0;
      canvas.drawRect(r, Paint()
        ..color = (isSwitch ? c.violet : Color.lerp(c.cyan, c.red, heat)!)
            .withValues(alpha: (isSwitch ? 0.5 : 0.6) * fade));
      if (!isSwitch) {
        for (var g = 0; g < 4; g++) {
          canvas.drawRect(Rect.fromLTWH(r.left + 6 + g * (r.width - 12) / 4, r.top + 2, (r.width - 12) / 4 - 4, r.height - 4),
              Paint()..color = c.bg.withValues(alpha: 0.45 * fade));
        }
      }
      if (selected == kind) {
        canvas.drawRRect(RRect.fromRectAndRadius(r.inflate(0.5), const Radius.circular(2)), Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = (isSwitch ? c.violet : c.cyan));
      }
    }
    if (liquid) {
      // Blue supply pipe on the left, warm return on the right, with moving drops.
      final left = Offset(size.width * 0.06, 0), right = Offset(size.width * 0.94, 0);
      canvas.drawLine(left, left + Offset(0, size.height), Paint()..color = c.cyan..strokeWidth = 6);
      canvas.drawLine(right, right + Offset(0, size.height), Paint()..color = c.magenta..strokeWidth = 6);
      for (var k = 0; k < 8; k++) {
        final y = ((t + k / 8) % 1.0) * size.height;
        canvas.drawCircle(Offset(left.dx, y), 4, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(right.dx, size.height - y), 4, Paint()..color = Colors.white.withValues(alpha: 0.8));
      }
    } else {
      // Heat shimmer rising from the top.
      for (var k = 0; k < 5; k++) {
        final p = Path();
        for (var i = 0; i <= 20; i++) {
          final y = 64.0 - i * 3.0;
          final x = frame.left + frame.width * (0.15 + k * 0.17) + math.sin(i * 0.8 + t * math.pi * 4 + k) * 4;
          i == 0 ? p.moveTo(x, y) : p.lineTo(x, y);
        }
        canvas.drawPath(p, Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = c.amber.withValues(alpha: 0.7));
      }
    }
  }

  @override
  bool shouldRepaint(_RackPainter old) => old.t != t || old.liquid != liquid || old.c != c || old.selected != selected;
}
