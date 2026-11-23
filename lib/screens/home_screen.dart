import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/study_controller.dart';
import 'settings_screen.dart';
import 'study_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final StudyController controller;

  const HomeScreen({super.key, required this.controller});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _textController;
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.controller.draftText);
    _searchController = TextEditingController();
    widget.controller.addListener(_syncFromController);
  }

  void _syncFromController() {
    if (!mounted) return;
    if (_textController.text != widget.controller.draftText) {
      _textController.value = TextEditingValue(
        text: widget.controller.draftText,
        selection: TextSelection.collapsed(
          offset: widget.controller.draftText.length,
        ),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncFromController);
    _textController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerate() async {
    final created = await widget.controller.createStudyNoteFromDraft();
    final navigator = Navigator.of(context);
    if (!mounted || created == null) return;

    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => StudyDetailScreen(
          noteId: created.id,
          controller: widget.controller,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final query = _searchQuery.trim().toLowerCase();
    final filteredNotes = query.isEmpty
        ? controller.notes
        : controller.notes.where((note) {
            return note.title.toLowerCase().contains(query) ||
                note.rawText.toLowerCase().contains(query) ||
                note.summaryBullets.any((b) => b.toLowerCase().contains(query));
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SnapNotes'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SettingsScreen(controller: controller),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: controller.isLoading
                      ? null
                      : () => controller.captureFromSource(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.isLoading
                      ? null
                      : () => controller.captureFromSource(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: controller.isListening ? 'Stop mic' : 'Voice note',
                onPressed: controller.isLoading
                    ? null
                    : () => controller.toggleVoiceDictation(),
                icon: Icon(controller.isListening ? Icons.mic_off : Icons.mic),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            maxLines: 5,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'Scanned text, voice notes, or typed study material...',
              suffixIcon: controller.draftText.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear draft',
                      icon: const Icon(Icons.clear),
                      onPressed: controller.clearDraft,
                    ),
            ),
            onChanged: controller.updateDraftText,
          ),
          if (controller.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              controller.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: controller.isLoading ? null : _handleGenerate,
            child: Text(
              controller.isLoading ? 'Processing...' : 'Generate Study Set',
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Saved Study Sets (${filteredNotes.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search saved notes...',
              border: const OutlineInputBorder(),
              isDense: true,
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 10),
          if (filteredNotes.isEmpty)
            const Text('No matching study sets.')
          else
            ...filteredNotes.map(
              (note) => Card(
                child: ListTile(
                  title: Text(note.title),
                  subtitle: Text(
                    '${note.summaryBullets.length} points • ${note.masteredCount}/${note.flashcards.length} mastered',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => controller.deleteNote(note.id),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => StudyDetailScreen(
                          noteId: note.id,
                          controller: controller,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
