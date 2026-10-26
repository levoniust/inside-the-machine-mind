import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../content/glossary.dart';

/// Searchable list of every engineering term with its everyday translation.
class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  String _q = '';
  int _section = 0;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final q = _q.toLowerCase();
    final items = glossary.where((g) {
      if (_section != 0 && (_section == 6 ? g.section < 6 : g.section != _section)) return false;
      if (q.isEmpty) return true;
      return g.term.toLowerCase().contains(q) ||
          g.everyday.toLowerCase().contains(q) ||
          g.aliases.any((a) => a.toLowerCase().contains(q));
    }).toList()
      ..sort((a, b) => a.term.toLowerCase().compareTo(b.term.toLowerCase()));
    return Scaffold(
      appBar: AppBar(title: const Text('Glossary')),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(Gap.l, Gap.s, Gap.l, Gap.s),
                  child: TextField(
                    key: const ValueKey('glossary-search'),
                    decoration: InputDecoration(
                      hintText: 'Search a word (e.g. "token" or "knob")',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: c.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c.line)),
                    ),
                    onChanged: (v) => setState(() => _q = v),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: Gap.l),
                  child: Row(
                    children: [
                      for (final (i, label) in const [(0, 'All'), (1, 'Hardware'), (2, 'Training'), (3, 'Inference'), (5, 'In your life'), (6, 'Lab')])
                        Padding(
                          padding: const EdgeInsets.only(right: Gap.s),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: _section == i,
                            selectedColor: c.section(i).withValues(alpha: 0.25),
                            onSelected: (_) => setState(() => _section = i),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: Gap.s),
                Expanded(
                  child: items.isEmpty
                      ? Center(child: Text('No match. Try another word!', style: TextStyle(color: c.textDim)))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(Gap.l, 0, Gap.l, Gap.xl),
                          itemCount: items.length,
                          separatorBuilder: (_, _) => Divider(color: c.line, height: 1),
                          itemBuilder: (context, i) {
                            final g = items[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: Gap.m),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(TextSpan(children: [
                                    TextSpan(text: g.term, style: TextStyle(color: c.section(g.section), fontWeight: FontWeight.w800, fontSize: 17)),
                                    TextSpan(text: '  =  ${g.everyday}', style: TextStyle(color: c.lime, fontWeight: FontWeight.w600)),
                                  ])),
                                  const SizedBox(height: Gap.xs),
                                  Text(g.definition, style: TextStyle(color: c.text)),
                                ],
                              ),
                            );
                          },
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
