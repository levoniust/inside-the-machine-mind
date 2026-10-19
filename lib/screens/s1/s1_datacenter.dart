import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 1 · "Into the datacenter": a build-your-own datacenter dial.
/// Pick a GPU count (8 → 1,000,000); racks, power, homes-equivalent and cooling water follow, using
/// verified figures: GB200 NVL72 racks (72 GPUs, ~132 kW), PUE 1.54 average / ~1.1 best,
/// ~1.2 kW per average U.S. home, ~1.8 L of water per kWh (average).
/// Facts: DC-NVL72, DC-NVL72-POWER, DC-PUE, DC-HOME-KW, DC-WUE, DC-COLOSSUS1, DC-STARGATE.
class S1DatacenterScreen extends StatelessWidget {
  const S1DatacenterScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(lessonId: 's1_datacenter', children: [_Builder()]);
}

/// Pure math for the dial (unit-tested).
class DatacenterPlan {
  DatacenterPlan(this.gpus, {this.efficient = false});
  final double gpus;
  final bool efficient;

  static const gpusPerRack = 72; // GB200 NVL72
  static const kwPerRack = 132.0; // HPE nominal rack TDP
  static const kwPerHome = 1.2; // ~10,500 kWh / year
  static const litresPerKwh = 1.8; // industry average WUE

  int get racks => (gpus / gpusPerRack).ceil();
  double get pue => efficient ? 1.1 : 1.54;
  double get itKw => racks * kwPerRack;
  double get facilityKw => itKw * pue;
  double get homes => facilityKw / kwPerHome;
  double get waterLitresPerDay => itKw * 24 * (efficient ? 0.2 : litresPerKwh);
}

class _Builder extends StatefulWidget {
  const _Builder();

  @override
  State<_Builder> createState() => _BuilderState();
}

class _BuilderState extends State<_Builder> {
  double _exp = 3; // log10(GPUs)
  bool _efficient = false;

  double get gpus => math.pow(10, _exp).toDouble();

  String _power(double kw) => kw >= 1e6
      ? '${(kw / 1e6).toStringAsFixed(2)} GW'
      : kw >= 1000
      ? '${(kw / 1000).toStringAsFixed(kw >= 1e5 ? 0 : 1)} MW'
      : '${kw.toStringAsFixed(0)} kW';

