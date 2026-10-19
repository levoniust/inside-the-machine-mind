import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Section 2 · "Step 4: rolling downhill" (gradient descent).
/// A foggy landscape of loss: a deep valley (good model), a shallow dip (a trap), and a ball that
/// only knows which way is downhill where it stands. Learning rate and momentum are adjustable;
/// tap the map to drop the ball somewhere else.
class S2DescentScreen extends StatelessWidget {
  const S2DescentScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's2_descent',
        children: [_Landscape(), _Explain()],
      );
}

/// The loss surface: a wide bowl with a deep valley on the left and a shallow trap on the right.
double lossSurface(double x, double y) =>
    0.10 * x * x +
    0.45 * y * y -
    1.1 * math.exp(-((x + 1.6) * (x + 1.6) + y * y) / 0.9) -
    0.45 * math.exp(-((x - 1.5) * (x - 1.5) + (y - 0.7) * (y - 0.7)) / 0.25);

Offset lossGradient(double x, double y) {
  const h = 1e-4;
  return Offset(
    (lossSurface(x + h, y) - lossSurface(x - h, y)) / (2 * h),
    (lossSurface(x, y + h) - lossSurface(x, y - h)) / (2 * h),
  );
}

class _Landscape extends StatefulWidget {
  const _Landscape();

  @override
  State<_Landscape> createState() => _LandscapeState();
}

class _LandscapeState extends State<_Landscape> with SingleTickerProviderStateMixin {
  static const start = Offset(2.7, 1.7);
  static const range = 3.2; // map shows x, y in [-range, range]
  Offset _pos = start;
  Offset _vel = Offset.zero;
  final List<Offset> _trail = [start];
  double _lr = 0.35;
  bool _momentum = false;
  bool _running = false;
  int _steps = 0;
  late final Ticker _ticker = createTicker((_) => _tick());

  void _stepOnce() {
    final g = lossGradient(_pos.dx, _pos.dy);
    _vel = _momentum ? _vel * 0.85 - g * _lr : -g * _lr;
    _pos += _vel;
    _pos = Offset(_pos.dx.clamp(-range, range), _pos.dy.clamp(-range, range));
    _trail.add(_pos);
    if (_trail.length > 600) _trail.removeAt(0);
    _steps++;
  }

  void _tick() {
    setState(() {
      _stepOnce();
      if (_steps >= 400 || (_vel.distance < 1e-4 && _steps > 5)) {
        _running = false;
        _ticker.stop();
      }
    });
  }

  void _toggle() {
    setState(() => _running = !_running);
    _running ? _ticker.start() : _ticker.stop();
  }

