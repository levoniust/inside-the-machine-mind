import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Section 1 · Lesson 5: CPU vs GPU.
/// A few big CPU cores (master chefs) face an army of tiny GPU cores and tensor cores.
/// "Showdown": fill a 24×24 grid — the CPU fills a few cells at a time, the GPU fills whole
/// blocks at once. Small enough that every cell is visible, so the counts match the picture. Facts: HW-H100-CORES, HW-CPU-CORES, HW-CPU-VS-GPU.
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
          crossAxisAlignment: CrossAxisAlignment.start,
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

// Shared grid dimensions (24×24 = 576 cells; small enough to see every cell on a phone).
const int _grid = 24;
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

/// "Showdown" demo: fill a 24×24 grid, one "swing" (step) at a time. The CPU fills [cpuPerSwing] cells per
/// swing, row by row; the GPU fills one whole block per swing, in exactly the outlined squares. The race ends
/// when the GPU is done. An illustration, not real data.
class _Showdown extends StatefulWidget {
  const _Showdown();

  @override
  State<_Showdown> createState() => _ShowdownState();
}

/// GPU block sizes on the slider (left to right: smaller to bigger blocks, so fewer swings).
const List<int> blockSizes = [4, 8, 12];

/// Cells the CPU fills per swing: a few cores, a few cells.
const int cpuPerSwing = 4;

/// Swings needed to fill the whole grid.
int gpuSwings(int block) => _total ~/ (block * block);
const int cpuSwings = _total ~/ cpuPerSwing;

class _ShowdownState extends State<_Showdown> with SingleTickerProviderStateMixin {
  static const swingMs = 200;

  int _size = 0; // index into blockSizes
  int _swings = 0; // swings done so far in this race

  int get _block => blockSizes[_size];
  int get _goal => gpuSwings(_block);

  late final AnimationController _race = AnimationController(vsync: this)..addListener(_onTick);

  @override
  void dispose() {
    _race.dispose();
    super.dispose();
  }

  void _onTick() {
    final n = (_race.value * _goal).floor().clamp(0, _goal);
    if (n != _swings || _race.isCompleted) setState(() => _swings = n);
  }

  void _start() {
    if (_swings >= _goal) _swings = 0;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _race.value = 1; // reduce motion: show the finish straight away
      setState(() => _swings = _goal);
      return;
    }
    _race.duration = Duration(milliseconds: swingMs * _goal);
    _race.forward(from: _swings / _goal);
    setState(() {});
  }

  void _pause() {
    _race.stop();
    setState(() {});
  }

  void _setSize(int i) {
    if (i == _size) return;
    _race.stop();
    _race.value = 0;
    setState(() {
      _size = i;
      _swings = 0; // a new block size is a new race, so the grids always match the setting
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(1);
    final running = _race.isAnimating;
    final finished = _swings >= _goal;
    final cpuCells = math.min(_swings * cpuPerSwing, _total);
    final gpuCells = _swings * _block * _block;
    return DemoCard(
      title: 'Showdown: fill a 24×24 grid',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
              'Same job for both: fill all $_total cells. Each swing, the CPU fills $cpuPerSwing cells; the GPU fills '
              'one whole $_block×$_block block. (An illustration, not real data.)',
              style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.l),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _GridPanel(key: const ValueKey('showdown-cpu'), label: 'CPU', color: c.amber, cells: cpuCells),
              ),
              const SizedBox(width: Gap.m),
              Expanded(
                child: _GridPanel(
                    key: const ValueKey('showdown-gpu'), label: 'GPU', color: accent, cells: gpuCells, block: _block),
              ),
            ],
          ),
          const SizedBox(height: Gap.m),
          Row(
            children: [
              Expanded(
                child: Text('Swing $_swings', key: const ValueKey('showdown-swings'),
                    style: AppText.mono.copyWith(color: c.textDim, fontSize: 16)),
              ),
              FilledButton.icon(
                key: const ValueKey('showdown-start'),
                onPressed: running ? _pause : _start,
                icon: Icon(finished ? Icons.replay : (running ? Icons.pause : Icons.play_arrow)),
                label: Text(finished ? 'Race again' : (running ? 'Pause' : (_swings > 0 ? 'Resume' : 'Showdown'))),
              ),
            ],
          ),
          if (finished) ...[
            const SizedBox(height: Gap.s),
            Text(
              'GPU done in $_goal swings. The CPU got ${(cpuCells / _total * 100).toStringAsFixed(cpuCells * 100 < _total * 10 ? 1 : 0)}% '
              'done and needs ${cpuSwings - _swings} more swings: ${cpuSwings ~/ _goal}× longer.',
              key: const ValueKey('showdown-result'),
              style: TextStyle(color: accent, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: Gap.m),
          LabeledSlider(
            key: const ValueKey('gpu-block-slider'),
            label: 'GPU block size (cells filled per swing)',
            value: _size.toDouble(),
            min: 0,
            max: (blockSizes.length - 1).toDouble(),
            divisions: blockSizes.length - 1,
            color: accent,
            format: (v) {
              final b = blockSizes[v.round()];
              return '$b×$b = ${b * b} cells';
            },
            onChanged: (v) => _setSize(v.round()),
          ),
          const SizedBox(height: Gap.xs),
          Text('Bigger blocks = the GPU finishes in fewer swings. A real GPU works on thousands of cells at once.',
              style: TextStyle(color: c.textDim, fontSize: 12)),
        ],
      ),
    );
  }
}

