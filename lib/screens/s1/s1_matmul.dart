import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 1 · "The one math trick behind AI": tap the cells of a 3×3 × 3×3 matrix multiplication to compute
/// each row·column sum, then scale up (≈ 2 × parameters operations per token). Facts: HW-MATMUL-PER-TOKEN, HW-H100-FLOPS.
class S1MatmulScreen extends StatelessWidget {
  const S1MatmulScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's1_matmul',
        children: [_Grid(), _ScaleUp()],
      );
}

const matA = [
  [2, 0, 1],
  [1, 3, 2],
  [0, 1, 4],
];
const matB = [
  [1, 2, 0],
  [0, 1, 3],
  [4, 0, 1],
];

int cellValue(int r, int col) => [for (var k = 0; k < 3; k++) matA[r][k] * matB[k][col]].reduce((a, b) => a + b);

class _Grid extends StatefulWidget {
  const _Grid();

  @override
  State<_Grid> createState() => _GridState();
}

class _GridState extends State<_Grid> with SingleTickerProviderStateMixin {
  static const _pairMs = 250; // how long each row×column pair stays lit

  final Set<int> _done = {};
  int? _sel;
  bool _revealed = true; // false while the tapped cell is counting through its pairs

  late final AnimationController _step = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _pairMs * 3),
  )..addListener(() => setState(() {}));

  /// The pair being multiplied right now (0..2), or null when nothing is counting.
  int? get _k => !_revealed && _sel != null ? math.min((_step.value * 3).floor(), 2) : null;

  /// Progress through the current pair (0..1); drives the little pulse on the two lit cells.
  double get _phase => (_step.value * 3) % 1.0;

  @override
  void initState() {
    super.initState();
    _step.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() {
          _revealed = true;
          if (_sel != null) _done.add(_sel!);
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If motion got switched off mid-count, reveal the answer instead of freezing half-way.
    if ((MediaQuery.maybeDisableAnimationsOf(context) ?? false) && _step.isAnimating) {
      _step.stop();
      _revealed = true;
      if (_sel != null) _done.add(_sel!);
    }
  }

  @override
  void dispose() {
    _step.dispose();
    super.dispose();
  }

  /// Tap an answer cell: light up the three row·column pairs one after another with a running
  /// total, then reveal the value. With reduce motion the answer appears at once.
  void _tapCell(int idx) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    setState(() {
      _sel = idx;
      _revealed = reduceMotion;
      if (reduceMotion) _done.add(idx);
    });
    if (reduceMotion) {
      _step.stop();
    } else {
      _step.forward(from: 0);
    }
  }

  void _fillRest() {
    _step.stop();
    setState(() {
      _revealed = true;
      _done.addAll(List.generate(9, (i) => i));
    });
  }

  /// Sum of the products up to and including pair [upTo] of the selected cell.
  int _termSum(int upTo) {
    final r = _sel! ~/ 3, col = _sel! % 3;
    return [for (var i = 0; i <= upTo; i++) matA[r][i] * matB[i][col]].reduce((a, b) => a + b);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final r = _sel == null ? null : _sel! ~/ 3;
    final col = _sel == null ? null : _sel! % 3;
    final k = _k;
    final terms = _sel == null
        ? const <String>[]
        : [for (var i = 0; i < 3; i++) '${matA[r!][i]}×${matB[i][col!]}'];
    final work = _sel == null
        ? 'Pick a "?" to start.'
        : k == null
            ? '${terms.join(' + ')} = ${cellValue(r!, col!)}'
            : '${terms.take(k + 1).join(' + ')} = ${_termSum(k)}';

    Widget matrix(List<List<int>> m, Color accent, bool Function(int, int) guide, bool Function(int, int) active, String tag) {
      Widget cell(int i, int j) {
        final on = active(i, j);
        final box = Container(
          key: ValueKey('$tag-$i-$j'),
          width: 30,
          height: 30,
          margin: const EdgeInsets.all(1.5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? c.lime.withValues(alpha: 0.9) : guide(i, j) ? accent.withValues(alpha: 0.4) : c.surfaceHi,
            borderRadius: BorderRadius.circular(5),
            border: on ? Border.all(color: c.lime, width: 1.5) : null,
          ),
          child: Text('${m[i][j]}',
              style: AppText.mono.copyWith(color: on ? c.bg : c.text, fontWeight: FontWeight.w700)),
        );
        // A gentle pulse so the pair being multiplied clearly stands out.
        return on ? Transform.scale(scale: 1 + 0.12 * math.sin(_phase * math.pi), child: box) : box;
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var j = 0; j < 3; j++) cell(i, j),
              ],
            ),
        ],
      );
    }

    Widget outCell(int i, int j) {
      final idx = i * 3 + j;
      final counting = _sel == idx && k != null;
      final label = counting ? '${_termSum(k)}' : _done.contains(idx) ? '${cellValue(i, j)}' : '?';
      return GestureDetector(
        key: ValueKey('mm-cell-$idx'),
        onTap: () => _tapCell(idx),
        child: Container(
          width: 34,
          height: 34,
          margin: const EdgeInsets.all(1.5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _sel == idx ? c.lime.withValues(alpha: 0.4) : c.surface,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: _done.contains(idx) ? c.lime : c.line),
          ),
          child: Text(label,
              style: AppText.mono.copyWith(color: counting ? c.lime : c.text, fontWeight: FontWeight.w800)),
        ),
      );
    }

    return DemoCard(
      title: 'Multiply two grids',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Tap a cell of the answer grid and watch: one row of the first grid times one column of the second, "
              "pair by pair, all added up.",
              style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.m),
          FittedBox(
            child: Row(
              children: [
                matrix(matA, c.cyan, (i, j) => i == r, (i, j) => k != null && i == r && j == k, 'mm-a'),
                Padding(padding: const EdgeInsets.all(6), child: Text('×', style: TextStyle(fontSize: 22, color: c.textDim))),
                matrix(matB, c.magenta, (i, j) => j == col, (i, j) => k != null && i == k && j == col, 'mm-b'),
                Padding(padding: const EdgeInsets.all(6), child: Text('=', style: TextStyle(fontSize: 22, color: c.textDim))),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < 3; i++)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var j = 0; j < 3; j++) outCell(i, j),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.m),
          Text(
            work,
            key: const ValueKey('mm-work'),
            style: AppText.mono.copyWith(color: c.text, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          if (k != null) ...[
            const SizedBox(height: Gap.xs),
            Text('Pair ${k + 1} of 3 - running total',
                key: const ValueKey('mm-step'),
                textAlign: TextAlign.center,
                style: TextStyle(color: c.lime, fontSize: 12.5, fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: Gap.s),
          Text('Cells done: ${_done.length} / 9  ·  multiply-adds: ${_done.length * 3} / 27',
              key: const ValueKey('mm-count'), style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.s),
          Center(
            child: TextButton(
              key: const ValueKey('mm-all'),
              onPressed: _fillRest,
              child: const Text('Fill in the rest'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScaleUp extends StatefulWidget {
  const _ScaleUp();

  @override
  State<_ScaleUp> createState() => _ScaleUpState();
}

class _ScaleUpState extends State<_ScaleUp> {
  double _exp = math.log(405e9) / math.ln10;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final params = math.pow(10, _exp).toDouble();
    final perToken = 2 * params;
    final perAnswer = perToken * 500;
    final gpuSeconds = perAnswer / 989e12;
    return DemoCard(
      title: 'Now scale it up',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledSlider(
            key: const ValueKey('mm-params'),
            label: 'Model size (knobs)',
            value: _exp,
            min: 6,
            max: 12,
            format: (v) => humanNumber(math.pow(10, v).toDouble(), digits: 0),
            onChanged: (v) => setState(() => _exp = v),
          ),
          StatGrid(
            children: [
              StatTile(key: const ValueKey('mm-per-token'), label: 'Math steps per token', value: humanNumber(perToken, digits: 0), color: c.cyan),
              StatTile(label: 'Per 500-token answer', value: humanNumber(perAnswer, digits: 0), color: c.violet),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text(
            'Even an H100 doing ~989 trillion steps a second needs about ${humanSeconds(gpuSeconds)} of pure math for that answer, '
            'and in practice it waits on memory, so it\'s slower.',
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
          const SizedBox(height: Gap.m),
          const TermText(
            'A model\'s knobs are stored as giant grids, and every word passes through them by [[matrix multiplication]]: one '
            'multiply and one add per knob. That\'s why AI chips are built to multiply grids, fast.',
          ),
          const SizedBox(height: Gap.m),
          const FactCard(value: '~810 billion', label: 'math steps per token for a 405B model', factId: 'HW-MATMUL-PER-TOKEN'),
        ],
      ),
    );
  }
}
