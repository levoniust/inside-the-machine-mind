import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/nav.dart';
import '../../app/theme.dart';
import '../../content/facts.dart';
import '../../content/source_docs.dart';
import 'source_doc_screen.dart';

/// Every source behind the numbers in the app, with an offline copy to read.
/// Tap an entry to read it; long-press to copy its link.
class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final list = sources.values.toList();
    final withCopy = sourceDocs.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Sources')),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(Gap.l, Gap.s, Gap.l, Gap.xl),
              itemCount: list.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: Gap.l),
                    child: Text(
                      'Every number in this app was checked against these sources (October 2026). '
                      '${facts.length} facts, ${sources.length} sources. '
                      'Tap any source to read a copy of the original ($withCopy copies bundled, offline). '
                      'Long-press to copy a link.',
                      style: TextStyle(color: c.textDim),
                    ),
                  );
                }
                final s = list[i - 1];
                final doc = sourceDocs[s.id];
                return ListTile(
                  key: ValueKey('source-${s.id}'),
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    doc == null
                        ? Icons.description_outlined
                        : (doc.pdf != null ? Icons.menu_book_outlined : Icons.article_outlined),
                    color: doc == null ? c.textDim : c.cyan,
                  ),
                  title: Text(s.title, style: TextStyle(color: c.text, fontSize: 14)),
                  subtitle: doc == null
                      ? Text('no copy available', style: TextStyle(color: c.textDim, fontSize: 11))
                      : Text(doc.pdf != null ? 'tap to read · original PDF included' : 'tap to read',
                          style: TextStyle(color: c.textDim, fontSize: 11)),
                  onTap: doc == null
                      ? null
                      : () => openPage(context, SourceDocScreen(sourceId: s.id), '/source/${s.id}'),
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: doc?.url ?? s.url ?? s.title));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied')));
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
