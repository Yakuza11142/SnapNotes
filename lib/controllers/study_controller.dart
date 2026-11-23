import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/app_settings.dart';
import '../models/flashcard.dart';
import '../models/study_note.dart';
import '../services/capture_and_ocr_service.dart';
import '../services/local_storage_service.dart';
import '../services/settings_service.dart';
import '../services/speech_service.dart';
import '../services/study_generator_service.dart';

class StudyController extends ChangeNotifier {
  final LocalStorageService _storage;
  final SettingsService _settingsService;
  final CaptureAndOcrService _ocr;
  final SpeechService _speech;
  final StudyGeneratorService _generator;

  StudyController({
    LocalStorageService? storage,
    SettingsService? settingsService,
    CaptureAndOcrService? ocr,
    SpeechService? speech,
    StudyGeneratorService? generator,
  })  : _storage = storage ?? LocalStorageService(),
        _settingsService = settingsService ?? SettingsService(),
        _ocr = ocr ?? CaptureAndOcrService(),
        _speech = speech ?? SpeechService(),
        _generator = generator ?? StudyGeneratorService();

  AppSettings _settings = const AppSettings();
  List<StudyNote> _notes = const [];
  bool _isLoading = false;
  bool _isListening = false;
  String _draftText = '';
  String? _errorMessage;

  AppSettings get settings => _settings;
  List<StudyNote> get notes => _notes;
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  String get draftText => _draftText;
  String? get errorMessage => _errorMessage;

  StudyNote? noteById(String id) {
    for (final note in _notes) {
      if (note.id == id) return note;
    }
    return null;
  }

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _settings = await _settingsService.loadSettings();
      await _speech.init(settings: _settings);
      _notes = await _storage.loadNotes();
    } catch (e) {
      _errorMessage = 'Failed to initialize SnapNotes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings(AppSettings updated) async {
    _settings = updated;
    notifyListeners();
    await _settingsService.saveSettings(updated);
    await _speech.applySettings(updated);
  }

  void updateDraftText(String text) {
    _draftText = text;
    if (_errorMessage != null) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void clearDraft() {
    _draftText = '';
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> captureFromSource(ImageSource source) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final extracted = await _ocr.captureAndExtractText(source: source);
      if (extracted != null && extracted.isNotEmpty) {
        _draftText = _draftText.trim().isEmpty
            ? extracted
            : '${_draftText.trim()}\n$extracted';
      } else if (extracted != null) {
        _errorMessage = 'No readable text detected in that image.';
      }
    } catch (e) {
      _errorMessage = 'Image capture or text scan failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleVoiceDictation() async {
    if (_isListening) {
      await _speech.stopListening();
      _isListening = false;
      notifyListeners();
      return;
    }

    _errorMessage = null;
    final started = await _speech.startListening(
      onResult: (transcript, isFinal) {
        _draftText = transcript;
        if (isFinal) {
          _isListening = false;
        }
        notifyListeners();
      },
    );

    if (!started) {
      _errorMessage =
          'Speech recognition unavailable on this device or offline pack missing.';
      _isListening = false;
      notifyListeners();
      return;
    }

    _isListening = true;
    notifyListeners();
  }

  Future<StudyNote?> createStudyNoteFromDraft({String? customTitle}) async {
    final cleaned = _draftText.trim();
    if (cleaned.isEmpty) {
      _errorMessage = 'Enter, scan, or speak study text before generating notes.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final id = 'note_${now.microsecondsSinceEpoch}';
      final title = (customTitle != null && customTitle.trim().isNotEmpty)
          ? customTitle.trim()
          : _generator.buildTitle(cleaned);
      final limit = _settings.maxStudyItems;
      final bullets = _generator.buildSummaryBullets(cleaned, maxBullets: limit);
      final List<Flashcard> cards =
          _generator.buildFlashcards(cleaned, baseId: id, maxCards: limit);

      final note = StudyNote(
        id: id,
        title: title,
        rawText: cleaned,
        summaryBullets: bullets,
        flashcards: cards,
        createdAt: now,
      );

      final updated = [note, ..._notes];
      await _storage.saveNotes(updated);
      _notes = updated;
      _draftText = '';
      return note;
    } catch (e) {
      _errorMessage = 'Could not save study note: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateNote(StudyNote updatedNote) async {
    final updatedList = _notes
        .map((note) => note.id == updatedNote.id ? updatedNote : note)
        .toList();
    await _storage.saveNotes(updatedList);
    _notes = updatedList;
    notifyListeners();
  }

  Future<void> setFlashcardMastery({
    required String noteId,
    required String flashcardId,
    required bool isMastered,
  }) async {
    final updatedList = _notes.map((note) {
      if (note.id != noteId) return note;
      final updatedCards = note.flashcards.map((card) {
        if (card.id != flashcardId) return card;
        return card.copyWith(
          isMastered: isMastered,
          reviewCount: card.reviewCount + 1,
        );
      }).toList();
      return note.copyWith(flashcards: updatedCards);
    }).toList();

    await _storage.saveNotes(updatedList);
    _notes = updatedList;
    notifyListeners();
  }

  Future<void> resetFlashcardProgress(String noteId) async {
    final updatedList = _notes.map((note) {
      if (note.id != noteId) return note;
      final resetCards = note.flashcards
          .map((card) => card.copyWith(isMastered: false, reviewCount: 0))
          .toList();
      return note.copyWith(flashcards: resetCards);
    }).toList();

    await _storage.saveNotes(updatedList);
    _notes = updatedList;
    notifyListeners();
  }

  Future<void> deleteNote(String noteId) async {
    final updated = _notes.where((n) => n.id != noteId).toList();
    await _storage.saveNotes(updated);
    _notes = updated;
    notifyListeners();
  }

  String formatNoteForSharing(StudyNote note) {
    final buffer = StringBuffer()
      ..writeln(note.title)
      ..writeln('--- Key Points ---');
    for (final b in note.summaryBullets) {
      buffer.writeln('• $b');
    }
    if (note.flashcards.isNotEmpty) {
      buffer.writeln('--- Flashcards ---');
      for (int i = 0; i < note.flashcards.length; i++) {
        final c = note.flashcards[i];
        buffer.writeln('Q${i + 1}: ${c.question}');
        buffer.writeln('A${i + 1}: ${c.answer}');
      }
    }
    return buffer.toString().trim();
  }

  Future<void> speakNoteSummary(StudyNote note) async {
    final spoken = note.summaryBullets.isNotEmpty
        ? note.summaryBullets.join('. ')
        : note.rawText;
    await _speech.speak(spoken);
  }

  Future<void> stopSpeaking() async {
    await _speech.stopSpeaking();
  }

  @override
  void dispose() {
    _ocr.dispose();
    _speech.dispose();
    super.dispose();
  }
}
