import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 2 · "Now do it trillions of times": a training-compute calculator.
/// compute ≈ 6 × parameters × tokens (TR-6ND), run on H100s (989 TFLOPS BF16 dense, 700 W; HW-H100-FLOPS)
/// at a realistic utilization (Llama 3: 38–43%, TR-MFU). Presets from TR-GPT3, TR-CHINCHILLA, TR-LLAMA3-TOKENS.
class S2ScaleUpScreen extends StatelessWidget {
  const S2ScaleUpScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(lessonId: 's2_scale_up', children: [_Calculator()]);
}

/// The calculator's math (unit-tested).
class TrainingRun {
  const TrainingRun({required this.params, required this.tokens, required this.gpus, this.utilization = 0.4});
  final double params, tokens, gpus, utilization;

  static const h100Flops = 989e12; // BF16 dense
  static const h100Kw = 0.7;
  static const homeKwhPerYear = 10500.0;

  double get flops => 6 * params * tokens;
  double get gpuHours => flops / (h100Flops * utilization) / 3600;
  double get days => gpuHours / gpus / 24;
  double get gpuMwh => gpuHours * h100Kw / 1000;
  double get homeYears => gpuMwh * 1000 / homeKwhPerYear;
}

class _Preset {
  const _Preset(this.name, this.params, this.tokens, this.gpus, [this.note]);
  final String name;
  final double params, tokens, gpus;
  final String? note;
}

const _presets = [
  _Preset(
    'GPT-3 (2020)',
    175e9,
    300e9,
    1024,
    'Paper: ~3.14×10²³ FLOPs. GPT-3 really ran on older V100 GPUs; here we imagine 1,024 H100s.',
  ),
  _Preset(
    'Chinchilla (2022)',
    70e9,
    1.4e12,
    1024,
    'About 20 tokens per knob: the "compute-optimal" recipe. (The GPU count here is just for the demo.)',
  ),
  _Preset('Llama 3 405B (2024)', 405e9, 15.6e12, 16000, 'Meta reported ~3.8×10²⁵ FLOPs and 30.84 million H100-hours.'),
];

class _Calculator extends StatefulWidget {
  const _Calculator();

  @override
  State<_Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<_Calculator> {
  // Sliders work in log10 space so they can span huge ranges.
  double _p = math.log(405e9) / math.ln10;
  double _t = math.log(15.6e12) / math.ln10;
  double _g = math.log(16000) / math.ln10;
  double _u = 0.4;
  int? _preset = 2;

  double _pow(double e) => math.pow(10, e).toDouble();

  void _apply(int i) => setState(() {
    final p = _presets[i];
    _p = math.log(p.params) / math.ln10;
    _t = math.log(p.tokens) / math.ln10;
    _g = math.log(p.gpus) / math.ln10;
    _preset = i;
  });

  String _sci(double v) {
    final e = (math.log(v) / math.ln10).floor();
    final m = v / math.pow(10.0, e);
    const sup = {'0': '⁰', '1': '¹', '2': '²', '3': '³', '4': '⁴', '5': '⁵', '6': '⁶', '7': '⁷', '8': '⁸', '9': '⁹'};
    return '${m.toStringAsFixed(1)}×10${e.toString().split('').map((d) => sup[d]).join()}';
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final run = TrainingRun(params: _pow(_p), tokens: _pow(_t), gpus: _pow(_g), utilization: _u);
    final preset = _preset == null ? null : _presets[_preset!];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          title: 'The training-cost calculator',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: Gap.s,
                runSpacing: Gap.s,
                children: [
                  for (var i = 0; i < _presets.length; i++)
                    ChoiceChip(
                      key: ValueKey('scale-preset-$i'),
                      label: Text(_presets[i].name),
                      selected: _preset == i,
                      selectedColor: c.violet.withValues(alpha: 0.3),
                      onSelected: (_) => _apply(i),
                    ),
                ],
              ),
              const SizedBox(height: Gap.m),
              LabeledSlider(
                key: const ValueKey('scale-params'),
                label: 'Model size (knobs)',
                value: _p,
                min: 9,
                max: 12.3,
                color: c.violet,
                format: (v) => humanNumber(_pow(v), digits: 0),
                onChanged: (v) => setState(() {
                  _p = v;
                  _preset = null;
                }),
              ),
              LabeledSlider(
                key: const ValueKey('scale-tokens'),
                label: 'Training data (tokens)',
                value: _t,
                min: 10,
                max: 13.5,
                color: c.violet,
                format: (v) => humanNumber(_pow(v), digits: 0),
                onChanged: (v) => setState(() {
                  _t = v;
                  _preset = null;
                }),
              ),
              LabeledSlider(
                key: const ValueKey('scale-gpus'),
                label: 'Number of H100 GPUs',
                value: _g,
                min: 2,
                max: 5.3,
                color: c.cyan,
                format: (v) => humanNumber(_pow(v), digits: 0),
                onChanged: (v) => setState(() => _g = v),
              ),
              LabeledSlider(
                key: const ValueKey('scale-util'),
                label: 'Utilization (time GPUs spend actually computing)',
                value: _u,
                min: 0.2,
                max: 0.6,
                color: c.amber,
                format: (v) => '${(v * 100).round()}%',
                onChanged: (v) => setState(() => _u = v),
              ),
              const SizedBox(height: Gap.m),
              StatGrid(
                children: [
                  StatTile(label: 'Math steps (FLOPs)', value: _sci(run.flops), color: c.violet, icon: Icons.functions),
                  StatTile(label: 'GPU-hours', value: humanNumber(run.gpuHours, digits: 1), icon: Icons.memory),
                  StatTile(
                    key: const ValueKey('scale-days'),
                    label: 'Calendar time',
                    value: humanSeconds(run.days * 86400),
                    color: c.lime,
                    icon: Icons.calendar_month_outlined,
                  ),
                  StatTile(
                    label: 'GPU electricity',
                    value: '${humanNumber(run.gpuMwh, digits: 0)} MWh',
                    color: c.amber,
                    icon: Icons.bolt,
                  ),
                ],
              ),
              const SizedBox(height: Gap.s),
              Text(
                '≈ ${humanNumber(run.homeYears, digits: 0)} U.S. homes\' electricity for a year (GPUs only; cooling adds more).',
                style: TextStyle(color: c.textDim, fontSize: 13),
              ),
              if (preset?.note != null) ...[
                const SizedBox(height: Gap.s),
                Text(
                  'Reality check: ${preset!.note}',
                  key: const ValueKey('scale-note'),
                  style: TextStyle(color: c.lime, fontSize: 13),
                ),
              ],
              const SizedBox(height: Gap.m),
              TermText(
                'The recipe: [[compute]] ≈ 6 × knobs × tokens. Each token needs one multiply and one add per knob to make '
                'a guess (2), and about twice that again to pass the blame backward (4).',
                style: TextStyle(color: c.textDim, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FactCard(
                value: '38–43%',
                label: 'how much of the GPUs\' peak speed Llama 3 actually used',
                factId: 'TR-MFU',
              ),
            ),
            SizedBox(width: Gap.m),
            Expanded(
              child: FactCard(value: '1,287 MWh', label: 'estimated energy to train GPT-3', factId: 'TR-GPT3-ENERGY'),
            ),
          ],
        ),
      ],
    );
  }
}
