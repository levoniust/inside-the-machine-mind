import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 3 · "Minds with bodies": vision-language-action (VLA) models close the loop see → understand → act.
/// A painted robot arm runs the loop for a chosen instruction: during "Act" the gripper reaches, closes
/// on the object, lifts it and carries it to the task's destination (basket, sink, hand). During "See"
/// a camera-view inset boxes the target object. Facts: RB-RT2, RB-PI0, RB-GEMINI.
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

class _ArmLoopState extends State<_ArmLoop> with TickerProviderStateMixin {
  int _task = 0;
  int _phase = 0;
  late final AnimationController _t = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  /// Plays the pick-and-place sequence once each time the Act phase is entered.
  late final AnimationController _act = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));
  late final Listenable _anim = Listenable.merge([_t, _act]);

  bool get _animationsOff => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_animationsOff) {
      _t.value = 0.5;
      _t.stop();
      _act.stop();
      if (_phase >= 2) _act.value = 1;
    } else if (!_t.isAnimating) {
      _t.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _t.dispose();
    _act.dispose();
    super.dispose();
  }

  void _setPhase(int i) {
    if (i == 2) {
      if (_animationsOff) {
        _act.value = 1;
      } else {
        _act.forward(from: 0);
      }
    } else {
      _act.stop();
      if (i < 2) _act.value = 0;
    }
    setState(() => _phase = i);
  }

  void _selectTask(int i) {
    _act.stop();
    _act.value = 0;
    setState(() {
      _task = i;
      _phase = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final task = _tasks[_task];
    final seeing = _phase == 0 || _phase == 3;
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
                  onSelected: (_) => _selectTask(i),
                ),
            ],
          ),
          const SizedBox(height: Gap.m),
          AspectRatio(
            aspectRatio: 1.4,
            child: Semantics(
              label: seeing
                  ? 'Robot arm, phase ${_phases[_phase]}; camera view boxes the target object on the table'
                  : 'Robot arm, phase ${_phases[_phase]}',
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _anim,
                      builder: (_, _) =>
                          CustomPaint(painter: _ArmPainter(_phase, _t.value, _act.value, task.colorOf(c), c, _task)),
                    ),
                  ),
                  // Camera view inset: what the robot's camera sees, with the target object boxed.
                  if (seeing)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Semantics(
                        label: 'Camera view of the table with a box around the target object',
                        child: Container(
                          key: const ValueKey('robot-cam-inset'),
                          width: 96,
                          height: 68,
                          decoration: BoxDecoration(
                            color: c.surfaceHi,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: c.cyan, width: 1.5),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: AnimatedBuilder(
                                  animation: _t,
                                  builder: (_, _) =>
                                      CustomPaint(painter: _CamPainter(_t.value, task.colorOf(c), c, _task)),
                                ),
                              ),
                              Positioned(
                                left: 5,
                                bottom: 3,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('camera view', style: AppText.mono.copyWith(fontSize: 8, color: c.cyan)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
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
          StepControls(step: _phase, count: _phases.length, onStep: _setPhase),
        ],
      ),
    );
  }
}

class _ArmPainter extends CustomPainter {
  _ArmPainter(this.phase, this.t, this.act, this.object, this.c, this.kind);
  final int phase;
  final int kind; // 0 shirt, 1 cup, 2 blocks
  final double t; // ambient hover loop (0..1)
  final double act; // pick-and-place progress while in Act (0..1)
  final Color object;
  final AppColors c;

  static double _seg(double v, double a, double b) => ((v - a) / (b - a)).clamp(0.0, 1.0);

