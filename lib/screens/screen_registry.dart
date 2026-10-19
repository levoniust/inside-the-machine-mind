import 'package:flutter/widgets.dart';

import 's1/s1_storage.dart';
import 's2/s2_backprop.dart';
import 's2/s2_descent.dart';
import 's2/s2_train_it.dart';
import 's3/s3_tiny_model.dart';

/// Lesson id → screen. Add one line per finished lesson screen (keep the list in journey order).
final Map<String, WidgetBuilder> screenBuilders = {
  's1_storage': (_) => const S1StorageScreen(),
  's2_backprop': (_) => const S2BackpropScreen(),
  's2_descent': (_) => const S2DescentScreen(),
  's2_train_it': (_) => const S2TrainItScreen(),
  's3_tiny_model': (_) => const S3TinyModelScreen(),
};
