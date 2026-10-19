import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Section 1 · Lesson 5: CPU vs GPU.
/// A few big CPU cores (master chefs) face an army of tiny GPU cores and tensor cores.
/// "Showdown": fill a 64×64 grid — the CPU fills a few cells at a time, the GPU fills whole
/// blocks at once. Facts: HW-H100-CORES, HW-CPU-CORES, HW-CPU-VS-GPU.
class S1CpuGpuScreen extends StatelessWidget {
  const S1CpuGpuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(1);
    return LessonScaffold(
      lessonId: 's1_cpu_gpu',
      children: [
        DemoCard(
          title: 'A handful of chefs vs an army of cooks',
          child: Row(
            children: const [
              Expanded(child: _CoreIllustration(kind: _CoreKind.cpu)),
              SizedBox(width: Gap.l),
              Expanded(child: _CoreIllustration(kind: _CoreKind.gpu)),
            ],
          ),
        ),
        const _Showdown(),
        Row(
          children: [
            Expanded(
              child: FactCard(
                value: '16,896',
                label: '[[CUDA core]]s on one H100 [[GPU]]',
                comparison: 'plus 528 [[tensor core]]s',
                factId: 'HW-H100-CORES',
                color: accent,
              ),
            ),
            SizedBox(width: Gap.m),
            Expanded(
              child: FactCard(
                value: '16',
                label: 'cores on a top desktop [[CPU]] (server CPUs: up to 192)',
                comparison: 'a chef, not a kitchen crew',
                factId: 'HW-CPU-CORES',
                color: accent,
              ),
            ),
          ],
        ),
        FactCard(
          value: '~100–300×',
          label: 'For [[matrix multiplication]], one H100 is roughly this much faster than a desktop [[CPU]]',
          comparison: 'the difference between a chef and a kitchen crew',
          factId: 'HW-CPU-VS-GPU',
          color: accent,
        ),
      ],
    );
  }
}

// Shared grid dimensions (64×64 = 4096 cells).
const int _grid = 64;
const int _total = _grid * _grid;

enum _CoreKind { cpu, gpu }

/// Animated illustration: a few large CPU cores on the left, or a dense swarm of
/// tiny GPU cores (and tensor cores) on the right.
class _CoreIllustration extends StatefulWidget {
  const _CoreIllustration({required this.kind});
  final _CoreKind kind;

  @override
  State<_CoreIllustration> createState() => _CoreIllustrationState();
}

class _CoreIllustrationState extends State<_CoreIllustration> with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(vsync: this, duration: const Duration(seconds: 4));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
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
    final isCpu = widget.kind == _CoreKind.cpu;
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Semantics(
            label: isCpu
                ? 'A CPU: a few large cores, each doing complex work one at a time'
                : 'A GPU: thousands of tiny cores and tensor cores working all at once',
            child: AnimatedBuilder(
              animation: _t,
              builder: (_, _) => CustomPaint(
                painter: isCpu ? _CpuPainter(_t.value, c) : _GpuPainter(_t.value, c),
              ),
            ),
          ),
        ),
        const SizedBox(height: Gap.s),
        Text(isCpu ? 'CPU — the master chefs' : 'GPU — the army of cooks',
            textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
        Text(isCpu ? 'a few, very capable' : 'thousands, simple, in parallel',
            textAlign: TextAlign.center,
            style: TextStyle(color: isCpu ? c.amber : c.section(1), fontSize: 13)),
      ],
    );
  }
}

