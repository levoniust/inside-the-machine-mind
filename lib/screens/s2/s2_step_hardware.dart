import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 2 · "One step, inside the hardware": the Section 1 parts working together on one training
/// step. Step through a server diagram: load batch → forward → loss → backward → all-reduce → update →
/// checkpoint. Facts: TR-6ND (2 + 4), HW-NVLINK4, HW-IB, HW-HBM-H100, TR-MFU, TR-LLAMA3-FAIL.
class S2StepHardwareScreen extends StatelessWidget {
  const S2StepHardwareScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's2_step_hardware',
        children: [_StepDiagram(), _Waiting()],
      );
}

enum _Part { storage, cpu, gpus, hbm, nvlink, network, others }

class _Phase {
  const _Phase(this.title, this.text, this.lit);
  final String title, text;
  final Set<_Part> lit;
}

const _phases = [
  _Phase('1 · Load a batch', 'A batch of text (already chopped into [[tokens|token]]) streams from storage through the CPU into each GPU\'s [[HBM]].',
      {_Part.storage, _Part.cpu, _Part.hbm}),
  _Phase('2 · Forward pass', '[[Tensor cores|tensor core]] multiply the batch by the weights, layer after layer, reading the weights from HBM. This is the "guess".',
      {_Part.gpus, _Part.hbm}),
  _Phase('3 · Loss', 'Each guess is compared with the real next token, giving the [[loss]] (wrongness score).', {_Part.gpus}),
  _Phase('4 · Backward pass', '[[Backpropagation]] sends the blame back through every layer. It costs about twice the math of the forward pass (that\'s the 4 in 6 × knobs × tokens).',
      {_Part.gpus, _Part.hbm}),
  _Phase('5 · Compare notes', 'Every GPU saw different text, so they average their [[gradients|gradient]]: over [[NVLink]] inside the server, over [[InfiniBand]] between servers.',
      {_Part.nvlink, _Part.network, _Part.others}),
  _Phase('6 · Update', 'Each GPU nudges its knobs with the averaged gradient. Every copy of the model stays identical.', {_Part.gpus, _Part.hbm}),
  _Phase('7 · Save game (sometimes)', 'Every so often the whole model is written back to storage as a [[checkpoint]], in case a GPU fails.',
      {_Part.hbm, _Part.cpu, _Part.storage}),
];

class _StepDiagram extends StatefulWidget {
  const _StepDiagram();

  @override
  State<_StepDiagram> createState() => _StepDiagramState();
}

class _StepDiagramState extends State<_StepDiagram> with SingleTickerProviderStateMixin {
  int _step = 0;
  bool _playing = false;
  Timer? _auto;
  late final AnimationController _flow = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _flow.value = 0.5;
      _flow.stop();
    } else if (!_flow.isAnimating) {
      _flow.repeat();
    }
  }

  void _togglePlay() {
    setState(() => _playing = !_playing);
    _auto?.cancel();
    if (_playing) {
      _auto = Timer.periodic(const Duration(milliseconds: 2600), (_) {
        if (!mounted) return;
        setState(() => _step = (_step + 1) % _phases.length);
      });
    }
  }

  @override
  void dispose() {
    _auto?.cancel();
    _flow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final p = _phases[_step];
    return DemoCard(
      title: 'One training step, part by part',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1.15,
            child: Semantics(
              label: 'Server diagram. ${p.title}',
              child: AnimatedBuilder(
                animation: _flow,
                builder: (_, _) => CustomPaint(painter: _ServerPainter(p.lit, _flow.value, c)),
              ),
            ),
          ),
          const SizedBox(height: Gap.m),
          Text(p.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: c.violet, fontWeight: FontWeight.w800)),
          const SizedBox(height: Gap.xs),
          TermText(p.text, key: ValueKey('hw-step-$_step')),
          const SizedBox(height: Gap.m),
          StepControls(
            step: _step,
            count: _phases.length,
            playing: _playing,
            onPlayPause: _togglePlay,
            onStep: (i) => setState(() => _step = i),
          ),
        ],
      ),
    );
  }
}

class _ServerPainter extends CustomPainter {
  _ServerPainter(this.lit, this.t, this.c);
  final Set<_Part> lit;
  final double t;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    Rect r(double x, double y, double ww, double hh) => Rect.fromLTWH(x * w, y * h, ww * w, hh * h);
    final storage = r(0.03, 0.06, 0.26, 0.16);
    final cpu = r(0.37, 0.06, 0.26, 0.16);
    final net = r(0.71, 0.06, 0.26, 0.16);
    final nvl = r(0.30, 0.52, 0.40, 0.08);
    final others = r(0.78, 0.82, 0.19, 0.14);
    final gpus = [
      for (var i = 0; i < 8; i++) r(0.04 + (i % 4) * 0.18, i < 4 ? 0.30 : 0.66, 0.15, 0.16),
    ];

