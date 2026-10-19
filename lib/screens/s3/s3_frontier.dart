import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 3 · "A frontier model in the datacenter".
/// Zoom between one layer, one whole model spread over GPUs, and a cluster of model copies; then a
/// dense-vs-mixture-of-experts router demo. Example model: Llama 3 405B (126 layers, 810 GB at BF16).
class S3FrontierScreen extends StatelessWidget {
  const S3FrontierScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(lessonId: 's3_frontier', children: [_Zoom(), _Experts()]);
}

enum _Level { layer, model, cluster }

class _Zoom extends StatefulWidget {
  const _Zoom();

  @override
  State<_Zoom> createState() => _ZoomState();
}

class _ZoomState extends State<_Zoom> with SingleTickerProviderStateMixin {
  _Level _level = _Level.model;
  late final AnimationController _t = AnimationController(vsync: this, duration: const Duration(seconds: 6));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _t.value = 0.6;
      _t.stop();
    } else if (!_t.isAnimating) {
      _t.repeat();
    }
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  String get _caption => switch (_level) {
    _Level.layer =>
      'One [[layer]]: 128 [[attention]] heads look for different clues at once, then the [[feed-forward layer]] '
          'transforms the result. Llama 3 405B has 126 of these floors.',
    _Level.model =>
      'One whole model: 810 GB of weights won\'t fit on one 80 GB [[GPU]], so the layers are split across many GPUs '
          '(16 in this picture) linked by [[NVLink]]. Watch one token travel down through every floor.',
    _Level.cluster =>
      'The cluster: many copies of the model run side by side, each answering different people. Each copy '
          '[[batches|batching]] many conversations together, like a bus full of passengers.',
  };

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DemoCard(
      title: 'Zoom into a giant',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<_Level>(
            key: const ValueKey('frontier-zoom'),
            segments: const [
              ButtonSegment(value: _Level.layer, label: Text('Layer'), icon: Icon(Icons.zoom_in)),
              ButtonSegment(value: _Level.model, label: Text('Model'), icon: Icon(Icons.layers_outlined)),
              ButtonSegment(value: _Level.cluster, label: Text('Cluster'), icon: Icon(Icons.zoom_out)),
            ],
            selected: {_level},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _level = s.first),
          ),
          const SizedBox(height: Gap.m),
          AspectRatio(
            aspectRatio: 1,
            child: Semantics(
              label: 'Zoom level: ${_level.name}',
              child: AnimatedBuilder(
                animation: _t,
                builder: (_, _) => CustomPaint(painter: _ZoomPainter(_level, _t.value, c)),
              ),
            ),
          ),
          const SizedBox(height: Gap.m),
          TermText(_caption, key: ValueKey('frontier-caption-${_level.name}')),
          const SizedBox(height: Gap.m),
          Row(
            children: [
              Expanded(
                child: StatTile(label: 'Layers', value: '126', color: c.magenta),
              ),
              const SizedBox(width: Gap.s),
              Expanded(
                child: StatTile(label: 'Weights (BF16)', value: '810 GB', color: c.cyan),
              ),
              const SizedBox(width: Gap.s),
              Expanded(
                child: StatTile(label: 'Math per token', value: '~810 bn', color: c.amber),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ZoomPainter extends CustomPainter {
  _ZoomPainter(this.level, this.t, this.c);
  final _Level level;
  final double t;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    switch (level) {
      case _Level.layer:
        _layer(canvas, size);
      case _Level.model:
        _model(canvas, size);
      case _Level.cluster:
        _cluster(canvas, size);
    }
  }

  void _layer(Canvas canvas, Size size) {
    // 128 attention heads as a ring of dots that pulse in waves, feeding a feed-forward block.
    final center = Offset(size.width / 2, size.height * 0.42);
    final r = size.width * 0.32;
    for (var i = 0; i < 128; i++) {
      final a = i / 128 * math.pi * 2;
      final glow = 0.5 + 0.5 * math.sin(a * 3 + t * math.pi * 2 * 2);
      final p = center + Offset(math.cos(a), math.sin(a)) * r;
      canvas.drawCircle(p, 3.2, Paint()..color = Color.lerp(c.line, c.magenta, glow)!);
      if (i % 8 == 0) {
        canvas.drawLine(
          p,
          center,
          Paint()
            ..color = c.magenta.withValues(alpha: 0.12 + 0.3 * glow)
            ..strokeWidth = 1,
        );
      }
    }
    canvas.drawCircle(center, size.width * 0.07, Paint()..color = c.magenta.withValues(alpha: 0.3));
    _label(canvas, 'attention: 128 heads', center + Offset(0, -r - 18), c.magenta);
    final ff = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.88),
      width: size.width * 0.7,
      height: size.height * 0.12,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(ff, const Radius.circular(10)),
      Paint()..color = c.cyan.withValues(alpha: 0.18),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(ff, const Radius.circular(10)),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = c.cyan,
    );
    _label(canvas, 'feed-forward', ff.center, c.cyan);
    final y = center.dy + (ff.top - center.dy) * ((t * 2) % 1);
    canvas.drawCircle(Offset(size.width / 2, y), 5, Paint()..color = c.lime);
  }

  void _model(Canvas canvas, Size size) {
    const layers = 126, gpus = 16;
    final top = size.height * 0.05, bottom = size.height * 0.95;
    final h = (bottom - top) / layers;
    final left = size.width * 0.28, right = size.width * 0.95;
    final current = (t * layers).floor().clamp(0, layers - 1);
    for (var i = 0; i < layers; i++) {
      final g = i * gpus ~/ layers;
      final col = g.isEven ? c.cyan : c.violet;
      final lit = i == current;
      canvas.drawRect(
        Rect.fromLTWH(left, top + i * h, right - left, math.max(1, h - 0.8)),
        Paint()..color = lit ? c.lime : col.withValues(alpha: i < current ? 0.55 : 0.2),
      );
    }
    for (var g = 0; g < gpus; g++) {
      final y0 = top + (g * layers / gpus) * h;
      final y1 = top + ((g + 1) * layers / gpus) * h;
      _label(
        canvas,
        'GPU ${g + 1}',
        Offset(size.width * 0.13, (y0 + y1) / 2),
        (g * layers ~/ gpus) <= current ? c.text : c.textDim,
        size: 10,
      );
    }
    _label(canvas, 'layer ${current + 1}/126', Offset((left + right) / 2, top + current * h - 10), c.lime, size: 11);
  }

  void _cluster(Canvas canvas, Size size) {
    const cols = 8, rows = 8;
    final w = size.width / cols, hh = size.height / rows;
    final r = math.Random(5);
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        final phase = r.nextDouble();
        final busy = 0.5 + 0.5 * math.sin((t + phase) * math.pi * 2);
        final rect = Rect.fromLTWH(x * w + 3, y * hh + 3, w - 6, hh - 6);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          Paint()..color = Color.lerp(c.surfaceHi, c.magenta, busy * 0.7)!,
        );
        // Little "passengers" (conversations) in each copy's batch.
        for (var k = 0; k < 4; k++) {
          canvas.drawCircle(
            rect.center + Offset((k - 1.5) * rect.width * 0.18, 0),
            2.2,
            Paint()..color = c.text.withValues(alpha: busy > k / 4 ? 0.9 : 0.15),
          );
        }
      }
    }
  }

  void _label(Canvas canvas, String s, Offset at, Color col, {double size = 12}) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(fontFamily: 'Roboto', color: col, fontSize: size, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_ZoomPainter old) => old.t != t || old.level != level || old.c != c;
}