class _CpuPainter extends CustomPainter {
  _CpuPainter(this.t, this.c);
  final double t;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final origin = Offset((size.width - s) / 2, (size.height - s) / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(origin & Size.square(s * 0.98), Radius.circular(s * 0.06)),
      Paint()..color = c.surfaceHi,
    );
    // 2x2 grid of large cores.
    const n = 2;
    final cell = s * 0.82 / n;
    final start = origin + Offset(s * 0.08, s * 0.08);
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        final rect = Rect.fromLTWH(start.dx + x * cell, start.dy + y * cell, cell * 0.8, cell * 0.8);
        // A "thought" pulse that travels around each core, one at a time.
        final phase = (t + (x * 0.5 + y * 0.25)) % 1.0;
        final pulse = c.amber.withValues(alpha: 0.25 + 0.55 * math.sin(phase * math.pi * 2).abs());
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(cell * 0.18)),
          Paint()..color = pulse,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(2), Radius.circular(cell * 0.22)),
          Paint()..color = c.amber.withValues(alpha: 0.12 * math.sin(phase * math.pi * 2).abs())
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(cell * 0.18)),
          Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = c.textDim.withValues(alpha: 0.5),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CpuPainter old) => old.t != t;
}

class _GpuPainter extends CustomPainter {
  _GpuPainter(this.t, this.c);
  final double t;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final origin = Offset((size.width - s) / 2, (size.height - s) / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(origin & Size.square(s * 0.98), Radius.circular(s * 0.06)),
      Paint()..color = c.surfaceHi,
    );
    // 8x8 grid of tiny cores; every other one is a tensor core (magenta).
    const n = 8;
    final cell = s * 0.82 / n;
    final start = origin + Offset(s * 0.08, s * 0.08);
    final rnd = math.Random((t * 10).floor());
    final lit = {for (var i = 0; i < 14; i++) rnd.nextInt(n * n)};
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        final isTensor = (x + y) % 2 == 0;
        final on = lit.contains(y * n + x);
        final base = isTensor ? c.magenta : c.section(1);
        final rect = Rect.fromLTWH(start.dx + x * cell, start.dy + y * cell, cell * 0.7, cell * 0.7);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(cell * 0.12)),
          Paint()..color = on ? base : c.line.withValues(alpha: 0.9),
        );
        if (on) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect.inflate(2), Radius.circular(cell * 0.18)),
            Paint()..color = base.withValues(alpha: 0.25)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_GpuPainter old) => (old.t * 10).floor() != (t * 10).floor();
}

/// "Showdown" demo: fill a 64×64 grid. The CPU fills a few cells at a time;
/// the GPU fills whole blocks at once. An illustration, not real data.
class _Showdown extends StatefulWidget {
  const _Showdown();

  @override
  State<_Showdown> createState() => _ShowdownState();
}

class _ShowdownState extends State<_Showdown> with SingleTickerProviderStateMixin {
  // The GPU finishes the whole grid in 10 simulated seconds.
  static const double raceDuration = 10.0;
  // The CPU is ~100× slower, so it only gets a few percent done in that time.
  static const double cpuFractionOfGpu = 1.0 / 100;
  // GPU block size is user-controlled (whole blocks at once).
  static const double minBlock = 2;
  static const double maxBlock = 8;

  double _block = 4;
  bool _running = false;

