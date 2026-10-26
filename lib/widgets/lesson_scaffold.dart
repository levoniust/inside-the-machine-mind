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
      if (mounted) AppScope.read(context).setLast(widget.lessonId, routeTrack(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final info = lessonById(widget.lessonId);
    final track = routeTrack(context);
    final section = info == null ? null : trackOf(info, track);
    final accent = c.section(section?.number ?? 0);
    final list = section?.lessons ?? const [];
    final index = list.indexWhere((l) => l.id == widget.lessonId);
    final text = narrationFor(widget.lessonId);
    final intro = widget.intro ?? text.intro;
    final keyIdea = widget.keyIdea ?? text.keyIdea;
    final screen = MediaQuery.sizeOf(context);
    final wide = screen.width >= 600;
    final landscape = screen.width > screen.height && screen.width >= 900;
    final gutter = wide ? Gap.xl : Gap.l;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section == null ? '' : '${section.label.toUpperCase()} · ${index + 1} / ${list.length}',
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
            // On wide-but-short screens (tablet landscape) a narrower column keeps square demos on screen.
            constraints: BoxConstraints(maxWidth: landscape ? 600 : 760),
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
                if (keyIdea.isNotEmpty) ...[const SizedBox(height: Gap.s), KeyIdea(keyIdea, color: accent)],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _NavBar(lessonId: widget.lessonId, track: section?.number, accent: accent),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.lessonId, required this.track, required this.accent});
  final String lessonId;
  final int? track;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final prev = prevInSection(lessonId, track);
    final next = nextInSection(lessonId, track);
    final info = lessonById(lessonId);
    final quizId = info == null ? '' : trackOf(info, track).quizId;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(Gap.l, Gap.s, Gap.l, Gap.s),
        decoration: BoxDecoration(
          color: c.bg,
          border: Border(top: BorderSide(color: c.line)),
        ),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Row(
              children: [
                Flexible(
                  child: OutlinedButton.icon(
                    onPressed: prev == null
                        ? () => Navigator.of(context).maybePop()
                        : () => replaceLesson(context, prev.id, track: track),
                    icon: const Icon(Icons.chevron_left),
                    label: FittedBox(child: Text(prev == null ? 'Back' : 'Previous')),
                  ),
                ),
                const SizedBox(width: Gap.m),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    heightFactor: 1,
                    child: FilledButton.icon(
                      key: const ValueKey('lesson-next'),
                      style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: c.bg),
                      onPressed: () {
                        AppScope.read(context).markDone(lessonId);
                        if (next != null) {
                          replaceLesson(context, next.id, track: track);
                        } else if (quizId.isNotEmpty) {
                          replaceQuiz(context, quizId);
                        } else {
                          Navigator.of(context).maybePop();
                        }
                      },
                      icon: Icon(
                        next != null
                            ? Icons.chevron_right
                            : quizId.isNotEmpty
                            ? Icons.quiz_outlined
                            : Icons.check,
                      ),
                      label: FittedBox(
                        child: Text(
                          next != null
                              ? 'Next'
                              : quizId.isNotEmpty
                              ? 'Quiz time'
                              : 'Done',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
    children: const [DemoCard(child: Text('This lesson is being built.'))],
  );
}