class _Experts extends StatefulWidget {
  const _Experts();

  @override
  State<_Experts> createState() => _ExpertsState();
}

class _ExpertsState extends State<_Experts> {
  bool _moe = true;
  int _token = 0;
  static const _tokens = ['Why', 'is', 'the', 'sky', 'blue'];

  // Two experts per token, picked by a fixed "router" so the demo is repeatable.
  List<int> _picked(int t) => [(t * 3) % 8, (t * 5 + 2) % 8];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final picked = _picked(_token);
    return DemoCard(
      title: 'A team of specialists',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            key: const ValueKey('frontier-moe'),
            contentPadding: EdgeInsets.zero,
            title: Text(_moe ? 'Mixture of experts: 2 of 8 work' : 'Dense: all 8 work on every token'),
            value: _moe,
            activeThumbColor: c.magenta,
            onChanged: (v) => setState(() => _moe = v),
          ),
          Wrap(
            spacing: 6,
            children: [
              for (var i = 0; i < _tokens.length; i++)
                ChoiceChip(
                  key: ValueKey('frontier-token-$i'),
                  label: Text(_tokens[i]),
                  selected: _token == i,
                  selectedColor: c.magenta.withValues(alpha: 0.25),
                  onSelected: (_) => setState(() => _token = i),
                ),
            ],
          ),
          const SizedBox(height: Gap.m),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: Gap.s,
            crossAxisSpacing: Gap.s,
            children: [
              for (var e = 0; e < 8; e++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: (!_moe || picked.contains(e)) ? c.magenta.withValues(alpha: 0.85) : c.surfaceHi,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.line),
                  ),
                  child: Text(
                    'E${e + 1}',
                    style: AppText.mono.copyWith(
                      fontWeight: FontWeight.w800,
                      color: (!_moe || picked.contains(e)) ? Colors.white : c.textDim,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Gap.m),
          Text(
            _moe
                ? 'Only 2 of 8 experts do the math for "${_tokens[_token]}": far less math per token.'
                : 'Every expert works on every token.',
            key: const ValueKey('frontier-moe-caption'),
            style: TextStyle(color: c.text, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: Gap.m),
          const Row(
            children: [
              Expanded(
                child: FactCard(
                  value: '12.9B / 46.7B',
                  label: 'Mixtral 8x7B: knobs used per token / total',
                  factId: 'TR-MIXTRAL',
                ),
              ),
              SizedBox(width: Gap.m),
              Expanded(
                child: FactCard(
                  value: '37B / 671B',
                  label: 'DeepSeek-V3: knobs used per token / total',
                  factId: 'TR-DEEPSEEKV3',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
