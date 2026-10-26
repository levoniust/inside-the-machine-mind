import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Every hidden Easter egg in the app (Settings shows how many are found, not which).
const eggIds = ['built', 'gallery', 'workbench', 'konami', 'rig'];

/// Remembers which lessons are done, quiz scores, the last lesson opened and found Easter eggs.
/// Persisted with shared_preferences; works in memory if storage is unavailable (tests).
class ProgressStore extends ChangeNotifier {
  ProgressStore([this._prefs]);

  static const _kDone = 'progress.done';
  static const _kLast = 'progress.last';
  static const _kQuiz = 'progress.quiz.';
  static const _kEggs = 'progress.eggs';
  static const _kTheme = 'settings.theme'; // 0 system, 1 dark, 2 light
  static const _kStill = 'settings.reduceMotion';
  static const _kSpeak = 'settings.autoSpeak';
  static const _kAudience = 'settings.audience'; // 0 not asked yet, 1 everyday, 2 enthusiast
  static const _kLastTrack = 'progress.lastTrack';

  final SharedPreferences? _prefs;
  final Set<String> _done = {};
  final Set<String> _eggs = {};
  final Map<String, int> _quiz = {};
  String? _last;
  int _theme = 0;
  bool _reduceMotion = false;
  bool _autoSpeak = false;
  int _audience = 0;
  int? _lastTrack;

  static Future<ProgressStore> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      return ProgressStore(p).._read();
    } catch (e) {
      debugPrint('ProgressStore: storage unavailable, keeping progress in memory: $e');
      return ProgressStore();
    }
  }

  void _read() {
    final p = _prefs;
    if (p == null) return;
    _done.addAll(p.getStringList(_kDone) ?? const []);
    _eggs.addAll(p.getStringList(_kEggs) ?? const []);
    _last = p.getString(_kLast);
    _theme = p.getInt(_kTheme) ?? 0;
    _reduceMotion = p.getBool(_kStill) ?? false;
    _autoSpeak = p.getBool(_kSpeak) ?? false;
    _audience = p.getInt(_kAudience) ?? 0;
    _lastTrack = p.getInt(_kLastTrack);
    for (final k in p.getKeys().where((k) => k.startsWith(_kQuiz))) {
      _quiz[k.substring(_kQuiz.length)] = p.getInt(k) ?? 0;
    }
  }

  bool isDone(String lessonId) => _done.contains(lessonId);

  /// 0 = follow the system, 1 = always dark, 2 = always light.
  int get theme => _theme;
  bool get reduceMotion => _reduceMotion;
  bool get autoSpeak => _autoSpeak;

  /// Who the app opens for: 0 = not asked yet (first launch), 1 = everyday (front door), 2 = enthusiast (the Lab).
  int get audience => _audience;

  void setAudience(int v) {
    _audience = v;
    _prefs?.setInt(_kAudience, v);
    notifyListeners();
  }

  void setTheme(int v) {
    _theme = v;
    _prefs?.setInt(_kTheme, v);
    notifyListeners();
  }

  void setReduceMotion(bool v) {
    _reduceMotion = v;
    _prefs?.setBool(_kStill, v);
    notifyListeners();
  }

  void setAutoSpeak(bool v) {
    _autoSpeak = v;
    _prefs?.setBool(_kSpeak, v);
    notifyListeners();
  }

  int get doneCount => _done.length;
  String? get lastLesson => _last;

  /// The track the last lesson was opened in (null = its home section).
  int? get lastTrack => _lastTrack;
  int? quizScore(String quizId) => _quiz[quizId];
  bool foundEgg(String egg) => _eggs.contains(egg);

  /// Fraction of [lessonIds] completed, 0..1.
  double fraction(Iterable<String> lessonIds) {
    final ids = lessonIds.toList();
    if (ids.isEmpty) return 0;
    return ids.where(_done.contains).length / ids.length;
  }

  void markDone(String lessonId) {
    if (_done.add(lessonId)) {
      _prefs?.setStringList(_kDone, _done.toList());
      notifyListeners();
    }
  }

  void setLast(String lessonId, [int? track]) {
    if (_last == lessonId && _lastTrack == track) return;
    _last = lessonId;
    _lastTrack = track;
    _prefs?.setString(_kLast, lessonId);
    if (track == null) {
      _prefs?.remove(_kLastTrack);
    } else {
      _prefs?.setInt(_kLastTrack, track);
    }
    notifyListeners();
  }

  void setQuizScore(String quizId, int score) {
    final best = _quiz[quizId];
    if (best != null && best >= score) return;
    _quiz[quizId] = score;
    _prefs?.setInt('$_kQuiz$quizId', score);
    notifyListeners();
  }

  void markEgg(String egg) {
    if (_eggs.add(egg)) {
      _prefs?.setStringList(_kEggs, _eggs.toList());
      notifyListeners();
    }
  }

  /// Forget lessons, quiz scores and found eggs (settings are kept).
  void reset() {
    _done.clear();
    _eggs.clear();
    _quiz.clear();
    _last = null;
    _lastTrack = null;
    for (final k in [_kDone, _kEggs, _kLast, _kLastTrack, ...?_prefs?.getKeys().where((k) => k.startsWith(_kQuiz))]) {
      _prefs?.remove(k);
    }
    notifyListeners();
  }
}

/// Makes the [ProgressStore] available below it: `AppScope.progress(context)`.
class AppScope extends InheritedNotifier<ProgressStore> {
  const AppScope({super.key, required ProgressStore progress, required super.child}) : super(notifier: progress);

  static ProgressStore progress(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// Read without subscribing to changes (for callbacks).
  static ProgressStore read(BuildContext context) => context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
