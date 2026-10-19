import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 2 · "When things break": the 54-day Llama 3 405B snapshot (466 interruptions: 47 planned, 419 unexpected,
/// 58.7% of the unexpected from GPUs) as a timeline, and a loss spike rescued by rewinding to a checkpoint.
/// Marker positions are spread at random (only the counts are real). Facts: TR-LLAMA3-FAIL, DC-POWER-SWING.
class S2ThingsBreakScreen extends StatelessWidget {
  const S2ThingsBreakScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's2_things_break',
        children: [_Timeline(), _Checkpoint()],
      );
}

enum Cause { planned, gpu, other }

const plannedCount = 47, unexpectedCount = 419;
final gpuCount = (unexpectedCount * 0.587).round(); // 246

/// 466 interruptions with random day positions (fixed seed) and the real category counts.
List<(double, Cause)> interruptions() {
  final r = math.Random(54);
  return [
    for (var i = 0; i < plannedCount; i++) (r.nextDouble() * 54, Cause.planned),
    for (var i = 0; i < gpuCount; i++) (r.nextDouble() * 54, Cause.gpu),
    for (var i = 0; i < unexpectedCount - gpuCount; i++) (r.nextDouble() * 54, Cause.other),
  ];
}

class _Timeline extends StatefulWidget {
  const _Timeline();

  @override
  State<_Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<_Timeline> {
  final events = interruptions();
  final Set<Cause> _show = {...Cause.values};

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    Color col(Cause k) => switch (k) { Cause.planned => c.lime, Cause.gpu => c.red, Cause.other => c.amber };
    final shown = events.where((e) => _show.contains(e.$2)).length;
    return DemoCard(
      title: '54 days, 466 interruptions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Every mark is one time the giant training run stopped. Tap the filters.', style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.m),
          SizedBox(
            height: 90,
            child: Semantics(
              label: '$shown interruptions shown on a 54-day timeline',
              child: CustomPaint(
                size: Size.infinite,
                painter: _MarksPainter([for (final e in events) if (_show.contains(e.$2)) (e.$1, col(e.$2))], c),
              ),
            ),
          ),
          const SizedBox(height: Gap.s),
          Wrap(
            spacing: Gap.s,
            runSpacing: Gap.s,
            children: [
              for (final (k, label, n) in [
                (Cause.gpu, 'GPU problems', gpuCount),
                (Cause.other, 'Other surprises', unexpectedCount - gpuCount),
                (Cause.planned, 'Planned (maintenance)', plannedCount),
              ])
                FilterChip(
                  key: ValueKey('break-${k.name}'),
                  label: Text('$label · $n'),
                  selected: _show.contains(k),
                  selectedColor: col(k).withValues(alpha: 0.25),
                  onSelected: (on) => setState(() => on ? _show.add(k) : _show.remove(k)),
                ),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text('Showing $shown', key: const ValueKey('break-shown'), style: AppText.mono.copyWith(color: c.text, fontWeight: FontWeight.w700)),
          Text('Counts are real; where each mark sits on the timeline is illustrative.', style: TextStyle(color: c.textDim, fontSize: 11)),
          const SizedBox(height: Gap.m),
          const FactCard(
            value: '~8.6 a day',
            label: 'interruptions during Llama 3 405B training (466 in 54 days); GPUs caused 58.7% of the unexpected ones',
            factId: 'TR-LLAMA3-FAIL',
          ),
        ],
      ),
    );
  }
}

class _MarksPainter extends CustomPainter {
  _MarksPainter(this.marks, this.c);
  final List<(double, Color)> marks;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * 0.45;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), Paint()..color = c.line..strokeWidth = 2);
    final r = math.Random(7);
    for (final (day, col) in marks) {
      final x = day / 54 * size.width;
      final jitter = (r.nextDouble() - 0.5) * size.height * 0.5;
      canvas.drawLine(Offset(x, y - 8 + jitter * 0.3), Offset(x, y + 8 + jitter * 0.3), Paint()..color = col.withValues(alpha: 0.8)..strokeWidth = 1.4);
    }
    for (var d = 0; d <= 54; d += 9) {
      final tp = TextPainter(
        text: TextSpan(text: 'day $d', style: TextStyle(fontFamily: 'Roboto', fontSize: 9, color: c.textDim)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset((d / 54 * size.width - tp.width / 2).clamp(0, size.width - tp.width), size.height - tp.height));
    }
  }

  @override
  bool shouldRepaint(_MarksPainter old) => old.marks.length != marks.length || old.c != c;
}

