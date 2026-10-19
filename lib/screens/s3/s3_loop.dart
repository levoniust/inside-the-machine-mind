import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Fractional geometry of the loop diagram, shared between the painter and the widget overlays.
const double _boxL = 0.26, _boxR = 0.74, _boxT = 0.42, _boxB = 0.84;
const double _midY = 0.63, _inX = 0.115, _outX = 0.885;

/// Section 3 · "One word at a time": the autoregressive loop. A small diagram shows the newest token
/// looping back into the model input, and each new token is appended while the whole thing goes back
/// in. With the KV cache on, earlier tokens' attention notes are reused instead of recomputed
/// (work grows ~n instead of ~n²). Fact: IN-KV-CACHE.
class S3LoopScreen extends StatelessWidget {
  const S3LoopScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's3_loop',
        children: [_Loop()],
      );
}

const _prompt = ['why', 'is', 'the', 'sky', 'blue', '?'];
const _answer = ['Air', 'scatters', 'blue', 'light', 'more', 'than', 'red', ',', 'so', 'blue', 'fills', 'the', 'sky', '.'];

/// Token-processing work for generating [steps] tokens after a prompt of [prompt] tokens.
int workWithoutCache(int prompt, int steps) {
  var w = 0;
  for (var i = 0; i < steps; i++) {
    w += prompt + i; // re-read everything so far
  }
  return w;
}

int workWithCache(int prompt, int steps) => steps == 0 ? 0 : prompt + steps - 1; // prompt once, then 1 per new token

class _Loop extends StatefulWidget {
  const _Loop();

  @override
  State<_Loop> createState() => _LoopState();
}

