import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Build your own notes helper: the RAG pipeline step by step with the real settings of an anonymized home build,
/// where one answer's time goes, and "Tune the helper", replaying the three fixes that were actually measured.
/// Facts NH-* (SRC-HOMELAB, Open WebUI docs).
class LNotesHelperScreen extends StatelessWidget {
  const LNotesHelperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.of(context).section(7);
    return LessonScaffold(
      lessonId: 'l_notes_helper',
      children: [
        const _Pipeline(),
        const _WhereTimeGoes(),
        const _Tune(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FactCard(
                value: '573 s → 20 s',
                label: 'one answer, first try vs after three fixes',
                factId: 'NH-FAST',
                color: accent,
              ),
            ),
            const SizedBox(width: Gap.m),
            Expanded(
              child: FactCard(
                value: '5 × 1,000',
                label: 'passages × tokens: about 5,000 tokens of reading before the model writes a word',
                factId: 'NH-TOPK',
                color: accent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------

class _Step {
  const _Step(this.icon, this.title, this.what, this.real);
  final IconData icon;
  final String title, what, real;
}

const _steps = [
  _Step(
    Icons.folder_copy_outlined,
    'Collect',
    'Gather what the helper may know: manuals, guides, your own notes. Clean them into plain text first.',
    'Official docs, papers, guides, hardware pages and forum Q&A: 1,754 cleaned files in 5 knowledge bases.',
  ),
  _Step(
    Icons.content_cut,
    'Chunk',
    'Cut each file into small overlapping pieces, so a search can hand back just the part that matters.',
    'Pieces of 1,500 characters, each overlapping the last by 150, cut at headings. Every piece keeps its file\'s title.',
  ),
  _Step(
    Icons.scatter_plot_outlined,
    'Embed',
    'A small [[embedding]] model turns every piece into a list of numbers, so pieces with similar meaning land close together.',
    'A small open embedding model (bge-base-en-v1.5) that runs on an ordinary CPU.',
  ),
  _Step(
    Icons.search,
    'Search',
    'Turn the question into numbers too and find the nearest pieces. Hybrid search also matches plain keywords, which catches part numbers and names.',
    'Hybrid search (keywords + meaning), top 10 pieces.',
  ),
  _Step(
    Icons.sort,
    'Rerank',
    'A second, more careful model reads the question next to each hit and re-orders them. Only the best few go on.',
    'A reranker on the CPU keeps the best 6 of the 10 (later: best 3 of 5).',
  ),
  _Step(
    Icons.chat_outlined,
    'Answer',
    'The chat model reads the question plus the chosen pieces and answers, with numbered sources you can open.',
    'A 27B model on a 16 GB GPU, told to cite its sources.',
  ),
];

class _Pipeline extends StatefulWidget {
  const _Pipeline();

  @override
  State<_Pipeline> createState() => _PipelineState();
}

class _PipelineState extends State<_Pipeline> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(7);
    final s = _steps[_i];
    return DemoCard(
      title: 'Six steps from notes to answers (RAG)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < _steps.length; i++)
                ChoiceChip(
                  key: ValueKey('nh-step-$i'),
                  avatar: Icon(_steps[i].icon, size: 16, color: i == _i ? Colors.white : accent),
                  label: Text('${i + 1}. ${_steps[i].title}'),
                  selected: i == _i,
                  selectedColor: accent,
                  labelStyle: TextStyle(color: i == _i ? Colors.white : c.text),
                  onSelected: (_) => setState(() => _i = i),
                ),
            ],
          ),
          const SizedBox(height: Gap.m),
          TermText(s.what, key: ValueKey('nh-what-$_i')),
          const SizedBox(height: Gap.s),
          Container(
            padding: const EdgeInsets.all(Gap.s),
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(8)),
            child: Text('In the real build: ${s.real}', style: TextStyle(color: c.text, fontSize: 13)),
          ),
          const SizedBox(height: Gap.s),
          StepControls(step: _i, count: _steps.length, onStep: (i) => setState(() => _i = i)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------

class _WhereTimeGoes extends StatelessWidget {
  const _WhereTimeGoes();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(7);
    return DemoCard(
      title: 'Where 65 seconds went',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('A typical answer after the first fixes: 65 s in total, 58 s of it before the first word.'),
          const SizedBox(height: Gap.s),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 26,
              child: Row(
                children: [
                  Expanded(
                    flex: 58,
                    child: Container(
                      color: c.amber,
                      alignment: Alignment.center,
                      child: const Text(
                        'waiting: 58 s',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Expanded(flex: 7, child: Container(color: accent)),
                ],
              ),
            ),
          ),
          const SizedBox(height: Gap.xs),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'writing: ~7 s',
              style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: Gap.s),
          const TermText(
            'The wait was an extra model call that rewrites your question into search queries, the search, reranking on '
            'the CPU, and reading ~20,000 [[tokens|token]] of passages. A faster chat model would only have sped up the '
            'short writing part.',
          ),
          const SizedBox(height: Gap.s),
          const FactCard(value: '~90%', label: 'of each answer\'s time came before the first word', factId: 'NH-WAIT'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------
// The game: three rounds, each the state of the helper at that point. One option per round is the fix that was
// really made and measured; the others are plausible ideas with the reason they wouldn't have helped.

class _Option {
  const _Option(this.text, this.why, {this.real = false});
  final String text, why;
  final bool real;
}

class _Round {
  const _Round(this.state, this.options, this.result, this.factId);
  final String state;
  final List<_Option> options;
  final String result, factId;
}

const _rounds = [
  _Round(
    'First try: a big model on the workstation searches all 5 knowledge bases. One question takes 573 seconds.',
    [
      _Option('Add more documents so it knows more', 'More to search and rerank makes the wait longer, not shorter.'),
      _Option(
        'Run it on a 27B model with a GPU to itself',
        'The real fix. The big model kept most of its weights in system RAM, so reading pages of passages was slow; a 27B model that fits on one card reads them far faster.',
        real: true,
      ),
      _Option(
        'Ask shorter questions',
        'The question is a few words; the time goes into the passages the helper reads.',
      ),
    ],
    '573 s → about 90 s per answer.',
    'NH-FIRST',
  ),
  _Round(
    'Now a 25-question test with hand-checked answers: score 0.80, median 74 s. It misses beginner basics because search often skips the short FAQ notes.',
    [
      _Option(
        'Switch to a bigger model',
        'Writing took only 5-10 s, and a bigger model can\'t use a fact that search never found.',
      ),
      _Option('Turn off the source list', 'Sources are how you check the answer; removing them saves almost nothing.'),
      _Option(
        'Put five hand-checked beginner notes in its instructions',
        'The real fix. The key facts are now always in front of the model, whether search finds them or not.',
        real: true,
      ),
    ],
    'Score 0.80 → 0.91, median 74 s → 65 s. (The test questions came from those notes, so it favours this change.)',
    'NH-NOTES',
  ),
  _Round(
    'Score 0.91 but 65 s per answer, almost all of it before the first word.',
    [
      _Option(
        'Skip the query-rewriting call; rerank the top 5 to the best 3',
        'The real fix. One model call fewer, and half as much text to rerank and read.',
        real: true,
      ),
      _Option('Read more passages: top 20', 'Twice the reranking and reading: slower, and more noise for the model.'),
      _Option(
        'Buy a faster GPU',
        'Much of the wait was the reranker on the CPU and the extra model call, not the GPU.',
      ),
    ],
    'Median 65 s → 20 s (slowest 93 s → 26 s); score 0.89, within the grader\'s noise.',
    'NH-FAST',
  ),
];

class _Tune extends StatefulWidget {
  const _Tune();

  @override
  State<_Tune> createState() => _TuneState();
}

class _TuneState extends State<_Tune> {
  int _round = 0;
  final _picked = <int?>[null, null, null];
  int _firstTry = 0;

  void _pick(int option) {
    setState(() {
      if (_picked[_round] == null && _rounds[_round].options[option].real) _firstTry++;
      _picked[_round] = option;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(7);
    final r = _rounds[_round];
    final picked = _picked[_round];
    final solved = picked != null && r.options[picked].real;
    final done = _round == _rounds.length - 1 && solved;
    return DemoCard(
      title: 'Tune the helper (round ${_round + 1} of ${_rounds.length})',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            r.state,
            key: ValueKey('nh-state-$_round'),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: Gap.s),
          Text('What would you change?', style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.xs),
          for (var i = 0; i < r.options.length; i++) ...[
            OutlinedButton(
              key: ValueKey('nh-opt-$_round-$i'),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(Gap.s),
                side: BorderSide(
                  color: picked == i ? (r.options[i].real ? accent : c.amber) : c.line,
                  width: picked == i ? 2 : 1,
                ),
              ),
              onPressed: solved ? null : () => _pick(i),
              child: Text(r.options[i].text, style: TextStyle(color: c.text)),
            ),
            const SizedBox(height: Gap.xs),
          ],
          if (picked != null) ...[
            const SizedBox(height: Gap.xs),
            Container(
              key: const ValueKey('nh-why'),
              padding: const EdgeInsets.all(Gap.s),
              decoration: BoxDecoration(
                color: (solved ? accent : c.amber).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                solved ? '${r.options[picked].why}\nMeasured: ${r.result}' : '${r.options[picked].why} Try another.',
                style: TextStyle(color: c.text),
              ),
            ),
          ],
          if (solved && !done) ...[
            const SizedBox(height: Gap.s),
            FilledButton(
              key: const ValueKey('nh-next'),
              style: FilledButton.styleFrom(backgroundColor: accent),
              onPressed: () => setState(() => _round++),
              child: const Text('Next round'),
            ),
          ],
          if (done) ...[
            const SizedBox(height: Gap.s),
            Text(
              'Found the real fix first time: $_firstTry of ${_rounds.length}. The lesson of all three: measure where '
              'the time and the misses come from before changing anything.',
              key: const ValueKey('nh-done'),
              style: TextStyle(color: accent, fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }
}