class _Checkpoint extends StatefulWidget {
  const _Checkpoint();

  @override
  State<_Checkpoint> createState() => _CheckpointState();
}

class _CheckpointState extends State<_Checkpoint> {
  int _stage = 0; // 0 normal, 1 spike, 2 rewound and continued

  static double normal(double x) => 1.0 * math.exp(-2.4 * x) + 0.25;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final caption = switch (_stage) {
      0 => 'Training is going well: the loss slides down. Every so often, a checkpoint saves the whole model.',
      1 => 'Uh-oh: a loss spike! Something went wrong (a bad batch, a broken GPU) and the model got worse.',
      _ => 'Rewound to the last checkpoint (the save game), skipped the bad data, and carried on. Crisis over.',
    };
    return DemoCard(
      title: 'Save games for giant models',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1.8,
            child: Semantics(
              label: 'Loss curve, stage $_stage',
              child: CustomPaint(painter: _LossPainter(_stage, c)),
            ),
          ),
          const SizedBox(height: Gap.s),
          Text(caption, key: ValueKey('break-stage-$_stage'), style: TextStyle(color: c.text, fontWeight: FontWeight.w600)),
          const SizedBox(height: Gap.m),
          Wrap(
            spacing: Gap.s,
            alignment: WrapAlignment.center,
            children: [
              FilledButton.icon(
                key: const ValueKey('break-next'),
                style: FilledButton.styleFrom(backgroundColor: _stage == 1 ? c.lime : c.violet, foregroundColor: Colors.white),
                onPressed: _stage < 2 ? () => setState(() => _stage++) : null,
                icon: Icon(_stage == 0 ? Icons.bolt : Icons.restore),
                label: Text(_stage == 0 ? 'Something breaks' : 'Rewind to checkpoint'),
              ),
              TextButton(onPressed: () => setState(() => _stage = 0), child: const Text('Start over')),
            ],
          ),
          const SizedBox(height: Gap.s),
          const TermText(
            'A [[checkpoint]] is a copy of every knob, written to storage regularly. Big runs also have to be gentle with the power '
            'grid: when thousands of GPUs pause at once, the datacenter\'s power use can swing by tens of megawatts.',
          ),
        ],
      ),
    );
  }
}

class _LossPainter extends CustomPainter {
  _LossPainter(this.stage, this.c);
  final int stage;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    double y(double v) => size.height - v / 1.4 * size.height;
    final axis = Paint()..color = c.line;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), axis);
    for (final cp in [0.2, 0.4, 0.6, 0.8]) {
      final x = cp * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), Paint()..color = c.lime.withValues(alpha: 0.25)..strokeWidth = 1);
      canvas.drawCircle(Offset(x, y(_CheckpointState.normal(cp))), 4, Paint()..color = c.lime);
    }
    final path = Path();
    const end1 = 0.62;
    for (var i = 0; i <= 100; i++) {
      final x = i / 100 * (stage == 0 ? 0.6 : end1);
      final v = _CheckpointState.normal(x);
      final pt = Offset(x * size.width, y(v));
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = c.violet;
    canvas.drawPath(path, line);
    if (stage >= 1) {
      final spike = Path()
        ..moveTo(end1 * size.width, y(_CheckpointState.normal(end1)))
        ..lineTo(0.66 * size.width, y(1.25))
        ..lineTo(0.7 * size.width, y(1.1));
      canvas.drawPath(spike, line..color = c.red);
    }
    if (stage == 2) {
      final back = Path()..moveTo(0.6 * size.width, y(_CheckpointState.normal(0.6)));
      for (var i = 0; i <= 50; i++) {
        final x = 0.6 + i / 50 * 0.4;
        back.lineTo(x * size.width, y(_CheckpointState.normal(x)));
      }
      canvas.drawPath(back, line..color = c.lime);
    }
  }

  @override
  bool shouldRepaint(_LossPainter old) => old.stage != stage || old.c != c;
}
