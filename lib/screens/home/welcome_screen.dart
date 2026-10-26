import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/progress.dart';
import '../../widgets/bit.dart';
import '../../widgets/components.dart';

/// First launch: one friendly question decides where the app opens (front door or Enthusiast Lab).
/// Either answer can be changed any time in Settings, and both sides stay reachable from each other.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final t = Theme.of(context).textTheme;
    final store = AppScope.read(context);
    return Scaffold(
      body: CircuitBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(Gap.l, Gap.xl, Gap.l, Gap.xl),
                children: [
                  const Center(child: BitAvatar(size: 120, mood: BitMood.happy)),
                  const SizedBox(height: Gap.l),
                  Text('Hi, I\'m Bit!', textAlign: TextAlign.center, style: t.headlineMedium),
                  const SizedBox(height: Gap.s),
                  Text(
                    'How much do you already know about AI?',
                    textAlign: TextAlign.center,
                    style: t.titleMedium?.copyWith(color: c.textDim),
                  ),
                  const SizedBox(height: Gap.xl),
                  _Choice(
                    key: const ValueKey('welcome-everyday'),
                    icon: Icons.emoji_objects_outlined,
                    color: c.cyan,
                    title: 'Just curious',
                    body: 'I\'ve used ChatGPT or similar, maybe. Show me how it works and how to use it well.',
                    onTap: () => store.setAudience(1),
                  ),
                  const SizedBox(height: Gap.m),
                  _Choice(
                    key: const ValueKey('welcome-lab'),
                    icon: Icons.science_outlined,
                    color: c.lime,
                    title: 'I tinker with it',
                    body: 'I run models at home, follow AI news or work near it. Take me to the Enthusiast Lab.',
                    onTap: () => store.setAudience(2),
                  ),
                  const SizedBox(height: Gap.l),
                  Text(
                    'You can switch any time in Settings, and both sides are open to everyone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: c.textDim, fontSize: 13),
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

class _Choice extends StatelessWidget {
  const _Choice({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String title, body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withValues(alpha: 0.6)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Gap.l),
          child: Row(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(width: Gap.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color)),
                    const SizedBox(height: Gap.xs),
                    Text(body, style: TextStyle(color: c.text)),
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
