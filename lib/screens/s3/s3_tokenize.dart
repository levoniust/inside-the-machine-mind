import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/mini_tokenizer.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 3 · "Your words become tokens": a live tokenizer playground (mini vocabulary, greedy
/// longest match). Facts: TR-TOKEN-WORDS, TR-BPE, TR-LLAMA3-ARCH (128K vocabulary).
class S3TokenizeScreen extends StatelessWidget {
  const S3TokenizeScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's3_tokenize',
        children: [_Playground()],
      );
}

class _Playground extends StatefulWidget {
  const _Playground();

  @override
  State<_Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<_Playground> {
  final tok = MiniTokenizer();
  late final TextEditingController _text = TextEditingController(text: 'Why is the sky blue?');

  static const _examples = ['Why is the sky blue?', 'unbelievably amazing', 'Transformers learn from tokens', 'The cat had tea 🍵'];

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final tokens = tok.encode(_text.text);
    final words = _text.text.trim().isEmpty ? 0 : _text.text.trim().split(RegExp(r'\s+')).length;
    final palette = [c.magenta, c.cyan, c.violet, c.lime, c.amber];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          title: 'Type anything',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const ValueKey('tok-input'),
                controller: _text,
                maxLength: 120,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: c.surfaceHi,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c.line)),
                ),
                onChanged: (_) => setState(() {}),
              ),
              Wrap(
                spacing: Gap.s,
                runSpacing: Gap.s,
                children: [
                  for (final e in _examples)
                    ActionChip(
                      label: Text(e),
                      onPressed: () => setState(() => _text.text = e),
                    ),
                ],
              ),
              const SizedBox(height: Gap.l),
              Text('What the model actually sees:', style: TextStyle(color: c.textDim)),
              const SizedBox(height: Gap.s),
              Wrap(
                key: const ValueKey('tok-chips'),
                spacing: 4,
                runSpacing: 6,
                children: [
                  for (var i = 0; i < tokens.length; i++)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: palette[i % palette.length].withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: palette[i % palette.length].withValues(alpha: 0.6)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(tokens[i].$1.replaceAll(' ', '·'), style: AppText.mono.copyWith(color: c.text, fontSize: 14)),
                          Text(tokens[i].$2 < 0 ? '?' : '${tokens[i].$2}',
                              style: AppText.mono.copyWith(color: palette[i % palette.length], fontSize: 10)),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Gap.s),
              Text('· marks a space: most tokens carry the space in front of a word.', style: TextStyle(color: c.textDim, fontSize: 12)),
              const SizedBox(height: Gap.m),
              StatGrid(
                columns: 3,
                children: [
                  StatTile(label: 'Characters', value: '${_text.text.length}'),
                  StatTile(label: 'Words', value: '$words'),
                  StatTile(key: const ValueKey('tok-count'), label: 'Tokens', value: '${tokens.length}', color: c.magenta),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
        DemoCard(
          title: 'The real thing',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TermText(
                'This mini [[tokenizer]] knows ${tok.vocabularySize} pieces. Real ones learn their pieces from data with '
                'byte-pair encoding ([[BPE|tokenizer]]): GPT-2 knew 50,257, Llama 3 knows about 128,000. Common words '
                'become one token; rare words get split into pieces; emoji and other symbols become several tokens.',
                style: TextStyle(color: c.text),
              ),
              const SizedBox(height: Gap.m),
              const Row(
                children: [
                  Expanded(child: FactCard(value: '≈ ¾ word', label: 'per token, on average, in English', factId: 'TR-TOKEN-WORDS')),
                  SizedBox(width: Gap.m),
                  Expanded(child: FactCard(value: '128K', label: 'tokens in Llama 3\'s [[vocabulary]]', factId: 'TR-LLAMA3-ARCH')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
