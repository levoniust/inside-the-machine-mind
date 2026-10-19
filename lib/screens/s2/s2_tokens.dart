import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/bpe.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 2 · "Chopping text into tokens": the byte-pair-encoding merge game on a tiny corpus.
/// Facts: TR-BPE, TR-TOKEN-WORDS.
class S2TokensScreen extends StatelessWidget {
  const S2TokensScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's2_tokens',
        children: [_MergeGame()],
      );
}

const bpeCorpus = 'the sky is blue the sea is blue the sky is big why is the sky blue';

class _MergeGame extends StatefulWidget {
  const _MergeGame();

  @override
  State<_MergeGame> createState() => _MergeGameState();
}

class _MergeGameState extends State<_MergeGame> {
  BpeState _bpe = BpeState(bpeCorpus);
  late final int _start = BpeState(bpeCorpus).tokenCount;

  void _merge((String, String) p) => setState(() => _bpe.merge(p));

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final pairs = _bpe.pairCounts();
    final top = pairs.take(4).toList();
    final palette = [c.violet, c.cyan, c.magenta, c.lime, c.amber];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          title: 'The merge game',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Our tiny library, chopped into pieces. "·" is a space. Glue the most common pair of side-by-side pieces into a new token.',
                  style: TextStyle(color: c.textDim)),
              const SizedBox(height: Gap.m),
              Wrap(
                spacing: 3,
                runSpacing: 6,
                children: [
                  for (final w in _bpe.words)
                    for (var i = 0; i < w.length; i++)
                      Container(
                        margin: EdgeInsets.only(right: i == w.length - 1 ? 8 : 0),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                        decoration: BoxDecoration(
                          color: palette[w[i].length.clamp(1, 5) - 1].withValues(alpha: 0.10 + 0.08 * w[i].length.clamp(1, 5)),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: palette[w[i].length.clamp(1, 5) - 1].withValues(alpha: 0.6)),
                        ),
                        child: Text(w[i].replaceAll(' ', '·'), style: AppText.mono.copyWith(color: c.text, fontSize: 13)),
                      ),
                ],
              ),
              const SizedBox(height: Gap.m),
              StatGrid(
                columns: 3,
                children: [
                  StatTile(key: const ValueKey('bpe-count'), label: 'Tokens', value: '${_bpe.tokenCount}', color: c.violet),
                  StatTile(label: 'Started with', value: '$_start'),
                  StatTile(label: 'Merges', value: '${_bpe.merges.length}', color: c.lime),
                ],
              ),
              const SizedBox(height: Gap.m),
              if (top.isNotEmpty) ...[
                Text('Most common neighbours, tap one to merge it:', style: TextStyle(color: c.textDim, fontSize: 13)),
                const SizedBox(height: Gap.xs),
                Wrap(
                  spacing: Gap.s,
                  runSpacing: Gap.s,
                  children: [
                    for (var i = 0; i < top.length; i++)
                      ActionChip(
                        key: ValueKey('bpe-pair-$i'),
                        avatar: i == 0 ? Icon(Icons.star, size: 16, color: c.amber) : null,
                        label: Text('${top[i].key.$1.replaceAll(' ', '·')} + ${top[i].key.$2.replaceAll(' ', '·')}  ×${top[i].value}',
                            style: AppText.mono),
                        onPressed: () => _merge(top[i].key),
                      ),
                  ],
                ),
              ] else
                Text('In this little example, every word is now one token!', style: TextStyle(color: c.lime, fontWeight: FontWeight.w700)),
              const SizedBox(height: Gap.s),
              Wrap(
                spacing: Gap.s,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    key: const ValueKey('bpe-auto'),
                    style: FilledButton.styleFrom(backgroundColor: c.violet, foregroundColor: Colors.white),
                    onPressed: top.isEmpty ? null : () => _merge(top.first.key),
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Merge the top pair'),
                  ),
                  TextButton(onPressed: () => setState(() => _bpe = BpeState(bpeCorpus)), child: const Text('Start over')),
                ],
              ),
              if (_bpe.merges.isNotEmpty) ...[
                const SizedBox(height: Gap.s),
                Text('New tokens: ${_bpe.merges.map((m) => m.replaceAll(' ', '·')).join('  ')}',
                    style: AppText.mono.copyWith(color: c.textDim, fontSize: 12)),
              ],
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
        DemoCard(
          title: 'That\'s really how it works',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TermText(
                'Real [[tokenizers|tokenizer]] play this exact game on a giant pile of text, tens of thousands of times. Common '
                'words end up as one token; rare words stay split into pieces. The result is the model\'s [[vocabulary]].',
              ),
              const SizedBox(height: Gap.m),
              const Row(
                children: [
                  Expanded(child: FactCard(value: '50,257', label: 'tokens in GPT-2\'s vocabulary, built with this merge game (BPE)', factId: 'TR-BPE')),
                  SizedBox(width: Gap.m),
                  Expanded(child: FactCard(value: '≈ 4 letters', label: 'per token on average in English', factId: 'TR-TOKEN-WORDS')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
