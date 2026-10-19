import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 1 · "Why one chip isn't enough": a model's weights as boxes that overflow 80 GB GPUs.
/// Pick a size and precision: GPUs needed to hold it, and ~8× that to train it (16 vs 2 bytes per knob).
/// Facts: DC-MODEL-MEM, DC-TRAIN-MEM, HW-HBM-H100, HW-FORMATS.
class S1TooBigScreen extends StatelessWidget {
  const S1TooBigScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's1_too_big',
        children: [_Fit()],
      );
}

const gpuGb = 80.0;

/// GPUs (80 GB each) needed just to hold [params] at [bytesPerParam].
int gpusToHold(double params, double bytesPerParam) => math.max(1, (params * bytesPerParam / 1e9 / gpuGb).ceil());

class _Fit extends StatefulWidget {
  const _Fit();

  @override
  State<_Fit> createState() => _FitState();
}

class _FitState extends State<_Fit> {
  double _exp = math.log(70e9) / math.ln10;
  int _fmt = 1; // FP32, BF16, FP8, FP4
  static const _formats = [('FP32', 4.0), ('BF16', 2.0), ('FP8', 1.0), ('FP4', 0.5)];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final params = math.pow(10, _exp).toDouble();
    final bytes = _formats[_fmt].$2;
    final gb = params * bytes / 1e9;
    final hold = gpusToHold(params, bytes);
    final train = gpusToHold(params, 16);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          title: 'Does it fit on one GPU?',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: Gap.s,
                children: [
                  for (final (n, p) in const [('8B', 8e9), ('70B', 70e9), ('405B', 405e9), ('2T', 2e12)])
                    ActionChip(label: Text(n), onPressed: () => setState(() => _exp = math.log(p) / math.ln10)),
                ],
              ),
              LabeledSlider(
                key: const ValueKey('big-params'),
                label: 'Model size (knobs)',
                value: _exp,
                min: 9,
                max: 12.3,
                format: (v) => humanNumber(math.pow(10, v).toDouble(), digits: 0),
                onChanged: (v) => setState(() => _exp = v),
              ),
              SegmentedButton<int>(
                key: const ValueKey('big-format'),
                segments: [for (var i = 0; i < _formats.length; i++) ButtonSegment(value: i, label: Text(_formats[i].$1))],
                selected: {_fmt},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _fmt = s.first),
              ),
              const SizedBox(height: Gap.xs),
              Text('${bytes == 0.5 ? '½' : bytes.toStringAsFixed(0)} byte${bytes == 1 ? '' : 's'} per knob',
                  style: TextStyle(color: c.textDim, fontSize: 12)),
              const SizedBox(height: Gap.m),
              AspectRatio(
                aspectRatio: 2,
                child: Semantics(
                  label: '$hold GPU${hold == 1 ? '' : 's'} needed to hold the model',
                  child: CustomPaint(painter: _GpuPainter(gb, c)),
                ),
              ),
              const SizedBox(height: Gap.m),
              StatGrid(
                columns: 3,
                children: [
                  StatTile(label: 'Weights', value: humanBytes(gb * 1e9), color: c.cyan),
                  StatTile(key: const ValueKey('big-hold'), label: 'GPUs to hold it', value: '$hold', color: hold == 1 ? c.lime : c.amber),
                  StatTile(label: 'GPUs to train it', value: '$train', color: c.red),
                ],
              ),
              const SizedBox(height: Gap.s),
              Text(
                hold == 1 ? 'It fits on one 80 GB GPU!' : 'Too big for one GPU: it has to be split across $hold of them.',
                key: const ValueKey('big-verdict'),
                style: TextStyle(color: c.text, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: Gap.s),
              TermText(
                'Training needs about 16 bytes per knob (weights, [[gradients|gradient]] and optimizer notes), about 8× as much as '
                'running at 16-bit, and that\'s before the scratch work. Fewer bits per number ([[precision]]) shrink the model.',
                style: TextStyle(color: c.textDim, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: FactCard(value: '80 GB', label: 'memory on one H100 GPU', factId: 'HW-HBM-H100')),
            SizedBox(width: Gap.m),
            Expanded(child: FactCard(value: '810 GB', label: 'Llama 3 405B at 2 bytes per knob', factId: 'DC-MODEL-MEM')),
          ],
        ),
      ],
    );
  }
}

/// Draws GPUs as 80 GB boxes, filled left to right by the model's weights (up to 24 drawn).
class _GpuPainter extends CustomPainter {
  _GpuPainter(this.gb, this.c);
  final double gb;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final need = math.max(1, (gb / gpuGb).ceil());
    final drawn = math.min(need, 24);
    final cols = drawn <= 4 ? drawn : (drawn <= 12 ? 6 : 8);
    final rows = (drawn / cols).ceil();
    final w = size.width / cols, h = size.height / math.max(rows, 1);
    var remaining = gb;
    for (var i = 0; i < drawn; i++) {
      final r = Rect.fromLTWH((i % cols) * w + 4, (i ~/ cols) * h + 4, w - 8, h - 8);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)), Paint()..color = c.surfaceHi);
      final fill = (remaining / gpuGb).clamp(0.0, 1.0);
      remaining -= gpuGb;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(r.left, r.bottom - r.height * fill, r.width, r.height * fill), const Radius.circular(6)),
        Paint()..color = c.cyan.withValues(alpha: 0.75),
      );
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)), Paint()
        ..style = PaintingStyle.stroke
        ..color = c.line);
    }
    if (need > drawn) {
      final tp = TextPainter(
        text: TextSpan(text: '+ ${need - drawn} more GPUs', style: TextStyle(fontFamily: 'Roboto', color: c.amber, fontSize: 12, fontWeight: FontWeight.w700)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width - tp.width - 6, size.height - tp.height - 6));
    }
  }

  @override
  bool shouldRepaint(_GpuPainter old) => old.gb != gb || old.c != c;
}
