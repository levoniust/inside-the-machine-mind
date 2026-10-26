import 'package:flutter/material.dart';

import '../../app/nav.dart';
import '../../app/theme.dart';
import '../../content/fit_data.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../home/lab_home.dart';

/// Can I run one at home? Pick a computer → which model sizes fit and how they would feel, in everyday words
/// (the same math as the Lab's "Will it fit?" calculator), the privacy upside, and the door into the Lab.
class EAtHomeScreen extends StatelessWidget {
  const EAtHomeScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const LessonScaffold(lessonId: 'e_at_home', children: [_Bench(), _Privacy(), _LabButton()]);
}

class _Machine {
  const _Machine(this.name, this.icon, this.hw, this.ramGB, this.note);
  final String name;
  final IconData icon;
  final FitHardware hw;
  final double ramGB;
  final String note;
}

final _machines = [
  _Machine(
    'Laptop',
    Icons.laptop,
    fitHardware.first,
    16,
    'No big graphics card: the model runs on the main processor from 16 GB of memory.',
  ),
  _Machine(
    'Gaming PC',
    Icons.desktop_windows,
    fitHardware.firstWhere((h) => h.name.startsWith('RTX 4090')),
    32,
    'A graphics card with 24 GB of its own fast memory.',
  ),
  _Machine(
    'Mac with lots of memory',
    Icons.laptop_mac,
    fitHardware.firstWhere((h) => h.name.startsWith('Mac Studio, M5 Max')),
    0,
    'Apple chips share one big pool of fast memory between everything.',
  ),
];

final _sizes = [
  ('Small model', 'e.g. 8 billion parameters', fitModels.firstWhere((m) => m.name == 'Llama 3.1 8B')),
  ('Medium model', 'e.g. 32 billion', fitModels.firstWhere((m) => m.name == 'Qwen3 32B')),
  ('Large model', 'e.g. 70 billion', fitModels.firstWhere((m) => m.name == 'Llama 3.3 70B')),
];

(String, Color) _feel(BuildContext context, FitResult r) {
  final c = AppColors.of(context);
  if (r.verdict == FitVerdict.noFit) return ('Doesn\'t fit', c.red);
  final t = r.tokPerSec ?? 0;
  if (t >= 30) return ('Faster than you can read', c.lime);
  if (t >= 10) return ('Like a fast typist', c.lime);
  if (t >= 3) return ('Slow, but usable', c.amber);
  return ('Very slow', c.amber);
}

class _Bench extends StatefulWidget {
  const _Bench();

  @override
  State<_Bench> createState() => _BenchState();
}

class _BenchState extends State<_Bench> {
  int _m = 1;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(5);
    final m = _machines[_m];
    return DemoCard(
      title: 'Pick a computer',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (var i = 0; i < _machines.length; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < _machines.length - 1 ? Gap.s : 0),
                    child: InkWell(
                      key: ValueKey('home-machine-$i'),
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _m = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: Gap.m, horizontal: Gap.xs),
                        decoration: BoxDecoration(
                          color: i == _m ? accent.withValues(alpha: 0.18) : null,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: i == _m ? accent : c.line),
                        ),
                        child: Column(
                          children: [
                            Icon(_machines[i].icon, size: 36, color: i == _m ? accent : c.textDim),
                            const SizedBox(height: Gap.xs),
                            Text(_machines[i].name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text(m.note, style: TextStyle(color: c.textDim, fontSize: 13)),
          const SizedBox(height: Gap.m),
          for (final (name, example, model) in _sizes)
            Builder(
              builder: (context) {
                final r = FitResult.compute(
                  model: model,
                  quant: fitQuants[3],
                  context: 8192,
                  kv: fitKvTypes.first,
                  hw: m.hw,
                  ramGB: m.ramGB,
                  ramBW: 89.6,
                );
                final (feel, color) = _feel(context, r);
                return Padding(
                  padding: const EdgeInsets.only(bottom: Gap.s),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(example, style: TextStyle(color: c.textDim, fontSize: 12)),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Container(
                          key: ValueKey('home-feel-$name'),
                          padding: const EdgeInsets.symmetric(horizontal: Gap.s, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            feel,
                            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          Text(
            'Rough guide for models squeezed to about 5 bits per number, with a short chat. The Lab\'s calculator shows the details.',
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Privacy extends StatelessWidget {
  const _Privacy();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DemoCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, color: c.lime, size: 28),
          const SizedBox(width: Gap.m),
          const Expanded(
            child: Text(
              'The big plus: your words never leave your computer. No account, no company servers, and it keeps '
              'working without internet. The trade-off: home models are smaller than the giant ones in the cloud.',
            ),
          ),
        ],
      ),
    );
  }
}

class _LabButton extends StatelessWidget {
  const _LabButton();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return FilledButton.icon(
      key: const ValueKey('home-to-lab'),
      style: FilledButton.styleFrom(
        backgroundColor: c.lime,
        foregroundColor: c.bg,
        padding: const EdgeInsets.all(Gap.m),
      ),
      onPressed: () => openPage(context, const LabHome(), '/lab'),
      icon: const Icon(Icons.science_outlined),
      label: const Text('Step into the Enthusiast Lab'),
    );
  }
}
