import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../content/fit_data.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Will it fit? Model × quant × context × KV type on a machine → memory bar, verdict and a speed upper bound.
class LWillItFitScreen extends StatelessWidget {
  const LWillItFitScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
    lessonId: 'l_will_it_fit',
    children: [
      _Calculator(),
      FactCard(
        value: '4.89 bits',
        label:
            'per weight in a whole Q4_K_M file (Llama 3.1 8B): a bit more than 4, because some tensors keep more bits',
        factId: 'RUN-BPW-FILE',
      ),
      FactCard(
        value: '≈ bandwidth ÷ bytes',
        label: 'Generating a token reads every active weight once, so memory speed, not compute, sets the pace at home',
        factId: 'RUN-SPEED-BOUND',
      ),
    ],
  );
}

const _contexts = [2048, 4096, 8192, 16384, 32768, 65536, 131072, 262144];

String _k(int tokens) => tokens >= 1024 ? '${tokens ~/ 1024}k' : '$tokens';
String _gb(double v) => v >= 100
    ? v.toStringAsFixed(0)
    : v >= 10
    ? v.toStringAsFixed(1)
    : v.toStringAsFixed(2);

class _Calculator extends StatefulWidget {
  const _Calculator();

  @override
  State<_Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<_Calculator> {
  int _model = 0, _quant = 3, _ctx = 2, _kv = 0, _hw = 3, _ramSpeed = 1;
  double _ramGB = 64;
  bool _math = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(6);
    final model = fitModels[_model], quant = fitQuants[_quant], hw = fitHardware[_hw], kv = fitKvTypes[_kv];
    final ramBW = fitRamSpeeds[_ramSpeed].$2;
    final r = FitResult.compute(
      model: model,
      quant: quant,
      context: _contexts[_ctx],
      kv: kv,
      hw: hw,
      ramGB: _ramGB,
      ramBW: ramBW,
    );

    Widget chips<T>(String keyPrefix, List<T> items, String Function(T) label, int selected, void Function(int) pick) =>
        Wrap(
          spacing: Gap.xs,
          runSpacing: Gap.xs,
          children: [
            for (var i = 0; i < items.length; i++)
              ChoiceChip(
                key: ValueKey('$keyPrefix-$i'),
                label: Text(label(items[i])),
                selected: i == selected,
                selectedColor: accent.withValues(alpha: 0.3),
                onSelected: (_) => setState(() => pick(i)),
              ),
          ],
        );

    final (verdictText, verdictColor) = switch (r.verdict) {
      FitVerdict.fits => (hw.unified ? 'Fits in unified memory' : 'Fits on the GPU', c.lime),
      FitVerdict.offload => ('Fits with offload to RAM (slower)', c.amber),
      FitVerdict.cpuOnly => ('Runs from system RAM on the CPU (slow)', c.amber),
      FitVerdict.noFit => ('Doesn\'t fit: pick a smaller quant, model or context', c.red),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          title: 'The model',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              chips('fit-model', fitModels, (m) => m.name, _model, (i) => _model = i),
              const SizedBox(height: Gap.s),
              Text(
                model.moe
                    ? '${_gb(model.totalB)} B parameters, ${_gb(model.activeB)} B active per token (mixture of experts)'
                    : '${_gb(model.totalB)} B parameters, all used for every token',
                style: TextStyle(color: c.textDim, fontSize: 13),
              ),
              const SizedBox(height: Gap.m),
              Text(
                'Quant (bits per weight)',
                style: TextStyle(color: c.textDim, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: Gap.xs),
              chips('fit-quant', fitQuants, (q) => q.name, _quant, (i) => _quant = i),
              const SizedBox(height: Gap.m),
              LabeledSlider(
                key: const ValueKey('fit-context'),
                label: 'Context',
                format: (_) => '${_k(_contexts[_ctx])} tokens',
                value: _ctx.toDouble(),
                min: 0,
                max: (_contexts.length - 1).toDouble(),
                divisions: _contexts.length - 1,
                color: accent,
                onChanged: (v) => setState(() => _ctx = v.round()),
              ),
              if (_contexts[_ctx] > model.maxContext)
                Padding(
                  key: const ValueKey('fit-ctx-warning'),
                  padding: const EdgeInsets.only(bottom: Gap.s),
                  child: Text(
                    model.scaledContext != null && _contexts[_ctx] <= model.scaledContext!
                        ? '${model.name} is trained for ${_k(model.maxContext)} tokens; beyond that it needs RoPE scaling (YaRN), '
                              'officially up to ${_k(model.scaledContext!)}.'
                        : 'Beyond ${model.name}\'s ${_k(model.maxContext)}-token limit: the memory math still works, the model won\'t.',
                    style: TextStyle(color: c.amber, fontSize: 13),
                  ),
                ),
              Text(
                'KV cache type',
                style: TextStyle(color: c.textDim, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: Gap.xs),
              chips('fit-kv', fitKvTypes, (k) => k.name, _kv, (i) => _kv = i),
            ],
          ),
        ),
        const SizedBox(height: Gap.m),
        DemoCard(
          title: 'Your machine',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              chips('fit-hw', fitHardware, (h) => h.name, _hw, (i) => _hw = i),
              if (!hw.unified) ...[
                const SizedBox(height: Gap.m),
                LabeledSlider(
                  key: const ValueKey('fit-ram'),
                  label: 'System RAM',
                  format: (_) => '${_ramGB.round()} GB',
                  value: _ramGB,
                  min: 16,
                  max: 512,
                  divisions: 31,
                  color: accent,
                  onChanged: (v) => setState(() => _ramGB = v),
                ),
                chips('fit-ramspeed', fitRamSpeeds, (s) => s.$1, _ramSpeed, (i) => _ramSpeed = i),
              ] else
                Padding(
                  padding: const EdgeInsets.only(top: Gap.s),
                  child: Text(
                    'Unified memory: the model and the system share one pool, so about '
                    '${FitResult.unifiedReserveGB.round()} GB is kept for the system (rough rule).',
                    style: TextStyle(color: c.textDim, fontSize: 13),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: Gap.m),
        DemoCard(
          title: 'The verdict',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                key: const ValueKey('fit-verdict'),
                padding: const EdgeInsets.all(Gap.m),
                decoration: BoxDecoration(
                  color: verdictColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: verdictColor),
                ),
                child: Text(
                  verdictText,
                  style: TextStyle(fontWeight: FontWeight.w800, color: verdictColor, fontSize: 16),
                ),
              ),
              const SizedBox(height: Gap.m),
              _MemoryBar(r: r, unified: hw.unified),
              const SizedBox(height: Gap.m),
              StatGrid(
                columns: 2,
                children: [
                  StatTile(label: 'Weights', value: '${_gb(r.weightsGB)} GB', color: accent),
                  StatTile(label: 'KV cache', value: '${_gb(r.kvGB)} GB', color: c.violet),
                  StatTile(label: 'Total (with overhead)', value: '${_gb(r.totalGB)} GB', color: c.text),
                  StatTile(
                    key: const ValueKey('fit-speed'),
                    label: 'Speed, upper bound',
                    value: r.tokPerSec == null
                        ? '—'
                        : '≤ ${r.tokPerSec! >= 10 ? r.tokPerSec!.round() : r.tokPerSec!.toStringAsFixed(1)} tok/s',
                    color: c.cyan,
                  ),
                ],
              ),
              const SizedBox(height: Gap.s),
              Text(
                'Real speeds are lower than the bound: the math ignores compute time, overheads and imperfect memory use.',
                style: TextStyle(color: c.textDim, fontSize: 12),
              ),
              const SizedBox(height: Gap.s),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const ValueKey('fit-math'),
                  onPressed: () => setState(() => _math = !_math),
                  icon: Icon(_math ? Icons.expand_less : Icons.functions),
                  label: Text(_math ? 'Hide the math' : 'Show the math'),
                ),
              ),
              if (_math)
                _Math(model: model, quant: quant, kv: kv, context: _contexts[_ctx], hw: hw, ramBW: ramBW, r: r),
            ],
          ),
        ),
      ],
    );
  }
}

