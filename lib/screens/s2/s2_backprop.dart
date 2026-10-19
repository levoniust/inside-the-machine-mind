import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 2 · "Step 3: passing the blame backward" (backpropagation).
/// A 2-3-1 network sees one example, makes a guess (forward pass, cyan), measures the loss, then
/// sends blame backward (red) to every weight and nudges each one. All numbers are computed live.
class S2BackpropScreen extends StatelessWidget {
  const S2BackpropScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's2_backprop',
        children: [_BackpropDemo(), _BlameAnalogy()],
      );
}

/// One example through a tiny network: inputs → 3 tanh neurons → sigmoid output, target 1.
class BackpropExample {
  BackpropExample() {
    w1 = [
      [0.6, -0.4],
      [-0.3, 0.8],
      [0.5, 0.2],
    ];
    b1 = [0.0, 0.1, -0.1];
    w2 = [0.4, -0.6, 0.3];
    b2 = 0.0;
  }

  static const x = [1.0, 0.5];
  static const target = 1.0;
  late List<List<double>> w1;
  late List<double> b1, w2;
  late double b2;

  List<double> hidden() =>
      [for (var j = 0; j < 3; j++) _tanh(w1[j][0] * x[0] + w1[j][1] * x[1] + b1[j])];
  double output() {
    final h = hidden();
    var z = b2;
    for (var j = 0; j < 3; j++) {
      z += w2[j] * h[j];
    }
    return 1 / (1 + math.exp(-z));
  }

  double loss() => -math.log(output().clamp(1e-9, 1.0)); // target = 1

  /// Gradients (blame) for each weight: dLoss/dw.
  ({List<double> gw2, List<List<double>> gw1, double dz}) grads() {
    final h = hidden();
    final dz = output() - target; // sigmoid + cross-entropy
    final gw2 = [for (var j = 0; j < 3; j++) dz * h[j]];
    final gw1 = [
      for (var j = 0; j < 3; j++)
        [for (var k = 0; k < 2; k++) dz * w2[j] * (1 - h[j] * h[j]) * x[k]]
    ];
    return (gw2: gw2, gw1: gw1, dz: dz);
  }

  void update(double lr) {
    final g = grads();
    final h = hidden();
    for (var j = 0; j < 3; j++) {
      final dh = g.dz * w2[j] * (1 - h[j] * h[j]);
      w2[j] -= lr * g.gw2[j];
      for (var k = 0; k < 2; k++) {
        w1[j][k] -= lr * g.gw1[j][k];
      }
      b1[j] -= lr * dh;
    }
    b2 -= lr * g.dz;
  }

  static double _tanh(double v) {
    final e = math.exp(2 * v);
    return (e - 1) / (e + 1);
  }
}

const _labels = [
  'The example: two input numbers. The right answer is 1 ("yes").',
  'Forward pass: each hidden neuron mixes the inputs with its weights.',
  'The output neuron makes its guess.',
  'Loss: how wrong was it? (−log of the probability given to the right answer)',
  'Backward: blame flows to the last layer\'s weights first.',
  'Backward: blame keeps flowing to the first layer\'s weights.',
  'Nudge: every weight moves a little against its blame. Guess again: less wrong!',
];

class _BackpropDemo extends StatefulWidget {
  const _BackpropDemo();

  @override
  State<_BackpropDemo> createState() => _BackpropDemoState();
}

class _BackpropDemoState extends State<_BackpropDemo> with SingleTickerProviderStateMixin {
  BackpropExample net = BackpropExample();
  int _step = 0;
  int _rounds = 0;
  double? _lossBefore;
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  void _go(int s) {
    setState(() {
      if (s == 6 && _step != 6) {
        _lossBefore = net.loss();
        net.update(1.0);
        _rounds++;
      }
      _step = s;
    });
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _pulse.value = 1;
    } else {
      _pulse.forward(from: 0);
    }
  }

  void _again() {
    setState(() {
      _step = 1;
      _lossBefore = null;
    });
    _pulse.forward(from: 0);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final g = net.grads();
    return DemoCard(
      title: 'Watch one example teach the network',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1.25,
            child: Semantics(
              label: 'Network diagram. ${_labels[_step]}',
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (_, _) => CustomPaint(painter: _NetPainter(net, _step, _pulse.value, c, g.gw2, g.gw1)),
              ),
            ),
          ),
          const SizedBox(height: Gap.m),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'Guess for "yes"',
                  value: _step >= 2 ? '${(net.output() * 100).toStringAsFixed(1)}%' : '?',
                  color: c.cyan,
                ),
              ),
              const SizedBox(width: Gap.s),
              Expanded(
                child: StatTile(
                  label: 'Loss (wrongness)',
                  value: _step >= 3 ? net.loss().toStringAsFixed(3) : '?',
                  color: _step >= 3 ? c.red : c.textDim,
                ),
              ),
            ],
          ),
          if (_step == 6 && _lossBefore != null) ...[
            const SizedBox(height: Gap.s),
            Text(
              'Loss went from ${_lossBefore!.toStringAsFixed(3)} to ${net.loss().toStringAsFixed(3)} after $_rounds '
              'round${_rounds == 1 ? '' : 's'}. Repeat this trillions of times and you have a trained model.',
              key: const ValueKey('bp-improved'),
              style: TextStyle(color: c.lime, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: Gap.m),
          StepControls(step: _step, count: _labels.length, onStep: _go, labels: _labels),
          if (_step == 6)
            Center(
              child: TextButton.icon(
                key: const ValueKey('bp-again'),
                onPressed: _again,
                icon: const Icon(Icons.replay),
                label: const Text('Do another round'),
              ),
            ),
        ],
      ),
    );
  }
}

