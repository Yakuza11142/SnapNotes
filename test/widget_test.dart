import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapnotes/models/flashcard.dart';
import 'package:snapnotes/models/study_note.dart';
import 'package:snapnotes/services/study_generator_service.dart';

void main() {
  test('StudyGeneratorService creates summary bullets and flashcards', () {
    const sampleText =
        'Photosynthesis is the process by which green plants convert light energy into chemical energy. '
        'Chlorophyll absorbs light primarily in the red and blue wavelengths. '
        'Glucose is produced and oxygen is released as a byproduct.';

    final generator = StudyGeneratorService();
    final bullets = generator.buildSummaryBullets(sampleText, maxBullets: 5);
    final cards = generator.buildFlashcards(
      sampleText,
      baseId: 'test_note',
      maxCards: 5,
    );

    expect(bullets, isNotEmpty);
    expect(cards, isNotEmpty);
    expect(cards.first.question, isNotEmpty);
    expect(cards.first.answer, isNotEmpty);
  });

  test('StudyNote serializes and deserializes with mastery count', () {
    final note = StudyNote(
      id: 'n1',
      title: 'Cell Biology',
      rawText: 'Mitochondria generate ATP.',
      summaryBullets: const ['Mitochondria generate ATP.'],
      flashcards: const [
        Flashcard(
          id: 'c1',
          question: 'What do mitochondria generate?',
          answer: 'Mitochondria generate ATP.',
          isMastered: true,
          reviewCount: 2,
        ),
      ],
      createdAt: DateTime.parse('2026-11-23T12:00:00.000Z'),
    );

    final restored = StudyNote.fromJson(note.toJson());
    expect(restored.id, 'n1');
    expect(restored.masteredCount, 1);
    expect(restored.flashcards.first.reviewCount, 2);
  });

  testWidgets('Basic MaterialApp renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Text('SnapNotes Ready')),
      ),
    );
    expect(find.text('SnapNotes Ready'), findsOneWidget);
  });
}
