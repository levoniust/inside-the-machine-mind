import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../core/progress.dart';
import '../core/speech.dart';
import 'term_text.dart';

enum BitMood { idle, talk, think, happy, wow }

/// Bit, the robot guide: a round head with a dark visor, two glowing eyes and an antenna.
/// Blinks on its own; [mood] changes the eyes and antenna.
class BitAvatar extends StatefulWidget {
  const BitAvatar({super.key, this.size = 72, this.mood = BitMood.idle, this.eyeColor});

  final double size;
  final BitMood mood;
  final Color? eyeColor;

  @override
  State<BitAvatar> createState() => _BitAvatarState();
}

class _BitAvatarState extends State<BitAvatar> with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(vsync: this, duration: const Duration(seconds: 4));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (still) {
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
    return Semantics(
      label: 'Bit the robot guide',
      image: true,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _t,
          builder: (_, _) => CustomPaint(
            size: Size.square(widget.size),
            painter: BitPainter(
              t: _t.value,
              mood: widget.mood,
              eye: widget.eyeColor ?? c.cyan,
              shell: c.isDark ? const Color(0xFFB9C6D8) : const Color(0xFF8A9AB0),
              visor: const Color(0xFF05080D),
              accent: c.magenta,
            ),
          ),
        ),
      ),
    );
  }
}

class BitPainter extends CustomPainter {
  BitPainter({
    required this.t,
    required this.mood,
    required this.eye,
    required this.shell,
    required this.visor,
    required this.accent,
  });

  final double t; // 0..1 loop
  final BitMood mood;
  final Color eye, shell, visor, accent;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final cx = s / 2;
    final headC = Offset(cx, s * 0.56);
    final r = s * 0.36;

    // Antenna (spins its tip when thinking).
    final stem = Paint()
      ..color = shell
      ..strokeWidth = s * 0.035
      ..strokeCap = StrokeCap.round;
    final tip = Offset(cx, s * 0.1);
    canvas.drawLine(Offset(cx, headC.dy - r), tip, stem);
    final tipColor = mood == BitMood.think ? accent : eye;
    final glow = 0.6 + 0.4 * math.sin(t * math.pi * 2 * (mood == BitMood.think ? 4 : 1));
    canvas.drawCircle(
      tip,
      s * 0.07,
      Paint()
        ..color = tipColor.withValues(alpha: 0.25 * glow)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.05),
    );
    canvas.drawCircle(tip, s * 0.04, Paint()..color = tipColor);
    if (mood == BitMood.think) {
      final a = t * math.pi * 8;
      canvas.drawCircle(tip + Offset(math.cos(a), math.sin(a)) * s * 0.07, s * 0.012, Paint()..color = tipColor);
    }

    // Ear bolts.
    final bolt = Paint()..color = shell.withValues(alpha: 0.9);
    canvas.drawCircle(headC + Offset(-r * 1.02, 0), s * 0.05, bolt);
    canvas.drawCircle(headC + Offset(r * 1.02, 0), s * 0.05, bolt);

    // Head: metallic gradient circle.
    final head = Rect.fromCircle(center: headC, radius: r);
    canvas.drawCircle(
      headC,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.5),
          colors: [Color.lerp(shell, Colors.white, 0.45)!, shell, Color.lerp(shell, Colors.black, 0.45)!],
          stops: const [0, 0.55, 1],
        ).createShader(head),
    );
    // Circuit lines on the forehead.
    final trace = Paint()
      ..color = eye.withValues(alpha: 0.35)
      ..strokeWidth = s * 0.012
      ..style = PaintingStyle.stroke;
    final p = Path()
      ..moveTo(cx - r * 0.5, headC.dy - r * 0.62)
      ..lineTo(cx - r * 0.2, headC.dy - r * 0.62)
      ..lineTo(cx - r * 0.1, headC.dy - r * 0.78)
      ..moveTo(cx + r * 0.15, headC.dy - r * 0.8)
      ..lineTo(cx + r * 0.25, headC.dy - r * 0.62)
      ..lineTo(cx + r * 0.55, headC.dy - r * 0.62);
    canvas.drawPath(p, trace);

    // Visor.
    final visorRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: headC + Offset(0, r * 0.08), width: r * 1.5, height: r * 0.92),
      Radius.circular(r * 0.42),
    );
    canvas.drawRRect(visorRect, Paint()..color = visor);
    canvas.drawRRect(
      visorRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.012
        ..color = eye.withValues(alpha: 0.25),
    );

    // Eyes.
    final blink = _blink(t);
    final eyeY = headC.dy + r * 0.08;
    final dx = r * 0.36;
    for (final sign in [-1.0, 1.0]) {
      final ec = Offset(cx + sign * dx, eyeY);
      _eye(canvas, ec, s, blink);
    }
  }

  double _blink(double t) {
    if (mood == BitMood.happy) return 1;
    // Quick blink near t = 0.92.
    final d = (t - 0.92).abs();
    return d < 0.025 ? d / 0.025 : 1;
  }

  void _eye(Canvas canvas, Offset c, double s, double open) {
    final glowPaint = Paint()
      ..color = eye.withValues(alpha: mood == BitMood.talk ? 0.35 + 0.25 * math.sin(t * math.pi * 16).abs() : 0.35)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.05);
    final er = switch (mood) {
      BitMood.wow => s * 0.085,
      _ => s * 0.065,
    };
    canvas.drawCircle(c, er * 1.6, glowPaint);
    final paint = Paint()..color = eye;
    if (mood == BitMood.happy) {
      // ^ ^ eyes.
      final arc = Paint()
        ..color = eye
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.03
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: c + Offset(0, er * 0.4), radius: er),
        math.pi * 1.1,
        math.pi * 0.8,
        false,
        arc,
      );
      return;
    }
    canvas.drawOval(Rect.fromCenter(center: c, width: er * 2, height: er * 2 * open.clamp(0.08, 1)), paint);
    // Highlight.
    if (open > 0.5) {
      canvas.drawCircle(
        c + Offset(-er * 0.35, -er * 0.35),
        er * 0.28,
        Paint()..color = Colors.white.withValues(alpha: 0.8),
      );
    }
  }

  @override
  bool shouldRepaint(BitPainter old) => old.t != t || old.mood != mood || old.eye != eye || old.shell != shell;
}

