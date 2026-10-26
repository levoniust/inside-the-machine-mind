import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// A giant on a gaming PC: a mixture-of-experts layer only uses a few experts per token, so the experts can live in
/// system RAM while the always-used parts sit on the GPU (llama.cpp --cpu-moe / --n-cpu-moe / -ot).
class LMoeHomeScreen extends StatelessWidget {
  const LMoeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
    lessonId: 'l_moe_home',
    children: [
      _Router(),
      _Split(),
      FactCard(
        value: '8 of 128',
        label: 'experts work on each token in Qwen3-30B-A3B: 30.5B parameters in total, only 3.3B used per token',
        factId: 'RUN-SHAPE-Q30BA3B',
      ),
    ],
  );
}

/// One MoE layer: a router picks k experts per token; only those light up.
class _Router extends StatefulWidget {
  const _Router();

  @override
  State<_Router> createState() => _RouterState();
}

class _RouterState extends State<_Router> {
  static const _tokens = ['Why', 'is', 'the', 'sky', 'blue', '?'];
  static const _experts = 16, _k = 2;
  final _rng = math.Random(7);
  int _t = 0;
  late List<int> _picked = _pick();

  List<int> _pick() => (List.generate(_experts, (i) => i)..shuffle(_rng)).take(_k).toList();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(6);
    return DemoCard(
      title: 'One layer, many experts',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                key: const ValueKey('moe-token'),
                padding: const EdgeInsets.symmetric(horizontal: Gap.m, vertical: Gap.s),
                decoration: BoxDecoration(color: accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: Text('"${_tokens[_t]}"', style: AppText.mono.copyWith(fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: Gap.s),
              Icon(Icons.arrow_forward, color: c.textDim),
              const SizedBox(width: Gap.s),
              Expanded(
                child: Text('router picks $_k of $_experts experts', style: TextStyle(color: c.textDim)),
              ),
            ],
          ),
          const SizedBox(height: Gap.m),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var e = 0; e < _experts; e++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _picked.contains(e) ? accent : c.surfaceHi,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _picked.contains(e) ? accent : c.line),
                  ),
                  child: Text(
                    'E${e + 1}',
                    style: AppText.mono.copyWith(fontSize: 11, color: _picked.contains(e) ? c.bg : c.textDim),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Gap.m),
          FilledButton.icon(
            key: const ValueKey('moe-next'),
            style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: c.bg),
            onPressed: () => setState(() {
              _t = (_t + 1) % _tokens.length;
              _picked = _pick();
            }),
            icon: const Icon(Icons.skip_next),
            label: const Text('Next token'),
          ),
          const SizedBox(height: Gap.s),
          Text(
            'Drawn with 16 experts and 2 picks to keep it readable; real models have far more. '
            'The other experts sit idle for this token, so their weights are not read at all.',
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Parameter split from the official config.json files (computed: experts = layers × experts × 3 × hidden × expert size).
class _MoeModel {
  const _MoeModel(this.name, this.sharedB, this.expertsB, this.activeExpertsB, this.layers);
  final String name;
  final double sharedB, expertsB, activeExpertsB;
  final int layers;
}

const _models = [
  _MoeModel('Qwen3 30B-A3B', 1.51, 28.99, 1.81, 48),
  _MoeModel('gpt-oss-120b', 2.34, 114.66, 3.58, 36),
  _MoeModel('Qwen3 235B-A22B', 7.9, 227.1, 14.19, 94),
];

const _bpw = 4.8944; // Q4_K_M, whole-file average (RUN-BPW-FILE)
const _vramGB = 24.0, _gpuBW = 936.0; // one RTX 3090-class card (HW-GDDR-3090)
const _kvReserveGB = 2.0; // room for the KV cache and buffers (rough)

/// GPU vs system RAM: slide how many layers keep their experts on the GPU (llama.cpp --n-cpu-moe moves the rest).
class _Split extends StatefulWidget {
  const _Split();

  @override
  State<_Split> createState() => _SplitState();
}

class _SplitState extends State<_Split> {
  int _model = 0;
  int _gpuLayers = 0;
  bool _server = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(6);
    final m = _models[_model];
    final ramBW = _server ? 409.6 : 89.6;
    final gb = _bpw / 8;
    final sharedGB = m.sharedB * gb, expertsGB = m.expertsB * gb, activeExpertsGB = m.activeExpertsB * gb;
    final frac = _gpuLayers / m.layers;
    final vram = sharedGB + expertsGB * frac + _kvReserveGB;
    final ram = expertsGB * (1 - frac);
    final fits = vram <= _vramGB;
    final perToken = (sharedGB + activeExpertsGB * frac) / _gpuBW + activeExpertsGB * (1 - frac) / ramBW;
    final speed = 1 / perToken;
    return DemoCard(
      title: 'Experts in RAM, the rest on the GPU',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: Gap.xs,
            children: [
              for (var i = 0; i < _models.length; i++)
                ChoiceChip(
                  key: ValueKey('moe-model-$i'),
                  label: Text(_models[i].name),
                  selected: i == _model,
                  selectedColor: accent.withValues(alpha: 0.3),
                  onSelected: (_) => setState(() {
                    _model = i;
                    _gpuLayers = 0;
                  }),
                ),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text(
            'One 24 GB GPU (936 GB/s) + system RAM, model at Q4_K_M',
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
          const SizedBox(height: Gap.m),
          LabeledSlider(
            key: const ValueKey('moe-layers'),
            label: 'Layers with experts on the GPU',
            value: _gpuLayers.toDouble(),
            min: 0,
            max: m.layers.toDouble(),
            divisions: m.layers,
            format: (_) => '$_gpuLayers of ${m.layers}',
            color: accent,
            onChanged: (v) => setState(() => _gpuLayers = v.round()),
          ),
          SwitchListTile(
            key: const ValueKey('moe-server'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Server-class RAM (8 channels)'),
            subtitle: Text(_server ? 'DDR5-6400 × 8 channels ≈ 410 GB/s' : 'Desktop DDR5-5600 × 2 channels ≈ 90 GB/s'),
            value: _server,
            onChanged: (v) => setState(() => _server = v),
          ),
          SizedBox(
            height: 56,
            child: CustomPaint(
              painter: _SplitPainter(
                gpu: vram / _vramGB,
                over: !fits,
                gpuColor: accent,
                ramColor: c.amber,
                line: c.line,
                ramShare: ram / (ram + vram),
              ),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: Gap.s),
          StatGrid(
            columns: 2,
            children: [
              StatTile(
                key: const ValueKey('moe-vram'),
                label: 'On the GPU',
                value: '${vram.toStringAsFixed(1)} / 24 GB',
                color: fits ? accent : c.red,
              ),
              StatTile(label: 'Experts in RAM', value: '${ram.toStringAsFixed(1)} GB', color: c.amber),
              StatTile(
                key: const ValueKey('moe-speed'),
                label: 'Speed, upper bound',
                value: fits ? '≤ ${speed.round()} tok/s' : 'too big for VRAM',
                color: c.cyan,
              ),
              StatTile(
                label: 'Read per token',
                value:
                    '${(sharedGB + activeExpertsGB).toStringAsFixed(1)} GB of ${(sharedGB + expertsGB).toStringAsFixed(0)} GB',
                color: c.text,
              ),
            ],
          ),
          const SizedBox(height: Gap.s),
          Container(
            padding: const EdgeInsets.all(Gap.m),
            decoration: BoxDecoration(color: c.surfaceHi, borderRadius: BorderRadius.circular(8)),
            child: Text(
              _gpuLayers == 0
                  ? 'llama-server -m model.gguf -ngl 99 --cpu-moe'
                  : 'llama-server -m model.gguf -ngl 99 --n-cpu-moe ${m.layers - _gpuLayers}',
              key: const ValueKey('moe-cmd'),
              style: AppText.mono.copyWith(fontSize: 12, color: c.text),
            ),
          ),
          const SizedBox(height: Gap.xs),
          Text(
            '-ngl 99 puts every layer on the GPU; --cpu-moe then keeps all expert weights in RAM, and --n-cpu-moe N '
            'only those of the first N layers. Speeds are upper bounds from memory bandwidth.',
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SplitPainter extends CustomPainter {
  _SplitPainter({
    required this.gpu,
    required this.over,
    required this.gpuColor,
    required this.ramColor,
    required this.line,
    required this.ramShare,
  });
  final double gpu, ramShare;
  final bool over;
  final Color gpuColor, ramColor, line;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height / 2 - 6;
    // GPU box: filled to how full VRAM is
    final g = Rect.fromLTWH(0, 0, size.width, h);
    canvas.drawRRect(
      RRect.fromRectAndRadius(g, const Radius.circular(6)),
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width * gpu.clamp(0, 1), h), const Radius.circular(6)),
      Paint()..color = (over ? ramColor : gpuColor).withValues(alpha: 0.8),
    );
    // RAM row: share of the model that lives in system RAM
    final r = Rect.fromLTWH(0, h + 12, size.width, h);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(6)),
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, h + 12, size.width * ramShare.clamp(0, 1), h), const Radius.circular(6)),
      Paint()..color = ramColor.withValues(alpha: 0.6),
    );
  }

  @override
  bool shouldRepaint(_SplitPainter o) => o.gpu != gpu || o.ramShare != ramShare || o.over != over;
}
