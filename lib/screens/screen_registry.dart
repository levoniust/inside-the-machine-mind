import 'package:flutter/widgets.dart';

import 's5/e_school_work.dart';

import 's5/e_asking.dart';

import 's1/s1_cpu_gpu.dart';

import 's2/s2_post_training.dart';

import 's2/s2_safety.dart';

import 's1/s1_data_scale.dart';
import 's1/s1_datacenter.dart';
import 's1/s1_intro.dart';
import 's1/s1_links.dart';
import 's1/s1_matmul.dart';
import 's1/s1_power_cooling.dart';
import 's1/s1_precision.dart';
import 's1/s1_rack.dart';
import 's1/s1_real_sites.dart';
import 's1/s1_server.dart';
import 's1/s1_memory_types.dart';
import 's1/s1_ram.dart';
import 's1/s1_storage.dart';
import 's1/s1_too_big.dart';
import 's2/s2_attention.dart';
import 's2/s2_backprop.dart';
import 's2/s2_cleaning.dart';
import 's2/s2_decoder.dart';
import 's2/s2_empty_brain.dart';
import 's2/s2_guess.dart';
import 's2/s2_intro.dart';
import 's2/s2_library.dart';
import 's2/s2_loss.dart';
import 's2/s2_making_small.dart';
import 's2/s2_big_small.dart';
import 's2/s2_descent.dart';
import 's2/s2_memory_budget.dart';
import 's2/s2_parallel.dart';
import 's2/s2_step_hardware.dart';
import 's2/s2_testing.dart';
import 's2/s2_things_break.dart';
import 's2/s2_tokens.dart';
import 's2/s2_scale_up.dart';
import 's2/s2_scaling_laws.dart';
import 's2/s2_train_it.dart';
import 's3/s3_answer.dart';
import 's3/s3_at_home.dart';
import 's3/s3_quants.dart';
import 's3/s3_beyond_text.dart';
import 's3/s3_embeddings.dart';
import 's3/s3_loop.dart';
import 's3/s3_robots.dart';
import 's3/s3_sampling.dart';
import 's3/s3_science.dart';
import 's3/s3_serving.dart';
import 's3/s3_tokenize.dart';
import 's3/s3_frontier.dart';
import 's3/s3_intro.dart';
import 's3/s3_timeline.dart';
import 's3/s3_tiny_model.dart';
import 's5/e_at_home.dart';
import 's5/e_good_bad.dart';
import 's5/e_privacy.dart';
import 's5/e_fakes.dart';
import 's5/e_model_size.dart';
import 's5/e_bias.dart';
import 's5/e_which.dart';
import 's6/l_frontends.dart';
import 's6/l_home_rig.dart';
import 's6/l_split_gpus.dart';
import 's6/l_safe_server.dart';
import 's6/l_speech_home.dart';
import 's6/l_kv_cache.dart';
import 's6/l_moe_home.dart';
import 's6/l_quant_pick.dart';
import 's6/l_runtimes.dart';
import 's6/l_speed_tricks.dart';
import 's6/l_will_it_fit.dart';
import 's7/l_datasets.dart';
import 's7/l_lora.dart';
import 's7/l_merging.dart';
import 's7/l_notes_helper.dart';
import 's7/l_tools_mcp.dart';
import 's7/l_inside.dart';
import 's7/l_steering.dart';
import 's7/l_which_custom.dart';
import 's8/l_paper_anatomy.dart';
import 's8/l_paper_shelf.dart';
import 's10/l_jobs.dart';
import 's10/l_keep_up.dart';
import 's10/l_who_makes.dart';
import 's9/l_leaderboards.dart';
import 's9/l_sota_hardware.dart';
import 's9/l_sota_models.dart';
import 's9/l_sota_techniques.dart';
import 's9/l_this_year.dart';
import 's11/e_agents.dart';
import 's11/e_thinking.dart';
import 's11/e_memory.dart';
import 's11/e_voice.dart';

