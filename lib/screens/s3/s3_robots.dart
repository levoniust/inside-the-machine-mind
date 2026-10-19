import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 3 · "Minds with bodies": vision-language-action (VLA) models close the loop see → understand → act.
/// A painted robot arm runs the loop for a chosen instruction. Facts: RB-RT2, RB-PI0, RB-GEMINI.
class S3RobotsScreen extends StatelessWidget {
  const S3RobotsScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(lessonId: 's3_robots', children: [_ArmLoop(), _Robots()]);
}

class _Task {
  const _Task(this.instruction, this.sees, this.thinks, this.does, this.colorOf);
  final String instruction, sees, thinks, does;
  final Color Function(AppColors) colorOf;
}

final _tasks = [
  _Task(
    'Fold the shirt',
    'A crumpled shirt on the table',
    '"Grab the sleeve, bring it across, then fold in half"',
    'Move gripper to the sleeve · close · lift · move · open',
    (c) => c.cyan,
  ),
  _Task(
    'Put the cup in the sink',
    'A cup next to a sink',
    '"The cup is the round thing; the sink is on the right"',
    'Reach · grip the handle · lift · move right · lower · release',
    (c) => c.amber,
  ),
  _Task(
    'Hand me the blue block',
    'Three blocks: red, green, blue',
    '"Blue block is on the left; the person is in front"',
    'Reach left · grip · lift · move forward · release',
    (c) => c.violet,
  ),
];

const _phases = ['See', 'Understand', 'Act', 'Check'];

class _ArmLoop extends StatefulWidget {
  const _ArmLoop();

  @override
  State<_ArmLoop> createState() => _ArmLoopState();
}

class _ArmLoopState extends State<_ArmLoop> with SingleTickerProviderStateMixin {
  int _task = 0;
  int _phase = 0;
  late final AnimationController _t = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _t.value = 0.5;
      _t.stop();
    } else if (!_t.isAnimating) {
      _t.repeat(reverse: true);
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
    final task = _tasks[_task];
    final caption = switch (_phase) {
      0 => 'Cameras see: ${task.sees}.',
      1 => 'The model connects the picture with the words "${task.instruction}": ${task.thinks}.',
      2 => 'It outputs motor commands, not words: ${task.does}.',
      _ => 'Did it work? It looks again, and the loop repeats until the job is done.',
    };
    return DemoCard(
      title: 'See → understand → act',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: Gap.s,
            runSpacing: Gap.s,
            children: [
              for (var i = 0; i < _tasks.length; i++)
                ChoiceChip(
                  key: ValueKey('robot-task-$i'),
                  label: Text(_tasks[i].instruction),
                  selected: _task == i,
                  selectedColor: c.magenta.withValues(alpha: 0.25),
                  onSelected: (_) => setState(() {
                    _task = i;
                    _phase = 0;
                  }),
                ),
            ],
          ),
          const SizedBox(height: Gap.m),
          AspectRatio(
            aspectRatio: 1.4,
            child: Semantics(
              label: 'Robot arm, phase ${_phases[_phase]}',
              child: AnimatedBuilder(
                animation: _t,
                builder: (_, _) => CustomPaint(painter: _ArmPainter(_phase, _t.value, task.colorOf(c), c, _task)),
              ),
            ),
          ),
          const SizedBox(height: Gap.m),
          Row(
            children: [
              for (var i = 0; i < _phases.length; i++) ...[
                if (i > 0) Icon(Icons.chevron_right, size: 16, color: c.textDim),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == _phase ? c.magenta.withValues(alpha: 0.25) : c.surfaceHi,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FittedBox(
                      child: Text(
                        _phases[i],
                        style: TextStyle(fontWeight: FontWeight.w700, color: i == _phase ? c.text : c.textDim),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: Gap.m),
          Text(
            caption,
            key: ValueKey('robot-caption-$_phase'),
            style: TextStyle(color: c.text),
          ),
          const SizedBox(height: Gap.m),
          StepControls(step: _phase, count: _phases.length, onStep: (i) => setState(() => _phase = i)),
        ],
      ),
    );
  }
}

