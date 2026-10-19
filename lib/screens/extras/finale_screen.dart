import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../content/lessons.dart';
import '../../content/narration.dart';
import '../../content/quizzes.dart';
import '../../core/progress.dart';
import '../../widgets/bit.dart';

/// The finale: Bit under a starry sky, the closing thought, and a completion certificate.
class FinaleScreen extends StatefulWidget {
  const FinaleScreen({super.key});

  @override
  State<FinaleScreen> createState() => _FinaleScreenState();
}

class _FinaleScreenState extends State<FinaleScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(vsync: this, duration: const Duration(seconds: 8));

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
    final p = AppScope.progress(context);
    final text = narrationFor('finale');
    final done = allLessons.where((l) => p.isDone(l.id)).length;
    final quizTotal = quizzes.values.fold<int>(0, (s, q) => s + q.length);
    final quizBest = sections.fold<int>(0, (s, sec) => s + (p.quizScore(sec.quizId) ?? 0));
    final eggs = ['built', 'gallery'].where(p.foundEgg).length;
    return Scaffold(
      backgroundColor: const Color(0xFF03050B),
      appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Colors.white),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _t,
                builder: (_, _) => CustomPaint(painter: _StarsPainter(_t.value, c)),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(Gap.l, Gap.xxl, Gap.l, Gap.xxl),
                  children: [
                    const SizedBox(height: Gap.xl),
                    const Center(child: BitAvatar(size: 140, mood: BitMood.happy)),
                    const SizedBox(height: Gap.xl),
                    Theme(
                      data: buildTheme(Brightness.dark),
                      child: BitSays(lines: text.intro, mood: BitMood.happy, size: 48),
                    ),
                    const SizedBox(height: Gap.xl),
                    Text(
                      'The most important part of the machine is the person asking the question.',
                      key: const ValueKey('finale-quote'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, height: 1.35),
                    ),
                    const SizedBox(height: Gap.xxl),
                    _Certificate(done: done, total: allLessons.length, quizBest: quizBest, quizTotal: quizTotal, eggs: eggs),
                    const SizedBox(height: Gap.xl),
                    Center(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(backgroundColor: c.amber, foregroundColor: Colors.black),
                        onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                        icon: const Icon(Icons.home_outlined),
                        label: const Text('Back to the start'),
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

class _Certificate extends StatelessWidget {
  const _Certificate({required this.done, required this.total, required this.quizBest, required this.quizTotal, required this.eggs});
  final int done, total, quizBest, quizTotal, eggs;

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFC857);
    Widget stat(String label, String value) => Expanded(
          child: Column(
            children: [
              Text(value, style: AppText.mono.copyWith(color: gold, fontSize: 22, fontWeight: FontWeight.w800)),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        );
    return Container(
      padding: const EdgeInsets.all(Gap.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withValues(alpha: 0.7), width: 1.5),
        gradient: LinearGradient(colors: [gold.withValues(alpha: 0.12), const Color(0x22FF3DCB)]),
      ),
      child: Column(
        children: [
          const Icon(Icons.workspace_premium, color: gold, size: 40),
          const SizedBox(height: Gap.s),
          const Text('CERTIFIED CURIOUS HUMAN',
              style: TextStyle(color: gold, letterSpacing: 2, fontWeight: FontWeight.w800)),
          const SizedBox(height: Gap.xs),
          const Text('for following a question all the way through the machine mind',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
          const SizedBox(height: Gap.l),
          Row(
            children: [
              stat('lessons explored', '$done/$total'),
              stat('best quiz answers', '$quizBest/$quizTotal'),
              stat('secrets found', '$eggs/2'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  _StarsPainter(this.t, this.c);
  final double t;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF03050B), Color(0xFF0B1030), Color(0xFF1B1446)],
        ).createShader(rect),
    );
    final r = math.Random(11);
    for (var i = 0; i < 160; i++) {
      final p = Offset(r.nextDouble() * size.width, r.nextDouble() * size.height * 0.85);
      final tw = 0.5 + 0.5 * math.sin((t + r.nextDouble()) * math.pi * 2);
      final rad = 0.6 + r.nextDouble() * 1.4;
      canvas.drawCircle(p, rad, Paint()..color = Colors.white.withValues(alpha: 0.25 + 0.7 * tw * r.nextDouble()));
    }
    // A shooting star now and then.
    final s = (t * 1.6) % 1.0;
    if (s < 0.25) {
      final a = Offset(size.width * (0.2 + s * 2), size.height * (0.1 + s * 0.6));
      canvas.drawLine(a, a - const Offset(60, 30), Paint()
        ..shader = LinearGradient(colors: [Colors.white, Colors.white.withValues(alpha: 0)])
            .createShader(Rect.fromPoints(a, a - const Offset(60, 30)))
        ..strokeWidth = 2);
    }
    // Hills on the horizon.
    final hill = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.9)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.82, size.width * 0.6, size.height * 0.9)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.96, size.width, size.height * 0.88)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(hill, Paint()..color = const Color(0xFF05070F));
  }

  @override
  bool shouldRepaint(_StarsPainter old) => old.t != t;
}