/// Weights | KV | overhead as one bar, with the fast-memory limit marked and the spill into RAM shaded.
class _MemoryBar extends StatelessWidget {
  const _MemoryBar({required this.r, required this.unified});
  final FitResult r;
  final bool unified;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final scale = [r.totalGB, r.fastGB, 1.0].reduce((a, b) => a > b ? a : b) * 1.08;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 44,
          child: CustomPaint(
            size: Size.infinite,
            painter: _BarPainter(
              segments: [(r.weightsGB, c.section(6)), (r.kvGB, c.violet), (r.overheadGB, c.textDim)],
              limit: r.fastGB / scale,
              scale: scale,
              line: c.text,
              spill: c.amber,
            ),
          ),
        ),
        const SizedBox(height: Gap.xs),
        Wrap(
          spacing: Gap.m,
          children: [
            _Legend(color: c.section(6), text: 'weights'),
            _Legend(color: c.violet, text: 'KV cache'),
            _Legend(color: c.textDim, text: 'overhead'),
            _Legend(
              color: c.text,
              text: unified ? 'usable memory ${_gb(r.fastGB)} GB' : 'VRAM ${_gb(r.fastGB)} GB',
              line: true,
            ),
            if (r.inRamGB > 0) _Legend(color: c.amber, text: 'in system RAM ${_gb(r.inRamGB)} GB'),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.text, this.line = false});
  final Color color;
  final String text;
  final bool line;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: line ? 3 : 10, height: 10, color: color),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(fontSize: 12, color: AppColors.of(context).textDim)),
    ],
  );
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.segments,
    required this.limit,
    required this.scale,
    required this.line,
    required this.spill,
  });
  final List<(double, Color)> segments;
  final double limit, scale;
  final Color line, spill;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height - 12;
    var x = 0.0;
    for (final (gb, color) in segments) {
      final w = gb / scale * size.width;
      canvas.drawRect(Rect.fromLTWH(x, 6, w, h), Paint()..color = color.withValues(alpha: 0.85));
      x += w;
    }
    final lx = limit * size.width;
    if (x > lx) {
      // hatch the part that lives in system RAM
      final clip = Rect.fromLTWH(lx, 6, x - lx, h);
      canvas.save();
      canvas.clipRect(clip);
      final p = Paint()
        ..color = spill
        ..strokeWidth = 2;
      for (var i = lx - h; i < x; i += 7) {
        canvas.drawLine(Offset(i, 6 + h), Offset(i + h, 6), p);
      }
      canvas.restore();
    }
    canvas.drawLine(
      Offset(lx, 0),
      Offset(lx, size.height),
      Paint()
        ..color = line
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_BarPainter old) => true;
}

