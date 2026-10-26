import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// The hardware right now (as of Oct 2026): datacenter chips and desk machines side by side, compared on the number
/// that matters most for running models: memory bandwidth (log scale).
class LSotaHardwareScreen extends StatelessWidget {
  const LSotaHardwareScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
    lessonId: 'l_sota_hardware',
    children: [
      _Compare(),
      FactCard(
        value: '288 GB · 19.2 TB/s',
        label: 'per NVIDIA Rubin GPU (HBM4); 72 of them per Vera Rubin NVL72 rack',
        factId: 'SOTA-RUBIN',
      ),
      FactCard(
        value: '614 GB/s · 1.2 TB/s',
        label: 'Mac Studio with M5 Max (up to 128 GB) or M5 Ultra (up to 512 GB)',
        factId: 'SOTA-M5',
      ),
    ],
  );
}

class _Chip {
  const _Chip(this.name, this.memGB, this.bwGBs, this.where, this.factId);
  final String name, where, factId;
  final double memGB, bwGBs;
}

const _chips = [
  _Chip('NVIDIA Rubin GPU', 288, 19200, 'datacenter', 'SOTA-RUBIN'),
  _Chip('NVIDIA B200 GPU', 180, 8000, 'datacenter', 'HW-HBM-B200'),
  _Chip('NVIDIA H100 SXM', 80, 3350, 'datacenter', 'HW-HBM-H100'),
  _Chip('RTX 5090', 32, 1792, 'desk', 'HW-GDDR-5090'),
  _Chip('Mac Studio M5 Ultra', 512, 1200, 'desk', 'SOTA-M5'),
  _Chip('RTX 3090', 24, 936, 'desk', 'HW-GDDR-3090'),
  _Chip('Mac Studio M5 Max', 128, 614, 'desk', 'SOTA-M5'),
  _Chip('DGX Spark', 128, 273, 'desk', 'IN-SPARK'),
];

class _Compare extends StatefulWidget {
  const _Compare();

  @override
  State<_Compare> createState() => _CompareState();
}

class _CompareState extends State<_Compare> {
  bool _memory = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(9);
    return DemoCard(
      title: 'Datacenter vs desk',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(alignment: Alignment.centerLeft, child: AsOfChip('Oct 2026')),
          const SizedBox(height: Gap.s),
          SegmentedButton<bool>(
            key: const ValueKey('hw-metric'),
            segments: const [
              ButtonSegment(value: false, label: Text('Bandwidth')),
              ButtonSegment(value: true, label: Text('Memory')),
            ],
            selected: {_memory},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _memory = s.first),
          ),
          const SizedBox(height: Gap.s),
          CompareBars(
            log: true,
            items: [
              for (final ch in _chips)
                BarItem(
                  ch.name,
                  _memory ? ch.memGB : ch.bwGBs,
                  display: _memory
                      ? '${ch.memGB.round()} GB'
                      : (ch.bwGBs >= 1000
                            ? '${(ch.bwGBs / 1000).toStringAsFixed(1)} TB/s'
                            : '${ch.bwGBs.round()} GB/s'),
                  color: ch.where == 'datacenter' ? accent : c.cyan,
                ),
            ],
          ),
          const SizedBox(height: Gap.s),
          Wrap(
            spacing: Gap.m,
            children: [
              Text('■ datacenter', style: TextStyle(color: accent)),
              Text('■ desk', style: TextStyle(color: c.cyan)),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text(
            _memory
                ? 'Memory decides what fits. A 512 GB Mac Studio holds more than any single datacenter GPU here, but reads it about 16 times more slowly than a Rubin.'
                : 'Bandwidth decides how fast a model talks (bars on a log scale: each step is 10×). A Rubin GPU reads its memory about 70 times faster than a DGX Spark.',
            key: const ValueKey('hw-note'),
          ),
        ],
      ),
    );
  }
}
