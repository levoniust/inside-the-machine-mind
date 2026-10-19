import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/toy_transformer.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 3 · "Picking the next word": temperature and top-p reshape the toy model's real
/// probabilities for "why is the sky ___"; roll the dice to sample and watch the tally.
class S3SamplingScreen extends StatelessWidget {
  const S3SamplingScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's3_sampling',
        children: [_Sampler()],
      );
}

/// Probabilities after temperature and top-p (nucleus) filtering, highest first.
List<MapEntry<String, double>> shapedProbabilities(Map<String, double> logits, double temperature, double topP) {
  final words = logits.keys.toList();
  final p = ToyTransformer.softmax([for (final w in words) logits[w]!], temperature: temperature);
  final list = [for (var i = 0; i < words.length; i++) MapEntry(words[i], p[i])]..sort((a, b) => b.value.compareTo(a.value));
  // Keep the smallest set of top words whose probabilities add up to at least topP.
  var sum = 0.0;
  final kept = <MapEntry<String, double>>[];
  for (final e in list) {
    kept.add(e);
    sum += e.value;
    if (sum >= topP) break;
  }
  final total = kept.fold<double>(0, (s, e) => s + e.value);
  return [for (final e in list) MapEntry(e.key, kept.contains(e) ? e.value / total : 0.0)];
}

class _Sampler extends StatefulWidget {
  const _Sampler();

  @override
  State<_Sampler> createState() => _SamplerState();
}

class _SamplerState extends State<_Sampler> {
  final logits = ToyTransformer().run().logits;
  final rnd = math.Random(7);
  double _temp = 1.0;
  double _topP = 1.0;
  final Map<String, int> _tally = {};
  String? _last;

  void _roll(int times) {
    final probs = shapedProbabilities(logits, _temp, _topP);
    setState(() {
      for (var k = 0; k < times; k++) {
        var r = rnd.nextDouble();
        String? pick;
        for (final e in probs) {
          r -= e.value;
          if (r <= 0 && e.value > 0) {
            pick = e.key;
            break;
          }
        }
        _last = pick ?? probs.first.key;
        _tally[_last!] = (_tally[_last!] ?? 0) + 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final probs = shapedProbabilities(logits, _temp, _topP);
    final rolls = _tally.values.fold<int>(0, (s, v) => s + v);
    final kept = probs.where((e) => e.value > 0).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          title: 'why is the sky ___ ?',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('The model\'s chances for each next word (from the toy model in the previous lesson):',
                  style: TextStyle(color: c.textDim)),
              const SizedBox(height: Gap.m),
              CompareBars(
                highlight: 0,
                color: c.magenta,
                items: [
                  for (final e in probs.take(8))
                    BarItem(e.key, e.value + 0.0001,
                        display: e.value == 0 ? 'cut' : '${(e.value * 100).toStringAsFixed(1)}%',
                        color: e.value == 0 ? c.line : null),
                ],
              ),
              const SizedBox(height: Gap.m),
              LabeledSlider(
                key: const ValueKey('sampling-temp'),
                label: 'Temperature (the creativity dial)',
                value: _temp,
                min: 0.1,
                max: 2.5,
                color: c.magenta,
                format: (v) => v.toStringAsFixed(2),
                onChanged: (v) => setState(() => _temp = v),
              ),
              Text(
                _temp < 0.5
                    ? 'Cold: the top word wins almost every time. Predictable, a bit boring.'
                    : (_temp > 1.5 ? 'Hot: unlikely words get a real chance. Creative… or nonsense.' : 'Balanced: mostly sensible, a little variety.'),
                key: const ValueKey('sampling-temp-note'),
                style: TextStyle(color: c.text, fontSize: 13),
              ),
              const SizedBox(height: Gap.s),
              LabeledSlider(
                key: const ValueKey('sampling-topp'),
                label: 'Top-p (only consider the likeliest words)',
                value: _topP,
                min: 0.3,
                max: 1.0,
                color: c.violet,
                format: (v) => '${(v * 100).round()}%',
                onChanged: (v) => setState(() => _topP = v),
              ),
              Text('Words still in the running: $kept of ${probs.length}', style: TextStyle(color: c.textDim, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
        DemoCard(
          title: 'Roll the dice',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _last == null ? '…' : '“why is the sky $_last”',
                    key: ValueKey('sampling-last-$rolls'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: c.magenta, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              const SizedBox(height: Gap.m),
              Wrap(
                spacing: Gap.s,
                runSpacing: Gap.s,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    key: const ValueKey('sampling-roll'),
                    style: FilledButton.styleFrom(backgroundColor: c.magenta, foregroundColor: Colors.white),
                    onPressed: () => _roll(1),
                    icon: const Icon(Icons.casino_outlined),
                    label: const Text('Roll once'),
                  ),
                  OutlinedButton(
                    key: const ValueKey('sampling-roll100'),
                    onPressed: () => _roll(100),
                    child: const Text('Roll 100 times'),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _tally.clear();
                      _last = null;
                    }),
                    child: const Text('Clear'),
                  ),
                ],
              ),
              if (rolls > 0) ...[
                const SizedBox(height: Gap.m),
                Text('Tally after $rolls rolls:', key: const ValueKey('sampling-tally'), style: TextStyle(color: c.textDim)),
                const SizedBox(height: Gap.xs),
                CompareBars(
                  color: c.violet,
                  items: [
                    for (final e in (_tally.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).take(6))
                      BarItem(e.key, e.value.toDouble(), display: '${e.value}'),
                  ],
                ),
              ],
              const SizedBox(height: Gap.m),
              TermText(
                'Chatbots don\'t always pick the single most likely word: they roll weighted dice. That\'s why the same '
                'question can get different answers. [[Temperature]] and [[top-p]] shape the dice.',
                style: TextStyle(color: c.textDim, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