/// Lesson id → screen. Add one line per finished lesson screen (keep the list in journey order).
final Map<String, WidgetBuilder> screenBuilders = {
  'e_school_work': (_) => const ESchoolWorkScreen(),
  'e_asking': (_) => const EAskingScreen(),
  's1_cpu_gpu': (_) => const S1CpuGpuScreen(),
  's2_intro': (_) => const S2IntroScreen(),
  's2_decoder': (_) => const S2DecoderScreen(),
  's2_library': (_) => const S2LibraryScreen(),
  's2_cleaning': (_) => const S2CleaningScreen(),
  's2_tokens': (_) => const S2TokensScreen(),
  's2_empty_brain': (_) => const S2EmptyBrainScreen(),
  's2_attention': (_) => const S2AttentionScreen(),
  's2_guess': (_) => const S2GuessScreen(),
  's2_loss': (_) => const S2LossScreen(),
  's1_intro': (_) => const S1IntroScreen(),
  's2_post_training': (_) => const S2PostTrainingScreen(),
  's2_safety': (_) => const S2SafetyScreen(),
  's1_storage': (_) => const S1StorageScreen(),
  's1_matmul': (_) => const S1MatmulScreen(),
  's1_precision': (_) => const S1PrecisionScreen(),
  's1_links': (_) => const S1LinksScreen(),
  's1_too_big': (_) => const S1TooBigScreen(),
  's1_server': (_) => const S1ServerScreen(),
  's1_rack': (_) => const S1RackScreen(),
  's1_datacenter': (_) => const S1DatacenterScreen(),
  's1_power_cooling': (_) => const S1PowerCoolingScreen(),
  's1_real_sites': (_) => const S1RealSitesScreen(),
  's1_data_scale': (_) => const S1DataScaleScreen(),
  's2_backprop': (_) => const S2BackpropScreen(),
  's2_descent': (_) => const S2DescentScreen(),
  's2_train_it': (_) => const S2TrainItScreen(),
  's2_scale_up': (_) => const S2ScaleUpScreen(),
  's2_memory_budget': (_) => const S2MemoryBudgetScreen(),
  's2_step_hardware': (_) => const S2StepHardwareScreen(),
  's2_parallel': (_) => const S2ParallelScreen(),
  's2_things_break': (_) => const S2ThingsBreakScreen(),
  's2_testing': (_) => const S2TestingScreen(),
  's2_scaling_laws': (_) => const S2ScalingLawsScreen(),
  's2_big_small': (_) => const S2BigSmallScreen(),
  's2_making_small': (_) => const S2MakingSmallScreen(),
  's3_tiny_model': (_) => const S3TinyModelScreen(),
  's3_intro': (_) => const S3IntroScreen(),
  's3_tokenize': (_) => const S3TokenizeScreen(),
  's3_embeddings': (_) => const S3EmbeddingsScreen(),
  's3_sampling': (_) => const S3SamplingScreen(),
  's3_loop': (_) => const S3LoopScreen(),
  's3_at_home': (_) => const S3AtHomeScreen(),
  's3_quants': (_) => const S3QuantsScreen(),
  's3_frontier': (_) => const S3FrontierScreen(),
  's3_serving': (_) => const S3ServingScreen(),
  's3_beyond_text': (_) => const S3BeyondTextScreen(),
  's3_timeline': (_) => const S3TimelineScreen(),
  's3_robots': (_) => const S3RobotsScreen(),
  's3_science': (_) => const S3ScienceScreen(),
  's3_answer': (_) => const S3AnswerScreen(),
  's1_ram': (_) => const S1RamScreen(),
  's1_memory_types': (_) => const S1MemoryTypesScreen(),
  'e_good_bad': (_) => const EGoodBadScreen(),
  'e_at_home': (_) => const EAtHomeScreen(),
  'e_privacy': (_) => const EPrivacyScreen(),
  'e_fakes': (_) => const EFakesScreen(),
  'e_which': (_) => const EWhichScreen(),
  'e_model_size': (_) => const EModelSizeScreen(),
  'e_bias': (_) => const EBiasScreen(),
  'l_will_it_fit': (_) => const LWillItFitScreen(),
  'l_kv_cache': (_) => const LKvCacheScreen(),
  'l_frontends': (_) => const LFrontendsScreen(),
  'l_datasets': (_) => const LDatasetsScreen(),
  'l_home_rig': (_) => const LHomeRigScreen(),
  'l_split_gpus': (_) => const LSplitGpusScreen(),
  'l_safe_server': (_) => const LSafeServerScreen(),
  'l_speech_home': (_) => const LSpeechHomeScreen(),
  'l_moe_home': (_) => const LMoeHomeScreen(),
  'l_quant_pick': (_) => const LQuantPickScreen(),
  'l_runtimes': (_) => const LRuntimesScreen(),
  'l_speed_tricks': (_) => const LSpeedTricksScreen(),
  'l_lora': (_) => const LLoraScreen(),
  'l_merging': (_) => const LMergingScreen(),
  'l_steering': (_) => const LSteeringScreen(),
  'l_notes_helper': (_) => const LNotesHelperScreen(),
  'l_tools_mcp': (_) => const LToolsMcpScreen(),
  'l_inside': (_) => const LInsideScreen(),
  'l_which_custom': (_) => const LWhichCustomScreen(),
  'l_paper_anatomy': (_) => const LPaperAnatomyScreen(),
  'l_paper_shelf': (_) => const LPaperShelfScreen(),
  'l_sota_models': (_) => const LSotaModelsScreen(),
  'l_sota_hardware': (_) => const LSotaHardwareScreen(),
  'l_sota_techniques': (_) => const LSotaTechniquesScreen(),
  'l_leaderboards': (_) => const LLeaderboardsScreen(),
  'l_this_year': (_) => const LThisYearScreen(),
  'l_who_makes': (_) => const LWhoMakesScreen(),
  'l_jobs': (_) => const LJobsScreen(),
  'l_keep_up': (_) => const LKeepUpScreen(),
  'e_agents': (_) => const EAgentsScreen(),
  'e_thinking': (_) => const EThinkingScreen(),
  'e_memory': (_) => const EMemoryScreen(),
  'e_voice': (_) => const EVoiceScreen(),
};
