import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Section 1 · "Real giants": swipeable cards of real AI datacenters with their cited numbers.
/// Facts: DC-COLOSSUS1, DC-COLOSSUS2, DC-STARGATE, DC-LLAMA-CLUSTER.
class S1RealSitesScreen extends StatelessWidget {
  const S1RealSitesScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's1_real_sites',
        children: [_Sites()],
      );
}

class Site {
  const Site(this.name, this.where, this.gpus, this.gpuLabel, this.power, this.story, this.factId);
  final String name, where, gpuLabel, power, story, factId;
  final double gpus;
}

const sites = [
  Site('Colossus 1', 'Memphis, Tennessee (xAI)', 100000, '~100,000 H100s', '~150 MW grid + gas turbines & batteries',
      'Built in an old factory: the first ~100,000 GPUs went in within 122 days in 2024. While the grid connection was upgraded, '
          'gas turbines and Tesla Megapack batteries filled the gap.',
      'DC-COLOSSUS1'),
  Site('Colossus 2', 'Memphis, Tennessee (xAI)', 110000, '~110,000 GB200-class (first phase)', '~210 MW first phase',
      'Its first cluster came online around January 2026 after about 91 days. A ~1.2 GW gas power plant was permitted to feed '
          'the growing Memphis–Southaven campus.',
      'DC-COLOSSUS2'),
  Site('Stargate Abilene', 'Abilene, Texas (OpenAI & Oracle)', 450000, '450,000+ GB200 (planned)', '1.2 GW planned',
      'Planned to use about 1.2 gigawatts, which Oracle described as enough for a million four-bedroom homes.',
      'DC-STARGATE'),
  Site('Llama 3 cluster', 'Meta', 16000, 'up to 16,000 H100s', '700 W per GPU',
      'Meta trained Llama 3 405B on up to 16,000 H100 GPUs in a 24,000-GPU cluster, for about 54 days of main training.',
      'DC-LLAMA-CLUSTER'),
];

class _Sites extends StatefulWidget {
  const _Sites();

  @override
  State<_Sites> createState() => _SitesState();
}

class _SitesState extends State<_Sites> {
  final _page = PageController(viewportFraction: 0.92);
  int _i = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final h = MediaQuery.textScalerOf(context).scale(330);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: h,
          child: PageView.builder(
            key: const ValueKey('sites-pages'),
            controller: _page,
            itemCount: sites.length,
            onPageChanged: (i) => setState(() => _i = i),
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _SiteCard(site: sites[i]),
            ),
          ),
        ),
        const SizedBox(height: Gap.s),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Previous site',
              onPressed: _i > 0 ? () => _page.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            for (var k = 0; k < sites.length; k++)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(shape: BoxShape.circle, color: k == _i ? c.cyan : c.line),
              ),
            IconButton(
              key: const ValueKey('sites-next'),
              tooltip: 'Next site',
              onPressed: _i < sites.length - 1 ? () => _page.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut) : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: Gap.l),
        DemoCard(
          title: 'GPUs, side by side',
          child: CompareBars(
            highlight: _i,
            items: [for (final s in sites) BarItem(s.name, s.gpus, display: humanNumber(s.gpus, digits: 0))],
          ),
        ),
      ],
    );
  }
}

class _SiteCard extends StatelessWidget {
  const _SiteCard({required this.site});
  final Site site;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Gap.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.factory_outlined, color: c.cyan),
                const SizedBox(width: Gap.s),
                Expanded(child: Text(site.name, style: Theme.of(context).textTheme.titleLarge)),
                IconButton(
                  tooltip: 'Source',
                  icon: Icon(Icons.info_outline, color: c.textDim),
                  onPressed: () => showFactSource(context, site.factId),
                ),
              ],
            ),
            Text(site.where, style: TextStyle(color: c.textDim)),
            const SizedBox(height: Gap.m),
            Row(
              children: [
                Icon(Icons.memory, size: 18, color: c.cyan),
                const SizedBox(width: Gap.s),
                Expanded(child: Text(site.gpuLabel, style: AppText.mono.copyWith(color: c.text, fontWeight: FontWeight.w700))),
              ],
            ),
            const SizedBox(height: Gap.xs),
            Row(
              children: [
                Icon(Icons.bolt, size: 18, color: c.amber),
                const SizedBox(width: Gap.s),
                Expanded(child: Text(site.power, style: AppText.mono.copyWith(color: c.text, fontWeight: FontWeight.w700))),
              ],
            ),
            const SizedBox(height: Gap.m),
            Expanded(child: Text(site.story, style: TextStyle(color: c.text), overflow: TextOverflow.fade)),
          ],
        ),
      ),
    );
  }
}
