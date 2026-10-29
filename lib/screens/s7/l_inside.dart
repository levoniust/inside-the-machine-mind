import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Looking inside the model: messy neurons vs cleaner features (sparse autoencoders), the Golden Gate Claude dial,
/// and "Light up a feature". Facts INS-* (Anthropic's monosemanticity papers and post, OpenAI's SAE paper).
class LInsideScreen extends StatelessWidget {
  const LInsideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.of(context).section(7);
    return LessonScaffold(
      lessonId: 'l_inside',
      children: [
        const _Messy(),
        const _LightUp(),
        const _Dial(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FactCard(
                value: '~34 million',
                label: 'features found in Claude 3 Sonnet by the biggest of three dictionaries',
                factId: 'INS-SCALE',
                color: accent,
              ),
            ),
            const SizedBox(width: Gap.m),
            Expanded(
              child: FactCard(
                value: '16 million',
                label: 'features in OpenAI\'s dictionary for GPT-4',
                factId: 'INS-OPENAI',
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

class _Messy extends StatefulWidget {
  const _Messy();

  @override
  State<_Messy> createState() => _MessyState();
}

class _MessyState extends State<_Messy> {
  bool _split = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(7);
    const topics = ['academic citations', 'English dialogue', 'web requests (HTTP)', 'Korean text'];
    final colors = [c.cyan, c.amber, c.magenta, c.lime];
    Widget chip(String t, Color col) => Container(
      padding: const EdgeInsets.symmetric(horizontal: Gap.s, vertical: 4),
      decoration: BoxDecoration(color: col.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(20)),
      child: Text(t, style: const TextStyle(fontSize: 12)),
    );
    return DemoCard(
      title: 'One neuron, four jobs',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TermText(
            'It\'s like a brain scan for a [[model]]. The trouble: a single neuron rarely means one thing. In a small '
            'language model, this one fired for all of these:',
          ),
          const SizedBox(height: Gap.m),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _split
                ? Wrap(
                    key: const ValueKey('ins-features'),
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      for (var i = 0; i < topics.length; i++)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: colors[i],
                              child: Text('f${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                            ),
                            const SizedBox(height: 2),
                            chip(topics[i], colors[i]),
                          ],
                        ),
                    ],
                  )
                : Column(
                    key: const ValueKey('ins-neuron'),
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: accent,
                        child: const Icon(Icons.circle_outlined, color: Colors.white),
                      ),
                      const SizedBox(height: Gap.s),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: [for (var i = 0; i < topics.length; i++) chip(topics[i], colors[i])],
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: Gap.m),
          FilledButton.tonal(
            key: const ValueKey('ins-split'),
            onPressed: () => setState(() => _split = !_split),
            child: Text(_split ? 'Back to the messy neuron' : 'Untangle it'),
          ),
          const SizedBox(height: Gap.s),
          TermText(
            _split
                ? 'A **sparse autoencoder** learns a "dictionary": far more features than neurons, each firing for one '
                      'idea, and only a few on at once. In the first study it turned 512 neurons into 4,096 features, '
                      'and bigger dictionaries kept finding more.'
                : 'Researchers think the model packs more ideas than it has neurons by sharing them (superposition). '
                      'Tap to untangle.',
            key: ValueKey('ins-explain-$_split'),
          ),
          const SizedBox(height: Gap.s),
          FactCard(
            value: _split ? '512 → 4,096' : '1 neuron, 4 jobs',
            label: _split ? 'neurons → features in the first study' : 'one neuron in a small model',
            factId: _split ? 'INS-SAE' : 'INS-POLY',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------
// The game. Bars are illustrations of the pattern the paper reports (strong on the bridge, in any language; weak on
// other San Francisco landmarks; nothing elsewhere), not measured values.

class _Sentence {
  const _Sentence(this.text, this.level, this.why);
  final String text, why;

  /// 0 = silent, 1 = weak, 2 = strong.
  final int level;
}

const _sentences = [
  _Sentence('We drove across the Golden Gate Bridge at sunset.', 2, 'A direct mention: the feature\'s strongest kind.'),
  _Sentence('My cat sleeps on the sofa all afternoon.', 0, 'Nothing to do with the bridge.'),
  _Sentence(
    'El puente Golden Gate es de color naranja.',
    2,
    'Same idea in Spanish: many features work across languages.',
  ),
  _Sentence('Alcatraz and Coit Tower are on every visitor\'s list.', 1, 'Other San Francisco landmarks: a weak glow.'),
  _Sentence('The recipe needs two cups of flour.', 0, 'Nothing to do with the bridge.'),
  _Sentence(
    'Fog rolled in around the famous orange suspension bridge by San Francisco Bay.',
    2,
    'No name, but clearly the bridge.',
  ),
];

class _LightUp extends StatefulWidget {
  const _LightUp();

  @override
  State<_LightUp> createState() => _LightUpState();
}

class _LightUpState extends State<_LightUp> {
  final _guess = <int>{};
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(7);
    final right = [for (var i = 0; i < _sentences.length; i++) (_sentences[i].level > 0) == _guess.contains(i)]
        .where((x) => x)
        .length;
    return DemoCard(
      title: 'Light up a feature: "Golden Gate Bridge"',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Tap every sentence you think would make this feature fire, then reveal.'),
          const SizedBox(height: Gap.s),
          for (var i = 0; i < _sentences.length; i++) ...[
            InkWell(
              key: ValueKey('ins-sent-$i'),
              onTap: _revealed ? null : () => setState(() => _guess.contains(i) ? _guess.remove(i) : _guess.add(i)),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(Gap.s),
                decoration: BoxDecoration(
                  border: Border.all(color: _guess.contains(i) ? accent : c.line, width: _guess.contains(i) ? 2 : 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _guess.contains(i) ? Icons.lightbulb : Icons.lightbulb_outline,
                          size: 18,
                          color: _guess.contains(i) ? accent : c.textDim,
                        ),
                        const SizedBox(width: Gap.s),
                        Expanded(child: Text(_sentences[i].text)),
                      ],
                    ),
                    if (_revealed) ...[
                      const SizedBox(height: Gap.xs),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          key: ValueKey('ins-bar-$i'),
                          value: [0.02, 0.3, 1.0][_sentences[i].level],
                          minHeight: 8,
                          color: c.amber,
                          backgroundColor: c.surfaceHi,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(_sentences[i].why, style: TextStyle(color: c.textDim, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: Gap.xs),
          ],
          const SizedBox(height: Gap.xs),
          if (!_revealed)
            FilledButton(
              key: const ValueKey('ins-reveal'),
              style: FilledButton.styleFrom(backgroundColor: accent),
              onPressed: () => setState(() => _revealed = true),
              child: const Text('Reveal the activations'),
            )
          else ...[
            Text(
              '$right of ${_sentences.length} right.',
              key: const ValueKey('ins-score'),
              style: TextStyle(color: accent, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              'Bars show the pattern the researchers report, not exact measurements.',
              style: TextStyle(color: c.textDim, fontSize: 12),
            ),
            TextButton(
              onPressed: () => setState(() {
                _revealed = false;
                _guess.clear();
              }),
              child: const Text('Try again'),
            ),
          ],
          const SizedBox(height: Gap.s),
          const FactCard(
            value: 'strong · weak · off',
            label: 'the bridge, other San Francisco sights, everything else',
            factId: 'INS-GGB',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------

class _Dial extends StatefulWidget {
  const _Dial();

  @override
  State<_Dial> createState() => _DialState();
}

class _DialState extends State<_Dial> {
  double _x = 1;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(7);
    final clamped = _x >= 10;
    return DemoCard(
      title: 'Turn the feature up: Golden Gate Claude',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TermText(
            'Finding a feature means you can also turn it up. In 2024 Anthropic clamped the bridge feature to 10× its '
            'highest natural value and let people chat with the result for a short time.',
          ),
          const SizedBox(height: Gap.s),
          LabeledSlider(
            key: const ValueKey('ins-dial'),
            label: 'Bridge feature strength',
            value: _x,
            min: 1,
            max: 10,
            divisions: 9,
            format: (v) => v <= 1 ? 'normal' : '${v.round()}×',
            color: accent,
            onChanged: (v) => setState(() => _x = v),
          ),
          Text('You: "How should I spend \$10?"', style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.xs),
          Container(
            key: ValueKey('ins-reply-$clamped'),
            padding: const EdgeInsets.all(Gap.s),
            decoration: BoxDecoration(
              color: (clamped ? c.amber : accent).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              clamped
                  ? 'Golden Gate Claude recommended driving across the Golden Gate Bridge and paying the toll. Asked what it '
                        'imagines it looks like, it said: the Golden Gate Bridge.'
                  : _x <= 1
                  ? 'A normal answer: everyday ideas for the money.'
                  : 'Somewhere in between, the bridge starts to creep in. Slide all the way to 10×.',
            ),
          ),
          const SizedBox(height: Gap.s),
          const TermText(
            'This is the same idea as the [[control vectors|control vector]] in "Steering a model", but aimed at one '
            'named feature. It isn\'t a prompt or fine-tuning: it changes the model\'s inner activity directly.',
          ),
          const SizedBox(height: Gap.s),
          const FactCard(value: '10×', label: 'the clamp that made Golden Gate Claude', factId: 'INS-GGC'),
        ],
      ),
    );
  }
}