  late final AnimationController _race = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..addListener(_onTick);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _race.stop();
    }
  }

  @override
  void dispose() {
    _race.dispose();
    super.dispose();
  }

  void _onTick() {
    final v = _race.value.clamp(0.0, 1.0);
    setState(() {
      _gpuCells = (_total * v).toInt();
      _cpuCells = (_total * cpuFractionOfGpu * v).toInt();
      _elapsed = v * raceDuration;
      if (v >= 1.0) _running = false;
    });
  }

  int _gpuCells = 0;
  int _cpuCells = 0;
  double _elapsed = 0;

  void _start() {
    setState(() {
      _gpuCells = 0;
      _cpuCells = 0;
      _elapsed = 0;
      _running = true;
    });
    _race.forward(from: 0);
  }

  void _stop() {
    setState(() => _running = false);
    _race.stop();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(1);
    final cpuDone = _cpuCells >= _total;
    final gpuDone = _gpuCells >= _total;
    return DemoCard(
      title: 'Showdown: fill a 64×64 grid',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Same job for both: fill all 4,096 cells. The CPU works a few at a time; the GPU works in whole blocks. (An illustration, not real data.)',
              style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.l),
          Row(
            children: [
              Expanded(
                child: _GridPanel(
                  label: 'CPU',
                  color: c.amber,
                  cells: _cpuCells,
                  done: cpuDone,
                ),
              ),
              SizedBox(width: Gap.m),
              Expanded(
                child: _GridPanel(
                  label: 'GPU',
                  color: accent,
                  cells: _gpuCells,
                  done: gpuDone,
                  block: _block.toInt(),
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.l),
          Row(
            children: [
              Expanded(
                child: Text('⏱ ${_elapsed.toStringAsFixed(1)} s',
                    style: AppText.mono.copyWith(color: c.textDim, fontSize: 16)),
              ),
              FilledButton.icon(
                key: const ValueKey('showdown-start'),
                onPressed: _running ? _stop : _start,
                icon: Icon(_race.isCompleted ? Icons.replay : (_running ? Icons.pause : Icons.play_arrow)),
                label: Text(_race.isCompleted ? 'Race again' : (_running ? 'Pause' : 'Showdown')),
              ),
            ],
          ),
          const SizedBox(height: Gap.m),
          LabeledSlider(
            key: const ValueKey('gpu-block-slider'),
            label: 'GPU block size (cells filled per swing)',
            value: _block,
            min: minBlock,
            max: maxBlock,
            divisions: (maxBlock - minBlock).toInt(),
            color: accent,
            format: (v) => '${v.toInt()}×${v.toInt()} = ${(v.toInt() * v.toInt()).toString()} cells',
            onChanged: (v) {
              setState(() => _block = v);
            },
          ),
          const SizedBox(height: Gap.xs),
          Text('Bigger blocks = the GPU finishes in fewer swings.',
              style: TextStyle(color: c.textDim, fontSize: 12)),
        ],
      ),
    );
  }
}

class _GridPanel extends StatelessWidget {
  const _GridPanel({
    required this.label,
    required this.color,
    required this.cells,
    required this.done,
    this.block = 1,
  });
  final String label;
  final Color color;
  final int cells;
  final bool done;
  final int block;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final pct = (cells / _total) * 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: Gap.s),
            Text(done ? 'done' : '${pct.toStringAsFixed(0)}%',
                style: AppText.mono.copyWith(fontSize: 13, color: done ? color : c.textDim)),
          ],
        ),
        const SizedBox(height: 4),
        Semantics(
          label: '$label grid: $cells of $_total cells filled${done ? ', complete' : ''}',
          child: AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: _GridPainter(cells, block, color, c),
            ),
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter(this.cells, this.block, this.color, this.c);
  final int cells;
  final int block;
  final Color color;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final origin = Offset((size.width - s) / 2, (size.height - s) / 2);
    final cell = s * 0.98 / _grid;
    final start = origin;
    // Fill cells in row-major order, up to [cells].
    for (var i = 0; i < cells; i++) {
      final y = i ~/ _grid;
      final x = i % _grid;
      final rect = Rect.fromLTWH(start.dx + x * cell, start.dy + y * cell, cell, cell);
      canvas.drawRect(rect, Paint()..color = color);
    }
    // For the GPU, draw block outlines to show it fills whole blocks at once.
    if (block > 1) {
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = c.textDim.withValues(alpha: 0.4);
      for (var y = 0; y < _grid; y += block) {
        for (var x = 0; x < _grid; x += block) {
          final w = (math.min(x + block, _grid) - x) * cell;
          final h = (math.min(y + block, _grid) - y) * cell;
          canvas.drawRect(
            Rect.fromLTWH(start.dx + x * cell, start.dy + y * cell, w, h),
            stroke,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) =>
      old.cells != cells || old.block != block || old.color != color;
}
