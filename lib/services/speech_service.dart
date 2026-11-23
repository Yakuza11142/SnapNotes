import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/app_settings.dart';

class SpeechService {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();

  bool _sttAvailable = false;
  String _localeId = 'en-US';

  Future<void> init({AppSettings settings = const AppSettings()}) async {
    await applySettings(settings);
    try {
      _sttAvailable = await _stt.initialize();
    } catch (_) {
      _sttAvailable = false;
    }
  }

  Future<void> applySettings(AppSettings settings) async {
    _localeId = settings.speechLocale;
    try {
      await _tts.setLanguage(_localeId);
      await _tts.setSpeechRate(settings.speechRate);
    } catch (_) {
      // Ignore unsupported browser voice engine parameters.
    }
  }

  Future<void> speak(String text) async {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return;
    try {
      await _tts.stop();
      await _tts.speak(cleaned);
    } catch (_) {
      // Ignore if browser audio autoplay/TTS is blocked.
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  Future<bool> startListening({
    required void Function(String transcript, bool isFinal) onResult,
  }) async {
    try {
      if (!_sttAvailable) {
        _sttAvailable = await _stt.initialize();
      }
      if (!_sttAvailable) {
        return false;
      }

      await _tts.stop();
      await _stt.listen(
        localeId: _localeId,
        onResult: (SpeechRecognitionResult result) {
          onResult(result.recognizedWords, result.finalResult);
        },
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stopListening() async {
    try {
      if (_stt.isListening) {
        await _stt.stop();
      }
    } catch (_) {}
  }

  Future<void> dispose() async {
    try {
      await _stt.cancel();
    } catch (_) {}
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
