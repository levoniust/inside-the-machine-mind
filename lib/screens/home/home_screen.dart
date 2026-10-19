import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/nav.dart';
import '../../app/theme.dart';
import '../../content/lessons.dart';
import '../../core/progress.dart';
import '../../widgets/bit.dart';
import '../../widgets/components.dart';
import '../extras/about_screen.dart';
import '../extras/egg_built_screen.dart';
import '../extras/egg_gallery_screen.dart';
import '../extras/glossary_screen.dart';
import '../extras/settings_screen.dart';
import '../extras/sources_screen.dart';

/// Home: Bit on a circuit board, the question, three section cards and the extras.
/// Easter eggs: tap Bit 5 times quickly → "How This App Was Built";
/// long-press the little amber "3060" chip → "The 3060 Gallery".
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _taps = 0;
  Timer? _tapReset;
  BitMood _mood = BitMood.idle;

  void _tapBit() {
    _tapReset?.cancel();
    _taps++;
    setState(() => _mood = _taps >= 3 ? BitMood.wow : BitMood.happy);
    if (_taps >= 5) {
      _taps = 0;
      setState(() => _mood = BitMood.idle);
      AppScope.read(context).markEgg('built');
      openPage(context, const EggBuiltScreen(), '/egg/built');
      return;
    }
    _tapReset = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _taps = 0;
          _mood = BitMood.idle;
        });
      }
    });
  }

  @override
  void dispose() {
    _tapReset?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = AppScope.progress(context);
    final last = p.lastLesson == null ? null : lessonById(p.lastLesson!);
    final wide = MediaQuery.sizeOf(context).width >= 700;

    final cards = [
      for (final s in sections)
        _SectionCard(
          key: ValueKey('section-card-${s.number}'),
          number: s.number,
          title: s.title,
          tagline: s.tagline,
          progress: p.fraction(s.lessons.map((l) => l.id)),
          lessons: s.lessons.length,
        ),
    ];

    return Scaffold(
      body: CircuitBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(Gap.l, Gap.l, Gap.l, Gap.xxl),
                children: [
                  _Hero(mood: _mood, onTapBit: _tapBit),
                  const SizedBox(height: Gap.xl),
                  if (last != null) ...[
                    _ContinueCard(title: last.title, section: last.section, onTap: () => openLesson(context, last.id)),
                    const SizedBox(height: Gap.l),
                  ],
                  if (wide)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < cards.length; i++) ...[
                            if (i > 0) const SizedBox(width: Gap.m),
                            Expanded(child: cards[i]),
                          ],
                        ],
                      ),
                    )
                  else
                    for (final card in cards) ...[card, const SizedBox(height: Gap.m)],
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
                        label: const Text('Sources'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => openPage(context, const AboutScreen(), '/about'),
                        icon: const Icon(Icons.info_outline),
                        label: const Text('About'),
                      ),
                      OutlinedButton.icon(
                        key: const ValueKey('home-settings'),
                        onPressed: () => openPage(context, const SettingsScreen(), '/settings'),
                        icon: const Icon(Icons.tune),
                        label: const Text('Settings'),
                      ),
                    ],
                  ),
                  const SizedBox(height: Gap.xl),
                  Center(child: _ChipBoard(onSecret: () {
                    AppScope.read(context).markEgg('gallery');
                    openPage(context, const EggGalleryScreen(), '/egg/gallery');
                  })),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.mood, required this.onTapBit});
  final BitMood mood;
  final VoidCallback onTapBit;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final t = Theme.of(context).textTheme;
    return Column(
      children: [
        GestureDetector(
          key: const ValueKey('home-bit'),
          onTap: onTapBit,
          child: BitAvatar(size: 132, mood: mood),
        ),
        const SizedBox(height: Gap.m),
        Text('Inside the', style: t.titleMedium?.copyWith(color: c.textDim, letterSpacing: 3)),
        ShaderMask(
          shaderCallback: (r) => LinearGradient(colors: [c.cyan, c.violet, c.magenta]).createShader(r),
          child: Text('Machine Mind',
              textAlign: TextAlign.center,
              style: t.headlineLarge?.copyWith(color: Colors.white, fontSize: 38)),
        ),
        const SizedBox(height: Gap.l),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: Gap.l, vertical: Gap.m),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: c.cyan.withValues(alpha: 0.5)),
            boxShadow: [BoxShadow(color: c.cyan.withValues(alpha: 0.15), blurRadius: 20)],
          ),
          child: Column(
            children: [
              Text('Follow one question through the machine:', style: TextStyle(color: c.textDim)),
              const SizedBox(height: Gap.xs),
              Text('“Why is the sky blue?”',
                  style: t.titleLarge?.copyWith(color: c.text, fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.title, required this.section, required this.onTap});
  final String title;
  final int section;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(section);
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: Icon(Icons.play_circle_fill, color: accent, size: 36),
        title: const Text('Continue where you left off'),
        subtitle: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    super.key,
    required this.number,
    required this.title,
    required this.tagline,
    required this.progress,
    required this.lessons,
  });
  final int number;
  final String title, tagline;
  final double progress;
  final int lessons;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(number);
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: accent.withValues(alpha: 0.45))),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => openSection(context, number),
        child: Padding(
          padding: const EdgeInsets.all(Gap.l),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 5,
                        color: accent,
                        backgroundColor: c.surfaceHi,
                      ),
                    ),
                    Text('$number', style: AppText.mono.copyWith(fontSize: 26, fontWeight: FontWeight.w800, color: accent)),
                  ],
                ),
              ),
              const SizedBox(width: Gap.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: Gap.xs),
                    Text(tagline, style: TextStyle(color: c.textDim)),
                    const SizedBox(height: Gap.s),
                    Text('$lessons lessons · ${(progress * 100).round()}% done',
                        style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A little strip of circuit-board chips at the bottom of the home screen. One of them,
/// the amber "3060", opens the gallery when long-pressed.
class _ChipBoard extends StatelessWidget {
  const _ChipBoard({required this.onSecret});
  final VoidCallback onSecret;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    Widget chip(String label, Color color, {Key? key, VoidCallback? onLong}) => GestureDetector(
          key: key,
          onLongPress: onLong,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withValues(alpha: 0.6)),
            ),
            child: Text(label, style: AppText.mono.copyWith(fontSize: 10, color: color.withValues(alpha: 0.8))),
          ),
        );
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            chip('CPU', c.line),
            chip('HBM', c.line),
            chip('3060', c.amber, key: const ValueKey('chip-3060'), onLong: onSecret),
            chip('NVMe', c.line),
            chip('RAM', c.line),
          ],
        ),
        const SizedBox(height: Gap.s),
        Text('v1.0 · made by machines, for curious humans', style: TextStyle(color: c.textDim, fontSize: 11)),
      ],
    );
  }
}
