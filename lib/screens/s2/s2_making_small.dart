import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 2 · "How small models are made": distillation (student imitates teacher), quantization (fewer bits per
/// number), mixture of experts (only some of the model works per token). Facts: TR-DISTILL, TR-QLORA, TR-MIXTRAL, TR-PHI3.
class S2MakingSmallScreen extends StatelessWidget {
  const S2MakingSmallScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's2_making_small',
        children: [_Tricks()],
      );
}

enum Trick { distill, quantize, moe }

class _Tricks extends StatefulWidget {
  const _Tricks();

  @override
  State<_Tricks> createState() => _TricksState();
}

class _TricksState extends State<_Tricks> {
  Trick _t = Trick.distill;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<Trick>(
          key: const ValueKey('small-trick'),
          segments: const [
            ButtonSegment(value: Trick.distill, label: Text('Teacher & student')),
            ButtonSegment(value: Trick.quantize, label: Text('Fewer bits')),
            ButtonSegment(value: Trick.moe, label: Text('Specialists')),
          ],
          selected: {_t},
          showSelectedIcon: false,
          onSelectionChanged: (s) => setState(() => _t = s.first),
        ),
        const SizedBox(height: Gap.l),
        switch (_t) {
          Trick.distill => const _Distill(),
          Trick.quantize => const _Quantize(),
          Trick.moe => const _Moe(),
        },
      ],
    );
  }
}

const _words = ['blue', 'grey', 'dark', 'clear', 'falling'];
const _teacher = [0.62, 0.16, 0.10, 0.09, 0.03];
const _untrained = [0.2, 0.2, 0.2, 0.2, 0.2];

class _Distill extends StatefulWidget {
  const _Distill();

  @override
  State<_Distill> createState() => _DistillState();
}

class _DistillState extends State<_Distill> {
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final student = [for (var i = 0; i < 5; i++) _untrained[i] + (_teacher[i] - _untrained[i]) * _progress];
    return DemoCard(
      key: const ValueKey('small-distill'),
      title: 'A teacher training a student',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TermText(
            'A big "teacher" model shows a small "student" its full list of chances for each next word, not just the right answer. '
            'The student learns to copy those chances: [[distillation]].',
            style: TextStyle(color: c.textDim),
          ),
          const SizedBox(height: Gap.m),
          Text('"The sky is ___"', style: TextStyle(color: c.text, fontWeight: FontWeight.w700)),
          const SizedBox(height: Gap.s),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Teacher (big)', style: TextStyle(color: c.violet, fontWeight: FontWeight.w800)),
                    CompareBars(color: c.violet, items: [for (var i = 0; i < 5; i++) BarItem(_words[i], _teacher[i], display: '${(_teacher[i] * 100).round()}%')]),
                  ],
                ),
              ),
              const SizedBox(width: Gap.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Student (small)', style: TextStyle(color: c.lime, fontWeight: FontWeight.w800)),
                    CompareBars(color: c.lime, items: [for (var i = 0; i < 5; i++) BarItem(_words[i], student[i], display: '${(student[i] * 100).round()}%')]),
                  ],
                ),
              ),
            ],
          ),
          LabeledSlider(
            key: const ValueKey('small-progress'),
            label: 'Student\'s training',
            value: _progress,
            min: 0,
            max: 1,
            color: c.lime,
            format: (v) => '${(v * 100).round()}%',
            onChanged: (v) => setState(() => _progress = v),
          ),
          Text(_progress > 0.9 ? 'The student now guesses almost exactly like the teacher, at a fraction of the size.' : 'Train the student…',
              key: const ValueKey('small-distill-note'), style: TextStyle(color: c.text, fontWeight: FontWeight.w600)),
          Text('Illustrative numbers.', style: TextStyle(color: c.textDim, fontSize: 11)),
          const SizedBox(height: Gap.m),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: FactCard(value: '2015', label: 'knowledge distillation was introduced', factId: 'TR-DISTILL')),
              SizedBox(width: Gap.m),
              Expanded(child: FactCard(value: '3.8B', label: 'Phi-3-mini: small enough for a phone', factId: 'TR-PHI3')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Quantize extends StatefulWidget {
  const _Quantize();

  @override
  State<_Quantize> createState() => _QuantizeState();
}

class _QuantizeState extends State<_Quantize> {
  double _bits = 8;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final b = _bits.round();
    return DemoCard(
      key: const ValueKey('small-quant'),
      title: 'Compressing a photo',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TermText(
            '[[Quantization]] stores every knob with fewer bits, like saving a photo with fewer colours. The picture gets rougher, '
            'but it\'s still recognisable, and much smaller.',
            style: TextStyle(color: c.textDim),
          ),
          const SizedBox(height: Gap.m),
          AspectRatio(
            aspectRatio: 1.8,
            child: Semantics(
              label: 'A sky picture stored with $b bits per colour',
              child: ClipRRect(borderRadius: BorderRadius.circular(12), child: CustomPaint(painter: _PosterPainter(b))),
            ),
          ),
          LabeledSlider(
            key: const ValueKey('small-bits'),
            label: 'Bits per number',
            value: _bits,
            min: 1,
            max: 16,
            divisions: 15,
            color: c.cyan,
            format: (v) => '${v.round()}',
            onChanged: (v) => setState(() => _bits = v),
          ),
          StatGrid(
            children: [
              StatTile(label: 'Levels per number', value: humanNumber(math.pow(2, b).toDouble(), digits: 0), color: c.cyan),
              StatTile(key: const ValueKey('small-size'), label: '70B model would be', value: '${(70 * b / 8).toStringAsFixed(b < 8 ? 1 : 0)} GB', color: c.lime),
            ],
          ),
          const SizedBox(height: Gap.m),
          const FactCard(value: '4-bit', label: 'enough to fine-tune a 65B model on a single 48 GB GPU (QLoRA)', factId: 'TR-QLORA'),
        ],
      ),
    );
  }
}

