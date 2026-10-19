import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 1 · "Feeding and cooling the beast": the power chain in, the heat chain out, PUE, water, and the
/// world total. Facts: DC-PUE, DC-WUE, DC-IEA, DC-POWER-SWING.
class S1PowerCoolingScreen extends StatelessWidget {
  const S1PowerCoolingScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's1_power_cooling',
        children: [_Chains(), _Pue()],
      );
}

const _power = [
  (Icons.electric_bolt, 'Power grid', 'High-voltage lines bring in electricity from power plants.'),
  (Icons.transform, 'Substation', 'Steps the voltage down to something the building can use.'),
  (Icons.battery_charging_full, 'Backup (UPS)', 'Batteries and generators keep the computers running if the grid blinks.'),
  (Icons.dns_outlined, 'Racks', 'Power is split out to every rack and server.'),
];

const _heat = [
  (Icons.memory, 'Chips', 'Almost every watt the chips use turns into heat.'),
  (Icons.water_drop_outlined, 'Coolant', 'Liquid in cold plates or chilled air picks the heat up.'),
  (Icons.ac_unit, 'Chillers', 'Heat exchangers and chillers move the heat out of the building\'s water loop.'),
  (Icons.cloud_outlined, 'Cooling towers', 'Evaporating a little water carries the heat into the sky, like sweat cooling skin.'),
];

class _Chains extends StatefulWidget {
  const _Chains();

  @override
  State<_Chains> createState() => _ChainsState();
}

class _ChainsState extends State<_Chains> with SingleTickerProviderStateMixin {
  bool _heatSide = false;
  int _sel = 0;
  bool? _flowPref; // null = follow the system's "reduce motion" setting

  late final AnimationController _t =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyFlow();
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  bool get _reduceMotion => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  bool get _flowing => _flowPref ?? !_reduceMotion;

