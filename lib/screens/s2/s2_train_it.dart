import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../app/theme.dart';
import '../../core/tiny_net.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 2 · "Train a tiny brain yourself".
/// A real neural network (2 → 8 → 1, 33 knobs) learns, live on the phone, to separate the dots in
/// the middle from the dots in the ring. Same recipe as a giant LLM, just 12 billion times smaller.
class S2TrainItScreen extends StatelessWidget {
  const S2TrainItScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LessonScaffold(
      lessonId: 's2_train_it',
      children: [
        _Trainer(),
        _ScaleCompare(),
      ],
    );
  }
}

class _Trainer extends StatefulWidget {
  const _Trainer();

  @override
  State<_Trainer> createState() => _TrainerState();
}

class _TrainerState extends State<_Trainer> with SingleTickerProviderStateMixin {
  final data = ringDataset();
  late TinyNet net = TinyNet(seed: _seed);
  int _seed = 1;
  double _lr = 0.8;
  bool _momentum = false;
  bool _running = false;
  final List<double> _history = [];
  late final Ticker _ticker = createTicker((_) => _tick());

  @override
  void initState() {
    super.initState();
    _history.add(net.loss(data));
  }

  void _tick() {
    setState(() {
      for (var i = 0; i < 4; i++) {
        final l = net.trainStep(data, _lr, momentum: _momentum ? 0.9 : 0);
        if (!l.isFinite) {
          _running = false;
          _ticker.stop();
          return;
        }
        if (net.steps % 2 == 0) _history.add(l);
      }
      if (_history.length > 400) _history.removeRange(0, _history.length - 400);
      if (net.steps >= 3000) _toggle();
    });
  }

  void _toggle() {
    setState(() => _running = !_running);
    _running ? _ticker.start() : _ticker.stop();
  }

  void _step() {
    setState(() {
      _history.add(net.trainStep(data, _lr, momentum: _momentum ? 0.9 : 0));
    });
  }