/// Bit with a speech bubble. Lines appear with a typewriter effect; tap to finish or go to the next line.
class BitSays extends StatefulWidget {
  const BitSays({super.key, required this.lines, this.mood = BitMood.talk, this.size = 64, this.onFinished});

  /// Lines may use the TermText markup: `[[term]]` for glossary terms, `**bold**`.
  final List<String> lines;
  final BitMood mood;
  final double size;
  final VoidCallback? onFinished;

  @override
  State<BitSays> createState() => _BitSaysState();
}

class _BitSaysState extends State<BitSays> with SingleTickerProviderStateMixin {
  int _line = 0;
  late final AnimationController _type = AnimationController(vsync: this);

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(BitSays old) {
    super.didUpdateWidget(old);
    if (old.lines.join() != widget.lines.join()) {
      _line = 0;
      _start();
    }
  }

  void _start() {
    if (widget.lines.isEmpty) return;
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    if (scope?.notifier?.autoSpeak ?? false) BitVoice.instance.say(widget.lines[_line]);
    final len = TermText.plain(widget.lines[_line]).length;
    _type.duration = Duration(milliseconds: (len * 22).clamp(300, 3500));
    _type.forward(from: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) _type.value = 1;
  }

  void _tap() {
    if (_type.isAnimating) {
      _type.value = 1;
    } else if (_line < widget.lines.length - 1) {
      setState(() => _line++);
      _start();
    } else {
      widget.onFinished?.call();
    }
  }

  @override
  void dispose() {
    _type.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    if (widget.lines.isEmpty) return const SizedBox.shrink();
    final speaker = IconButton(
      tooltip: 'Read aloud',
      visualDensity: VisualDensity.compact,
      iconSize: 18,
      color: c.textDim,
      onPressed: () => BitVoice.instance.say(widget.lines[_line]),
      icon: const Icon(Icons.volume_up_outlined),
    );
    final more = _line < widget.lines.length - 1;
    return GestureDetector(
      onTap: _tap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          BitAvatar(size: widget.size, mood: widget.mood),
          const SizedBox(width: Gap.s),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(Gap.l, Gap.m, Gap.l, Gap.m),
              decoration: BoxDecoration(
                color: c.surfaceHi,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                  bottomLeft: Radius.circular(4),
                ),
                border: Border.all(color: c.line),
              ),
              child: AnimatedBuilder(
                animation: _type,
                builder: (context, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TermText(widget.lines[_line], reveal: _type.value),
                    Padding(
                      padding: const EdgeInsets.only(top: Gap.xs),
                      child: Row(
                        children: [
                          if (widget.lines.length > 1)
                            for (var i = 0; i < widget.lines.length; i++)
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(shape: BoxShape.circle, color: i == _line ? c.cyan : c.line),
                              ),
                          // Takes the free space and shortens itself, so narrow bubbles at large text don't overflow.
                          Expanded(
                            child: more && !_type.isAnimating
                                ? Text('tap for more',
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: c.textDim, fontSize: 12))
                                : const SizedBox.shrink(),
                          ),
                          speaker,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
