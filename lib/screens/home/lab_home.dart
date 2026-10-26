import 'package:flutter/material.dart';

import '../../app/nav.dart';
import '../../app/theme.dart';
import '../../content/lab_news.dart';
import '../../content/lessons.dart';
import '../../core/models.dart';
import '../../core/progress.dart';
import '../../widgets/components.dart';
import '../extras/egg_gallery_screen.dart';
import '../extras/glossary_screen.dart';
import '../extras/settings_screen.dart';
import '../extras/sources_screen.dart';
import 'home_screen.dart';

/// The Enthusiast Lab: a denser "workbench" hub for people who run models themselves.
/// Foundations (the original three sections) first, then the Lab tracks, with a dated "new in this version" strip.
/// [asRoot] = the app opened straight into the Lab (Settings → Start in the Lab); it then links to the front door.
class LabHome extends StatelessWidget {
  const LabHome({super.key, this.asRoot = false});
  final bool asRoot;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final t = Theme.of(context).textTheme;
    final p = AppScope.progress(context);
    final last = p.lastLesson == null ? null : lessonById(p.lastLesson!);
    final lastTrack = last == null ? null : trackOf(last, p.lastTrack);
    final wide = MediaQuery.sizeOf(context).width >= 700;

    Widget grid(List<Widget> cards) => LayoutBuilder(
      builder: (context, box) => wide
          ? Wrap(
              spacing: Gap.m,
              runSpacing: Gap.m,
              children: [for (final card in cards) SizedBox(width: (box.maxWidth - Gap.m) / 2, child: card)],
            )
          : Column(
              children: [
                for (final card in cards) ...[card, const SizedBox(height: Gap.s)],
              ],
            ),
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !asRoot,
        title: Text(
          'ENTHUSIAST LAB',
          style: AppText.mono.copyWith(fontWeight: FontWeight.w800, letterSpacing: 2, color: c.lime),
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => openPage(context, const SettingsScreen(), '/settings'),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: CircuitBackground(
        accent: c.lime,
        density: 0.5,
        child: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(Gap.l, Gap.m, Gap.l, Gap.xxl),
                children: [
                  Text('Run it, tune it, read the papers, keep up.', style: t.titleMedium?.copyWith(color: c.textDim)),
                  const SizedBox(height: Gap.m),
                  if (last != null && lastTrack != null && lastTrack.area == Area.lab) ...[
                    Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        key: const ValueKey('lab-continue'),
                        onTap: () => openLesson(context, last.id, track: lastTrack.number),
                        leading: Icon(Icons.play_circle_fill, color: c.section(lastTrack.number), size: 32),
                        title: const Text('Continue'),
                        subtitle: Text(
                          '${lastTrack.label} · ${last.title}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                    const SizedBox(height: Gap.m),
                  ],
                  _NewsStrip(news: labNews),
                  const SizedBox(height: Gap.l),
                  _Heading('FOUNDATIONS', 'The original journey with the real terms: hardware, training, inference'),
                  const SizedBox(height: Gap.s),
                  grid([for (final s in foundations) _TrackCard(track: s, icon: _icons[s.number]!)]),
                  const SizedBox(height: Gap.l),
                  _Heading('TRACKS', 'Beyond the basics'),
                  const SizedBox(height: Gap.s),
                  grid([for (final s in labTracks) _TrackCard(track: s, icon: _icons[s.number]!)]),
                  const SizedBox(height: Gap.l),
                  Wrap(
                    spacing: Gap.s,
                    runSpacing: Gap.s,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => openPage(context, const GlossaryScreen(), '/glossary'),
                        icon: const Icon(Icons.menu_book_outlined),
                        label: const Text('Glossary'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => openPage(context, const SourcesScreen(), '/sources'),
                        icon: const Icon(Icons.fact_check_outlined),
                        label: const Text('Sources & papers'),
                      ),
                      OutlinedButton.icon(
                        key: const ValueKey('lab-front-door'),
                        onPressed: () =>
                            asRoot ? openPage(context, const HomeScreen(), '/home') : Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.door_front_door_outlined),
                        label: const Text('Front door'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const _icons = {
  1: Icons.memory,
  2: Icons.model_training,
  3: Icons.chat_bubble_outline,
  6: Icons.dns_outlined,
  7: Icons.tune,
  8: Icons.article_outlined,
  9: Icons.radar,
  10: Icons.hub_outlined,
};

class _Heading extends StatelessWidget {
  const _Heading(this.title, this.subtitle);
  final String title, subtitle;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppText.mono.copyWith(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 2, color: c.lime),
        ),
        Text(subtitle, style: TextStyle(color: c.textDim, fontSize: 13)),
      ],
    );
  }
}

/// "New in this version": dated items, so stale content is honest about its age.
class _NewsStrip extends StatelessWidget {
  const _NewsStrip({required this.news});
  final List<LabNews> news;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(Gap.m),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.lime.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.new_releases_outlined, size: 18, color: c.lime),
              const SizedBox(width: Gap.s),
              Expanded(
                child: Text(
                  'NEW IN THIS VERSION',
                  style: AppText.mono.copyWith(fontSize: 12, fontWeight: FontWeight.w800, color: c.lime),
                ),
              ),
              AsOfChip(
                labNewsDate,
                key: const ValueKey('lab-asof'),
                onLongPress: () {
                  AppScope.read(context).markEgg('workbench');
                  openPage(
                    context,
                    const EggGalleryScreen(manifest: 'assets/workbench/gallery.json', title: 'Bit\'s Workbench'),
                    '/egg/workbench',
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: Gap.s),
          for (final n in news)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.xs),
              child: InkWell(
                onTap: n.lessonId == null ? null : () => openLesson(context, n.lessonId!),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('›  ', style: AppText.mono.copyWith(color: c.lime)),
                    Expanded(
                      child: Text(n.text, style: TextStyle(color: c.text, fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({required this.track, required this.icon});
  final SectionInfo track;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final p = AppScope.progress(context);
    final accent = c.section(track.number);
    final done = p.fraction(track.lessons.map((l) => l.id));
    return Material(
      key: ValueKey('track-card-${track.number}'),
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: accent.withValues(alpha: 0.45)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => openSection(context, track.number),
        child: Padding(
          padding: const EdgeInsets.all(Gap.m),
          child: Row(
            children: [
              Icon(icon, color: accent, size: 30),
              const SizedBox(width: Gap.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.number <= 3 ? '${track.number} · ${track.tag}' : track.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(track.tagline, style: TextStyle(color: c.textDim, fontSize: 13)),
                    const SizedBox(height: Gap.xs),
                    Text(
                      '${track.lessons.length} lessons · ${(done * 100).round()}%',
                      style: AppText.mono.copyWith(color: accent, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: c.textDim),
            ],
          ),
        ),
      ),
    );
  }
}
