# shared_preferences_android 2.5 calls its Kotlin API from Dart through JNI, looking methods up by their exact
# signatures, e.g. getAll(String, List, kotlin.coroutines.Continuation). R8 renamed Continuation in release
# builds, the lookup failed, and SharedPreferences.getInstance() threw, so settings and progress were never saved.
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class kotlin.coroutines.** { *; }
-keep class kotlin.Unit { *; }
-keep class kotlin.Result { *; }
-keep class kotlin.Result$Failure { *; }