class _ArmPainter extends CustomPainter {
  _ArmPainter(this.phase, this.t, this.object, this.c, this.kind);
  final int phase;
  final int kind; // 0 shirt, 1 cup, 2 blocks
  final double t;
  final Color object;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Table.
    canvas.drawRect(Rect.fromLTWH(0, h * 0.78, w, h * 0.22), Paint()..color = c.surfaceHi);
    // Object on the table (lifted during Act).
    final lift = phase == 2 ? t * h * 0.18 : 0.0;
    final objPos = Offset(w * 0.62, h * 0.72 - lift);
    final paint = Paint()..color = object;
    switch (kind) {
      case 0: // a T-shirt
        final s = w * 0.08;
        final shirt = Path()
          ..moveTo(objPos.dx - s * 0.5, objPos.dy - s * 0.6)
          ..lineTo(objPos.dx - s * 1.1, objPos.dy - s * 0.2)
          ..lineTo(objPos.dx - s * 0.8, objPos.dy + s * 0.15)
          ..lineTo(objPos.dx - s * 0.5, objPos.dy)
          ..lineTo(objPos.dx - s * 0.5, objPos.dy + s * 0.7)
          ..lineTo(objPos.dx + s * 0.5, objPos.dy + s * 0.7)
          ..lineTo(objPos.dx + s * 0.5, objPos.dy)
          ..lineTo(objPos.dx + s * 0.8, objPos.dy + s * 0.15)
          ..lineTo(objPos.dx + s * 1.1, objPos.dy - s * 0.2)
          ..lineTo(objPos.dx + s * 0.5, objPos.dy - s * 0.6)
          ..close();
        canvas.drawPath(shirt, paint);
      case 1: // a cup with a handle
        final r = Rect.fromCenter(center: objPos, width: w * 0.08, height: h * 0.11);
        canvas.drawRRect(
          RRect.fromRectAndCorners(r, bottomLeft: const Radius.circular(6), bottomRight: const Radius.circular(6)),
          paint,
        );
        canvas.drawArc(
          Rect.fromCenter(center: r.centerRight, width: w * 0.04, height: h * 0.06),
          -1.4,
          2.8,
          false,
          Paint()
            ..color = object
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      default: // three blocks; the blue one is the target
        final s = w * 0.05;
        canvas.drawRect(
          Rect.fromCenter(center: Offset(w * 0.78, h * 0.735), width: s, height: s),
          Paint()..color = c.red,
        );
        canvas.drawRect(
          Rect.fromCenter(center: Offset(w * 0.88, h * 0.735), width: s, height: s),
          Paint()..color = c.lime,
        );
        canvas.drawRect(Rect.fromCenter(center: objPos, width: s, height: s), Paint()..color = const Color(0xFF3D7BFF));
    }
    // Camera with view cone (bright during See/Check).
    final cam = Offset(w * 0.12, h * 0.16);
    final seeing = phase == 0 || phase == 3;
    final cone = Path()
      ..moveTo(cam.dx, cam.dy)
      ..lineTo(w * 0.85, h * 0.62)
      ..lineTo(w * 0.45, h * 0.85)
      ..close();
    canvas.drawPath(cone, Paint()..color = c.cyan.withValues(alpha: seeing ? 0.10 + 0.08 * t : 0.03));
    canvas.drawCircle(cam, 10, Paint()..color = seeing ? c.cyan : c.textDim);
    // "Brain" glow during Understand.
    if (phase == 1) {
      final b = Offset(w * 0.12, h * 0.45);
      canvas.drawCircle(b, 18 + 6 * t, Paint()..color = c.magenta.withValues(alpha: 0.25));
      canvas.drawCircle(b, 12, Paint()..color = c.magenta);
      canvas.drawLine(
        cam,
        b,
        Paint()
          ..color = c.magenta
          ..strokeWidth = 2,
      );
    }
    // Arm: base → elbow → gripper reaching toward the object.
    final base = Offset(w * 0.32, h * 0.78);
    final reach = phase >= 2 ? 1.0 : 0.35 + 0.1 * t;
    final target = Offset.lerp(Offset(w * 0.4, h * 0.35), objPos - Offset(0, h * 0.08), reach)!;
    final mid = Offset((base.dx + target.dx) / 2 - w * 0.05, math.min(base.dy, target.dy) - h * 0.2);
    final arm = Paint()
      ..color = c.text.withValues(alpha: 0.85)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(base, mid, arm);
    canvas.drawLine(mid, target, arm);
    canvas.drawCircle(base, 14, Paint()..color = c.textDim);
    canvas.drawCircle(mid, 8, Paint()..color = c.textDim);
    final open = phase == 2 ? 4.0 : 10.0;
    final g = Paint()
      ..color = c.lime
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(target, target + Offset(-open, 12), g);
    canvas.drawLine(target, target + Offset(open, 12), g);
  }

  @override
  bool shouldRepaint(_ArmPainter old) => old.t != t || old.phase != phase || old.object != object;
}

class _Robots extends StatelessWidget {
  const _Robots();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DemoCard(
      title: 'Real robots learning this way',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TermText(
            'A [[VLA model]] is a language model that learned to see and to move. Because it already knows about the world '
            'from text and pictures, it can follow instructions it was never specifically trained on.',
          ),
          const SizedBox(height: Gap.m),
          for (final (year, name, what, fact) in const [
            ('2023', 'RT-2 (Google DeepMind)', 'turned web knowledge into robot actions', 'RB-RT2'),
            (
              '2024',
              'π0 (Physical Intelligence)',
              'one general policy that folds laundry, buses tables and packs boxes',
              'RB-PI0',
            ),
            ('2026', 'Gemini Robotics 2', 'whole-body control for humanoid robots', 'RB-GEMINI'),
          ])
            Card(
              margin: const EdgeInsets.only(bottom: Gap.s),
              child: ListTile(
                leading: Text(
                  year,
                  style: AppText.mono.copyWith(color: c.magenta, fontWeight: FontWeight.w800),
                ),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(what),
                trailing: IconButton(
                  tooltip: 'Source',
                  icon: Icon(Icons.info_outline, color: c.textDim),
                  onPressed: () => showFactSource(context, fact),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
