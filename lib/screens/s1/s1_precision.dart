import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 1 · "How precise is a number?": π rounded the way each number format rounds it (real mantissa rounding),
/// a ruler that gets coarser, and the memory a 70B model needs. Facts: HW-FORMATS, DC-MODEL-MEM.
class S1PrecisionScreen extends StatelessWidget {
  const S1PrecisionScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's1_precision',
        children: [_Formats()],
      );
}

class NumFormat {
  const NumFormat(this.name, this.bits, this.mantissaBits);
  final String name;
  final int bits, mantissaBits;
  double get bytes => bits / 8;
}

const numFormats = [NumFormat('FP32', 32, 23), NumFormat('BF16', 16, 7), NumFormat('FP8', 8, 3), NumFormat('FP4', 4, 1)];

/// Round [v] (> 0) to a float with [m] mantissa bits (ignores exponent range limits, fine for values near π).
double roundToMantissa(double v, int m) {
  final e = (math.log(v) / math.ln2).floor();
  final scale = math.pow(2, e).toDouble();
  final frac = v / scale; // in [1, 2)
  final steps = math.pow(2, m).toDouble();
  return (frac * steps).round() / steps * scale;
}

class _Formats extends StatefulWidget {
  const _Formats();

  @override
  State<_Formats> createState() => _FormatsState();
}

class _FormatsState extends State<_Formats> {
  int _f = 1;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final f = numFormats[_f];
    final pi = roundToMantissa(math.pi, f.mantissaBits);
    final err = (pi - math.pi).abs();
    final gb = 70e9 * f.bytes / 1e9;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          title: 'Same number, coarser rulers',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<int>(
                key: const ValueKey('prec-format'),
                segments: [for (var i = 0; i < numFormats.length; i++) ButtonSegment(value: i, label: Text(numFormats[i].name))],
                selected: {_f},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _f = s.first),
              ),
              const SizedBox(height: Gap.m),
              // The bits as boxes.
              Wrap(
                spacing: 2,
                runSpacing: 2,
                children: [
                  for (var i = 0; i < f.bits; i++)
                    Container(
                      width: 9,
                      height: 16,
                      decoration: BoxDecoration(
                        color: i == 0 ? c.magenta : (i <= f.bits - 1 - f.mantissaBits ? c.amber : c.cyan),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Gap.xs),
              Text('${f.bits} bits = ${f.bytes == 0.5 ? '½ byte' : '${f.bytes.toStringAsFixed(0)} byte${f.bytes == 1 ? '' : 's'}'}  ·  '
                  'pink = sign, amber = size, cyan = detail',
                  style: TextStyle(color: c.textDim, fontSize: 12)),
              const SizedBox(height: Gap.l),
              Center(
                child: Column(
                  children: [
                    Text('π stored as ${f.name}:', style: TextStyle(color: c.textDim)),
                    Text(pi.toStringAsFixed(f.mantissaBits > 10 ? 7 : 6).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '.0'),
                        key: const ValueKey('prec-pi'),
                        style: AppText.mono.copyWith(fontSize: 32, fontWeight: FontWeight.w800, color: c.cyan)),
                    Text('off by ${err < 1e-6 ? 'less than a millionth' : err.toStringAsFixed(4)}',
                        style: TextStyle(color: err > 0.05 ? c.amber : c.lime)),
                  ],
                ),
              ),
              const SizedBox(height: Gap.m),
              SizedBox(
                height: 60,
                child: Semantics(
                  label: 'Ruler between 2 and 4 with ticks for each value ${f.name} can store',
                  child: CustomPaint(size: Size.infinite, painter: _RulerPainter(f.mantissaBits, pi, c)),
                ),
              ),
              Text('Every tick is a number this format can store between 2 and 4.', style: TextStyle(color: c.textDim, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
        DemoCard(
          title: 'Why bother with rougher numbers?',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CompareBars(
                highlight: _f,
                color: c.cyan,
                items: [for (final nf in numFormats) BarItem('70B model in ${nf.name}', 70 * nf.bytes, display: '${(70 * nf.bytes).toStringAsFixed(0)} GB')],
              ),
              const SizedBox(height: Gap.s),
              Text('In ${f.name}: ${gb.toStringAsFixed(0)} GB. Fewer bits = less memory to store and to move, and faster math.',
                  key: const ValueKey('prec-gb'), style: TextStyle(color: c.text, fontWeight: FontWeight.w600)),
              const SizedBox(height: Gap.s),
              const TermText(
                'Neural networks tolerate rounding surprisingly well, so training usually uses 16-bit numbers and running a model '
                'often uses 8 or even 4. Squeezing a finished model into fewer bits is called [[quantization]].',
              ),
              const SizedBox(height: Gap.m),
              const FactCard(value: '140 GB', label: 'a 70B model at 2 bytes (16 bits) per knob', factId: 'DC-MODEL-MEM'),
            ],
          ),
        ),
      ],
    );
  }
}

class _RulerPainter extends CustomPainter {
  _RulerPainter(this.m, this.value, this.c);
  final int m;
  final double value;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    double x(double v) => (v - 2) / 2 * size.width;
    canvas.drawLine(Offset(0, size.height * 0.6), Offset(size.width, size.height * 0.6), Paint()..color = c.line..strokeWidth = 2);
    final n = math.min(math.pow(2, m).toInt(), 256);
    for (var i = 0; i <= n; i++) {
      final v = 2 + 2 * i / n;
      canvas.drawLine(Offset(x(v), size.height * 0.4), Offset(x(v), size.height * 0.8),
          Paint()..color = c.textDim.withValues(alpha: n > 64 ? 0.4 : 0.9)..strokeWidth = n > 64 ? 0.6 : 1.5);
    }
    canvas.drawLine(Offset(x(math.pi), 0), Offset(x(math.pi), size.height), Paint()..color = c.magenta..strokeWidth = 2);
    canvas.drawCircle(Offset(x(value), size.height * 0.6), 6, Paint()..color = c.cyan);
  }

  @override
  bool shouldRepaint(_RulerPainter old) => old.m != m || old.c != c;
}
