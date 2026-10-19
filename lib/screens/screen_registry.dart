import 'package:flutter/widgets.dart';

import 's1/s1_intro.dart';
import 's1/s1_ram.dart';
import 's1/s1_storage.dart';

/// Lesson id → screen. Add one line per finished lesson screen (keep the list in journey order).
final Map<String, WidgetBuilder> screenBuilders = {
  's1_intro': (_) => const S1IntroScreen(),
  's1_storage': (_) => const S1StorageScreen(),
  's1_ram': (_) => const S1RamScreen(),
};
