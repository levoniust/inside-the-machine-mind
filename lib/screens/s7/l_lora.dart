import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Small patches for big models: a frozen weight matrix W plus a thin A·B update (LoRA), and what fine-tuning an
/// 8B model costs in memory: full, LoRA, QLoRA.
class LLoraScreen extends StatelessWidget {
  const LLoraScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
    lessonId: 'l_lora',
    children: [
      _Matrix(),
      _Memory(),
      FactCard(
        value: '10,000×',
        label: 'fewer trainable parameters for GPT-3 175B, and 3× less GPU memory',
        factId: 'CU-LORA-10K',
      ),
      FactCard(value: '780 → 48 GB', label: 'QLoRA: fine-tuning a 65B model on one 48 GB GPU', factId: 'CU-QLORA-48'),
    ],
  );
}

String _n(int v) => v >= 1000000
    ? '${(v / 1e6).toStringAsFixed(1)} M'
    : v >= 1000
    ? '${(v / 1000).toStringAsFixed(v >= 100000 ? 0 : 1)} k'
    : '$v';

class _Matrix extends StatefulWidget {
  const _Matrix();

  @override
  State<_Matrix> createState() => _MatrixState();
}

class _MatrixState extends State<_Matrix> {
  static const _d = 4096; // hidden size of Llama 3.1 8B
  static const _ranks = [1, 2, 4, 8, 16, 32, 64, 128];
  int _ri = 3;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(7);
    final r = _ranks[_ri];
    final full = _d * _d, lora = 2 * _d * r;
    return DemoCard(
      title: 'Freeze W, train two thin matrices',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 180,
            child: CustomPaint(
              key: const ValueKey('lora-matrix'),
              painter: _MatrixPainter(rank: r, frozen: c.line, a: accent, b: c.cyan, text: c.textDim),
            ),
          ),
          const SizedBox(height: Gap.s),
          LabeledSlider(
            key: const ValueKey('lora-rank'),
            label: 'Rank r',
            value: _ri.toDouble(),
            min: 0,
            max: (_ranks.length - 1).toDouble(),
            divisions: _ranks.length - 1,
            format: (_) => '$r',
            color: accent,
            onChanged: (v) => setState(() => _ri = v.round()),
          ),
          StatGrid(
            columns: 2,
            children: [
              StatTile(label: 'W (frozen), 4,096 × 4,096', value: _n(full), color: c.textDim),
              StatTile(
                key: const ValueKey('lora-params'),
                label: 'A + B (trained)',
                value: '${_n(lora)} · ${(lora / full * 100).toStringAsFixed(2)}%',
                color: accent,
              ),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text(
            'new W = W + B·A. After training, B·A can be added into W, so the model runs exactly as fast as before; '
            'or keep it separate as a small adapter file you switch on and off.',
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _MatrixPainter extends CustomPainter {
  _MatrixPainter({required this.rank, required this.frozen, required this.a, required this.b, required this.text});
  final int rank;
  final Color frozen, a, b, text;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.height - 20;
    // W: a big square grid
    final w = Rect.fromLTWH(0, 0, s, s);
    final grid = Paint()
      ..color = frozen
      ..strokeWidth = 1;
    canvas.drawRect(w, Paint()..color = frozen.withValues(alpha: 0.25));
    for (var i = 1; i < 12; i++) {
      canvas.drawLine(Offset(i * s / 12, 0), Offset(i * s / 12, s), grid);
      canvas.drawLine(Offset(0, i * s / 12), Offset(s, i * s / 12), grid);
    }
    _label(canvas, 'W  (frozen)', Offset(0, s + 4));
    // + B (s × r) and A (r × s), thickness grows with the rank (log-ish so rank 128 still fits)
    final thick = (4 + 6 * (rank.bitLength - 1)).toDouble();
    final x0 = s + 24;
    _label(canvas, '+', Offset(s + 6, s / 2 - 8));
    final bRect = Rect.fromLTWH(x0, 0, thick, s);
    canvas.drawRect(bRect, Paint()..color = b.withValues(alpha: 0.85));
    _label(canvas, 'B', Offset(x0, s + 4));
    final ax = x0 + thick + 14;
    final aRect = Rect.fromLTWH(ax, s / 2 - thick / 2, (size.width - ax).clamp(40, s), thick);
    canvas.drawRect(aRect, Paint()..color = a.withValues(alpha: 0.85));
    _label(canvas, 'A   (r = $rank)', Offset(ax, s / 2 + thick / 2 + 4));
  }

  void _label(Canvas canvas, String t, Offset at) {
    (TextPainter(
      text: TextSpan(
        text: t,
        style: TextStyle(fontSize: 12, color: text),
      ),
      textDirection: TextDirection.ltr,
    )..layout()).paint(canvas, at);
  }

  @override
  bool shouldRepaint(_MatrixPainter old) => old.rank != rank || old.a != a;
}

/// Memory to fine-tune an 8B model, before activations: full (≈16 bytes per parameter with Adam), LoRA (16-bit frozen
/// weights + small adapters), QLoRA (4-bit frozen weights + small adapters).
class _Memory extends StatefulWidget {
  const _Memory();

  @override
  State<_Memory> createState() => _MemoryState();
}

class _MemoryState extends State<_Memory> {
  int _mode = 0;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(7);
    const params = 8.03; // billions
    final bars = [
      BarItem('Full fine-tune', params * 16, display: '${(params * 16).round()} GB', color: c.red),
      BarItem('LoRA', params * 2, display: '${(params * 2).round()} GB', color: accent),
      BarItem('QLoRA', params * 0.5, display: '${(params * 0.5).round()} GB', color: c.lime),
    ];
    final notes = [
      'Full: every weight gets a gradient and two Adam numbers. About 16 bytes per parameter, ${(params * 16).round()} GB '
          'before activations: several datacenter GPUs.',
      'LoRA: the 16-bit weights stay frozen (2 bytes per parameter, ${(params * 2).round()} GB); gradients and Adam only '
          'for the small adapters. One 24 GB card can do it.',
      'QLoRA: the frozen base is stored in 4 bits (about ${(params * 0.5).round()} GB); the adapters train in 16-bit. '
          'A 12-16 GB gaming card can fine-tune an 8B model.',
    ];
    return DemoCard(
      title: 'Fine-tuning an 8B model: memory before activations',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CompareBars(items: bars, highlight: _mode),
          const SizedBox(height: Gap.s),
          SegmentedButton<int>(
            key: const ValueKey('lora-mode'),
            segments: const [
              ButtonSegment(value: 0, label: Text('Full')),
              ButtonSegment(value: 1, label: Text('LoRA')),
              ButtonSegment(value: 2, label: Text('QLoRA')),
            ],
            selected: {_mode},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _mode = s.first),
          ),
          const SizedBox(height: Gap.s),
          Text(notes[_mode], key: const ValueKey('lora-note')),
          const SizedBox(height: Gap.xs),
          Text(
            'Rough: 16 / 2 / 0.5 bytes per parameter; real runs also need memory for activations and batches.',
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