  void _reset() {
    _ticker.stop();
    setState(() {
      _running = false;
      _seed++;
      net = TinyNet(seed: _seed);
      _history
        ..clear()
        ..add(net.loss(data));
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final loss = _history.isEmpty ? double.nan : _history.last;
    final acc = net.accuracy(data);
    return DemoCard(
      title: 'Teach it: middle dots vs ring dots',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Violet dots sit in the middle, cyan dots in the ring. The background shows what the network '
            'currently believes. Press Train and watch it figure out the boundary.',
            style: TextStyle(color: c.textDim),
          ),
          const SizedBox(height: Gap.m),
          AspectRatio(
            aspectRatio: 1,
            child: Semantics(
              label: 'Decision map: accuracy ${(acc * 100).round()} percent after ${net.steps} training steps',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomPaint(painter: _MapPainter(net, data, c, net.steps)),
              ),
            ),
          ),
          const SizedBox(height: Gap.m),
          Row(
            children: [
              Expanded(child: StatTile(label: 'Training steps', value: '${net.steps}')),
              const SizedBox(width: Gap.s),
              Expanded(
                  child: StatTile(
                      label: 'Loss (wrongness)',
                      value: loss.isFinite ? loss.toStringAsFixed(3) : 'exploded!',
                      color: loss.isFinite ? c.violet : c.red)),
              const SizedBox(width: Gap.s),
              Expanded(child: StatTile(label: 'Accuracy', value: '${(acc * 100).round()}%', color: c.lime)),
            ],
          ),
          const SizedBox(height: Gap.m),
          SizedBox(
            height: 90,
            child: Semantics(
              label: 'Loss curve',
              child: CustomPaint(painter: _LossPainter(List.of(_history), c)),
            ),
          ),
          Text('Loss over time: it should slide downhill.', style: TextStyle(color: c.textDim, fontSize: 12)),
          const SizedBox(height: Gap.m),
          LabeledSlider(
            key: const ValueKey('train-lr'),
            label: 'Learning rate (step size)',
            value: _lr,
            min: 0.05,
            max: 12,
            color: c.violet,
            format: (v) => v.toStringAsFixed(2),
            onChanged: (v) => setState(() => _lr = v),
          ),
          if (_lr > 6)
            Text('Huge steps! Watch it overshoot and jitter instead of settling.',
                style: TextStyle(color: c.amber, fontSize: 13)),
          if (_lr < 0.2)
            Text('Tiny steps: safe but painfully slow.', style: TextStyle(color: c.textDim, fontSize: 13)),
          SwitchListTile(
            key: const ValueKey('train-momentum'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Momentum (like a ball that keeps rolling)'),
            value: _momentum,
            activeThumbColor: c.violet,
            onChanged: (v) => setState(() => _momentum = v),
          ),
          Wrap(
            spacing: Gap.s,
            runSpacing: Gap.s,
            alignment: WrapAlignment.center,
            children: [
              FilledButton.icon(
                key: const ValueKey('train-play'),
                style: FilledButton.styleFrom(backgroundColor: c.violet, foregroundColor: Colors.white),
                onPressed: _toggle,
                icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                label: Text(_running ? 'Pause' : 'Train'),
              ),
              OutlinedButton.icon(
                key: const ValueKey('train-step'),
                onPressed: _running ? null : _step,
                icon: const Icon(Icons.skip_next),
                label: const Text('One step'),
              ),
              OutlinedButton.icon(
                key: const ValueKey('train-reset'),
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: const Text('New random brain'),
              ),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text('This network has ${net.parameterCount} knobs. Every step nudges all of them a tiny bit downhill.',
              textAlign: TextAlign.center, style: TextStyle(color: c.textDim, fontSize: 13)),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter(this.net, this.data, this.c, this.steps);
  final TinyNet net;
  final List<Sample> data;
  final AppColors c;
  final int steps;

  @override
  void paint(Canvas canvas, Size size) {
    const n = 36;
    final cw = size.width / n, ch = size.height / n;
    final paint = Paint();
    for (var i = 0; i < n; i++) {
      for (var j = 0; j < n; j++) {
        final x = (i + 0.5) / n * 2 - 1;
        final y = (j + 0.5) / n * 2 - 1;
        final p = net.predict(x, y);
        paint.color = Color.lerp(c.cyan, c.violet, p)!.withValues(alpha: 0.18 + 0.32 * (p - 0.5).abs() * 2);
        canvas.drawRect(Rect.fromLTWH(i * cw, j * ch, cw + 0.5, ch + 0.5), paint);
      }
    }
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = c.bg;
    for (final s in data) {
      final o = Offset((s.x + 1) / 2 * size.width, (s.y + 1) / 2 * size.height);
      canvas.drawCircle(o, 4.5, Paint()..color = s.label == 1 ? c.violet : c.cyan);
      canvas.drawCircle(o, 4.5, border);
    }
  }

  @override
  bool shouldRepaint(_MapPainter old) => true;
}

class _LossPainter extends CustomPainter {
  _LossPainter(this.history, this.c);
  final List<double> history;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = c.line
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), grid);
    canvas.drawLine(Offset.zero, Offset(0, size.height), grid);
    final finite = history.where((v) => v.isFinite).toList();
    if (finite.length < 2) return;
    final maxV = math.max(finite.reduce(math.max), 0.8);
    final path = Path();
    for (var i = 0; i < finite.length; i++) {
      final x = i / (finite.length - 1) * size.width;
      final y = size.height - (finite[i] / maxV).clamp(0.0, 1.0) * size.height;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = c.violet);
  }

  @override
  bool shouldRepaint(_LossPainter old) => true;
}

/// Puts the toy in perspective: same recipe, wildly different scale.
class _ScaleCompare extends StatelessWidget {
  const _ScaleCompare();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DemoCard(
      title: 'Same recipe, different size',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CompareBars(
            log: true,
            color: c.violet,
            items: [
              BarItem('Your tiny brain', 33, display: '33 knobs'),
              BarItem('GPT-3 (2020)', 175e9, display: '175 billion'),
              BarItem('Llama 3 405B (2024)', 405e9, display: '405 billion'),
            ],
          ),
          const SizedBox(height: Gap.m),
          TermText(
            'Your network learned from 160 dots in a few seconds. Llama 3 405B learned from 15.6 trillion '
            '[[tokens|token]] on up to 16,000 [[GPUs|GPU]]. The loop was identical: guess, measure the [[loss]], '
            '[[backpropagate|backpropagation]], nudge.',
          ),
          const SizedBox(height: Gap.s),
          const Row(
            children: [
              Expanded(child: FactCard(value: '15.6T', label: 'tokens used to train Llama 3 405B', factId: 'TR-LLAMA3-TOKENS')),
              SizedBox(width: Gap.m),
              Expanded(child: FactCard(value: '30.8M', label: 'H100 GPU-hours to train it', factId: 'TR-LLAMA3-TOKENS')),
            ],
          ),
        ],
      ),
    );
  }
}
