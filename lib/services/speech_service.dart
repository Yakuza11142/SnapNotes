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
    _sttAvailable = await _stt.initialize();
  }

  Future<void> applySettings(AppSettings settings) async {
    _localeId = settings.speechLocale;
    await _tts.setLanguage(_localeId);
    await _tts.setSpeechRate(settings.speechRate);
  }

  Future<void> speak(String text) async {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return;
    await _tts.stop();
    await _tts.speak(cleaned);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  Future<bool> startListening({
    required void Function(String transcript, bool isFinal) onResult,
  }) async {
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
  }

  Future<void> stopListening() async {
    if (_stt.isListening) {
      await _stt.stop();
    }
  }

  Future<void> dispose() async {
    await _stt.cancel();
    await _tts.stop();
  }
}
