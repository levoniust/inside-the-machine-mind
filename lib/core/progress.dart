import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers which lessons are done, quiz scores, the last lesson opened and found Easter eggs.
/// Persisted with shared_preferences; works in memory if storage is unavailable (tests).
class ProgressStore extends ChangeNotifier {
  ProgressStore([this._prefs]);

  static const _kDone = 'progress.done';
  static const _kLast = 'progress.last';
  static const _kQuiz = 'progress.quiz.';
  static const _kEggs = 'progress.eggs';

  final SharedPreferences? _prefs;
  final Set<String> _done = {};
  final Set<String> _eggs = {};
  final Map<String, int> _quiz = {};
  String? _last;

  static Future<ProgressStore> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      return ProgressStore(p).._read();
    } catch (_) {
      return ProgressStore();
    }
  }

  void _read() {
    final p = _prefs;
    if (p == null) return;
    _done.addAll(p.getStringList(_kDone) ?? const []);
    _eggs.addAll(p.getStringList(_kEggs) ?? const []);
    _last = p.getString(_kLast);
    for (final k in p.getKeys().where((k) => k.startsWith(_kQuiz))) {
      _quiz[k.substring(_kQuiz.length)] = p.getInt(k) ?? 0;
    }
  }

  bool isDone(String lessonId) => _done.contains(lessonId);
  int get doneCount => _done.length;
  String? get lastLesson => _last;
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

  void setLast(String lessonId) {
    if (_last == lessonId) return;
    _last = lessonId;
    _prefs?.setString(_kLast, lessonId);
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

  void reset() {
    _done.clear();
    _eggs.clear();
    _quiz.clear();
    _last = null;
    _prefs?.clear();
    notifyListeners();
  }
}

/// Makes the [ProgressStore] available below it: `AppScope.progress(context)`.
class AppScope extends InheritedNotifier<ProgressStore> {
  const AppScope({super.key, required ProgressStore progress, required super.child})
      : super(notifier: progress);

  static ProgressStore progress(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// Read without subscribing to changes (for callbacks).
  static ProgressStore read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