  String get _scale {
    final g = gpus;
    if (g < 100) return 'A single rack: fits in a closet-sized room.';
    if (g < 5000) return 'A row of racks in one hall.';
    if (g < 60000) return 'A whole building full of halls.';
    if (g < 300000) return 'A campus: about the size of xAI\'s Colossus in Memphis (~100,000 GPUs).';
    return 'A gigawatt campus, like Stargate Abilene (450,000+ GPUs, 1.2 GW planned).';
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final plan = DatacenterPlan(gpus, efficient: _efficient);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          title: 'Build your datacenter',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1.3,
                child: Semantics(
                  label: 'Aerial view of a datacenter with ${plan.racks} racks',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomPaint(painter: _AerialPainter(plan.racks, c)),
                  ),
                ),
              ),
              const SizedBox(height: Gap.s),
              Text(
                _scale,
                key: const ValueKey('dc-scale'),
                style: TextStyle(color: c.text, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: Gap.s),
              LabeledSlider(
                key: const ValueKey('dc-gpus'),
                label: 'Number of GPUs',
                value: _exp,
                min: math.log(8) / math.ln10,
                max: 6,
                format: (v) => humanNumber(math.pow(10, v).toDouble(), digits: 0),
                onChanged: (v) => setState(() => _exp = v),
              ),
              Wrap(
                spacing: Gap.s,
                children: [
                  for (final (label, g) in const [('1 rack', 72.0), ('Colossus', 100000.0), ('Stargate', 450000.0)])
                    ActionChip(label: Text(label), onPressed: () => setState(() => _exp = math.log(g) / math.ln10)),
                ],
              ),
              SwitchListTile(
                key: const ValueKey('dc-efficient'),
                contentPadding: EdgeInsets.zero,
                title: const Text('Super-efficient design'),
                subtitle: const Text('Best-in-class overhead (PUE 1.1) and closed-loop liquid cooling'),
                value: _efficient,
                activeThumbColor: c.cyan,
                onChanged: (v) => setState(() => _efficient = v),
              ),
              const SizedBox(height: Gap.s),
              StatGrid(
                children: [
                  StatTile(
                    label: 'Racks (72 GPUs each)',
                    value: humanNumber(plan.racks.toDouble(), digits: 0),
                    icon: Icons.dns_outlined,
                  ),
                  StatTile(
                    key: const ValueKey('dc-power'),
                    label: 'Power, incl. cooling',
                    value: _power(plan.facilityKw),
                    color: c.amber,
                    icon: Icons.bolt,
                  ),
                  StatTile(
                    label: 'Same as … US homes',
                    value: humanNumber(plan.homes, digits: 0),
                    color: c.lime,
                    icon: Icons.home_outlined,
                  ),
                  StatTile(
                    label: 'Cooling water / day',
                    value: '${humanNumber(plan.waterLitresPerDay, digits: 1)} L',
                    color: c.cyan,
                    icon: Icons.water_drop_outlined,
                  ),
                ],
              ),
              const SizedBox(height: Gap.s),
              TermText(
                'Math: racks × ~132 kW per rack × [[PUE]] ${plan.pue} (overhead for cooling and power losses). '
                'Water: about ${_efficient ? '0.2' : '1.8'} litres per kWh of computing (${_efficient ? 'efficient closed-loop design' : 'average datacenter'}).',
                style: TextStyle(color: c.textDim, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
        const Row(
          children: [
            Expanded(
              child: FactCard(
                value: '~132 kW',
                label: 'one NVL72 [[rack]] of 72 GPUs, liquid-cooled',
                comparison: '110 U.S. homes',
                factId: 'DC-NVL72-POWER',
              ),
            ),
            SizedBox(width: Gap.m),
            Expanded(
              child: FactCard(value: '1 MW', label: '≈ the average use of ~830 U.S. homes', factId: 'DC-HOME-KW'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Aerial view: buildings filled with rack dots, plus cooling towers and a substation as it grows.
class _AerialPainter extends CustomPainter {
  _AerialPainter(this.racks, this.c);
  final int racks;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = c.isDark ? const Color(0xFF0A1410) : const Color(0xFFE3EBDD));
    // Up to 4 buildings; each building holds a grid of racks (each dot may stand for many racks).
    const maxDots = 400;
    final buildings = racks <= 20 ? 1 : (racks <= 1500 ? 1 : (racks <= 3000 ? 2 : 4));
    final perDot = math.max(1, (racks / maxDots).ceil());
    final dots = (racks / perDot).ceil();
    final bw = size.width * (buildings == 1 ? 0.62 : 0.34);
    final bh = size.height * (buildings <= 2 ? 0.62 : 0.34);
    final dotsPerBuilding = (dots / buildings).ceil();
    var drawn = 0;
    for (var b = 0; b < buildings; b++) {
      final ox = size.width * 0.06 + (b % 2) * (bw + size.width * 0.04);
      final oy = size.height * 0.08 + (b ~/ 2) * (bh + size.height * 0.06);
      final rect = Rect.fromLTWH(ox, oy, bw, bh);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), Paint()..color = c.surfaceHi);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = c.line,
      );
      final n = math.min(dotsPerBuilding, dots - drawn);
      final cols = math.max(1, math.sqrt(n * bw / bh).ceil());
      final rows = math.max(1, (n / cols).ceil());
      final cw = (bw - 12) / cols, ch = (bh - 12) / rows;
      final r = math.max(1.2, math.min(cw, ch) * 0.32);
      for (var i = 0; i < n; i++) {
        final p = Offset(ox + 6 + (i % cols + 0.5) * cw, oy + 6 + (i ~/ cols + 0.5) * ch);
        canvas.drawCircle(p, r, Paint()..color = c.cyan.withValues(alpha: 0.85));
      }
      drawn += n;
    }
    // Cooling towers + substation appear as the site grows.
    final towers = racks < 30 ? 0 : math.min(8, (math.log(racks) / math.ln10).floor() * 2 - 2);
    for (var i = 0; i < towers; i++) {
      final p = Offset(size.width * (0.75 + (i % 2) * 0.11), size.height * (0.12 + (i ~/ 2) * 0.2));
      canvas.drawCircle(p, size.width * 0.04, Paint()..color = c.textDim.withValues(alpha: 0.6));
      canvas.drawCircle(p, size.width * 0.025, Paint()..color = c.bg);
    }
    if (racks >= 100) {
      final sub = Rect.fromLTWH(size.width * 0.72, size.height * 0.84, size.width * 0.22, size.height * 0.1);
      canvas.drawRect(sub, Paint()..color = c.amber.withValues(alpha: 0.35));
      for (var i = 0; i < 4; i++) {
        canvas.drawLine(
          sub.topLeft + Offset(i * sub.width / 3, 0),
          sub.bottomLeft + Offset(i * sub.width / 3, 0),
          Paint()..color = c.amber,
        );
      }
    }
    final tp = TextPainter(
      text: TextSpan(
        text: perDot == 1 ? '● = 1 rack' : '● = $perDot racks',
        style: TextStyle(fontFamily: 'Roboto', color: c.textDim, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(8, size.height - tp.height - 6));
  }

  @override
  bool shouldRepaint(_AerialPainter old) => old.racks != racks || old.c != c;
}
