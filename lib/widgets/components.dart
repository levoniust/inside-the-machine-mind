import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../content/facts.dart';
import 'term_text.dart';

/// Subtle animated circuit traces with light pulses. Cheap to paint; static when animations are off.
class CircuitBackground extends StatefulWidget {
  const CircuitBackground({super.key, this.child, this.accent, this.density = 1.0});
  final Widget? child;
  final Color? accent;
  final double density;

  @override
  State<CircuitBackground> createState() => _CircuitBackgroundState();
}

class _CircuitBackgroundState extends State<CircuitBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(vsync: this, duration: const Duration(seconds: 12));

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
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _t,
              builder: (_, _) => CustomPaint(
                painter: _CircuitPainter(_t.value, c.line, widget.accent ?? c.cyan, widget.density),
              ),
            ),
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _CircuitPainter extends CustomPainter {
  _CircuitPainter(this.t, this.line, this.accent, this.density);
  final double t;
  final Color line, accent;
  final double density;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    final trace = Paint()
      ..color = line.withValues(alpha: 0.55)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final pad = Paint()..color = line.withValues(alpha: 0.8);
    final n = (size.width * size.height / 26000 * density).clamp(6, 60).toInt();
    for (var i = 0; i < n; i++) {
      final start = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height);
      final horiz = rnd.nextBool();
      final l1 = 30 + rnd.nextDouble() * 90;
      final l2 = 20 + rnd.nextDouble() * 70;
      final mid = horiz ? start + Offset(l1, 0) : start + Offset(0, l1);
      final end = mid + Offset(l2 * 0.7, l2 * 0.7) * (rnd.nextBool() ? 1 : -1);
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(mid.dx, mid.dy)
        ..lineTo(end.dx, end.dy);
      canvas.drawPath(path, trace);
      canvas.drawCircle(start, 2.2, pad);
      canvas.drawCircle(end, 2.2, pad);
      // A pulse travelling along some traces.
      if (i % 3 == 0) {
        final phase = (t + i * 0.137) % 1.0;
        final total = l1 + l2;
        final d = phase * total;
        final p = d < l1 ? Offset.lerp(start, mid, d / l1)! : Offset.lerp(mid, end, (d - l1) / l2)!;
        canvas.drawCircle(p, 6, Paint()..color = accent.withValues(alpha: 0.18)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
        canvas.drawCircle(p, 1.8, Paint()..color = accent.withValues(alpha: 0.8));
      }
    }
  }

  @override
  bool shouldRepaint(_CircuitPainter old) => old.t != t || old.accent != accent || old.line != line;
}

/// A highlighted "key idea" box at the end of a lesson.
class KeyIdea extends StatelessWidget {
  const KeyIdea(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = color ?? c.lime;
    return Container(
      padding: const EdgeInsets.all(Gap.l),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: accent),
          const SizedBox(width: Gap.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('KEY IDEA', style: TextStyle(color: accent, fontWeight: FontWeight.w800, letterSpacing: 1.2, fontSize: 12)),
                const SizedBox(height: Gap.xs),
                TermText(text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A big number with a plain-language comparison and a tappable source (fact id from facts.dart).
class FactCard extends StatelessWidget {
  const FactCard({super.key, required this.value, required this.label, this.comparison, this.factId, this.color});
  final String value;
  final String label;
  final String? comparison;
  final String? factId;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = color ?? c.cyan;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Gap.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(value,
                        style: AppText.mono.copyWith(fontSize: 28, fontWeight: FontWeight.w800, color: accent, height: 1.1)),
                  ),
                ),
                if (factId != null)
                  IconButton(
                    tooltip: 'Source',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.info_outline, size: 20, color: c.textDim),
                    onPressed: () => showFactSource(context, factId!),
                  ),
              ],
            ),
            const SizedBox(height: Gap.xs),
            TermText(label, style: Theme.of(context).textTheme.bodyMedium),
            if (comparison != null) ...[
              const SizedBox(height: Gap.s),
              TermText('≈ $comparison', style: TextStyle(color: c.textDim, fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet with a fact's text and its sources.
void showFactSource(BuildContext context, String factId) {
  final f = facts[factId];
  final c = AppColors.of(context);
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: c.surface,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Where this number comes from', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: Gap.m),
            if (f != null) ...[
              Text(f.text),
              const SizedBox(height: Gap.m),
              for (final sid in f.sources)
                if (sources[sid] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Gap.s),
                    child: Text('• ${sources[sid]!.title}', style: TextStyle(color: c.textDim)),
                  ),
            ] else
              Text('Source: $factId', style: TextStyle(color: c.textDim)),
          ],
        ),
      ),
    ),
  );
}

