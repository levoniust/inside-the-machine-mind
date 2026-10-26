import 'package:flutter/material.dart';

import '../../app/nav.dart';
import '../../app/theme.dart';
import '../../content/facts.dart';
import '../../core/models.dart';
import '../../core/progress.dart';
import '../../widgets/components.dart';
import '../extras/source_doc_screen.dart';

/// One annotated paper: the one idea, a plain summary, why it mattered, where you meet it today,
/// what to read and skip, key terms, a 3-question check and the bundled copy.
/// Finishing the check (or opening the paper) marks `paper_<sourceId>` as read.
class PaperScreen extends StatelessWidget {
  const PaperScreen({super.key, required this.paper});
  final Paper paper;

  static String readKey(Paper p) => 'paper_${p.sourceId}';

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final t = Theme.of(context).textTheme;
    final src = sources[paper.sourceId];
    final accent = c.section(8);
    return Scaffold(
      appBar: AppBar(title: Text(paper.short)),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(Gap.l, Gap.m, Gap.l, Gap.xxl),
              children: [
                Text(src?.title ?? paper.short, style: t.titleLarge),
                const SizedBox(height: Gap.xs),
                Text('${paper.authors} · ${paper.year}', style: AppText.mono.copyWith(color: c.textDim, fontSize: 12)),
                const SizedBox(height: Gap.l),
                KeyIdea(paper.oneIdea, color: accent),
                const SizedBox(height: Gap.l),
                _Block('In plain words', paper.summary),
                _Block('Why it mattered', paper.whyItMattered),
                _Block('Where you meet it today', paper.inYourTools),
                _Heading('If you open the paper, read'),
                for (final r in paper.readThis)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Gap.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('›  ', style: AppText.mono.copyWith(color: accent)),
                        Expanded(child: Text(r)),
                      ],
                    ),
                  ),
                const SizedBox(height: Gap.s),
                Text(
                  'Safe to skip: ${paper.skipThis}',
                  style: TextStyle(color: c.textDim, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: Gap.l),
                _Heading('Terms'),
                Wrap(
                  spacing: Gap.s,
                  runSpacing: Gap.s,
                  children: [
                    for (final (term, plain) in paper.terms) _TermChip(term: term, plain: plain, color: accent),
                  ],
                ),
                const SizedBox(height: Gap.l),
                FilledButton.icon(
                  key: const ValueKey('paper-open'),
                  style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: c.bg),
                  onPressed: () {
                    AppScope.read(context).markDone(readKey(paper));
                    openPage(context, SourceDocScreen(sourceId: paper.sourceId), '/source/${paper.sourceId}');
                  },
                  icon: const Icon(Icons.article_outlined),
                  label: const Text('Open the paper (offline copy)'),
                ),
                const SizedBox(height: Gap.xl),
                _Heading('Check yourself'),
                _Check(paper: paper, accent: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Gap.s),
    child: Text(
      text.toUpperCase(),
      style: AppText.mono.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: AppColors.of(context).section(8),
      ),
    ),
  );
}

class _Block extends StatelessWidget {
  const _Block(this.title, this.body);
  final String title, body;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Gap.l),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Heading(title),
        Text(body, style: const TextStyle(height: 1.4)),
      ],
    ),
  );
}

class _TermChip extends StatefulWidget {
  const _TermChip({required this.term, required this.plain, required this.color});
  final String term, plain;
  final Color color;

  @override
  State<_TermChip> createState() => _TermChipState();
}

class _TermChipState extends State<_TermChip> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _open = !_open),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Gap.m, vertical: Gap.s),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: widget.color.withValues(alpha: _open ? 0.9 : 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.term,
              style: TextStyle(fontWeight: FontWeight.w700, color: widget.color),
            ),
            if (_open)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: Text(widget.plain, style: TextStyle(color: c.text)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Three questions, answered inline with instant feedback.
class _Check extends StatefulWidget {
  const _Check({required this.paper, required this.accent});
  final Paper paper;
  final Color accent;

  @override
  State<_Check> createState() => _CheckState();
}

class _CheckState extends State<_Check> {
  late final List<int?> _picked = List.filled(widget.paper.check.length, null);

  void _pick(int q, int i) {
    if (_picked[q] != null) return;
    setState(() => _picked[q] = i);
    if (_picked.every((p) => p != null)) AppScope.read(context).markDone(PaperScreen.readKey(widget.paper));
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final qs = widget.paper.check;
    final score = [
      for (var q = 0; q < qs.length; q++)
        if (_picked[q] == qs[q].answer) 1,
    ].length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var q = 0; q < qs.length; q++)
          DemoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('${q + 1}. ${qs[q].question}', style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: Gap.s),
                for (var i = 0; i < qs[q].options.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Gap.xs),
                    child: OutlinedButton(
                      key: ValueKey('paper-q$q-o$i'),
                      style: OutlinedButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        backgroundColor: _picked[q] == null
                            ? null
                            : i == qs[q].answer
                            ? c.lime.withValues(alpha: 0.18)
                            : i == _picked[q]
                            ? c.red.withValues(alpha: 0.15)
                            : null,
                      ),
                      onPressed: () => _pick(q, i),
                      child: Text(qs[q].options[i]),
                    ),
                  ),
                if (_picked[q] != null) ...[
                  const SizedBox(height: Gap.xs),
                  Text(
                    '${_picked[q] == qs[q].answer ? 'Right!' : 'Not quite.'} ${qs[q].explain}',
                    style: TextStyle(color: _picked[q] == qs[q].answer ? c.lime : c.textDim),
                  ),
                ],
              ],
            ),
          ),
        if (_picked.every((p) => p != null))
          Padding(
            padding: const EdgeInsets.only(top: Gap.s),
            child: Text(
              '$score / ${qs.length} · marked as read',
              textAlign: TextAlign.center,
              style: AppText.mono.copyWith(color: widget.accent),
            ),
          ),
      ],
    );
  }
}
