import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/study_controller.dart';
import '../models/study_note.dart';

class StudyDetailScreen extends StatefulWidget {
  final String noteId;
  final StudyController controller;

  const StudyDetailScreen({
    super.key,
    required this.noteId,
    required this.controller,
  });

  @override
  State<StudyDetailScreen> createState() => _StudyDetailScreenState();
}

class _StudyDetailScreenState extends State<StudyDetailScreen> {
  final Set<String> _revealedCardIds = <String>{};
  bool _onlyNeedsReview = false;
  bool _isEditing = false;

  late final TextEditingController _titleController;
  late final TextEditingController _bulletsController;

  @override
  void initState() {
    super.initState();
    final initialNote = widget.controller.noteById(widget.noteId);
    _titleController = TextEditingController(text: initialNote?.title ?? '');
    _bulletsController = TextEditingController(
      text: initialNote?.summaryBullets.join('\n') ?? '',
    );
    widget.controller.addListener(_handleControllerUpdate);
  }

  void _handleControllerUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerUpdate);
    _titleController.dispose();
    _bulletsController.dispose();
    widget.controller.stopSpeaking();
    super.dispose();
  }

  Future<void> _saveEdits(StudyNote currentNote) async {
    final updatedTitle = _titleController.text.trim().isEmpty
        ? currentNote.title
        : _titleController.text.trim();
    final updatedBullets = _bulletsController.text
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.replaceFirst(RegExp(r'^[•\-\*]\s*'), '').trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final editedNote = currentNote.copyWith(
      title: updatedTitle,
      summaryBullets:
          updatedBullets.isNotEmpty ? updatedBullets : currentNote.summaryBullets,
    );

    await widget.controller.updateNote(editedNote);
    if (!mounted) return;
    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _copyStudySet(StudyNote note) async {
    final formatted = widget.controller.formatNoteForSharing(note);
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: formatted));
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Study set copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.controller.noteById(widget.noteId);
    if (note == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Study Set')),
        body: const Center(child: Text('Study note not found.')),
      );
    }

    final visibleCards = _onlyNeedsReview
        ? note.flashcards.where((card) => !card.isMastered).toList()
        : note.flashcards;

    return Scaffold(
      appBar: AppBar(
        title: Text(note.title),
        actions: [
          IconButton(
            tooltip: _isEditing ? 'Cancel edit' : 'Edit title & bullets',
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                if (!_isEditing) {
                  _titleController.text = note.title;
                  _bulletsController.text = note.summaryBullets.join('\n');
                }
                _isEditing = !_isEditing;
              });
            },
          ),
          IconButton(
            tooltip: 'Read summary aloud',
            icon: const Icon(Icons.volume_up),
            onPressed: () => widget.controller.speakNoteSummary(note),
          ),
          IconButton(
            tooltip: 'Stop audio',
            icon: const Icon(Icons.stop),
            onPressed: () => widget.controller.stopSpeaking(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'copy') {
                await _copyStudySet(note);
              } else if (value == 'reset') {
                await widget.controller.resetFlashcardProgress(note.id);
                if (!mounted) return;
                setState(() {
                  _revealedCardIds.clear();
                });
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'copy',
                child: Text('Copy study set'),
              ),
              PopupMenuItem(
                value: 'reset',
                child: Text('Reset flashcard progress'),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Mastery Progress'),
                      Text(
                        '${note.masteredCount} / ${note.flashcards.length} mastered',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: note.masteryRatio),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Key Points',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_isEditing) ...[
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Note Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bulletsController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Summary Bullets (one per line)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () => _saveEdits(note),
              icon: const Icon(Icons.save),
              label: const Text('Save Changes'),
            ),
          ] else ...[
            ...note.summaryBullets.map(
              (bullet) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  '),
                    Expanded(child: Text(bullet)),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Flashcards',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              FilterChip(
                label: const Text('Needs Review'),
                selected: _onlyNeedsReview,
                onSelected: (selected) {
                  setState(() {
                    _onlyNeedsReview = selected;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (visibleCards.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No flashcards match the current filter.'),
            )
          else
            ...visibleCards.map((card) {
              final isRevealed = _revealedCardIds.contains(card.id);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (isRevealed) {
                              _revealedCardIds.remove(card.id);
                            } else {
                              _revealedCardIds.add(card.id);
                            }
                          });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.question,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isRevealed
                                  ? card.answer
                                  : 'Tap question to reveal answer',
                              style: TextStyle(
                                color: isRevealed
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => widget.controller
                                  .setFlashcardMastery(
                                noteId: note.id,
                                flashcardId: card.id,
                                isMastered: false,
                              ),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Review Again'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => widget.controller
                                  .setFlashcardMastery(
                                noteId: note.id,
                                flashcardId: card.id,
                                isMastered: true,
                              ),
                              icon: const Icon(Icons.check),
                              label: Text(card.isMastered ? 'Mastered' : 'Got It'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