class _LoopState extends State<_Loop> with SingleTickerProviderStateMixin {
  int _n = 0;
  bool _cache = true;
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));

  void _next() {
    if (_n >= _answer.length) return;
    setState(() => _n++);
    if (!(MediaQuery.maybeDisableAnimationsOf(context) ?? false)) _pulse.forward(from: 0);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final done = _n >= _answer.length;
    final work = _cache ? workWithCache(_prompt.length, _n) : workWithoutCache(_prompt.length, _n);
    final other = _cache ? workWithoutCache(_prompt.length, _n) : workWithCache(_prompt.length, _n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          title: 'Watch the answer grow',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _LoopDiagram(pulse: _pulse, done: done),
              const SizedBox(height: Gap.m),
              Wrap(
                key: const ValueKey('loop-chips'),
                spacing: 5,
                runSpacing: 5,
                children: [
                  for (var i = 0; i < _prompt.length; i++) _chip(context, _prompt[i], c.textDim, cached: _cache && _n > 0),
                  for (var i = 0; i < _n; i++)
                    _chip(context, _answer[i], c.magenta, isNew: i == _n - 1, cached: _cache && i < _n - 1),
                  if (!done)
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, _) => Opacity(opacity: 0.4 + 0.6 * (1 - _pulse.value), child: _chip(context, '?', c.lime)),
                    ),
                ],
              ),
              const SizedBox(height: Gap.m),
              Row(
                children: [
                  Icon(Icons.loop, color: c.magenta),
                  const SizedBox(width: Gap.s),
                  Expanded(
                    child: Text(
                      done
                          ? 'Done: the model predicted a "stop" and the loop ends.'
                          : 'Everything so far goes back into the model to predict word ${_n + 1}.',
                      key: const ValueKey('loop-status'),
                      style: TextStyle(color: c.text),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Gap.m),
              Wrap(
                spacing: Gap.s,
                runSpacing: Gap.s,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    key: const ValueKey('loop-next'),
                    style: FilledButton.styleFrom(backgroundColor: c.magenta, foregroundColor: Colors.white),
                    onPressed: done ? null : _next,
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Next word'),
                  ),
                  OutlinedButton.icon(
                    key: const ValueKey('loop-all'),
                    onPressed: done ? null : () => setState(() => _n = _answer.length),
                    icon: const Icon(Icons.fast_forward),
                    label: const Text('Finish'),
                  ),
                  TextButton(onPressed: () => setState(() => _n = 0), child: const Text('Restart')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
        DemoCard(
          title: 'Notes so it doesn\'t re-read',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile(
                key: const ValueKey('loop-cache'),
                contentPadding: EdgeInsets.zero,
                title: const Text('KV cache'),
                subtitle: Text(_cache ? 'On: keeps each word\'s attention notes' : 'Off: re-reads everything every time'),
                value: _cache,
                activeThumbColor: c.magenta,
                onChanged: (v) => setState(() => _cache = v),
              ),
              StatGrid(
                children: [
                  StatTile(label: 'Words processed so far', value: '$work', color: _cache ? c.lime : c.red, icon: Icons.memory),
                  StatTile(label: _cache ? 'Without the cache it\'d be' : 'With the cache it\'d be', value: '$other', icon: Icons.compare_arrows),
                ],
              ),
              const SizedBox(height: Gap.m),
              TermText(
                'Without notes the work grows like a triangle (1 + 2 + 3 + …): a 1,000-word answer would mean re-reading '
                'about half a million words. The [[KV cache]] keeps it to about one new word per step, but the notes take '
                'memory: real models need gigabytes of them for long conversations.',
                style: TextStyle(color: c.textDim, fontSize: 13),
              ),
              const SizedBox(height: Gap.m),
              const FactCard(
                value: '~0.33 MB',
                label: 'of notes per token for a 70B model, about 40 GB for a 128,000-token conversation',
                factId: 'IN-KV-CACHE',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(BuildContext context, String t, Color col, {bool isNew = false, bool cached = false}) {
    final c = AppColors.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isNew ? col.withValues(alpha: 0.3) : col.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: cached ? c.lime.withValues(alpha: 0.7) : col.withValues(alpha: 0.6)),
      ),
      child: Text(t, style: TextStyle(color: c.text, fontWeight: isNew ? FontWeight.w800 : FontWeight.w500)),
    );
  }
}

/// Miniature of the autoregressive loop: a MODEL box whose output ("out") arcs back over the top
/// into the input ("in"). A magenta dot — the newest token — travels the loop each time a word is
/// generated; when the answer is finished the dot and the coloured arrows disappear.
class _LoopDiagram extends StatelessWidget {
  const _LoopDiagram({required this.pulse, required this.done});

  final Animation<double> pulse;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Semantics(
      key: const ValueKey('loop-diagram'),
      label: done
          ? 'Diagram: the loop has ended. The model predicted a stop, so no new word goes back in.'
          : 'Diagram: the model predicts one new word at a time; the newest word at the output loops '
              'back over the top into the model input, and the loop runs again.',
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, box) {
          final h = (box.maxWidth * 0.5).clamp(110.0, 150.0);
          return SizedBox(
            height: h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // The model box.
                Positioned(
                  left: _boxL * box.maxWidth,
                  top: _boxT * h,
                  width: (_boxR - _boxL) * box.maxWidth,
                  height: (_boxB - _boxT) * h,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.surfaceHi,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: done ? c.line : c.violet.withValues(alpha: 0.8)),
                    ),
                    child: Text(
                      'MODEL',
                      style: TextStyle(
                        color: done ? c.textDim : c.violet,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                // Arrows and the travelling token dot.
                AnimatedBuilder(
                  animation: pulse,
                  builder: (_, _) => CustomPaint(
                    key: const ValueKey('loop-diagram-paint'),
                    painter: _LoopPainter(t: pulse.value, done: done, c: c),
                  ),
                ),
                // Input / output nodes and their labels.
                _node(_inX, _midY, c.cyan),
                _node(_outX, _midY, c.magenta),
                _nodeLabel(_inX, 0.78, 'in', c),
                _nodeLabel(_outX, 0.78, 'out', c),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _node(double fx, double fy, Color col) => Positioned.fill(
        child: Align(
          alignment: Alignment(fx * 2 - 1, fy * 2 - 1),
          child: Container(width: 11, height: 11, decoration: BoxDecoration(color: col, shape: BoxShape.circle)),
        ),
      );

  Widget _nodeLabel(double fx, double fy, String label, AppColors c) => Positioned.fill(
        child: Align(
          alignment: Alignment(fx * 2 - 1, fy * 2 - 1),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label, style: TextStyle(color: c.textDim, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ),
      );
}

class _LoopPainter extends CustomPainter {
  _LoopPainter({required this.t, required this.done, required this.c});
  final double t; // how far the newest token has travelled around the loop (0 = still at "out")
  final bool done;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    Offset at(double fx, double fy) => Offset(fx * w, fy * h);
    final col = done ? c.line : c.violet;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = col;

    // Stub: the model emits its new word at "out".
    canvas.drawLine(at(_boxR, _midY), at(_outX, _midY), stroke);
    _head(canvas, at(_outX - 0.03, _midY), const Offset(1, 0), size, col);

    // The loop: the newest word arcs from "out" over the top back into the model input.
    final loop = Path()
      ..moveTo(_outX * w, _midY * h)
      ..cubicTo(1.02 * w, 0.02 * h, -0.02 * w, 0.02 * h, _inX * w, _midY * h)
      ..lineTo((_boxL - 0.015) * w, _midY * h);
    canvas.drawPath(loop, stroke);
    _head(canvas, at(_boxL - 0.015, _midY), const Offset(1, 0), size, col);

    // The token travelling around the loop (gone once the loop ends).
    if (!done) {
      for (final m in loop.computeMetrics()) {
        final tan = m.getTangentForOffset(t.clamp(0.0, 1.0) * m.length);
        if (tan == null) continue;
        canvas.drawCircle(tan.position, h * 0.05,
            Paint()
              ..color = c.magenta.withValues(alpha: 0.3)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
        canvas.drawCircle(tan.position, h * 0.032, Paint()..color = c.magenta);
      }
    }
  }

  /// A filled triangle arrowhead with its tip at [tip], pointing along [dir].
  void _head(Canvas canvas, Offset tip, Offset dir, Size size, Color col) {
    final d = dir / dir.distance;
    final n = Offset(-d.dy, d.dx);
    final s = size.shortestSide * 0.045;
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx - d.dx * s + n.dx * s * 0.55, tip.dy - d.dy * s + n.dy * s * 0.55)
        ..lineTo(tip.dx - d.dx * s - n.dx * s * 0.55, tip.dy - d.dy * s - n.dy * s * 0.55)
        ..close(),
      Paint()..color = col,
    );
  }

  @override
  bool shouldRepaint(_LoopPainter old) => old.t != t || old.done != done || old.c != c;
}
