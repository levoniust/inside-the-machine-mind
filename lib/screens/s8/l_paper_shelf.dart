import 'package:flutter/material.dart';

import '../../app/nav.dart';
import '../../app/theme.dart';
import '../../content/facts.dart';
import '../../content/papers.dart';
import '../../core/models.dart';
import '../../core/progress.dart';
import '../../widgets/lesson_scaffold.dart';
import 'paper_screen.dart';

/// The paper shelf: every annotated paper, grouped by era, with read marks.
/// Easter egg: swipe up, up, down, down on the shelf sign → a hidden paper.
class LPaperShelfScreen extends StatelessWidget {
  const LPaperShelfScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const LessonScaffold(lessonId: 'l_paper_shelf', children: [_ShelfSign(), _Shelf()]);
}

class _ShelfSign extends StatefulWidget {
  const _ShelfSign();

  @override
  State<_ShelfSign> createState() => _ShelfSignState();
}

class _ShelfSignState extends State<_ShelfSign> {
  static const _code = ['u', 'u', 'd', 'd'];
  final List<String> _swipes = [];

  void _swipe(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    if (v.abs() < 100) return;
    _swipes.add(v < 0 ? 'u' : 'd');
    if (_swipes.length > _code.length) _swipes.removeAt(0);
    if (_swipes.join() == _code.join()) {
      _swipes.clear();
      AppScope.read(context).markEgg('konami');
      showDialog<void>(context: context, builder: (_) => const _SecretPaper());
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final p = AppScope.progress(context);
    final all = [for (final g in paperGroups) ...g.papers];
    final read = all.where((x) => p.isDone(PaperScreen.readKey(x))).length;
    return GestureDetector(
      key: const ValueKey('shelf-sign'),
      onVerticalDragEnd: _swipe,
      child: Container(
        padding: const EdgeInsets.all(Gap.m),
        decoration: BoxDecoration(
          color: c.surfaceHi,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.section(8).withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Icon(Icons.menu_book, color: c.section(8)),
            const SizedBox(width: Gap.m),
            Expanded(
              child: Text('${all.length} papers on the shelf', style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            Text('$read read', style: AppText.mono.copyWith(color: c.section(8))),
          ],
        ),
      ),
    );
  }
}

class _Shelf extends StatelessWidget {
  const _Shelf();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final p = AppScope.progress(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final g in paperGroups)
          if (g.papers.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: Gap.m, bottom: Gap.s),
              child: Text(
                g.title.toUpperCase(),
                style: AppText.mono.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: c.section(8),
                ),
              ),
            ),
            for (final paper in g.papers) _PaperTile(paper: paper, read: p.isDone(PaperScreen.readKey(paper))),
          ],
      ],
    );
  }
}

class _PaperTile extends StatelessWidget {
  const _PaperTile({required this.paper, required this.read});
  final Paper paper;
  final bool read;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: Gap.s),
      child: ListTile(
        key: ValueKey('paper-${paper.sourceId}'),
        onTap: () => openPage(context, PaperScreen(paper: paper), '/paper/${paper.sourceId}'),
        leading: Icon(read ? Icons.check_circle : Icons.article_outlined, color: read ? c.lime : c.section(8)),
        title: Text(paper.short, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(sources[paper.sourceId]?.title ?? paper.oneIdea, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Text(paper.year, style: AppText.mono.copyWith(color: c.textDim, fontSize: 12)),
      ),
    );
  }
}

class _SecretPaper extends StatelessWidget {
  const _SecretPaper();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return AlertDialog(
      title: const Text('Attention Is All Bit Needs'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bit et al. · a workbench somewhere · 2026',
            style: AppText.mono.copyWith(color: c.textDim, fontSize: 12),
          ),
          const SizedBox(height: Gap.m),
          const Text(
            'Abstract: We show that a small robot, given enough attention (and an occasional pat on the head), '
            'outperforms all baselines at finding hidden pages. Limitations: n = 1. Code: you just ran it.',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Accepted at NeurIPS (Bit\'s Notes)'),
        ),
      ],
    );
  }
}
