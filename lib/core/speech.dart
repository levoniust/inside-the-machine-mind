import 'package:flutter_tts/flutter_tts.dart';

import '../widgets/term_text.dart';

/// Bit's voice: the phone's built-in text-to-speech engine (works offline with the installed voices).
class BitVoice {
  BitVoice._();
  static final BitVoice instance = BitVoice._();

  FlutterTts? _tts;
  bool _broken = false;

  Future<void> say(String markup) async {
    if (_broken) return;
    try {
      _tts ??= FlutterTts()
        ..setSpeechRate(0.48)
        ..setPitch(1.15);
      await _tts!.stop();
      await _tts!.speak(TermText.plain(markup));
    } catch (_) {
      _broken = true; // no TTS engine (or running in tests): stay silent
    }
  }

  Future<void> stop() async {
    try {
      await _tts?.stop();
    } catch (_) {}
  }
}
