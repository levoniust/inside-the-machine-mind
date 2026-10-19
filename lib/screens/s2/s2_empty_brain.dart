import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 2 · "Building an empty brain": the transformer block (tap the parts), random starting weights
/// ("a brain full of static"), and how layers × width give the knob count (≈ 12 × layers × width²).
/// Facts: TR-TRANSFORMER, TR-GPT3, TR-LLAMA3-ARCH.
class S2EmptyBrainScreen extends StatelessWidget {
  const S2EmptyBrainScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's2_empty_brain',
        children: [_Block(), _Static(), _Size()],
      );
}

/// Approximate knob count of a transformer: ~12 × layers × width² (attention ≈ 4w², feed-forward ≈ 8w²).
double approxParams(int layers, int width) => 12.0 * layers * width * width;

const _parts = [
  ('Embedding', 'a word\'s address on a map', 'Turns each token into a list of numbers.', Icons.place_outlined),
  ('Attention', 'deciding who to listen to', 'Each word looks at the earlier words and mixes in what matters.', Icons.hearing),
  ('Feed-forward', 'looking it up in memory', 'Transforms each word\'s numbers using stored knowledge. Most knobs live here.', Icons.memory),
  ('Output', 'scores for every word', 'Turns the result into a score for every word piece the model knows.', Icons.format_list_numbered),
];

class _Block extends StatefulWidget {
  const _Block();

  @override
  State<_Block> createState() => _BlockState();
}

class _BlockState extends State<_Block> {
  int _sel = 1;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final colors = [c.cyan, c.magenta, c.violet, c.amber];
    final p = _parts[_sel];
    Widget box(int i, {bool repeat = false}) => InkWell(
          key: ValueKey('brain-part-$i'),
          onTap: () => setState(() => _sel = i),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: Gap.m, horizontal: Gap.m),
            decoration: BoxDecoration(
              color: colors[i].withValues(alpha: _sel == i ? 0.3 : 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors[i], width: _sel == i ? 2 : 1),
            ),
            child: Row(
              children: [
                Icon(_parts[i].$4, color: colors[i]),
                const SizedBox(width: Gap.s),
                Expanded(child: Text(_parts[i].$1, style: const TextStyle(fontWeight: FontWeight.w700))),
              ],
            ),
          ),
        );
    return DemoCard(
      title: 'The blueprint: a transformer',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          box(0),
          const Icon(Icons.arrow_downward, size: 18),
          Container(
            padding: const EdgeInsets.all(Gap.s),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.line, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('one layer (repeated many times)', style: TextStyle(color: c.textDim, fontSize: 12)),
                const SizedBox(height: Gap.xs),
                box(1),
                const SizedBox(height: Gap.xs),
                box(2),
              ],
            ),
          ),
          const Icon(Icons.arrow_downward, size: 18),
          box(3),
          const SizedBox(height: Gap.m),
          Text('${p.$1}: ${p.$2}', key: const ValueKey('brain-caption'), style: TextStyle(color: colors[_sel], fontWeight: FontWeight.w800)),
          const SizedBox(height: Gap.xs),
          Text(p.$3, style: TextStyle(color: c.text)),
        ],
      ),
    );
  }
}

class _Static extends StatefulWidget {
  const _Static();

  @override
  State<_Static> createState() => _StaticState();
}

class _StaticState extends State<_Static> {
  int _seed = 1;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DemoCard(
      title: 'Before training: a brain full of static',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TermText(
            'Every knob starts as a small random number. The empty brain knows nothing: ask it anything and you get gibberish. '
            'Each square below is one knob (a real model has billions).',
            style: TextStyle(color: c.textDim),
          ),
          const SizedBox(height: Gap.m),
          AspectRatio(
            aspectRatio: 2,
            child: Semantics(
              label: 'Grid of random weights',
              child: ClipRRect(borderRadius: BorderRadius.circular(10), child: CustomPaint(painter: _NoisePainter(_seed, c))),
            ),
          ),
          const SizedBox(height: Gap.s),
          Center(
            child: OutlinedButton.icon(
              key: const ValueKey('brain-reroll'),
              onPressed: () => setState(() => _seed++),
              icon: const Icon(Icons.casino_outlined),
              label: const Text('Start a new random brain'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  _NoisePainter(this.seed, this.c);
  final int seed;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(seed);
    const cols = 48, rows = 24;
    final cw = size.width / cols, ch = size.height / rows;
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        final v = (r.nextDouble() * 2 - 1);
        canvas.drawRect(Rect.fromLTWH(x * cw, y * ch, cw + 0.5, ch + 0.5),
            Paint()..color = (v >= 0 ? c.cyan : c.magenta).withValues(alpha: 0.1 + 0.6 * v.abs()));
      }
    }
  }

  @override
  bool shouldRepaint(_NoisePainter old) => old.seed != seed || old.c != c;
}

class _Size extends StatefulWidget {
  const _Size();

  @override
  State<_Size> createState() => _SizeState();
}

class _SizeState extends State<_Size> {
  double _layers = 96;
  double _widthExp = math.log(12288) / math.ln2;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final width = math.pow(2, _widthExp).round();
    final params = approxParams(_layers.round(), width);
    return DemoCard(
      title: 'Taller and wider = more knobs',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: Gap.s,
            children: [
              ActionChip(
                label: const Text('GPT-3'),
                onPressed: () => setState(() {
                  _layers = 96;
                  _widthExp = math.log(12288) / math.ln2;
                }),
              ),
              ActionChip(
                label: const Text('Llama 3 405B'),
                onPressed: () => setState(() {
                  _layers = 126;
                  _widthExp = math.log(16384) / math.ln2;
                }),
              ),
            ],
          ),
          LabeledSlider(
            key: const ValueKey('brain-layers'),
            label: 'Layers (floors of the building)',
            value: _layers,
            min: 2,
            max: 128,
            divisions: 126,
            color: c.violet,
            format: (v) => '${v.round()}',
            onChanged: (v) => setState(() => _layers = v),
          ),
          LabeledSlider(
            key: const ValueKey('brain-width'),
            label: 'Width (numbers per token)',
            value: _widthExp,
            min: 8,
            max: 14,
            color: c.cyan,
            format: (v) => humanNumber(math.pow(2, v).toDouble(), digits: 0),
            onChanged: (v) => setState(() => _widthExp = v),
          ),
          const SizedBox(height: Gap.s),
          Center(
            child: Text('≈ ${humanNumber(params, digits: 0)} knobs',
                key: const ValueKey('brain-params'),
                style: AppText.mono.copyWith(fontSize: 28, fontWeight: FontWeight.w800, color: c.violet)),
          ),
          const SizedBox(height: Gap.s),
          Text('Rule of thumb: about 12 × layers × width². Check it: GPT-3 (96 layers × 12,288 wide) gives ~174 billion; '
              'the real number is 175 billion.',
              style: TextStyle(color: c.textDim, fontSize: 13)),
          const SizedBox(height: Gap.m),
          const Row(
            children: [
              Expanded(child: FactCard(value: '96 × 12,288', label: 'GPT-3: layers × width (175B knobs)', factId: 'TR-GPT3')),
              SizedBox(width: Gap.m),
              Expanded(child: FactCard(value: '126 × 16,384', label: 'Llama 3 405B: layers × width', factId: 'TR-LLAMA3-ARCH')),
            ],
          ),
        ],
      ),
    );
  }
}
