import 'package:flutter/material.dart';

import 'controllers/study_controller.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SnapNotesApp());
}

class SnapNotesApp extends StatefulWidget {
  const SnapNotesApp({super.key});

  @override
  State<SnapNotesApp> createState() => _SnapNotesAppState();
}

class _SnapNotesAppState extends State<SnapNotesApp> {
  late final StudyController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StudyController()
      ..addListener(_onSettingsChanged)
      ..initialize();
  }

  void _onSettingsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onSettingsChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF0F766E);

    return MaterialApp(
      title: 'SnapNotes',
      debugShowCheckedModeBanner: false,
      themeMode: _controller.settings.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
      ),
      home: HomeScreen(controller: _controller),
    );
  }
}
