import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Splitting a model across GPUs: layer split (an assembly line) vs tensor split (two people carrying one sofa),
/// a "Split it" game that places Llama 3.3 70B's 80 layers on two 24 GB cards and the CPU, and real home numbers.
/// Facts SPL-* (llama.cpp server README, Megatron-LM) and RIG-SPLIT-* (anonymized home lab).
class LSplitGpusScreen extends StatelessWidget {
  const LSplitGpusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.of(context).section(6);
    return LessonScaffold(
      lessonId: 'l_split_gpus',
      children: [
        const _TwoWays(),
        const _SplitIt(),
        const _HomeNumbers(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FactCard(
                value: '2 per layer',
                label: 'times tensor-split GPUs must swap results for every layer of every token',
                factId: 'SPL-SYNC',
                color: accent,
              ),
            ),
            const SizedBox(width: Gap.m),
            Expanded(
              child: FactCard(
                value: '300 GB/s',
                label: 'the GPU-to-GPU links Megatron-LM kept tensor splits on; a home PCIe 4.0 slot moves ~32',
                factId: 'SPL-NVSWITCH',
                color: accent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------
// Panel 1: the two ways, animated.

class _TwoWays extends StatefulWidget {
  const _TwoWays();

  @override
  State<_TwoWays> createState() => _TwoWaysState();
}

class _TwoWaysState extends State<_TwoWays> with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(vsync: this, duration: const Duration(seconds: 4));
  bool _tensor = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _t.value = 0.3;
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
    final accent = c.section(6);
    return DemoCard(
      title: 'Two ways to share one model',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Layer split'), icon: Icon(Icons.view_agenda_outlined)),
              ButtonSegment(value: true, label: Text('Tensor split'), icon: Icon(Icons.view_column_outlined)),
            ],
            selected: {_tensor},
            onSelectionChanged: (s) => setState(() => _tensor = s.first),
          ),
          const SizedBox(height: Gap.m),
          SizedBox(
            height: 210,
            child: AnimatedBuilder(
              animation: _t,
              builder: (context, _) => CustomPaint(
                key: ValueKey(_tensor ? 'split-anim-tensor' : 'split-anim-layer'),
                painter: _SplitPainter(
                  tensor: _tensor,
                  t: _t.value,
                  gpu1: accent,
                  gpu2: c.cyan,
                  line: c.line,
                  text: c.textDim,
                  sync: c.amber,
                ),
                size: Size.infinite,
              ),
            ),
          ),
          const SizedBox(height: Gap.s),
          TermText(
            key: ValueKey(_tensor ? 'split-explain-tensor' : 'split-explain-layer'),
            _tensor
                ? '**Two people carrying one sofa.** Each GPU holds half of **every** [[layer]] and both work at the same '
                      'time, so in theory each token is up to twice as fast. The catch: after each layer they must swap '
                      'results ([[all-reduce]], the orange flashes): twice per layer, 160 times per token for an 80-layer '
                      'model. Over a home [[PCIe]] slot that chatter eats much of the gain.'
                : '**An assembly line.** GPU 1 runs the top layers, then hands the token to GPU 2 for the rest. Only one '
                      'card works at a time and they talk once per token, so two cards don\'t make one chat faster: they '
                      'make a bigger model **fit**. This is llama.cpp\'s default (--split-mode layer).',
          ),
        ],
      ),
    );
  }
}

class _SplitPainter extends CustomPainter {
  _SplitPainter({
    required this.tensor,
    required this.t,
    required this.gpu1,
    required this.gpu2,
    required this.line,
    required this.text,
    required this.sync,
  });
  final bool tensor;
  final double t;
  final Color gpu1, gpu2, line, text, sync;
  static const layers = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width.clamp(0.0, 420.0);
    final left = (size.width - w) / 2;
    final top = 18.0;
    final h = (size.height - top - 4) / layers;
    final active = (t * layers).floor().clamp(0, layers - 1);
    final within = t * layers - active;

