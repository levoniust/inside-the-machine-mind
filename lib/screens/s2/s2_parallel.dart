import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 2 · "Splitting the work": data, tensor and pipeline parallelism on 8 GPUs, with kitchen analogies.
/// Fact: DC-LLAMA-CLUSTER (16,000 GPUs).
class S2ParallelScreen extends StatelessWidget {
  const S2ParallelScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's2_parallel',
        children: [_Modes()],
      );
}

enum Mode { data, tensor, pipeline }

const modeText = {
  Mode.data: ('Data parallel', 'Many kitchens, same recipe',
      'Every GPU holds a full copy of the model and works on different text. Afterwards they average what they learned.'),
  Mode.tensor: ('Tensor parallel', 'One dish, many chefs',
      'Each layer is too big for one GPU, so its grids of numbers are sliced up: every GPU computes its slice of the same step at once.'),
  Mode.pipeline: ('Pipeline parallel', 'An assembly line',
      'GPU 1 runs the first layers, GPU 2 the next ones, and so on. Batches flow down the line like cars in a factory.'),
};

class _Modes extends StatefulWidget {
  const _Modes();

  @override
  State<_Modes> createState() => _ModesState();
}

class _ModesState extends State<_Modes> with SingleTickerProviderStateMixin {
  Mode _mode = Mode.data;
  late final AnimationController _t = AnimationController(vsync: this, duration: const Duration(seconds: 3));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _t.value = 0.5;
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

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final m = modeText[_mode]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          title: 'Three ways to split a giant job',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<Mode>(
                key: const ValueKey('par-mode'),
                segments: const [
                  ButtonSegment(value: Mode.data, label: Text('Data')),
                  ButtonSegment(value: Mode.tensor, label: Text('Tensor')),
                  ButtonSegment(value: Mode.pipeline, label: Text('Pipeline')),
                ],
                selected: {_mode},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _mode = s.first),
              ),
              const SizedBox(height: Gap.m),
              AspectRatio(
                aspectRatio: 1.6,
                child: Semantics(
                  label: '${m.$1} on 8 GPUs',
                  child: AnimatedBuilder(
                    animation: _t,
                    builder: (_, _) => CustomPaint(painter: _GpusPainter(_mode, _t.value, c)),
                  ),
                ),
              ),
              const SizedBox(height: Gap.m),
              Text('${m.$1}: ${m.$2}', key: const ValueKey('par-title'), style: TextStyle(color: c.violet, fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: Gap.xs),
              Text(m.$3, style: TextStyle(color: c.text)),
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
        DemoCard(
          title: 'Real runs use all three at once',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TermText(
                'Training a frontier model mixes every kind of [[parallelism]]: slices of each layer inside a server (fast [[NVLink]]), '
                'stages of the pipeline across servers, and many copies of the whole setup working on different data, '
                'all kept in sync over the network.',
              ),
              const SizedBox(height: Gap.m),
              const FactCard(value: '16,000', label: 'H100 GPUs working together on Llama 3 405B', factId: 'DC-LLAMA-CLUSTER'),
            ],
          ),
        ),
      ],
    );
  }
}

class _GpusPainter extends CustomPainter {
  _GpusPainter(this.mode, this.t, this.c);
  final Mode mode;
  final double t;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    const n = 8;
    final w = size.width / n;
    final colors = [c.cyan, c.magenta, c.violet, c.lime, c.amber, c.cyan, c.magenta, c.violet];
    for (var i = 0; i < n; i++) {
      final box = Rect.fromLTWH(i * w + 3, size.height * 0.3, w - 6, size.height * 0.5);
      canvas.drawRRect(RRect.fromRectAndRadius(box, const Radius.circular(6)), Paint()..color = c.surfaceHi);
      canvas.drawRRect(RRect.fromRectAndRadius(box, const Radius.circular(6)), Paint()
        ..style = PaintingStyle.stroke
        ..color = c.line);
      switch (mode) {
        case Mode.data:
          // Full model in each GPU (4 stacked layers), each fed a different coloured batch from above.
          for (var l = 0; l < 4; l++) {
            canvas.drawRect(Rect.fromLTWH(box.left + 5, box.top + 6 + l * (box.height - 12) / 4, box.width - 10, (box.height - 12) / 4 - 3),
                Paint()..color = c.violet.withValues(alpha: 0.6));
          }
          final y = size.height * 0.05 + t * size.height * 0.22;
          canvas.drawCircle(Offset(box.center.dx, y), 6, Paint()..color = colors[i]);
        case Mode.tensor:
          // One layer split in vertical slices; all light up together.
          final lit = (t * 4).floor() % 4;
          for (var l = 0; l < 4; l++) {
            canvas.drawRect(Rect.fromLTWH(box.left + 5, box.top + 6 + l * (box.height - 12) / 4, box.width - 10, (box.height - 12) / 4 - 3),
                Paint()..color = (l == lit ? c.magenta : c.violet).withValues(alpha: l == lit ? 0.9 : 0.25));
          }
          final y = size.height * 0.05 + t * size.height * 0.22;
          canvas.drawCircle(Offset(box.center.dx, y), 6, Paint()..color = c.cyan);
        case Mode.pipeline:
          // Each GPU holds a different stage; batches move left to right.
          canvas.drawRect(Rect.fromLTWH(box.left + 5, box.top + 6, box.width - 10, box.height - 12),
              Paint()..color = Color.lerp(c.cyan, c.violet, i / (n - 1))!.withValues(alpha: 0.45));
      }
    }
    if (mode == Mode.pipeline) {
      for (var k = 0; k < 4; k++) {
        final x = ((t + k / 4) % 1.0) * size.width;
        canvas.drawCircle(Offset(x, size.height * 0.55), 7, Paint()..color = colors[k]);
      }
    }
    final tp = TextPainter(
      text: TextSpan(text: '8 GPUs', style: TextStyle(fontFamily: 'Roboto', fontSize: 11, color: c.textDim)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(4, size.height - tp.height));
  }

  @override
  bool shouldRepaint(_GpusPainter old) => old.t != t || old.mode != mode || old.c != c;
}
