import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 3 · "Serving a billion people": batching (carpooling) — the GPU reads the weights once per step for a
/// whole batch — plus PagedAttention and speculative decoding. Facts: IN-USERS, IN-BANDWIDTH-BOUND, IN-VLLM, IN-SPEC.
class S3ServingScreen extends StatelessWidget {
  const S3ServingScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's3_serving',
        children: [_Carpool(), _Tricks()],
      );
}

/// Full reads of the model's weights needed to produce one next word for [users] people with batches of [batch].
int weightReads(int users, int batch) => (users / batch).ceil();

class _Carpool extends StatefulWidget {
  const _Carpool();

  @override
  State<_Carpool> createState() => _CarpoolState();
}

class _CarpoolState extends State<_Carpool> with SingleTickerProviderStateMixin {
  double _batch = 1;
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
    final b = _batch.round();
    const users = 64;
    final reads = weightReads(users, b);
    return DemoCard(
      title: 'Carpooling for computers',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TermText(
            'To write each new [[token]] the GPU must read the whole model from memory (that\'s the slow part). With [[batching]] it reads '
            'the model once and uses it for many people\'s conversations at the same time.',
            style: TextStyle(color: c.textDim),
          ),
          const SizedBox(height: Gap.m),
          AspectRatio(
            aspectRatio: 2.2,
            child: Semantics(
              label: '64 requests travelling in groups of $b',
              child: AnimatedBuilder(
                animation: _t,
                builder: (_, _) => CustomPaint(painter: _RoadPainter(b, _t.value, c)),
              ),
            ),
          ),
          LabeledSlider(
            key: const ValueKey('serve-batch'),
            label: 'People per batch',
            value: _batch,
            min: 1,
            max: 64,
            divisions: 63,
            color: c.magenta,
            format: (v) => '${v.round()}',
            onChanged: (v) => setState(() => _batch = v),
          ),
          StatGrid(
            children: [
              StatTile(
                key: const ValueKey('serve-reads'),
                label: 'Model reads for 64 people',
                value: '$reads',
                color: reads <= 4 ? c.lime : (reads <= 16 ? c.amber : c.red),
              ),
              StatTile(label: 'Work saved', value: '${((1 - reads / users) * 100).round()}%', color: c.lime),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoadPainter extends CustomPainter {
  _RoadPainter(this.batch, this.t, this.c);
  final int batch;
  final double t;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(10)), Paint()..color = c.surfaceHi);
    final gpu = Rect.fromLTWH(size.width * 0.86, size.height * 0.2, size.width * 0.12, size.height * 0.6);
    canvas.drawRRect(RRect.fromRectAndRadius(gpu, const Radius.circular(8)), Paint()..color = c.magenta.withValues(alpha: 0.35));
    final tp = TextPainter(
      text: TextSpan(text: 'GPU', style: TextStyle(fontFamily: 'Roboto', color: c.text, fontSize: 11, fontWeight: FontWeight.w800)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, gpu.center - Offset(tp.width / 2, tp.height / 2));
    final groups = (64 / batch).ceil();
    final shown = math.min(groups, 8);
    for (var g = 0; g < shown; g++) {
      final p = (t + g / shown) % 1.0;
      final x = p * size.width * 0.8;
      final y = size.height * (0.2 + 0.6 * ((g * 0.37) % 1));
      final w = 10.0 + math.min(batch, 32) * 1.6;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, y), width: w, height: 14), const Radius.circular(5)),
          Paint()..color = batch == 1 ? c.cyan : c.lime);
    }
    if (groups > shown) {
      final more = TextPainter(
        text: TextSpan(text: '+${groups - shown} more trips', style: TextStyle(fontFamily: 'Roboto', color: c.textDim, fontSize: 10)),
        textDirection: TextDirection.ltr,
      )..layout();
      more.paint(canvas, Offset(6, size.height - more.height - 4));
    }
  }

  @override
  bool shouldRepaint(_RoadPainter old) => old.t != t || old.batch != batch || old.c != c;
}

class _Tricks extends StatelessWidget {
  const _Tricks();

  @override
  Widget build(BuildContext context) {
    return const DemoCard(
      title: 'More tricks to serve everyone',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TermText(
            '**Paging the notes:** each conversation\'s [[KV cache]] is stored in small pages, like an operating system '
            'does with memory, so far more conversations fit on one GPU.',
          ),
          SizedBox(height: Gap.m),
          TermText(
            '**Draft and check:** a small, fast model drafts a few [[tokens|token]]; the big model checks them all at once and keeps the '
            'right ones. Same answer, less waiting.',
          ),
          SizedBox(height: Gap.m),
          Row(
            children: [
              Expanded(child: FactCard(value: '2–4×', label: 'more requests per GPU with paged notes (vLLM)', factId: 'IN-VLLM')),
              SizedBox(width: Gap.m),
              Expanded(child: FactCard(value: '2–3×', label: 'faster with draft-and-check (speculative decoding)', factId: 'IN-SPEC')),
            ],
          ),
          SizedBox(height: Gap.m),
          FactCard(value: '1 billion+', label: 'people use ChatGPT every week (2026)', factId: 'IN-USERS'),
        ],
      ),
    );
  }
}
