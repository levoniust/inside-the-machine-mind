import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// The source library (text copies + original PDFs of every source) is a separate plug-in, not part of the app:
/// a "library pack" zip downloaded once from the app's GitHub release (or imported from a file), then read offline.
/// On the web the library sits next to the app (library/ on the same site), so it is always available.
class Library extends ChangeNotifier {
  Library._();
  static final Library instance = Library._();

  /// Pack version this app expects (manifest.json "version"). An older pack still works for the sources it has;
  /// sources added later ask for an update.
  static const version = '2026.11';
  static const packName = 'machine-mind-library-$version.zip';
  static const downloadUrl =
      'https://github.com/levoniust/inside-the-machine-mind/releases/download/library-$version/$packName';
  static const approxSizeMB = 65;

  Directory? _dir;
  bool _installed = false;
  String? _packVersion;
  double? _progress; // 0..1 while downloading or unpacking
  String? _error;

  bool get installed => kIsWeb || _installed;
  double? get progress => _progress;
  String? get error => _error;
  bool get busy => _progress != null;

  /// An older pack is installed: it works, but sources added since then are missing.
  bool get outdated => !kIsWeb && _installed && _packVersion != version;
  String? get packVersion => _packVersion;

  /// Whether this file is in the installed pack (an older pack may not have it).
  bool has(String path) => kIsWeb || (_installed && File('${_dir!.path}/$path').existsSync());

  /// Tests (and tools) can point the library at an unpacked folder, e.g. the repo's library/.
  void useDirectory(Directory dir) {
    _dir = dir;
    _installed = File('${dir.path}/sources/SRC-TRANSFORMER.txt').existsSync();
    _packVersion = _installed ? version : null;
    notifyListeners();
  }

  Future<void> init() async {
    if (kIsWeb || _dir != null) return;
    try {
      final docs = await getApplicationDocumentsDirectory();
      _dir = Directory('${docs.path}/library');
      final m = File('${_dir!.path}/manifest.json');
      _packVersion = m.existsSync() ? (jsonDecode(m.readAsStringSync()) as Map)['version'] as String? : null;
      _installed = _packVersion != null;
    } catch (e) {
      debugPrint('Library: no documents folder ($e)');
    }
    notifyListeners();
  }

  Future<String> loadText(String path) async {
    if (kIsWeb) return NetworkAssetBundle(Uri.base.resolve('library/')).loadString(path);
    // Synchronous on purpose: copies are at most a few MB, and it also works inside widget tests' fake clock.
    return File('${_dir!.path}/$path').readAsStringSync();
  }

  Future<Uint8List> loadBytes(String path) async {
    if (kIsWeb) return (await NetworkAssetBundle(Uri.base.resolve('library/')).load(path)).buffer.asUint8List();
    return File('${_dir!.path}/$path').readAsBytesSync();
  }

  /// Download the pack from the GitHub release (the only time the app uses the internet), then unpack it.
  Future<void> download() async {
    if (busy || _dir == null) return;
    _start();
    final tmp = File('${_dir!.parent.path}/$packName.part');
    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse(downloadUrl));
      final res = await req.close();
      if (res.statusCode != 200) throw HttpException('HTTP ${res.statusCode}');
      final total = res.contentLength;
      var got = 0;
      final sink = tmp.openWrite();
      await for (final chunk in res) {
        sink.add(chunk);
        got += chunk.length;
        if (total > 0) _setProgress(0.9 * got / total);
      }
      await sink.close();
      await _unpack(tmp);
    } catch (e) {
      _fail('Download failed: $e');
    } finally {
      client.close();
      if (tmp.existsSync()) tmp.deleteSync();
    }
  }

  /// Install from a pack file the user picked (no internet needed).
  Future<void> importFile(String path) async {
    if (busy || _dir == null) return;
    _start();
    try {
      await _unpack(File(path));
    } catch (e) {
      _fail('That file is not a library pack: $e');
    }
  }

  Future<void> remove() async {
    if (_dir != null && _dir!.existsSync()) await _dir!.delete(recursive: true);
    _installed = false;
    _packVersion = null;
    notifyListeners();
  }

  Future<void> _unpack(File zip) async {
    _setProgress(0.92);
    final archive = await compute(_decode, zip.path);
    final manifest = archive.findFile('manifest.json');
    if (manifest == null) throw const FormatException('no manifest.json');
    final m = jsonDecode(utf8.decode(manifest.content as List<int>)) as Map;
    final v = m['version'];
    if (v is! String) throw const FormatException('no version in manifest.json');
    if (_dir!.existsSync()) await _dir!.delete(recursive: true);
    for (final f in archive.files) {
      if (!f.isFile || f.name.contains('..')) continue;
      final out = File('${_dir!.path}/${f.name}');
      await out.parent.create(recursive: true);
      await out.writeAsBytes(f.content as List<int>);
    }
    _installed = true;
    _packVersion = v;
    _progress = null;
    notifyListeners();
  }

  static Archive _decode(String path) => ZipDecoder().decodeBytes(File(path).readAsBytesSync());

  void _start() {
    _error = null;
    _setProgress(0);
  }

  void _setProgress(double p) {
    _progress = p;
    notifyListeners();
  }

  void _fail(String message) {
    _error = message;
    _progress = null;
    notifyListeners();
  }
}
