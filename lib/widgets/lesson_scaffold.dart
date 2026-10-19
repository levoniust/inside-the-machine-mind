import 'package:flutter/material.dart';

import '../app/nav.dart';
import '../app/theme.dart';
import '../content/lessons.dart';
import '../content/narration.dart';
import '../core/progress.dart';
import 'bit.dart';
import 'components.dart';

/// Standard layout for every lesson:
///   top bar (section color, "n / N", title) → Bit's intro bubble → [children] (the interactive part)
///   → key idea → Back / Next bar. Pressing Next marks the lesson done.
/// Bit's text and the key idea come from content/narration.dart unless overridden.
class LessonScaffold extends StatefulWidget {
  const LessonScaffold({
    super.key,
    required this.lessonId,
    required this.children,
    this.intro,
    this.keyIdea,
    this.bitMood = BitMood.talk,
  });

  final String lessonId;
  final List<Widget> children;
  final List<String>? intro;
  final String? keyIdea;
  final BitMood bitMood;

  @override
  State<LessonScaffold> createState() => _LessonScaffoldState();
}

class _LessonScaffoldState extends State<LessonScaffold> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppScope.read(context).setLast(widget.lessonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final info = lessonById(widget.lessonId);
    final section = info == null ? null : sectionOf(info);
    final accent = c.section(info?.section ?? 0);
    final list = section?.lessons ?? const [];
    final index = list.indexWhere((l) => l.id == widget.lessonId);
    final text = narrationFor(widget.lessonId);
    final intro = widget.intro ?? text.intro;
    final keyIdea = widget.keyIdea ?? text.keyIdea;
    final wide = MediaQuery.sizeOf(context).width >= 600;
    final gutter = wide ? Gap.xl : Gap.l;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section == null ? '' : 'SECTION ${section.number} · ${index + 1} / ${list.length}',
              style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1),
            ),
            Text(info?.title ?? widget.lessonId, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: list.isEmpty ? 0 : (index + 1) / list.length,
            minHeight: 3,
            color: accent,
            backgroundColor: c.surfaceHi,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: EdgeInsets.fromLTRB(gutter, Gap.l, gutter, Gap.xl),
              children: [
                if (info != null && info.subtitle.isNotEmpty) ...[
                  SectionTag(info.subtitle, color: accent),
                  const SizedBox(height: Gap.m),
                ],
                if (intro.isNotEmpty) BitSays(lines: intro, mood: widget.bitMood),
                const SizedBox(height: Gap.xl),
                for (final w in widget.children) ...[w, const SizedBox(height: Gap.l)],
                if (keyIdea.isNotEmpty) ...[
                  const SizedBox(height: Gap.s),
                  KeyIdea(keyIdea, color: accent),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _NavBar(lessonId: widget.lessonId, accent: accent),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.lessonId, required this.accent});
  final String lessonId;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final prev = prevInSection(lessonId);
    final next = nextInSection(lessonId);
    final info = lessonById(lessonId);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(Gap.l, Gap.s, Gap.l, Gap.s),
        decoration: BoxDecoration(color: c.bg, border: Border(top: BorderSide(color: c.line))),
        child: Row(
          children: [
            OutlinedButton.icon(
              onPressed: prev == null ? () => Navigator.of(context).maybePop() : () => replaceLesson(context, prev.id),
              icon: const Icon(Icons.chevron_left),
              label: Text(prev == null ? 'Back' : 'Previous'),
            ),
            const Spacer(),
            FilledButton.icon(
              key: const ValueKey('lesson-next'),
              style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: c.bg),
              onPressed: () {
                AppScope.read(context).markDone(lessonId);
                if (next != null) {
                  replaceLesson(context, next.id);
                } else if (info != null) {
                  replaceQuiz(context, sectionOf(info).quizId);
                } else {
                  Navigator.of(context).maybePop();
                }
              },
              icon: Icon(next == null ? Icons.quiz_outlined : Icons.chevron_right),
              label: Text(next == null ? 'Quiz time' : 'Next'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown for lessons whose screen hasn't been built yet.
class PlaceholderLesson extends StatelessWidget {
  const PlaceholderLesson({super.key, required this.lessonId});
  final String lessonId;

  @override
  Widget build(BuildContext context) => LessonScaffold(
        lessonId: lessonId,
        children: const [
          DemoCard(child: Text('This lesson is being built.')),
        ],
      );
}