class _Math extends StatelessWidget {
  const _Math({
    required this.model,
    required this.quant,
    required this.kv,
    required this.context,
    required this.hw,
    required this.ramBW,
    required this.r,
  });
  final FitModel model;
  final FitQuant quant;
  final FitKvType kv;
  final int context;
  final FitHardware hw;
  final double ramBW;
  final FitResult r;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final mono = AppText.mono.copyWith(fontSize: 12, color: c.text, height: 1.5);
    final kvLine = model.kvElemsOverride != null
        ? 'KV = ${model.layers} layers × ${model.kvElemsPerLayer} numbers (compressed MLA cache) × ${kv.bytes.toStringAsFixed(2)} B × ${_k(this.context)} tokens'
        : 'KV = 2 (K and V) × ${model.layers} layers × ${model.kvHeads} KV heads × ${model.headDim} dims × ${kv.bytes.toStringAsFixed(2)} B × ${_k(this.context)} tokens'
              '${model.slidingLayers > 0 ? '\n     (${model.slidingLayers} sliding-window layers keep only ${model.window} tokens)' : ''}';
    return Container(
      padding: const EdgeInsets.all(Gap.m),
      decoration: BoxDecoration(color: c.surfaceHi, borderRadius: BorderRadius.circular(8)),
      child: Text(
        'weights = ${_gb(model.totalB)} B params × ${quant.bpw.toStringAsFixed(2)} bits ÷ 8 = ${_gb(r.weightsGB)} GB\n'
        '$kvLine = ${_gb(r.kvGB)} GB\n'
        'overhead ≈ 0.5 GB + 2 % of weights = ${_gb(r.overheadGB)} GB  (rough rule)\n'
        'per token: read ${_gb(model.activeB)} B active params × ${quant.bpw.toStringAsFixed(2)} ÷ 8 + the KV cache\n'
        'speed ≤ 1 ÷ (GB from VRAM ÷ ${hw.fastBW.round()} GB/s + GB from RAM ÷ ${ramBW.round()} GB/s)',
        style: mono,
      ),
    );
  }
}
