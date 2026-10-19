import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../widgets/bit.dart';
import '../../widgets/components.dart';

/// Easter egg 1: "How This App Was Built" — Bit's secret logbook. Short on purpose.
/// Numbers come from assets/data/build_stats.json, generated from the build's real metrics.
class EggBuiltScreen extends StatefulWidget {
  const EggBuiltScreen({super.key});

  @override
  State<EggBuiltScreen> createState() => _EggBuiltScreenState();
}

class _EggBuiltScreenState extends State<EggBuiltScreen> {
  late final Future<Map<String, dynamic>> _stats = rootBundle
      .loadString('assets/data/build_stats.json')
      .then((s) => jsonDecode(s) as Map<String, dynamic>)
      .catchError((_) => <String, dynamic>{});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Bit\'s secret logbook')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _stats,
        builder: (context, snap) {
          final s = snap.data ?? const {};
          num n(List<String> path) {
            dynamic v = s;
            for (final p in path) {
              v = v is Map ? v[p] : null;
            }
            return v is num ? v : 0;
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.all(Gap.l),
                children: [
                  const BitSays(
                    lines: [
                      'You found my logbook! Here\'s a secret: this whole app was built by AI models working together on '
                          'a homelab, mostly overnight while its owner slept.',
                    ],
                    mood: BitMood.happy,
                  ),
                  const SizedBox(height: Gap.xl),
                  Text('The team', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: Gap.s),
                  _member(context, Icons.hub_outlined, c.amber, 'Claude (Opus 5.5)', 'cloud',
                      'Orchestrator: planned the app, wrote the trickiest screens, checked every fact, reviewed everyone\'s work.'),
                  _member(context, Icons.code, c.cyan, 'Qwen3.8-Flash-Next', '2× RTX 3090',
                      'Coding agent: built lesson screens one after another, at about 21 words per second.'),
                  _member(context, Icons.edit_note, c.violet, 'Mirai (Qwen3.8-27B)', 'RTX 5060 Ti',
                      'Writer and second coder: drafted Bit\'s script, the quizzes and research notes, and coded screens.'),
                  _member(context, Icons.palette_outlined, c.magenta, 'Qwen-Image 2.1', 'RTX 3060',
                      'Artist: painted the secret gallery, about 15 seconds per picture.'),
                  const SizedBox(height: Gap.xl),
                  Text('By the numbers', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: Gap.s),
                  StatGrid(
                    columns: MediaQuery.sizeOf(context).width >= 600 ? 3 : 2,
                    children: [
                      StatTile(label: 'Build time', value: '${n(['hours'])} h', icon: Icons.timer_outlined),
                      StatTile(
                          label: 'Words written by local AIs',
                          value: humanNumber((n(['qwen', 'tokens']) + n(['mirai', 'tokens'])).toDouble() * 0.75),
                          icon: Icons.text_snippet_outlined),
                      StatTile(label: 'Lines of app code', value: humanNumber(n(['dart_lines']).toDouble()), icon: Icons.code),
                      StatTile(label: 'Pictures painted', value: '${n(['images', 'jobs'])}', icon: Icons.image_outlined),
                      StatTile(label: 'Hottest GPU', value: '${n(['peak', 'gpu_5060ti_c'])} °C', icon: Icons.thermostat, color: c.amber),
                      StatTile(label: 'Wrong facts caught', value: '${n(['facts_fixed'])}', icon: Icons.fact_check_outlined, color: c.lime),
                    ],
                  ),
                  const SizedBox(height: Gap.xl),
                  Text('Day two (v1.1)', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: Gap.s),
                  Text(
                    'After the first version shipped, the team kept going: the writer re-read every lesson as a curious '
                    '15-year-old and flagged anything confusing, the coding agent gave 12 lessons new interactive extras, '
                    'and a robot "monkey" tapped and swiped thousands of times at random to hunt for crashes. It found two.',
                    style: TextStyle(color: c.textDim),
                  ),
                  const SizedBox(height: Gap.xl),
                  KeyIdea(
                    'Even the AIs that built this needed checking: the local models drafted plenty of numbers that were '
                    'wrong, and every one was corrected against a real source before it reached you. Always check the source!',
                    color: c.amber,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _member(BuildContext context, IconData icon, Color color, String name, String hw, String role) {
    final c = AppColors.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: Gap.s),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.15), child: Icon(icon, color: color)),
        title: Text.rich(TextSpan(children: [
          TextSpan(text: name, style: const TextStyle(fontWeight: FontWeight.w700)),
          TextSpan(text: '  ·  $hw', style: TextStyle(color: c.textDim, fontSize: 13)),
        ])),
        subtitle: Text(role),
      ),
    );
  }
}
