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

/// The demo's fixed number of waiting conversations.
const _users = 64;

/// One-line description of the current carpool, shown under the road.
String _carpoolCaption(int b) {
  final trips = weightReads(_users, b);
  if (b == 1) return '$_users solo cars — the model is read $_users times';
  if (trips == 1) return 'One bus for everyone — the model is read once';
  return '$trips ${b <= 8 ? 'vans' : 'buses'} carry up to $b people each — $trips model reads';
}

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
    final reads = weightReads(_users, b);
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
              label: 'A road to a GPU building: $_users requests travelling in groups of up to $b',
              child: AnimatedBuilder(
                animation: _t,
                builder: (_, _) => CustomPaint(painter: _RoadPainter(b, _t.value, c)),
              ),
            ),
          ),
          const SizedBox(height: Gap.s),
          Text(
            _carpoolCaption(b),
            key: const ValueKey('serve-caption'),
            textAlign: TextAlign.center,
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
          const SizedBox(height: Gap.s),
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
              StatTile(label: 'Work saved', value: '${((1 - reads / _users) * 100).round()}%', color: c.lime),
            ],
          ),
        ],
      ),
    );
  }
}

/// A two-lane road with traffic driving into a GPU building at the end (it is painted last, so vehicles
/// disappear into it). Each vehicle carries a dot per passenger, as many as fit inside: batch 1 is many
/// separate little cars, a big batch is one long bus.
class _RoadPainter extends CustomPainter {
  _RoadPainter(this.batch, this.t, this.c);
  final int batch;
  final double t;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(10)), Paint()..color = c.surfaceHi);
    final road = Rect.fromLTRB(0, size.height * 0.52, size.width, size.height * 0.86);
    final gpu = Rect.fromLTWH(size.width * 0.8, size.height * 0.1, size.width * 0.17, road.bottom - size.height * 0.1);
    final midY = (road.top + road.bottom) / 2;

    // The road: asphalt, a top edge line and a dashed middle line.
    canvas.drawRect(road, Paint()..color = c.line);
    canvas.drawLine(Offset(0, road.top + 1), Offset(gpu.left, road.top + 1),
        Paint()..color = c.textDim.withValues(alpha: 0.7)..strokeWidth = 1.5);
    final dash = Paint()
      ..color = c.textDim.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var x = 5.0; x < gpu.left - 10; x += 20) {
      canvas.drawLine(Offset(x, midY), Offset(x + 10, midY), dash);
    }

    // Traffic: one vehicle per trip, spread over two lanes, all driving right into the building.
    final trips = weightReads(_users, batch);
    final w = batch == 1 ? 17.0 : (20.0 + math.min(batch, 32) * 1.9);
    final h = batch == 1 ? 13.0 : 16.0;
    final perLane = ((gpu.left + 10) / (w + 12)).floor().clamp(2, 9);
    final shown = math.min(trips, perLane * 2);
    for (var g = 0; g < shown; g++) {
      final lane = g % 2, k = g ~/ 2;
      final p = (t + k / perLane + (lane == 1 ? 0.5 / perLane : 0)) % 1.0;
      final cx = -w + p * (gpu.left + w + 8) + w / 2;
      final cy = lane == 0 ? (road.top + midY) / 2 : (midY + road.bottom) / 2;
      _vehicle(canvas, cx, cy, w, h);
    }

    // The GPU building at the end of the road, painted last so vehicles enter it.
    final body = RRect.fromRectAndRadius(gpu, const Radius.circular(6));
    canvas.drawRRect(body, Paint()..color = Color.alphaBlend(c.magenta.withValues(alpha: 0.45), c.surface));
    canvas.drawRRect(body, Paint()
      ..color = c.magenta
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
    final tp = TextPainter(
      text: TextSpan(text: 'GPU', style: TextStyle(fontFamily: 'Roboto', color: c.text, fontSize: 11, fontWeight: FontWeight.w800)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(gpu.center.dx - tp.width / 2, gpu.top + 6));
    final win = Paint()..color = c.text.withValues(alpha: 0.8);
    final winW = math.max(3.0, (gpu.width - 22) / 3);
    for (var y = gpu.top + 22; y < road.top - 10; y += 12) {
      for (var col = 0; col < 3; col++) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(gpu.left + 8 + col * (winW + 3), y, winW, 6), const Radius.circular(1)), win);
      }
    }

    if (trips > shown) {
      final more = TextPainter(
        text: TextSpan(text: '+${trips - shown} more trips', style: TextStyle(fontFamily: 'Roboto', color: c.textDim, fontSize: 10)),
        textDirection: TextDirection.ltr,
      )..layout();
      more.paint(canvas, Offset(6, size.height - more.height - 3));
    }
  }

  /// One vehicle — a little car when [batch] is 1, a longer van/bus otherwise — with its passengers
  /// as dots inside. Wheels and dots use [AppColors.bg], which contrasts with the body in both themes.
  void _vehicle(Canvas canvas, double cx, double cy, double w, double h) {
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(batch == 1 ? w * 0.35 : 4)),
        Paint()..color = batch == 1 ? c.cyan : c.lime);
    final dark = Paint()..color = c.bg;
    canvas.drawCircle(Offset(cx - w * 0.28, cy + h / 2), 2.6, dark);
    canvas.drawCircle(Offset(cx + w * 0.28, cy + h / 2), 2.6, dark);
    final seats = math.min(batch, ((w - 8) / 7).floor());
    for (var i = 0; i < seats; i++) {
      final dx = seats == 1 ? 0.0 : -(seats - 1) * 3.5 + i * 7;
      canvas.drawCircle(Offset(cx + dx, cy - 1), 2.2, dark);
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