  /// Where the target object sits, following the pick-and-place sequence:
  /// reach 0–.20, close .20–.32, lift .32–.46, travel .46–.72, lower .72–.84, release .84–1.
  static Offset objectAt(double a, int kind, Size size) {
    final w = size.width, h = size.height;
    final rest = Offset(w * 0.62, h * 0.72);
    if (a <= 0.32) return rest;
    final target = switch (kind) {
      0 => Offset(w * 0.85, h * 0.71), // into the basket
      1 => Offset(w * 0.86, h * 0.745), // into the sink
      _ => Offset(w * 0.865, h * 0.48), // into the person's open hand
    };
    final liftedY = rest.dy - h * 0.26;
    if (a <= 0.46) return Offset(rest.dx, rest.dy + (liftedY - rest.dy) * _seg(a, 0.32, 0.46));
    if (a <= 0.72) {
      final from = Offset(rest.dx, liftedY);
      return Offset.lerp(from, Offset(target.dx, liftedY), Curves.easeInOutCubic.transform(_seg(a, 0.46, 0.72)))!;
    }
    if (a <= 0.84) return Offset(target.dx, liftedY + (target.dy - liftedY) * _seg(a, 0.72, 0.84));
    return target;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // The sequence is complete during Check ("it looks again" — the result is visible); idle before Act.
    final a = phase == 2 ? act : (phase == 3 ? 1.0 : 0.0);
    // Table.
    canvas.drawRect(Rect.fromLTWH(0, h * 0.78, w, h * 0.22), Paint()..color = c.surfaceHi);
    // The destination for this task, drawn behind the object.
    switch (kind) {
      case 0: // basket on the right
        final basket = Paint()
          ..color = c.textDim.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        final b = Rect.fromLTWH(w * 0.765, h * 0.685, w * 0.175, h * 0.115);
        canvas.drawRRect(
          RRect.fromRectAndCorners(b, bottomLeft: const Radius.circular(8), bottomRight: const Radius.circular(8)),
          basket,
        );
        canvas.drawLine(Offset(b.left + 4, b.top + b.height * 0.45), Offset(b.right - 4, b.top + b.height * 0.45), basket);
      case 1: // sink basin on the right with a faucet
        final basin = Rect.fromLTWH(w * 0.75, h * 0.76, w * 0.225, h * 0.17);
        canvas.drawRRect(
          RRect.fromRectAndRadius(basin, const Radius.circular(8)),
          Paint()..color = c.bg,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(basin, const Radius.circular(8)),
          Paint()
            ..color = c.line
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        canvas.drawCircle(Offset(basin.center.dx, basin.bottom - h * 0.045), 3, Paint()..color = c.line);
        canvas.drawLine(
          Offset(w * 0.965, h * 0.65),
          Offset(w * 0.965, h * 0.775),
          Paint()
            ..color = c.textDim
            ..strokeWidth = 5
            ..strokeCap = StrokeCap.round,
        );
      default: // a person's open hand reaching in from the right
        final arm = Paint()
          ..color = c.textDim
          ..strokeWidth = w * 0.035
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(w + 4, h * 0.36), Offset(w * 0.90, h * 0.46), arm);
        canvas.drawCircle(Offset(w * 0.875, h * 0.47), w * 0.03, Paint()..color = c.textDim);
        final finger = Paint()
          ..color = c.textDim
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(w * 0.855, h * 0.45), Offset(w * 0.825, h * 0.44), finger);
        canvas.drawLine(Offset(w * 0.855, h * 0.495), Offset(w * 0.825, h * 0.51), finger);
    }
    // Object on the table, carried along the pick-and-place path.
    final objPos = objectAt(a, kind, size);
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
    // Arm: base → elbow → gripper. In Act it reaches down, grabs the object and carries it to the target.
    final base = Offset(w * 0.32, h * 0.78);
    final neutral = Offset(w * 0.48, h * (0.44 - 0.04 * t));
    final grabPoint = Offset(w * 0.62, h * 0.72) - Offset(0, h * 0.06);
    final tip = phase != 2
        ? neutral
        : a < 0.20
            ? Offset.lerp(neutral, grabPoint, Curves.easeOut.transform(_seg(a, 0, 0.20)))!
            : objPos - Offset(0, h * 0.06);
    final mid = Offset((base.dx + tip.dx) / 2 - w * 0.05, math.min(base.dy, tip.dy) - h * 0.2);
    final armPaint = Paint()
      ..color = c.text.withValues(alpha: 0.85)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(base, mid, armPaint);
    canvas.drawLine(mid, tip, armPaint);
    canvas.drawCircle(base, 14, Paint()..color = c.textDim);
    canvas.drawCircle(mid, 8, Paint()..color = c.textDim);
    // The gripper closes on the object at .20–.32 and opens again to release at .86–1.
    final open = phase == 2 ? 10.0 - 6.0 * _seg(a, 0.20, 0.32) + 6.0 * _seg(a, 0.86, 1.0) : 10.0;
    final g = Paint()
      ..color = c.lime
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(tip, tip + Offset(-open, 12), g);
    canvas.drawLine(tip, tip + Offset(open, 12), g);
  }

  @override
  bool shouldRepaint(_ArmPainter old) =>
      old.t != t || old.act != act || old.phase != phase || old.object != object || old.kind != kind;
}

/// The little camera-view inset: a simplified table with the target object in viewfinder brackets.
class _CamPainter extends CustomPainter {
  _CamPainter(this.t, this.object, this.c, this.kind);
  final double t;
  final Color object;
  final AppColors c;
  final int kind;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Table edge, as the camera sees it.
    canvas.drawRect(Rect.fromLTWH(0, h * 0.78, w, h * 0.22), Paint()..color = c.line.withValues(alpha: 0.55));
    // The target object, in its resting place.
    final obj = _ArmPainter.objectAt(0, kind, size);
    final s = w * 0.09;
    canvas.drawRect(Rect.fromCenter(center: obj, width: s, height: s * 0.9), Paint()..color = object);
    // Viewfinder corner brackets around it, pulsing with the camera.
    final box = Rect.fromCenter(center: obj, width: s * 2.1, height: s * 2.0);
    final k = (s * 0.5).clamp(4.0, 10.0);
    final g = Paint()
      ..color = c.magenta.withValues(alpha: 0.6 + 0.4 * t)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    for (final (corner, dx, dy) in [
      (box.topLeft, 1.0, 1.0),
      (box.topRight, -1.0, 1.0),
      (box.bottomLeft, 1.0, -1.0),
      (box.bottomRight, -1.0, -1.0),
    ]) {
      canvas.drawLine(corner, corner + Offset(k * dx, 0), g);
      canvas.drawLine(corner, corner + Offset(0, k * dy), g);
    }
  }

  @override
  bool shouldRepaint(_CamPainter old) => old.t != t || old.object != object || old.kind != kind;
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