    void label(String s, Offset at, Color col) {
      final tp = TextPainter(
        text: TextSpan(
          text: s,
          style: TextStyle(color: col, fontSize: 11, fontWeight: FontWeight.w700),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, at - Offset(tp.width / 2, 0));
    }

    final fill = Paint();
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..color = line;
    if (tensor) {
      label('GPU 1', Offset(left + w * 0.25, 0), gpu1);
      label('GPU 2', Offset(left + w * 0.75, 0), gpu2);
    } else {
      label('GPU 1: layers 1-4  ·  GPU 2: layers 5-8', Offset(left + w * 0.5, 0), text);
    }
    for (var i = 0; i < layers; i++) {
      final y = top + i * h;
      final on = i == active;
      if (tensor) {
        for (var half = 0; half < 2; half++) {
          final r = RRect.fromRectAndRadius(
            Rect.fromLTWH(left + half * w / 2 + (half == 0 ? 0 : 3), y + 2, w / 2 - 3, h - 4),
            const Radius.circular(4),
          );
          fill.color = (half == 0 ? gpu1 : gpu2).withValues(alpha: on ? 0.85 : 0.22);
          canvas.drawRRect(r, fill);
          canvas.drawRRect(r, border);
        }
        // The swap after each layer: an orange bridge between the halves while that layer finishes.
        if (on && within > 0.55) {
          final p = Paint()
            ..color = sync
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round;
          final cy = y + h / 2;
          canvas.drawLine(Offset(left + w / 2 - 14, cy), Offset(left + w / 2 + 14, cy), p);
        }
      } else {
        final second = i >= layers / 2;
        final r = RRect.fromRectAndRadius(Rect.fromLTWH(left, y + 2, w, h - 4), const Radius.circular(4));
        fill.color = (second ? gpu2 : gpu1).withValues(alpha: on ? 0.85 : 0.22);
        canvas.drawRRect(r, fill);
        canvas.drawRRect(r, border);
        if (i == layers / 2) {
          // The hand-over between the cards.
          final p = Paint()
            ..color = text
            ..strokeWidth = 1.5;
          canvas.drawLine(Offset(left - 6, y), Offset(left + w + 6, y), p);
        }
      }
      if (on) {
        // The token travelling down.
        final dot = Paint()..color = Colors.white;
        canvas.drawCircle(Offset(left + w * (tensor ? 0.5 : 0.08), y + h * within.clamp(0.15, 0.85)), 4, dot);
      }
    }
  }

  @override
  bool shouldRepaint(_SplitPainter old) => old.t != t || old.tensor != tensor || old.gpu1 != gpu1;
}

// ---------------------------------------------------------------------------------------------------------------
// Panel 2: the game. Numbers are the "Will it fit?" rule: each token reads every weight once, so time per token is
// (GB on each device ÷ that device's memory speed), added up because a layer split runs the devices one after another.

/// Llama 3.3 70B at Q4_K_M, 8K context (SPL-L70B-FIT): GB per layer for weights and 16-bit KV cache.
const _layers = 80;
const _weightPerLayer = 0.540;
const _kvPerLayer = 0.034;
const _perLayer = _weightPerLayer + _kvPerLayer;

/// Working buffers per GPU that holds layers: a rough allowance, labelled as such on screen.
const _buffers = 1.0;
const _vram = 24.0;
const _gpuBW = 936.0; // RTX 3090, GB/s (HW-GDDR-3090)
const _ramBW = 62.0; // measured on the home workstation (RIG-TUNE)

class _SplitIt extends StatefulWidget {
  const _SplitIt();

  @override
  State<_SplitIt> createState() => _SplitItState();
}

class _SplitItState extends State<_SplitIt> {
  int _g1 = 50, _g2 = 20;

  int get _cpu => _layers - _g1 - _g2;
  double _used(int n) => n == 0 ? 0 : n * _perLayer + _buffers;

