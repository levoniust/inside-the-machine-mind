import 'package:flutter/widgets.dart';

import 's1/s1_storage.dart';
import 's2/s2_train_it.dart';

/// Lesson id → screen. Add one line per finished lesson screen (keep the list in journey order).
final Map<String, WidgetBuilder> screenBuilders = {
  's1_storage': (_) => const S1StorageScreen(),
  's2_train_it': (_) => const S2TrainItScreen(),
};
