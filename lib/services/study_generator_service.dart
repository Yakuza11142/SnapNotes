import '../models/flashcard.dart';

class StudyGeneratorService {
  static const Set<String> _stopWords = {
    'this',
    'that',
    'with',
    'from',
    'into',
    'they',
    'them',
    'their',
    'there',
    'which',
    'when',
    'where',
    'what',
    'were',
    'been',
    'have',
    'will',
    'would',
    'could',
    'should',
    'about',
    'after',
    'before',
    'because',
    'between',
    'through',
    'during',
    'under',
    'over',
    'also',
    'only',
    'very',
    'more',
    'most',
    'some',
    'such',
    'than',
    'then',
    'each',
    'other',
  };

  String buildTitle(String rawText) {
    final lines = rawText
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) return 'Untitled Note';
    final firstLine = lines.first;
    return firstLine.length > 48
        ? '${firstLine.substring(0, 48).trim()}...'
        : firstLine;
  }

  List<String> buildSummaryBullets(String rawText, {int maxBullets = 6}) {
    final normalized = rawText.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return const [];

    final rawCandidates = normalized
        .split(RegExp(r'(?<=[.!?])\s+|\s*;\s*|\s*•\s*'))
        .map((s) => s.trim())
        .where((s) => s.length >= 10)
        .toList();

    if (rawCandidates.isEmpty) {
      return [normalized];
    }

    final scored = <_ScoredSentence>[];
    for (int i = 0; i < rawCandidates.length; i++) {
      scored.add(
        _ScoredSentence(
          text: rawCandidates[i],
          index: i,
          score: _scoreSentence(rawCandidates[i]),
        ),
      );
    }

    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return a.index.compareTo(b.index);
    });

    final selected = <_ScoredSentence>[];
    for (final candidate in scored) {
      if (selected.length >= maxBullets) break;
      final isTooSimilar = selected.any(
        (existing) => _jaccardSimilarity(existing.text, candidate.text) > 0.65,
      );
      if (!isTooSimilar) {
        selected.add(candidate);
      }
    }

    selected.sort((a, b) => a.index.compareTo(b.index));
    return selected.map((item) => item.text).toList();
  }

  List<Flashcard> buildFlashcards(
    String rawText, {
    required String baseId,
    int maxCards = 6,
  }) {
    final bullets = buildSummaryBullets(rawText, maxBullets: maxCards);
    final cards = <Flashcard>[];

    for (int i = 0; i < bullets.length; i++) {
      final point = bullets[i];
      cards.add(
        _buildCardForPoint(
          point: point,
          id: '${baseId}_card_$i',
          variantIndex: i,
        ),
      );
    }

    return cards;
  }

  Flashcard _buildCardForPoint({
    required String point,
    required String id,
    required int variantIndex,
  }) {
    final definitionMatch = RegExp(
      r'^([A-Za-z][A-Za-z0-9\s-]{2,32}?)\s+(?:is|are|refers to|means|represents)\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(point);

    if (definitionMatch != null) {
      final term = definitionMatch.group(1)!.trim();
      return Flashcard(
        id: id,
        question: 'Define or explain "$term".',
        answer: point,
      );
    }

    final keywords = _extractKeywords(point);
    final primaryKeyword =
        keywords.isNotEmpty ? keywords.first : 'this concept';

    if (variantIndex % 2 == 1 && keywords.length >= 2) {
      final targetWord = keywords[1];
      final blanked = point.replaceFirst(
        RegExp('\\b${RegExp.escape(targetWord)}\\b', caseSensitive: false),
        '_____',
      );
      if (blanked != point) {
        return Flashcard(
          id: id,
          question: 'Complete the statement: "$blanked"',
          answer: point,
        );
      }
    }

    return Flashcard(
      id: id,
      question: 'What is the key takeaway regarding "$primaryKeyword"?',
      answer: point,
    );
  }

  double _scoreSentence(String sentence) {
    double score = 0;
    final lower = sentence.toLowerCase();

    if (RegExp(
      r'\b(is|are|refers to|means|defined as|consists of|causes|results in)\b',
    ).hasMatch(lower)) {
      score += 3.0;
    }
    if (RegExp(r'\d').hasMatch(sentence)) {
      score += 2.0;
    }
    score += (_extractKeywords(sentence).length * 0.75).clamp(0.0, 4.5);

    if (sentence.length < 18) {
      score -= 1.5;
    } else if (sentence.length > 220) {
      score -= 1.0;
    }

    return score;
  }

  List<String> _extractKeywords(String text) {
    final tokens = text
        .replaceAll(RegExp(r'[^A-Za-z0-9\s-]'), ' ')
        .split(RegExp(r'\s+'))
        .map((w) => w.trim())
        .where((w) => w.length >= 4 && !_stopWords.contains(w.toLowerCase()))
        .toList();

    final seen = <String>{};
    final result = <String>[];
    for (final token in tokens) {
      final key = token.toLowerCase();
      if (seen.add(key)) {
        result.add(token);
      }
    }
    return result;
  }

  double _jaccardSimilarity(String a, String b) {
    final setA = a
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toSet();
    final setB = b
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toSet();

    if (setA.isEmpty || setB.isEmpty) return 0.0;
    final intersection = setA.intersection(setB).length;
    final union = setA.union(setB).length;
    return union == 0 ? 0.0 : intersection / union;
  }
}

class _ScoredSentence {
  final String text;
  final int index;
  final double score;

  const _ScoredSentence({
    required this.text,
    required this.index,
    required this.score,
  });
}
