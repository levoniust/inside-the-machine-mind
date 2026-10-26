import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../content/fit_data.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Context costs memory: every token leaves a K and a V vector in every layer. Context slider, grouped-query vs
/// "every head keeps its own K/V", and KV cache quantization, all on real model shapes.
class LKvCacheScreen extends StatelessWidget {
  const LKvCacheScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
    lessonId: 'l_kv_cache',
    children: [
      _TokenStrip(),
      _KvCalculator(),
      FactCard(
        value: '1 GiB',
        label: 'Llama 3.1 8B\'s KV cache for 8,192 tokens in f16: 2 × 32 layers × 8 KV heads × 128 numbers × 2 bytes per token',
        factId: 'RUN-KV-FORMULA',
      ),
      FactCard(
        value: 'Same math, less traffic',
        label:
            'Flash attention computes exact attention in small tiles in fast on-chip memory instead of writing the full '
            'attention table to VRAM, which saves memory at long context',
        factId: 'RUN-FLASHATTN',
      ),
    ],
  );
}

/// A row of token chips; each new token stacks a K and a V slab onto every layer.
class _TokenStrip extends StatefulWidget {
  const _TokenStrip();

  @override
  State<_TokenStrip> createState() => _TokenStripState();
}

class _TokenStripState extends State<_TokenStrip> {
  static const _words = ['Why', ' is', ' the', ' sky', ' blue', '?', ' Because', ' sunlight', ' scatters'];
  static const _layers = 6;
  int _n = 3;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(6);
    return DemoCard(
      title: 'Every token leaves notes in every layer',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 170,
            child: CustomPaint(
              key: const ValueKey('kv-strip'),
              painter: _StripPainter(
                n: _n,
                layers: _layers,
                k: accent,
                v: c.violet,
                grid: c.line,
                text: c.text,
                words: _words,
              ),
            ),
          ),
          const SizedBox(height: Gap.s),
          Text(
            '$_n tokens × $_layers layers × (K + V) = ${_n * _layers * 2} vectors kept',
            key: const ValueKey('kv-strip-count'),
            style: AppText.mono.copyWith(color: accent),
          ),
          const SizedBox(height: Gap.s),
          Wrap(
            spacing: Gap.s,
            children: [
              OutlinedButton.icon(
                key: const ValueKey('kv-add'),
                onPressed: _n < _words.length ? () => setState(() => _n++) : null,
                icon: const Icon(Icons.add),
                label: const Text('Next token'),
              ),
              TextButton(onPressed: () => setState(() => _n = 1), child: const Text('Reset')),
            ],
          ),
          Text(
            'The model never re-reads old tokens from scratch: it looks back at these saved keys (K) and values (V). '
            'That saved pile is the KV cache, and it grows with every token.',
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _StripPainter extends CustomPainter {
  _StripPainter({
    required this.n,
    required this.layers,
    required this.k,
    required this.v,
    required this.grid,
    required this.text,
    required this.words,
  });
  final int n, layers;
  final Color k, v, grid, text;
  final List<String> words;

  @override
  void paint(Canvas canvas, Size size) {
    final cols = words.length;
    final cw = size.width / cols;
    const top = 26.0;
    final lh = (size.height - top) / layers;
    for (var i = 0; i < cols; i++) {
      final active = i < n;
      final tp = TextPainter(
        text: TextSpan(
          text: words[i].trim(),
          style: TextStyle(fontSize: 11, color: active ? text : grid),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: cw);
      tp.paint(canvas, Offset(i * cw + (cw - tp.width) / 2, 4));
      for (var l = 0; l < layers; l++) {
        final r = Rect.fromLTWH(i * cw + 3, top + l * lh + 2, cw - 6, lh - 4);
        if (!active) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(r, const Radius.circular(3)),
            Paint()
              ..color = grid
              ..style = PaintingStyle.stroke,
          );
          continue;
        }
        final half = r.width / 2;
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(r.left, r.top, half - 1, r.height), const Radius.circular(3)),
          Paint()..color = k.withValues(alpha: 0.85),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(r.left + half + 1, r.top, half - 1, r.height),
            const Radius.circular(3),
          ),
          Paint()..color = v.withValues(alpha: 0.85),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_StripPainter old) => old.n != n || old.k != k;
}

const _ctxStops = [1024, 4096, 8192, 16384, 32768, 65536, 131072, 262144];
String _k(int t) => '${t ~/ 1024}k';
String _gb(double v) => v >= 100
    ? v.toStringAsFixed(0)
    : v >= 10
    ? v.toStringAsFixed(1)
    : v.toStringAsFixed(2);

/// Real model shapes: context slider, "what if every head kept its own K/V", and KV quantization.
class _KvCalculator extends StatefulWidget {
  const _KvCalculator();

