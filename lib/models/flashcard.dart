class Flashcard {
  final String id;
  final String question;
  final String answer;
  final bool isMastered;
  final int reviewCount;

  const Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.isMastered = false,
    this.reviewCount = 0,
  });

  Flashcard copyWith({
    String? id,
    String? question,
    String? answer,
    bool? isMastered,
    int? reviewCount,
  }) {
    return Flashcard(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      isMastered: isMastered ?? this.isMastered,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'isMastered': isMastered,
      'reviewCount': reviewCount,
    };
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    final rawReviewCount = json['reviewCount'];
    final parsedCount = rawReviewCount is int
        ? rawReviewCount
        : int.tryParse(rawReviewCount?.toString() ?? '') ?? 0;

    return Flashcard(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      isMastered: json['isMastered'] as bool? ?? false,
      reviewCount: parsedCount < 0 ? 0 : parsedCount,
    );
  }
}
