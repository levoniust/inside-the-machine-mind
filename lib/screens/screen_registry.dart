import 'package:flutter/widgets.dart';

import 's2/s2_post_training.dart';

import 's2/s2_safety.dart';

import 's1/s1_datacenter.dart';
import 's1/s1_intro.dart';
import 's1/s1_storage.dart';
import 's2/s2_backprop.dart';
import 's2/s2_descent.dart';
import 's2/s2_memory_budget.dart';
import 's2/s2_step_hardware.dart';
import 's2/s2_scale_up.dart';
import 's2/s2_train_it.dart';
import 's3/s3_answer.dart';
import 's3/s3_at_home.dart';
import 's3/s3_frontier.dart';
import 's3/s3_tiny_model.dart';

/// Lesson id → screen. Add one line per finished lesson screen (keep the list in journey order).
final Map<String, WidgetBuilder> screenBuilders = {
  's1_intro': (_) => const S1IntroScreen(),
  's2_post_training': (_) => const S2PostTrainingScreen(),
  's2_safety': (_) => const S2SafetyScreen(),
  's1_storage': (_) => const S1StorageScreen(),
  's1_datacenter': (_) => const S1DatacenterScreen(),
  's2_backprop': (_) => const S2BackpropScreen(),
  's2_descent': (_) => const S2DescentScreen(),
  's2_train_it': (_) => const S2TrainItScreen(),
  's2_scale_up': (_) => const S2ScaleUpScreen(),
  's2_memory_budget': (_) => const S2MemoryBudgetScreen(),
  's2_step_hardware': (_) => const S2StepHardwareScreen(),
  's3_tiny_model': (_) => const S3TinyModelScreen(),
  's3_at_home': (_) => const S3AtHomeScreen(),
  's3_frontier': (_) => const S3FrontierScreen(),
  's3_answer': (_) => const S3AnswerScreen(),
};