class _PosterPainter extends CustomPainter {
  _PosterPainter(this.bits);
  final int bits;

  @override
  void paint(Canvas canvas, Size size) {
    const cols = 64, rows = 36;
    final levels = math.pow(2, math.min(bits, 8)).toDouble() - 1;
    double q(double v) => levels <= 0 ? v.roundToDouble() : (v * levels).round() / levels;
    final cw = size.width / cols, ch = size.height / rows;
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        final u = x / cols, v = y / rows;
        // Sky gradient, sun and a hill, then quantized per channel.
        var r = 0.12 + 0.4 * v, g = 0.43 + 0.35 * v, b = 0.85 + 0.15 * v;
        final sun = math.sqrt(math.pow(u - 0.78, 2) + math.pow((v - 0.3) * 0.56, 2));
        if (sun < 0.09) {
          r = 1.0;
          g = 0.83;
          b = 0.3;
        }
        if (v > 0.78 - 0.25 * math.sin(u * math.pi)) {
          r = 0.18;
          g = 0.55 + 0.1 * (1 - v);
          b = 0.33;
        }
        canvas.drawRect(Rect.fromLTWH(x * cw, y * ch, cw + 0.6, ch + 0.6),
            Paint()..color = Color.fromARGB(255, (q(r.clamp(0, 1)) * 255).round(), (q(g.clamp(0, 1)) * 255).round(), (q(b.clamp(0, 1)) * 255).round()));
      }
    }
  }

  @override
  bool shouldRepaint(_PosterPainter old) => old.bits != bits;
}

class _Moe extends StatefulWidget {
  const _Moe();

  @override
  State<_Moe> createState() => _MoeState();
}

class _MoeState extends State<_Moe> {
  int _token = 0;
  static const _tokens = ['The', 'sky', 'is', 'blue', 'because', 'light', 'scatters'];
  List<int> _experts(int t) => [(t * 3 + 1) % 8, (t * 5 + 4) % 8];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final on = _experts(_token);
    return DemoCard(
      key: const ValueKey('small-moe'),
      title: 'A team of specialists',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TermText(
            'In a [[mixture of experts]], a little router sends each token to just 2 of 8 "expert" networks. The model has lots of '
            'knobs in total, but only a few are busy for each word, so it runs much faster than its size suggests.',
            style: TextStyle(color: c.textDim),
          ),
          const SizedBox(height: Gap.m),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < _tokens.length; i++)
                ChoiceChip(
                  key: ValueKey('small-token-$i'),
                  label: Text(_tokens[i]),
                  selected: i == _token,
                  selectedColor: c.magenta.withValues(alpha: 0.25),
                  onSelected: (_) => setState(() => _token = i),
                ),
            ],
          ),
          const SizedBox(height: Gap.m),
          StatGrid(
            columns: 4,
            children: [
              for (var e = 0; e < 8; e++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: on.contains(e) ? c.magenta : c.surfaceHi,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('expert ${e + 1}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: on.contains(e) ? Colors.white : c.textDim)),
                ),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text('"${_tokens[_token]}" → experts ${on.map((e) => e + 1).join(' & ')}', key: const ValueKey('small-moe-note'),
              style: AppText.mono.copyWith(color: c.text, fontWeight: FontWeight.w700)),
          const SizedBox(height: Gap.m),
          const FactCard(value: '12.9B of 46.7B', label: 'knobs Mixtral 8x7B uses per token', factId: 'TR-MIXTRAL'),
        ],
      ),
    );
  }
}
