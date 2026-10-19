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

class _GridState extends State<_Grid> {
  final Set<int> _done = {};
  int? _sel;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final r = _sel == null ? null : _sel! ~/ 3;
    final col = _sel == null ? null : _sel! % 3;
    Widget matrix(List<List<int>> m, Color accent, {bool Function(int, int)? hl}) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var j = 0; j < 3; j++)
                    Container(
                      width: 30,
                      height: 30,
                      margin: const EdgeInsets.all(1.5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: (hl?.call(i, j) ?? false) ? accent.withValues(alpha: 0.4) : c.surfaceHi,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text('${m[i][j]}', style: AppText.mono.copyWith(color: c.text, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
          ],
        );
    return DemoCard(
      title: 'Multiply two grids',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Tap a cell of the answer grid. Each one = a row of the first grid times a column of the second, added up.',
              style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.m),
          FittedBox(
            child: Row(
              children: [
                matrix(matA, c.cyan, hl: (i, j) => i == r),
                Padding(padding: const EdgeInsets.all(6), child: Text('×', style: TextStyle(fontSize: 22, color: c.textDim))),
                matrix(matB, c.magenta, hl: (i, j) => j == col),
                Padding(padding: const EdgeInsets.all(6), child: Text('=', style: TextStyle(fontSize: 22, color: c.textDim))),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < 3; i++)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var j = 0; j < 3; j++)
                            GestureDetector(
                              key: ValueKey('mm-cell-${i * 3 + j}'),
                              onTap: () => setState(() {
                                _sel = i * 3 + j;
                                _done.add(i * 3 + j);
                              }),
                              child: Container(
                                width: 34,
                                height: 34,
                                margin: const EdgeInsets.all(1.5),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _sel == i * 3 + j ? c.lime.withValues(alpha: 0.4) : c.surface,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: _done.contains(i * 3 + j) ? c.lime : c.line),
                                ),
                                child: Text(_done.contains(i * 3 + j) ? '${cellValue(i, j)}' : '?',
                                    style: AppText.mono.copyWith(color: c.text, fontWeight: FontWeight.w800)),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.m),
          Text(
            _sel == null
                ? 'Pick a "?" to start.'
                : '${[for (var k = 0; k < 3; k++) '${matA[r!][k]}×${matB[k][col!]}'].join(' + ')} = ${cellValue(r!, col!)}',
            key: const ValueKey('mm-work'),
            style: AppText.mono.copyWith(color: c.text, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: Gap.s),
          Text('Cells done: ${_done.length} / 9  ·  multiply-adds: ${_done.length * 3} / 27',
              key: const ValueKey('mm-count'), style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.s),
          Center(
            child: TextButton(
              key: const ValueKey('mm-all'),
              onPressed: () => setState(() => _done.addAll(List.generate(9, (i) => i))),
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
              StatTile(label: 'For a 500-token answer (~375 words)', value: humanNumber(perAnswer, digits: 0), color: c.violet),
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