  @override
  State<_KvCalculator> createState() => _KvCalculatorState();
}

class _KvCalculatorState extends State<_KvCalculator> {
  int _model = 0, _ctx = 2, _kv = 0;
  bool _fullHeads = false;

  double _gbFor(FitModel m, int ctx, double bytes, {bool fullHeads = false}) {
    final perLayer = fullHeads && m.kvElemsOverride == null ? 2 * m.attnHeads * m.headDim : m.kvElemsPerLayer;
    final full = m.layers - m.slidingLayers;
    final tokens = full * ctx + m.slidingLayers * math.min(ctx, m.window);
    return tokens * perLayer * bytes / 1e9;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(6);
    final m = fitModels[_model];
    final ctx = _ctxStops[_ctx];
    final kv = fitKvTypes[_kv];
    final gb = _gbFor(m, ctx, kv.bytes, fullHeads: _fullHeads);
    final weights = m.totalB * 4.8944 / 8;
    final mla = m.kvElemsOverride != null;
    return DemoCard(
      title: 'How big does it get?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: Gap.xs,
            runSpacing: Gap.xs,
            children: [
              for (var i = 0; i < fitModels.length; i++)
                ChoiceChip(
                  key: ValueKey('kv-model-$i'),
                  label: Text(fitModels[i].name),
                  selected: i == _model,
                  selectedColor: accent.withValues(alpha: 0.3),
                  onSelected: (_) => setState(() => _model = i),
                ),
            ],
          ),
          const SizedBox(height: Gap.m),
          LabeledSlider(
            key: const ValueKey('kv-context'),
            label: 'Context',
            value: _ctx.toDouble(),
            min: 0,
            max: (_ctxStops.length - 1).toDouble(),
            divisions: _ctxStops.length - 1,
            format: (_) => '${_k(ctx)} tokens',
            color: accent,
            onChanged: (v) => setState(() => _ctx = v.round()),
          ),
          Wrap(
            spacing: Gap.xs,
            children: [
              for (var i = 0; i < fitKvTypes.length; i++)
                ChoiceChip(
                  key: ValueKey('kv-type-$i'),
                  label: Text('KV ${fitKvTypes[i].name}'),
                  selected: i == _kv,
                  selectedColor: c.violet.withValues(alpha: 0.3),
                  onSelected: (_) => setState(() => _kv = i),
                ),
            ],
          ),
          if (!mla)
            SwitchListTile(
              key: const ValueKey('kv-fullheads'),
              contentPadding: EdgeInsets.zero,
              title: const Text('What if every attention head kept its own K and V?'),
              subtitle: Text(
                '${m.name} has ${m.attnHeads} attention heads sharing ${m.kvHeads} K/V heads (grouped-query attention)',
              ),
              value: _fullHeads,
              onChanged: (v) => setState(() => _fullHeads = v),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Gap.s),
              child: Text(
                'DeepSeek compresses its cache (multi-head latent attention): 576 numbers per token per layer.',
                style: TextStyle(color: c.textDim, fontSize: 13),
              ),
            ),
          const SizedBox(height: Gap.s),
          StatGrid(
            columns: 2,
            children: [
              StatTile(key: const ValueKey('kv-gb'), label: 'KV cache', value: '${_gb(gb)} GB', color: c.violet),
              StatTile(label: 'Weights at Q4_K_M, for scale', value: '${_gb(weights)} GB', color: accent),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text(
            mla
                ? 'KV = ${m.layers} layers × 576 numbers × ${kv.bytes.toStringAsFixed(2)} bytes × tokens'
                : 'KV = 2 × ${m.layers} layers × ${_fullHeads ? m.attnHeads : m.kvHeads} heads × ${m.headDim} × '
                      '${kv.bytes.toStringAsFixed(2)} bytes × tokens'
                      '${m.slidingLayers > 0 ? '  (${m.slidingLayers} sliding layers stop at ${m.window} tokens)' : ''}',
            style: AppText.mono.copyWith(fontSize: 12, color: c.textDim),
          ),
        ],
      ),
    );
  }
}