  /// Electricity zips, heat drifts. With reduce-motion the dots stay put (t = 0) unless the
  /// learner explicitly presses play.
  void _applyFlow() {
    if (_t.isAnimating) _t.stop();
    if (!_flowing) {
      _t.value = 0;
      return;
    }
    _t.duration = Duration(milliseconds: _heatSide ? 4600 : 2600);
    _t.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final chain = _heatSide ? _heat : _power;
    final col = _heatSide ? c.red : c.amber;
    return DemoCard(
      title: 'Power in, heat out',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<bool>(
            key: const ValueKey('pc-side'),
            segments: const [
              ButtonSegment(value: false, label: Text('Power in'), icon: Icon(Icons.bolt)),
              ButtonSegment(value: true, label: Text('Heat out'), icon: Icon(Icons.local_fire_department_outlined)),
            ],
            selected: {_heatSide},
            showSelectedIcon: false,
            onSelectionChanged: (s) {
              setState(() {
                _heatSide = s.first;
                _sel = 0;
              });
              _applyFlow();
            },
          ),
          const SizedBox(height: Gap.m),
          Stack(
            children: [
              Row(
                children: [
                  for (var i = 0; i < chain.length; i++) ...[
                    if (i > 0) Icon(Icons.arrow_forward, size: 16, color: col.withValues(alpha: 0.7)),
                    Expanded(
                      child: GestureDetector(
                        key: ValueKey('pc-stage-$i'),
                        onTap: () => setState(() => _sel = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: Gap.m),
                          decoration: BoxDecoration(
                            color: i == _sel ? col.withValues(alpha: 0.25) : c.surfaceHi,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: i == _sel ? col : c.line),
                          ),
                          child: Icon(chain[i].$1, color: i == _sel ? col : c.textDim),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Semantics(
                    label: _heatSide
                        ? 'Red heat blobs drifting from left to right along the heat chain, from chips to cooling towers'
                        : 'Amber electricity dots flowing from left to right along the power chain, from the grid to the racks',
                    child: AnimatedBuilder(
                      animation: _t,
                      builder: (_, _) => CustomPaint(
                        painter: _FlowPainter(t: _t.value, color: col, heat: _heatSide),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.s),
          Row(
            children: [
              Expanded(
                child: Text(
                  _heatSide ? 'heat blobs drift out →' : 'power sparks zip in →',
                  key: const ValueKey('pc-flow-caption'),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: col, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                key: const ValueKey('pc-flow-toggle'),
                tooltip: _flowing ? 'Pause the flow' : 'Play the flow',
                visualDensity: VisualDensity.compact,
                iconSize: 20,
                onPressed: () {
                  setState(() => _flowPref = !_flowing);
                  _applyFlow();
                },
                icon: Icon(_flowing ? Icons.pause : Icons.play_arrow, color: col),
              ),
            ],
          ),
          const SizedBox(height: Gap.m),
          Text(chain[_sel].$2, key: const ValueKey('pc-title'), style: TextStyle(color: col, fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: Gap.xs),
          Text(chain[_sel].$3, style: TextStyle(color: c.text)),
          const SizedBox(height: Gap.m),
          const FactCard(
            value: 'tens of MW',
            label: 'sudden power swings when thousands of GPUs pause and restart together: the grid has to cope',
            factId: 'DC-POWER-SWING',
          ),
        ],
      ),
    );
  }
}

/// Particles flowing left→right over the stage chain: small sharp sparks for electricity,
/// bigger wobbling blobs for heat. Purely decorative drawing; the [Semantics] label around it
/// says what it shows.
class _FlowPainter extends CustomPainter {
  _FlowPainter({required this.t, required this.color, required this.heat});
  final double t; // 0..1, one trip across the chain
  final Color color;
  final bool heat;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final n = heat ? 5 : 7;
    final r = heat ? 3.6 : 2.2;
    final fade = size.width * 0.08; // fade at the ends so wrapping doesn't pop
    for (var i = 0; i < n; i++) {
      final phase = (t + i / n) % 1.0;
      final x = phase * size.width;
      final a = (math.min(x, size.width - x) / fade).clamp(0.0, 1.0);
      if (a <= 0) continue;
      // Two lanes above and below the middle so the dots don't sit on the stage icons.
      var y = cy + (i.isEven ? -1 : 1) * size.height * 0.24;
      if (heat) y += math.sin((phase * 3 + t) * 2 * math.pi) * size.height * 0.06;
      final glow = Paint()
        ..color = color.withValues(alpha: (heat ? 0.22 : 0.3) * a)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, heat ? 5 : 3);
      canvas.drawCircle(Offset(x, y), r * (heat ? 1.8 : 2.4), glow);
      canvas.drawCircle(Offset(x, y), r, Paint()..color = color.withValues(alpha: (heat ? 0.55 : 0.9) * a));
    }
  }

  @override
  bool shouldRepaint(_FlowPainter old) => old.t != t || old.color != color || old.heat != heat;
}

class _Pue extends StatefulWidget {
  const _Pue();

  @override
  State<_Pue> createState() => _PueState();
}

class _PueState extends State<_Pue> {
  double _pue = 1.54;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final overhead = _pue - 1;
    return DemoCard(
      title: 'The overhead score (PUE)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TermText('[[PUE]] = total power the building uses ÷ power the computers use. 1.0 would mean zero waste.',
              style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.m),
          LabeledSlider(
            key: const ValueKey('pc-pue'),
            label: 'PUE',
            value: _pue,
            min: 1.05,
            max: 2.0,
            color: c.amber,
            format: (v) => v.toStringAsFixed(2),
            onChanged: (v) => setState(() => _pue = v),
          ),
          Wrap(
            spacing: Gap.s,
            children: [
              ActionChip(label: const Text('Industry average 1.54'), onPressed: () => setState(() => _pue = 1.54)),
              ActionChip(label: const Text('Best sites ~1.1'), onPressed: () => setState(() => _pue = 1.1)),
            ],
          ),
          const SizedBox(height: Gap.m),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 28,
              child: Row(
                children: [
                  Expanded(flex: 100, child: Container(color: c.cyan, alignment: Alignment.center, child: const Text('computing', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w700)))),
                  Expanded(flex: (overhead * 100).round().clamp(1, 100), child: Container(color: c.amber)),
                ],
              ),
            ),
          ),
          const SizedBox(height: Gap.s),
          Text(
            'For every 1 W of computing, ${overhead.toStringAsFixed(2)} W more goes to cooling and power losses.',
            key: const ValueKey('pc-overhead'),
            style: TextStyle(color: c.text, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: Gap.m),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: FactCard(value: '~1.8 L', label: 'of water per kWh of computing, on average', factId: 'DC-WUE')),
              SizedBox(width: Gap.m),
              Expanded(child: FactCard(value: '~1.5%', label: 'of the world\'s electricity went to data centres in 2024', factId: 'DC-IEA')),
            ],
          ),
        ],
      ),
    );
  }
}
