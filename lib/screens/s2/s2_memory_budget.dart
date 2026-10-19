import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 2 · "What fills the GPU during training".
/// Mixed-precision training with the Adam optimizer keeps ~16 bytes per knob (DC-TRAIN-MEM):
/// 2 (16-bit weight) + 2 (16-bit gradient) + 4 (32-bit master weight) + 4 + 4 (Adam's two running averages).
/// Splitting ("sharding") those across GPUs is how giant models fit (ZeRO-style). Activations come on top.
class S2MemoryBudgetScreen extends StatelessWidget {
  const S2MemoryBudgetScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's2_memory_budget',
        children: [_Backpack(), _Budget()],
      );
}

class _Part {
  const _Part(this.name, this.everyday, this.bytes, this.colorOf);
  final String name, everyday;
  final int bytes;
  final Color Function(AppColors) colorOf;
}

final _parts = [
  _Part('Weight (16-bit)', 'the knob itself', 2, (c) => c.violet),
  _Part('Gradient (16-bit)', 'which way to turn it', 2, (c) => c.magenta),
  _Part('Master copy (32-bit)', 'the real weight, kept at full precision', 4, (c) => c.cyan),
  _Part('Adam momentum (32-bit)', 'recent direction', 4, (c) => c.lime),
  _Part('Adam variance (32-bit)', 'how bumpy the road has been', 4, (c) => c.amber),
];

/// Bytes of training state per parameter.
int get bytesPerParam => _parts.fold(0, (s, p) => s + p.bytes);

class _Backpack extends StatelessWidget {
  const _Backpack();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DemoCard(
      title: 'Every knob carries a backpack',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Running a model needs only the weight (2 bytes). Training needs all of this, for every single knob:',
              style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.m),
          Semantics(
            label: 'Stacked bar: 16 bytes per knob during training',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 36,
                child: Row(
                  children: [
                    for (final p in _parts)
                      Expanded(
                        flex: p.bytes,
                        child: Container(
                          color: p.colorOf(c),
                          alignment: Alignment.center,
                          child: Text('${p.bytes} B',
                              style: AppText.mono.copyWith(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 12)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: Gap.m),
          for (final p in _parts)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.xs),
              child: Row(
                children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: p.colorOf(c), borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: Gap.s),
                  Expanded(child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                  Flexible(child: Text(p.everyday, textAlign: TextAlign.end, style: TextStyle(color: c.textDim, fontSize: 13))),
                ],
              ),
            ),
          const Divider(),
          Row(
            children: [
              const Expanded(child: Text('Total per knob', style: TextStyle(fontWeight: FontWeight.w800))),
              Text('$bytesPerParam bytes', style: AppText.mono.copyWith(fontWeight: FontWeight.w800, color: c.violet)),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text('That\'s 8 times the 2 bytes needed just to run the model, before counting the "scratch paper" '
              '(activations) the forward pass leaves behind for the backward pass.',
              style: TextStyle(color: c.textDim, fontSize: 13)),
        ],
      ),
    );
  }
}

class _Budget extends StatefulWidget {
  const _Budget();

  @override
  State<_Budget> createState() => _BudgetState();
}

class _BudgetState extends State<_Budget> {
  double _p = math.log(70e9) / math.ln10; // log10(params)
  double _g = 3; // log2(GPUs sharing the state)

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final params = math.pow(10, _p).toDouble();
    final gpus = math.pow(2, _g).round();
    final totalGb = params * bytesPerParam / 1e9;
    final perGpu = totalGb / gpus;
    const hbm = 80.0;
    final fits = perGpu <= hbm * 0.7; // leave room for activations
    return DemoCard(
      title: 'Will it fit?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledSlider(
            key: const ValueKey('mem-params'),
            label: 'Model size (knobs)',
            value: _p,
            min: 9,
            max: math.log(405e9) / math.ln10,
            color: c.violet,
            format: (v) => humanNumber(math.pow(10, v).toDouble(), digits: 0),
            onChanged: (v) => setState(() => _p = v),
          ),
          LabeledSlider(
            key: const ValueKey('mem-gpus'),
            label: 'GPUs sharing the training state',
            value: _g,
            min: 0,
            max: 10,
            divisions: 10,
            color: c.cyan,
            format: (v) => '${math.pow(2, v).round()}',
            onChanged: (v) => setState(() => _g = v),
          ),
          const SizedBox(height: Gap.s),
          StatGrid(
            children: [
              StatTile(label: 'Training state in total', value: humanBytes(totalGb * 1e9), color: c.violet, icon: Icons.inventory_2_outlined),
              StatTile(label: 'Per GPU', value: humanBytes(perGpu * 1e9), color: fits ? c.lime : c.red, icon: Icons.memory),
            ],
          ),
          const SizedBox(height: Gap.m),
          Text('Each H100 has 80 GB. Keep some room for the scratch-paper activations:', style: TextStyle(color: c.textDim, fontSize: 13)),
          const SizedBox(height: Gap.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (perGpu / hbm).clamp(0, 1),
              minHeight: 16,
              color: fits ? c.lime : c.red,
              backgroundColor: c.surfaceHi,
            ),
          ),
          const SizedBox(height: Gap.s),
          Text(
            fits
                ? 'Fits, with room left for activations.'
                : (perGpu > hbm ? 'Doesn\'t fit at all: split it across more GPUs.' : 'Too tight: no room left for activations.'),
            key: const ValueKey('mem-verdict'),
            style: TextStyle(color: c.text, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: Gap.m),
          TermText(
            'Real training runs split this state across hundreds or thousands of [[GPUs|GPU]] ("sharding"), and also split '
            'the layers themselves ([[parallelism]]). Llama 3 405B needed about ${humanBytes(405e9 * 16)} of training state.',
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
          const SizedBox(height: Gap.m),
          const FactCard(
            value: '~16 bytes',
            label: 'per knob to train with the Adam optimizer in mixed precision (vs 2 bytes to run it)',
            factId: 'DC-TRAIN-MEM',
          ),
        ],
      ),
    );
  }
}