  void _drop(Offset p) {
    _ticker.stop();
    setState(() {
      _running = false;
      _pos = p;
      _vel = Offset.zero;
      _trail
        ..clear()
        ..add(p);
      _steps = 0;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  String get _verdict {
    if (_steps == 0) return 'Ready. Press Roll.';
    final l = lossSurface(_pos.dx, _pos.dy);
    if (_running) return 'Rolling…';
    if (l < -0.7) return 'Found the deep valley: a well-trained model!';
    if (_steps >= 400) return 'Bouncing around and never settling: the steps are too big!';
    if (_pos.dx > 0.8) return 'Stuck in the shallow dip: a "local minimum". Try momentum!';
    return 'Stopped. Try another learning rate.';
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final loss = lossSurface(_pos.dx, _pos.dy);
    return DemoCard(
      title: 'Find the bottom of the valley',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Darker = lower loss (less wrong). The ball can only feel the slope under it. Tap the map to move it.',
              style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.m),
          AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (context, box) => GestureDetector(
                key: const ValueKey('descent-map'),
                onTapDown: (d) {
                  final s = box.maxWidth;
                  _drop(Offset(d.localPosition.dx / s * 2 * range - range, d.localPosition.dy / s * 2 * range - range));
                },
                child: Semantics(
                  label: 'Loss landscape. Ball at height ${loss.toStringAsFixed(2)} after $_steps steps',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomPaint(painter: _SurfacePainter(_pos, List.of(_trail), c, range)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Gap.m),
          Row(
            children: [
              Expanded(child: StatTile(label: 'Steps', value: '$_steps')),
              const SizedBox(width: Gap.s),
              Expanded(child: StatTile(label: 'Loss here', value: loss.toStringAsFixed(2), color: c.violet)),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text(_verdict, key: const ValueKey('descent-verdict'), style: TextStyle(color: c.text, fontWeight: FontWeight.w600)),
          const SizedBox(height: Gap.s),
          LabeledSlider(
            key: const ValueKey('descent-lr'),
            label: 'Learning rate (step size)',
            value: _lr,
            min: 0.02,
            max: 3.5,
            color: c.violet,
            format: (v) => v.toStringAsFixed(2),
            onChanged: (v) => setState(() => _lr = v),
          ),
          SwitchListTile(
            key: const ValueKey('descent-momentum'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Momentum (keep some speed between steps)'),
            subtitle: const Text('This is one half of the Adam optimizer; Adam also gives each knob its own step size.'),
            value: _momentum,
            activeThumbColor: c.violet,
            onChanged: (v) => setState(() => _momentum = v),
          ),
          Wrap(
            spacing: Gap.s,
            alignment: WrapAlignment.center,
            children: [
              FilledButton.icon(
                key: const ValueKey('descent-roll'),
                style: FilledButton.styleFrom(backgroundColor: c.violet, foregroundColor: Colors.white),
                onPressed: _toggle,
                icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                label: Text(_running ? 'Pause' : 'Roll'),
              ),
              OutlinedButton.icon(
                key: const ValueKey('descent-reset'),
                onPressed: () => _drop(start),
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SurfacePainter extends CustomPainter {
  _SurfacePainter(this.pos, this.trail, this.c, this.range);
  final Offset pos;
  final List<Offset> trail;
  final AppColors c;
  final double range;

  static List<List<double>>? _cache;
  static const n = 72;

  @override
  void paint(Canvas canvas, Size size) {
    _cache ??= List.generate(
        n, (i) => List.generate(n, (j) => lossSurface((i + 0.5) / n * 2 * range - range, (j + 0.5) / n * 2 * range - range)));
    final grid = _cache!;
    var lo = double.infinity, hi = -double.infinity;
    for (final row in grid) {
      for (final v in row) {
        lo = math.min(lo, v);
        hi = math.max(hi, v);
      }
    }
    final cw = size.width / n;
    final paint = Paint();
    // Contour bands: deep violet (low loss) → cyan → pale (high loss).
    final stops = [const Color(0xFF14082E), c.violet, c.cyan, const Color(0xFFD8F6FF)];
    Color ramp(double t) {
      final x = t * (stops.length - 1);
      final i = x.floor().clamp(0, stops.length - 2);
      return Color.lerp(stops[i], stops[i + 1], x - i)!;
    }
    for (var i = 0; i < n; i++) {
      for (var j = 0; j < n; j++) {
        final raw = math.pow((grid[i][j] - lo) / (hi - lo), 0.55).toDouble();
        final band = (raw * 12).floor() / 12;
        paint.color = ramp(band);
        canvas.drawRect(Rect.fromLTWH(i * cw, j * cw, cw + 0.6, cw + 0.6), paint);
      }
    }
    void label(String text, Offset at) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: const TextStyle(fontFamily: 'Roboto', color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
    }
    Offset toPx(Offset p) => Offset((p.dx + range) / (2 * range) * size.width, (p.dy + range) / (2 * range) * size.height);
    label('deep valley', toPx(const Offset(-1.6, 0.55)));
    label('trap', toPx(const Offset(1.5, 0.15)));
    if (trail.length > 1) {
      final path = Path()..moveTo(toPx(trail.first).dx, toPx(trail.first).dy);
      for (final p in trail.skip(1)) {
        final q = toPx(p);
        path.lineTo(q.dx, q.dy);
      }
      canvas.drawPath(path, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = c.lime.withValues(alpha: 0.8));
    }
    final b = toPx(pos);
    canvas.drawCircle(b, 14, Paint()..color = c.lime.withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    canvas.drawCircle(b, 8, Paint()..color = c.lime);
    canvas.drawCircle(b + const Offset(-2.5, -2.5), 2.5, Paint()..color = Colors.white.withValues(alpha: 0.8));
  }

  @override
  bool shouldRepaint(_SurfacePainter old) => old.pos != pos || old.trail.length != trail.length || old.c != c;
}

class _Explain extends StatelessWidget {
  const _Explain();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    Widget row(IconData i, Color col, String title, String body) => Padding(
          padding: const EdgeInsets.only(bottom: Gap.m),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(i, color: col),
              const SizedBox(width: Gap.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(body, style: TextStyle(color: c.textDim)),
                  ],
                ),
              ),
            ],
          ),
        );
    return DemoCard(
      title: 'Why this matters for real models',
      child: Column(
        children: [
          row(Icons.terrain, c.violet, 'Billions of directions, not two',
              'A real model\'s landscape has one direction per knob: 405 billion of them for Llama 3 405B. Nobody can picture it, but the slope math works the same.'),
          row(Icons.speed, c.amber, 'Step size is a balancing act',
              'Engineers start with small steps ("warm-up"), go faster, then slow down at the end ("cool-down") to settle into the valley.'),
          row(Icons.sports_baseball, c.lime, 'Momentum helps',
              'Like a ball that keeps rolling, momentum carries the model past small bumps and dips.'),
        ],
      ),
    );
  }
}
