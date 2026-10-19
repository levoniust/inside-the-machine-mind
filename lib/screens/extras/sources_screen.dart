import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../content/facts.dart';

/// Every source behind the numbers in the app. Long-press to copy a link.
class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final list = sources.values.toList();
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
                      '${facts.length} facts, ${sources.length} sources. Long-press a source to copy it.',
                      style: TextStyle(color: c.textDim),
                    ),
                  );
                }
                final s = list[i - 1];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.description_outlined, color: c.cyan),
                  title: Text(s.title, style: TextStyle(color: c.text, fontSize: 14)),
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: s.url ?? s.title));
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