/// Slider with a label and a formatted value.
class LabeledSlider extends StatelessWidget {
  const LabeledSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.format,
    this.color,
  });
  final String label;
  final double value, min, max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final String Function(double)? format;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final shown = format?.call(value) ?? value.toStringAsFixed(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: TextStyle(color: c.textDim))),
            Text(shown, style: AppText.mono.copyWith(fontWeight: FontWeight.w700, color: color ?? c.cyan)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            label: shown,
            onChanged: onChanged,
            semanticFormatterCallback: (v) => '$label ${format?.call(v) ?? v.toStringAsFixed(1)}',
          ),
        ),
      ],
    );
  }
}

/// Small labelled number tile.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.label, required this.value, this.color, this.icon});
  final String label;
  final String value;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(Gap.m),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (icon != null) ...[Icon(icon, size: 16, color: c.textDim), const SizedBox(width: Gap.xs)],
            Flexible(child: Text(label, style: TextStyle(color: c.textDim, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: Gap.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppText.mono.copyWith(fontSize: 20, fontWeight: FontWeight.w800, color: color ?? c.text)),
          ),
        ],
      ),
    );
  }
}

/// One bar in a [CompareBars] chart.
class BarItem {
  const BarItem(this.label, this.value, {this.display, this.color});
  final String label;
  final double value;
  final String? display;
  final Color? color;
}

