import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 1 · "Eight GPUs in a box": a tappable server diagram and the power it draws.
/// Facts: DC-DGXH100 (8× H100, 640 GB, ~10.2 kW), DC-DGXB200 (8 GPUs, 1,440 GB, ~14.3 kW), DC-HOME-KW.
class S1ServerScreen extends StatelessWidget {
  const S1ServerScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's1_server',
        children: [_Server()],
      );
}

enum Part { gpu, nvswitch, cpu, nic, ssd, fan, psu }

const partInfo = {
  Part.gpu: ('8 GPUs', 'The army of cooks. Each has its own super-fast HBM memory right next to it.'),
  Part.nvswitch: ('NVLink switches', 'Private express lanes so every GPU can talk to every other GPU at full speed.'),
  Part.cpu: ('2 CPUs', 'The managers: they load data, run the operating system and keep the GPUs fed.'),
  Part.nic: ('Network cards', 'The doors to the rest of the datacenter: very fast links to thousands of other servers.'),
  Part.ssd: ('SSDs', 'Fast storage for the training data and saved checkpoints.'),
  Part.fan: ('Fans', 'All that power turns into heat, and it has to go somewhere.'),
  Part.psu: ('Power supplies', 'Several big power supplies feed the box, with spares in case one fails.'),
};

class _Server extends StatefulWidget {
  const _Server();

  @override
  State<_Server> createState() => _ServerState();
}

class _ServerState extends State<_Server> {
  Part _sel = Part.gpu;
  bool _b200 = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final kw = _b200 ? 14.3 : 10.2;
    final mem = _b200 ? '1,440 GB' : '640 GB';
    final info = partInfo[_sel]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          title: 'Tap the parts',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<bool>(
                key: const ValueKey('server-model'),
                segments: const [
                  ButtonSegment(value: false, label: Text('DGX H100')),
                  ButtonSegment(value: true, label: Text('DGX B200')),
                ],
                selected: {_b200},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _b200 = s.first),
              ),
              const SizedBox(height: Gap.m),
              _Diagram(sel: _sel, onTap: (p) => setState(() => _sel = p)),
              const SizedBox(height: Gap.m),
              Text(info.$1, key: const ValueKey('server-part'), style: TextStyle(color: c.cyan, fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: Gap.xs),
              Text(info.$2, style: TextStyle(color: c.text)),
              const SizedBox(height: Gap.m),
              StatGrid(
                columns: 3,
                children: [
                  StatTile(label: 'GPU memory', value: mem, color: c.cyan),
                  StatTile(key: const ValueKey('server-kw'), label: 'Power (max)', value: '${kw.toStringAsFixed(1)} kW', color: c.amber),
                  StatTile(label: '≈ US homes', value: '${(kw / 1.2).round()}', color: c.lime),
                ],
              ),
              const SizedBox(height: Gap.s),
              TermText(
                'One [[server]] draws about as much power as ${(kw / 1.2).round()} average American homes, and nearly all of it '
                'leaves as heat. A big training cluster has thousands of these boxes.',
                style: TextStyle(color: c.textDim, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
        const Row(
          children: [
            Expanded(child: FactCard(value: '~10.2 kW', label: 'DGX H100: 8 GPUs, 640 GB', factId: 'DC-DGXH100')),
            SizedBox(width: Gap.m),
            Expanded(child: FactCard(value: '~14.3 kW', label: 'DGX B200: 8 GPUs, 1,440 GB', factId: 'DC-DGXB200')),
          ],
        ),
      ],
    );
  }
}

class _Diagram extends StatelessWidget {
  const _Diagram({required this.sel, required this.onTap});
  final Part sel;
  final ValueChanged<Part> onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    Widget cell(Part p, String label, {IconData? icon, int flex = 1, double height = 44}) => Expanded(
          flex: flex,
          child: GestureDetector(
            key: ValueKey('server-${p.name}-$label'),
            onTap: () => onTap(p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: height,
              margin: const EdgeInsets.all(3),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel == p ? c.cyan.withValues(alpha: 0.3) : c.surfaceHi,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: sel == p ? c.cyan : c.line, width: sel == p ? 2 : 1),
              ),
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) Icon(icon, size: 14, color: c.textDim),
                      if (icon != null) const SizedBox(width: 3),
                      Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.text)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
    return Semantics(
      label: 'Server diagram; selected ${partInfo[sel]!.$1}',
      child: Container(
        padding: const EdgeInsets.all(Gap.s),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: c.line, width: 2)),
        child: Column(
          children: [
            Row(children: [for (var i = 0; i < 6; i++) cell(Part.fan, 'fan', icon: Icons.toys_outlined, height: 30)]),
            Row(children: [for (var i = 1; i <= 4; i++) cell(Part.gpu, 'GPU $i', height: 50)]),
            Row(children: [cell(Part.nvswitch, 'NVLink switches', flex: 4, height: 30)]),
            Row(children: [for (var i = 5; i <= 8; i++) cell(Part.gpu, 'GPU $i', height: 50)]),
            Row(children: [
              cell(Part.cpu, 'CPU 1'),
              cell(Part.cpu, 'CPU 2'),
              cell(Part.nic, 'network', icon: Icons.lan_outlined),
              cell(Part.ssd, 'SSDs', icon: Icons.storage),
            ]),
            Row(children: [for (var i = 0; i < 4; i++) cell(Part.psu, 'power', icon: Icons.bolt, height: 30)]),
          ],
        ),
      ),
    );
  }
}