class _GridPanel extends StatelessWidget {
  const _GridPanel({super.key, required this.label, required this.color, required this.cells, this.block});
  final String label;
  final Color color;
  final int cells;

  /// Null for the CPU (fills row by row); the block size for the GPU (fills block by block).
  final int? block;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final done = cells >= _total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: Gap.s),
            Expanded(
              child: Text('$cells / $_total cells${done ? ' ✓' : ''}',
                  textAlign: TextAlign.end,
                  style: AppText.mono.copyWith(fontSize: 12, color: done ? color : c.textDim)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Semantics(
          label: '$label grid: $cells of $_total cells filled${done ? ', complete' : ''}',
          child: AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(painter: _GridPainter(cells, block, color, c)),
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter(this.cells, this.block, this.color, this.c);
  final int cells;
  final int? block;
  final Color color;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final o = Offset((size.width - s) / 2, (size.height - s) / 2);
    final cell = s / _grid;
    canvas.drawRect(o & Size(s, s), Paint()..color = c.surfaceHi);
    final fill = Paint()..color = color;
    final b = block;
    if (b == null) {
      // CPU: row by row. Full rows, then the part of the next row.
      final rows = cells ~/ _grid, rest = cells % _grid;
      if (rows > 0) canvas.drawRect(Rect.fromLTWH(o.dx, o.dy, s, rows * cell), fill);
      if (rest > 0) canvas.drawRect(Rect.fromLTWH(o.dx, o.dy + rows * cell, rest * cell, cell), fill);
    } else {
      // GPU: whole blocks, left to right and top to bottom, exactly inside the outlines.
      final perRow = _grid ~/ b;
      final blocks = cells ~/ (b * b);
      for (var i = 0; i < blocks; i++) {
        canvas.drawRect(
            Rect.fromLTWH(o.dx + (i % perRow) * b * cell, o.dy + (i ~/ perRow) * b * cell, b * cell, b * cell), fill);
      }
    }
    // Every cell is outlined, so what you count matches the numbers.
    final thin = Paint()
      ..strokeWidth = 0.6
      ..color = c.textDim.withValues(alpha: 0.3);
    for (var i = 1; i < _grid; i++) {
      canvas.drawLine(Offset(o.dx + i * cell, o.dy), Offset(o.dx + i * cell, o.dy + s), thin);
      canvas.drawLine(Offset(o.dx, o.dy + i * cell), Offset(o.dx + s, o.dy + i * cell), thin);
    }
    if (b == null) return;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = c.textDim.withValues(alpha: 0.8);
    final perRow = _grid ~/ b;
    for (var y = 0; y < perRow; y++) {
      for (var x = 0; x < perRow; x++) {
        canvas.drawRect(Rect.fromLTWH(o.dx + x * b * cell, o.dy + y * b * cell, b * cell, b * cell), stroke);
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.cells != cells || old.block != block || old.color != color;
}
