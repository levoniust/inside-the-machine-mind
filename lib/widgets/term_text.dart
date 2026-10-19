import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../content/glossary.dart';
import '../core/models.dart';

/// Rich text with light markup:
///   `[[term]]` or `[[shown text|term]]` → tappable glossary term (accent color, dotted underline);
///              tapping shows the everyday translation and definition.
///   `**bold**` → bold.
/// [reveal] (0..1) shows only the first part of the text (typewriter effect).
class TermText extends StatefulWidget {
  const TermText(this.text, {super.key, this.reveal = 1, this.style, this.textAlign});

  final String text;
  final double reveal;
  final TextStyle? style;
  final TextAlign? textAlign;

  /// The text without markup (what the user reads).
  static String plain(String text) => _parse(text).map((s) => s.text).join();

  @override
  State<TermText> createState() => _TermTextState();
}

class _Seg {
  _Seg(this.text, {this.term, this.bold = false});
  final String text;
  final String? term;
  final bool bold;
}

final _re = RegExp(r'\[\[([^\]|]+)(?:\|([^\]]+))?\]\]|\*\*([^*]+)\*\*');

List<_Seg> _parse(String text) {
  final out = <_Seg>[];
  var i = 0;
  for (final m in _re.allMatches(text)) {
    if (m.start > i) out.add(_Seg(text.substring(i, m.start)));
    if (m.group(1) != null) {
      out.add(_Seg(m.group(1)!, term: (m.group(2) ?? m.group(1))!));
    } else {
      out.add(_Seg(m.group(3)!, bold: true));
    }
    i = m.end;
  }
  if (i < text.length) out.add(_Seg(text.substring(i)));
  return out;
}

class _TermTextState extends State<TermText> {
  final List<TapGestureRecognizer> _taps = [];

  @override
  void dispose() {
    for (final t in _taps) {
      t.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final t in _taps) {
      t.dispose();
    }
    _taps.clear();
    final c = AppColors.of(context);
    final base = widget.style ?? Theme.of(context).textTheme.bodyLarge!;
    final segs = _parse(widget.text);
    final total = segs.fold<int>(0, (n, s) => n + s.text.length);
    var budget = (total * widget.reveal.clamp(0, 1)).round();
    final spans = <InlineSpan>[];
    for (final s in segs) {
      if (budget <= 0) break;
      final shown = s.text.length <= budget ? s.text : s.text.substring(0, budget);
      budget -= shown.length;
      if (s.term != null) {
        final rec = TapGestureRecognizer()..onTap = () => showTermSheet(context, s.term!);
        _taps.add(rec);
        spans.add(TextSpan(
          text: shown,
          recognizer: rec,
          style: TextStyle(
            color: c.cyan,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dotted,
            decorationColor: c.cyan,
          ),
        ));
      } else {
        spans.add(TextSpan(text: shown, style: s.bold ? const TextStyle(fontWeight: FontWeight.w700) : null));
      }
    }
    // Keep layout stable while typing: render the hidden rest transparent.
    final shownLen = spans.fold<int>(0, (n, s) => n + s.toPlainText().length);
    final hidden = TermText.plain(widget.text).substring(shownLen);
    if (hidden.isNotEmpty) {
      spans.add(TextSpan(text: hidden, style: const TextStyle(color: Colors.transparent)));
    }
    return Text.rich(TextSpan(style: base, children: spans), textAlign: widget.textAlign);
  }
}

/// Bottom sheet explaining a glossary term ("engineering word = everyday word").
void showTermSheet(BuildContext context, String term) {
  final g = findTerm(term);
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
            Text(g?.term ?? term, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: c.cyan)),
            if (g != null) ...[
              const SizedBox(height: Gap.s),
              Text('Everyday word: ${g.everyday}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: c.lime)),
              const SizedBox(height: Gap.m),
              Text(g.definition, style: Theme.of(context).textTheme.bodyLarge),
            ] else
              Text('(Not in the glossary yet.)', style: TextStyle(color: c.textDim)),
          ],
        ),
      ),
    ),
  );
}

/// Inline "Engineering term (everyday term)" chip, e.g. for headings.
class TermChip extends StatelessWidget {
  const TermChip(this.term, {super.key});
  final String term;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final GlossaryTerm? g = findTerm(term);
    return ActionChip(
      onPressed: () => showTermSheet(context, term),
      backgroundColor: c.surfaceHi,
      side: BorderSide(color: c.line),
      shape: const StadiumBorder(),
      label: Text.rich(TextSpan(children: [
        TextSpan(text: g?.term ?? term, style: TextStyle(color: c.cyan, fontWeight: FontWeight.w700)),
        if (g != null) TextSpan(text: '  ·  ${g.everyday}', style: TextStyle(color: c.textDim)),
      ])),
    );
  }
}