  /// Upper bound on tokens per second; null when a card is over its memory.
  double? get _speed {
    if (_used(_g1) > _vram || _used(_g2) > _vram) return null;
    final s = (_g1 + _g2) * _weightPerLayer / _gpuBW + _cpu * _weightPerLayer / _ramBW;
    return 1 / s;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(6);
    final speed = _speed;
    final over1 = _used(_g1) > _vram, over2 = _used(_g2) > _vram;
    final String verdict;
    final Color vColor;
    if (over1 || over2) {
      verdict = 'Out of memory on GPU ${over1 ? 1 : 2}: the model would crash while loading. Move layers off it.';
      vColor = c.red;
    } else if (_cpu == 0) {
      verdict = 'All 80 layers on the GPUs. That\'s the classic two-card setup for a 70B model: llama.cpp\'s -ts 1,1.';
      vColor = accent;
    } else {
      verdict = '$_cpu layers run from system RAM, about 15× slower memory than the cards. Squeeze them onto the GPUs.';
      vColor = c.amber;
    }
    return DemoCard(
      title: 'Split it: Llama 3.3 70B on two 24 GB cards',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TermText(
            '80 [[layers|layer]], 4.9 [[bits per weight]] (Q4_K_M), 8K context: about 0.57 GB per layer with its '
            '[[KV cache]]. Give each card some layers; the rest stay in RAM on the CPU.',
          ),
          const SizedBox(height: Gap.s),
          LabeledSlider(
            key: const ValueKey('split-g1'),
            label: 'Layers on GPU 1',
            value: _g1.toDouble(),
            min: 0,
            max: _layers.toDouble(),
            divisions: _layers,
            format: (v) => '${v.round()}',
            color: accent,
            onChanged: (v) => setState(() {
              _g1 = v.round();
              if (_g1 + _g2 > _layers) _g2 = _layers - _g1;
            }),
          ),
          LabeledSlider(
            key: const ValueKey('split-g2'),
            label: 'Layers on GPU 2',
            value: _g2.toDouble(),
            min: 0,
            max: _layers.toDouble(),
            divisions: _layers,
            format: (v) => '${v.round()}',
            color: c.cyan,
            onChanged: (v) => setState(() {
              _g2 = v.round();
              if (_g1 + _g2 > _layers) _g1 = _layers - _g2;
            }),
          ),
          const SizedBox(height: Gap.s),
          _Bar(label: 'GPU 1', used: _used(_g1), color: accent, keyName: 'split-bar-1'),
          const SizedBox(height: Gap.xs),
          _Bar(label: 'GPU 2', used: _used(_g2), color: c.cyan, keyName: 'split-bar-2'),
          const SizedBox(height: Gap.xs),
          Text(
            'CPU / RAM: $_cpu layers',
            key: const ValueKey('split-cpu'),
            style: TextStyle(color: c.textDim),
          ),
          const SizedBox(height: Gap.m),
          StatGrid(
            children: [
              StatTile(
                key: const ValueKey('split-speed'),
                label: 'Speed (upper bound)',
                value: speed == null ? 'won\'t load' : '≤ ${speed.toStringAsFixed(speed >= 10 ? 0 : 1)} tok/s',
                color: speed == null ? c.red : accent,
              ),
              StatTile(label: 'Layers on GPUs', value: '${_g1 + _g2} / $_layers'),
            ],
          ),
          const SizedBox(height: Gap.s),
          Container(
            key: const ValueKey('split-verdict'),
            padding: const EdgeInsets.all(Gap.s),
            decoration: BoxDecoration(color: vColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Text(
              verdict,
              style: TextStyle(color: vColor, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: Gap.s),
          Text(
            'Speed ≤ 1 ÷ (GB on the GPUs ÷ 936 GB/s + GB in RAM ÷ 62 GB/s). The cards take turns in a layer split, so '
            'their times add up. Each card also needs ~1 GB of working buffers (a rough rule). Real speeds are lower.',
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.label, required this.used, required this.color, required this.keyName});
  final String label, keyName;
  final double used;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final over = used > _vram;
    final col = over ? c.red : color;
    return Row(
      key: ValueKey(keyName),
      children: [
        SizedBox(
          width: 52,
          child: Text(label, style: TextStyle(color: c.textDim, fontSize: 12)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (used / _vram).clamp(0.0, 1.0),
              minHeight: 14,
              color: col,
              backgroundColor: c.surfaceHi,
            ),
          ),
        ),
        const SizedBox(width: Gap.s),
        SizedBox(
          width: 92,
          child: Text(
            '${((used * 10).floor() / 10).toStringAsFixed(1)} / 24 GB',
            textAlign: TextAlign.right,
            style: AppText.mono.copyWith(
              fontSize: 12,
              color: col,
              fontWeight: over ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------
// Panel 3: what happened on a real home server (anonymized).

class _HomeNumbers extends StatelessWidget {
  const _HomeNumbers();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(6);
    return DemoCard(
      title: 'Measured at home: one card vs two',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('A small home server with a 16 GB card, plus an older 12 GB card added to try splitting:'),
          const SizedBox(height: Gap.s),
          CompareBars(
            color: accent,
            items: [
              BarItem('27B squeezed to ~2.4 bits, one 16 GB card', 55, display: '~55 tok/s', color: accent),
              BarItem('27B at 4 bits, tensor split over both', 43, display: '39-47 tok/s', color: c.cyan),
              BarItem('74B MoE (9B active), layer split over both', 52.6, display: '52.6 tok/s', color: c.amber),
            ],
          ),
          const SizedBox(height: Gap.s),
          const TermText(
            'Fitting on one card beat splitting. The two cards were different generations, so the [[tensor split]] '
            'also needed extra settings (a smaller [[batch]] and llama.cpp\'s own [[all-reduce]]). The '
            '[[mixture of experts]] model reads only 9B of its 74B per token, so even a plain '
            '[[layer split]] stayed quick.',
          ),
          const SizedBox(height: Gap.s),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FactCard(value: '39-47', label: 'tok/s, 27B tensor split', factId: 'RIG-SPLIT-TENSOR'),
              ),
              SizedBox(width: Gap.s),
              Expanded(
                child: FactCard(value: '~55', label: 'tok/s, squeezed onto one card', factId: 'RIG-SPLIT-SQUEEZE'),
              ),
            ],
          ),
          const SizedBox(height: Gap.s),
          const FactCard(value: '52.6', label: 'tok/s, 74B MoE layer split', factId: 'RIG-SPLIT-MOE'),
          const SizedBox(height: Gap.s),
          const FactCard(
            value: 'layer',
            label: 'llama.cpp\'s default split mode; row and tensor are the others, and -ts sets each card\'s share',
            factId: 'SPL-MODES',
          ),
        ],
      ),
    );
  }
}
