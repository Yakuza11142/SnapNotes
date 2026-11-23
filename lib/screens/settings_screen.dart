import 'package:flutter/material.dart';

import '../controllers/study_controller.dart';

class SettingsScreen extends StatefulWidget {
  final StudyController controller;

  const SettingsScreen({super.key, required this.controller});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _localeController;

  @override
  void initState() {
    super.initState();
    _localeController = TextEditingController(
      text: widget.controller.settings.speechLocale,
    );
    widget.controller.addListener(_onControllerChange);
  }

  void _onControllerChange() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    _localeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.controller.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Appearance',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (selection) {
              widget.controller.updateSettings(
                settings.copyWith(themeMode: selection.first),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Study Generation Limit: ${settings.maxStudyItems} items',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            min: 3,
            max: 10,
            divisions: 7,
            label: '${settings.maxStudyItems}',
            value: settings.maxStudyItems.toDouble(),
            onChanged: (value) {
              widget.controller.updateSettings(
                settings.copyWith(maxStudyItems: value.round()),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Voice Read-Aloud Speed: ${settings.speechRate.toStringAsFixed(2)}x',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            min: 0.25,
            max: 1.0,
            divisions: 15,
            label: settings.speechRate.toStringAsFixed(2),
            value: settings.speechRate,
            onChanged: (value) {
              widget.controller.updateSettings(
                settings.copyWith(speechRate: value),
              );
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _localeController,
            decoration: const InputDecoration(
              labelText: 'Speech Locale (e.g. en-US, en-GB)',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              widget.controller.updateSettings(
                settings.copyWith(speechLocale: value),
              );
            },
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () {
                final messenger = ScaffoldMessenger.of(context);
                widget.controller.updateSettings(
                  settings.copyWith(speechLocale: _localeController.text),
                );
                messenger.showSnackBar(
                  const SnackBar(content: Text('Speech locale saved')),
                );
              },
              child: const Text('Apply Locale'),
            ),
          ),
          const Divider(height: 32),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('SnapNotes'),
            subtitle: Text('Local-first capture, summary & flashcard study app'),
          ),
        ],
      ),
    );
  }
}