/// Animated horizontal bars, optionally on a log scale (for values spanning many orders of magnitude).
class CompareBars extends StatelessWidget {
  const CompareBars({super.key, required this.items, this.log = false, this.highlight, this.color});
  final List<BarItem> items;
  final bool log;
  final int? highlight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    if (items.isEmpty) return const SizedBox.shrink();
    double f(double v) => log ? math.log(v.clamp(1e-12, double.infinity)) / math.ln10 : v;
    final vals = items.map((e) => f(e.value)).toList();
    final maxV = vals.reduce(math.max);
    final minV = log ? vals.reduce(math.min) - 1 : 0.0;
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(items[i].label,
                            style: TextStyle(
                                fontWeight: i == highlight ? FontWeight.w800 : FontWeight.w500,
                                color: i == highlight ? c.text : c.textDim))),
                    Text(items[i].display ?? items[i].value.toString(),
                        style: AppText.mono.copyWith(fontSize: 13, color: c.text)),
                  ],
                ),
                const SizedBox(height: 4),
                LayoutBuilder(
                  builder: (context, box) {
                    final frac = maxV == minV ? 1.0 : ((vals[i] - minV) / (maxV - minV)).clamp(0.02, 1.0);
                    final col = items[i].color ?? color ?? c.cyan;
                    return Stack(
                      children: [
                        Container(height: 10, decoration: BoxDecoration(color: c.surfaceHi, borderRadius: BorderRadius.circular(5))),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          height: 10,
                          width: box.maxWidth * frac,
                          decoration: BoxDecoration(
                            color: col,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: i == highlight ? [BoxShadow(color: col.withValues(alpha: 0.5), blurRadius: 10)] : null,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        if (log)
          Align(
            alignment: Alignment.centerRight,
            child: Text('log scale: each step = 10× more', style: TextStyle(color: c.textDim, fontSize: 11)),
          ),
      ],
    );
  }
}

/// ◀ step ▶ controls with an optional play/pause button.
class StepControls extends StatelessWidget {
  const StepControls({
    super.key,
    required this.step,
    required this.count,
    required this.onStep,
    this.playing,
    this.onPlayPause,
    this.labels,
  });
  final int step;
  final int count;
  final ValueChanged<int> onStep;
  final bool? playing;
  final VoidCallback? onPlayPause;
  final List<String>? labels;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.outlined(
              tooltip: 'Previous step',
              onPressed: step > 0 ? () => onStep(step - 1) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            const SizedBox(width: Gap.s),
            if (onPlayPause != null)
              IconButton.filled(
                tooltip: playing == true ? 'Pause' : 'Play',
                onPressed: onPlayPause,
                icon: Icon(playing == true ? Icons.pause : Icons.play_arrow),
              ),
            const SizedBox(width: Gap.s),
            Text('${step + 1} / $count', style: AppText.mono.copyWith(color: c.textDim)),
            const SizedBox(width: Gap.s),
            IconButton.outlined(
              tooltip: 'Next step',
              onPressed: step < count - 1 ? () => onStep(step + 1) : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        if (labels != null && step < labels!.length)
          Padding(
            padding: const EdgeInsets.only(top: Gap.xs),
            child: Text(labels![step], textAlign: TextAlign.center, style: TextStyle(color: c.text, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

/// A section label pill, e.g. "SECTION 1 · HARDWARE".
class SectionTag extends StatelessWidget {
  const SectionTag(this.text, {super.key, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(text.toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.1)),
      );
}

/// Card container with standard padding, used to frame interactive demos.
class DemoCard extends StatelessWidget {
  const DemoCard({super.key, required this.child, this.title, this.padding = const EdgeInsets.all(Gap.l)});
  final Widget child;
  final String? title;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Text(title!, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: c.text, fontWeight: FontWeight.w700)),
              const SizedBox(height: Gap.m),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

/// Formats big numbers in plain words: 1.2 thousand, 3.4 million, 5 billion, 2 trillion.
String humanNumber(double v, {int digits = 1}) {
  final a = v.abs();
  String f(double x, String unit) {
    final s = x.toStringAsFixed(x >= 100 ? 0 : digits);
    return unit.isEmpty ? s : '$s $unit';
  }
  if (a >= 1e15) return '${(v / 1e15).toStringAsFixed(digits)} quadrillion';
  if (a >= 1e12) return f(v / 1e12, 'trillion');
  if (a >= 1e9) return f(v / 1e9, 'billion');
  if (a >= 1e6) return f(v / 1e6, 'million');
  if (a >= 1e4) return f(v / 1e3, 'thousand');
  return v >= 100 ? v.toStringAsFixed(0) : v.toStringAsFixed(digits);
}

/// Formats bytes: 512 MB, 1.4 TB, 3 PB.
String humanBytes(double bytes) {
  const units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB'];
  var v = bytes;
  var i = 0;
  while (v >= 1000 && i < units.length - 1) {
    v /= 1000;
    i++;
  }
  return '${v >= 100 ? v.toStringAsFixed(0) : v.toStringAsFixed(1)} ${units[i]}';
}

/// Formats a duration given in seconds: 4.2 ms, 3 s, 5 min, 2.5 h, 54 days, 3 years.
String humanSeconds(double s) {
  if (s < 1e-6) return '${(s * 1e9).toStringAsFixed(0)} ns';
  if (s < 1e-3) return '${(s * 1e6).toStringAsFixed(0)} µs';
  if (s < 1) return '${(s * 1e3).toStringAsFixed(s < 0.01 ? 1 : 0)} ms';
  if (s < 120) return '${s.toStringAsFixed(s < 10 ? 1 : 0)} s';
  if (s < 7200) return '${(s / 60).toStringAsFixed(0)} min';
  if (s < 172800) return '${(s / 3600).toStringAsFixed(1)} h';
  if (s < 3.15e7 * 2) return '${(s / 86400).toStringAsFixed(0)} days';
  return '${humanNumber(s / 3.156e7, digits: 0)} years';
}

/// Tiles in rows of [columns], each row as tall as its tallest tile (safe at large text sizes,
/// unlike a fixed-aspect GridView).
class StatGrid extends StatelessWidget {
  const StatGrid({super.key, required this.children, this.columns = 2, this.spacing = Gap.s});
  final List<Widget> children;
  final int columns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final row = children.sublist(i, math.min(i + columns, children.length));
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var j = 0; j < columns; j++) ...[
              if (j > 0) SizedBox(width: spacing),
              Expanded(child: j < row.length ? row[j] : const SizedBox.shrink()),
            ],
          ],
        ),
      ));
      if (i + columns < children.length) rows.add(SizedBox(height: spacing));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }
}