class _NetPainter extends CustomPainter {
  _NetPainter(this.net, this.step, this.t, this.c, this.gw2, this.gw1);
  final BackpropExample net;
  final int step;
  final double t;
  final AppColors c;
  final List<double> gw2;
  final List<List<double>> gw1;

  @override
  void paint(Canvas canvas, Size size) {
    final inX = size.width * 0.12, hidX = size.width * 0.5, outX = size.width * 0.86;
    final ins = [Offset(inX, size.height * 0.33), Offset(inX, size.height * 0.67)];
    final hid = [for (var j = 0; j < 3; j++) Offset(hidX, size.height * (0.2 + 0.3 * j))];
    final out = Offset(outX, size.height * 0.5);
    final h = net.hidden();

    void edge(Offset a, Offset b, double w, {double? grad, bool forward = false, bool backward = false}) {
      final base = Paint()
        ..strokeWidth = 1 + w.abs() * 3
        ..color = (w >= 0 ? c.cyan : c.amber).withValues(alpha: 0.35);
      canvas.drawLine(a, b, base);
      if (forward) {
        final p = Offset.lerp(a, b, t)!;
        canvas.drawCircle(p, 5, Paint()..color = c.cyan);
      }
      if (backward && grad != null) {
        final p = Offset.lerp(b, a, t)!;
        canvas.drawCircle(p, 5, Paint()..color = c.red);
        _text(canvas, (grad >= 0 ? '+' : '') + grad.toStringAsFixed(2), Offset.lerp(a, b, 0.55)! + const Offset(0, -12), c.red, 10);
      }
    }

    for (var j = 0; j < 3; j++) {
      for (var k = 0; k < 2; k++) {
        edge(ins[k], hid[j], net.w1[j][k], forward: step == 1, backward: step == 5, grad: gw1[j][k]);
      }
      edge(hid[j], out, net.w2[j], forward: step == 2, backward: step == 4, grad: gw2[j]);
    }

    void node(Offset o, String label, Color col, {bool lit = false}) {
      if (lit) canvas.drawCircle(o, 26, Paint()..color = col.withValues(alpha: 0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      canvas.drawCircle(o, 20, Paint()..color = c.surface);
      canvas.drawCircle(o, 20, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = col);
      _text(canvas, label, o, c.text, 11, center: true);
    }

    for (var k = 0; k < 2; k++) {
      node(ins[k], BackpropExample.x[k].toStringAsFixed(1), c.cyan, lit: step == 0);
    }
    for (var j = 0; j < 3; j++) {
      node(hid[j], step >= 1 ? h[j].toStringAsFixed(2) : '?', c.violet, lit: step == 1);
    }
    node(out, step >= 2 ? net.output().toStringAsFixed(2) : '?', step >= 3 ? c.red : c.magenta, lit: step == 2 || step == 3);
    _text(canvas, 'inputs', Offset(inX, size.height * 0.08), c.textDim, 11, center: true);
    _text(canvas, 'hidden', Offset(hidX, size.height * 0.04), c.textDim, 11, center: true);
    _text(canvas, 'guess', Offset(outX, size.height * 0.33), c.textDim, 11, center: true);
    if (step >= 3) _text(canvas, 'target 1.00', Offset(outX, size.height * 0.68), c.lime, 11, center: true);
  }

  void _text(Canvas canvas, String s, Offset at, Color col, double size, {bool center = false}) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(fontFamily: 'Roboto', color: col, fontSize: size, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center ? at - Offset(tp.width / 2, tp.height / 2) : at - Offset(tp.width / 2, 0));
  }

  @override
  bool shouldRepaint(_NetPainter old) => true;
}

class _BlameAnalogy extends StatelessWidget {
  const _BlameAnalogy();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DemoCard(
      title: 'Blame, passed down the line',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TermText(
            'Imagine a kitchen that served a dish that was too salty. The head chef asks: "How much did each '
            'station add?" Each station asks its own helpers the same question. In the end, everyone knows exactly '
            'how much to cut back. That\'s [[backpropagation]]: the [[gradient]] tells every knob which way to turn, '
            'and by how much.',
          ),
          const SizedBox(height: Gap.m),
          Text('In a real model the same trick runs through over a hundred layers and billions of weights at once, '
              'and it costs about twice as much math as the guess itself.',
              style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.s),
          const FactCard(
            value: '1986',
            label: 'Rumelhart, Hinton & Williams popularized [[backpropagation]] in the journal Nature',
            factId: 'TR-BACKPROP',
          ),
        ],
      ),
    );
  }
}
