import 'flashcard.dart';

class StudyNote {
  final String id;
  final String title;
  final String rawText;
  final List<String> summaryBullets;
  final List<Flashcard> flashcards;
  final DateTime createdAt;

  const StudyNote({
    required this.id,
    required this.title,
    required this.rawText,
    required this.summaryBullets,
    required this.flashcards,
    required this.createdAt,
  });

  int get masteredCount => flashcards.where((card) => card.isMastered).length;

  double get masteryRatio {
    if (flashcards.isEmpty) return 0.0;
    return masteredCount / flashcards.length;
  }

  StudyNote copyWith({
    String? id,
    String? title,
    String? rawText,
    List<String>? summaryBullets,
    List<Flashcard>? flashcards,
    DateTime? createdAt,
  }) {
    return StudyNote(
      id: id ?? this.id,
      title: title ?? this.title,
      rawText: rawText ?? this.rawText,
      summaryBullets: summaryBullets ?? this.summaryBullets,
      flashcards: flashcards ?? this.flashcards,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'rawText': rawText,
      'summaryBullets': summaryBullets,
      'flashcards': flashcards.map((card) => card.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StudyNote.fromJson(Map<String, dynamic> json) {
    final rawBullets = json['summaryBullets'] as List<dynamic>? ?? const [];
    final rawCards = json['flashcards'] as List<dynamic>? ?? const [];
    final parsedDate = DateTime.tryParse(json['createdAt'] as String? ?? '');

    return StudyNote(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Note',
      rawText: json['rawText'] as String? ?? '',
      summaryBullets: rawBullets.map((item) => item.toString()).toList(),
      flashcards: rawCards
          .whereType>()
          .map(Flashcard.fromJson)
          .toList(),
      createdAt: parsedDate ?? DateTime.now(),
    );
  }
}