    void box(Rect rect, String label, bool on, Color col) {
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)),
          Paint()..color = on ? col.withValues(alpha: 0.28) : c.surfaceHi);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = on ? 2 : 1
        ..color = on ? col : c.line);
      final tp = TextPainter(
        text: TextSpan(
            text: label,
            style: TextStyle(fontFamily: 'Roboto', fontSize: 10.5, fontWeight: FontWeight.w700, color: on ? c.text : c.textDim)),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: rect.width - 4);
      tp.paint(canvas, rect.center - Offset(tp.width / 2, tp.height / 2));
    }

    void wire(Offset a, Offset b, bool on, Color col) {
      canvas.drawLine(a, b, Paint()
        ..color = on ? col.withValues(alpha: 0.7) : c.line
        ..strokeWidth = on ? 2.5 : 1.2);
      if (on) {
        for (final k in [0.0, 0.33, 0.66]) {
          final p = Offset.lerp(a, b, (t + k) % 1)!;
          canvas.drawCircle(p, 4, Paint()..color = col);
        }
      }
    }

    final dataOn = lit.contains(_Part.storage) || lit.contains(_Part.cpu);
    wire(storage.centerRight, cpu.centerLeft, dataOn, c.cyan);
    wire(cpu.bottomCenter, nvl.topCenter, dataOn || lit.contains(_Part.nvlink), c.cyan);
    for (final g in gpus) {
      wire(g.center, nvl.center, lit.contains(_Part.nvlink) || (dataOn && lit.contains(_Part.hbm)), lit.contains(_Part.nvlink) ? c.violet : c.cyan);
    }
    wire(net.bottomCenter, Offset(net.center.dx, others.top), lit.contains(_Part.network), c.amber);
    wire(nvl.centerRight, Offset(net.center.dx, nvl.center.dy), lit.contains(_Part.network), c.amber);

    box(storage, 'Storage\n(SSDs)', lit.contains(_Part.storage), c.cyan);
    box(cpu, 'CPU', lit.contains(_Part.cpu), c.cyan);
    box(net, 'Network card\n(InfiniBand)', lit.contains(_Part.network), c.amber);
    box(nvl, 'NVLink switch', lit.contains(_Part.nvlink), c.violet);
    box(others, 'other\nservers', lit.contains(_Part.others), c.amber);
    for (var i = 0; i < gpus.length; i++) {
      final g = gpus[i];
      box(g, 'GPU ${i + 1}', lit.contains(_Part.gpus), c.magenta);
      final hbm = Rect.fromLTWH(g.left + 3, g.bottom - g.height * 0.28, g.width - 6, g.height * 0.22);
      canvas.drawRRect(RRect.fromRectAndRadius(hbm, const Radius.circular(3)),
          Paint()..color = lit.contains(_Part.hbm) ? c.lime.withValues(alpha: 0.8) : c.line);
    }
    final tp = TextPainter(
      text: TextSpan(text: 'green strip = HBM memory', style: TextStyle(fontFamily: 'Roboto', fontSize: 10, color: c.textDim)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w * 0.04, h * 0.88));
  }

  @override
  bool shouldRepaint(_ServerPainter old) => old.t != t || old.lit != lit || old.c != c;
}

class _Waiting extends StatelessWidget {
  const _Waiting();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DemoCard(
      title: 'Why GPUs spend so much time waiting',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TermText(
            'Steps 1, 5 and 7 move data instead of doing math. Even in the best-run training jobs, the GPUs are doing '
            'useful math well under half the time; the rest goes to waiting for data, notes from other GPUs, and '
            'recovering from failures.',
            style: TextStyle(color: c.text),
          ),
          const SizedBox(height: Gap.m),
          const Row(
            children: [
              Expanded(child: FactCard(value: '38–43%', label: 'of peak math speed reached by Llama 3 405B training', factId: 'TR-MFU')),
              SizedBox(width: Gap.m),
              Expanded(child: FactCard(value: '900 GB/s', label: 'NVLink between GPUs in one server (H100)', factId: 'HW-NVLINK4')),
            ],
          ),
        ],
      ),
    );
  }
}
