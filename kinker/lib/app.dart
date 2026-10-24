import 'package:flutter/material.dart';

import 'pages/root_page.dart';
import 'services/auth.dart';
import 'services/repository.dart';
import 'services/services.dart';
import 'services/theme_settings.dart';

class KinkerApp extends StatefulWidget {
  const KinkerApp({
    super.key,
    required this.auth,
    required this.repository,
    this.themeSettings,
    this.isDemo = false,
  });

  final BaseAuth auth;
  final Repository repository;

  /// Defaults to an unsaved setting that follows the system theme.
  final ThemeSettings? themeSettings;
  final bool isDemo;

  static ThemeData buildTheme(Brightness brightness) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: brightness,
      ),
    );
  }

  @override
  State<KinkerApp> createState() => _KinkerAppState();
}

class _KinkerAppState extends State<KinkerApp> {
  late final ThemeSettings _ownedSettings = ThemeSettings();

  ThemeSettings get _themeSettings => widget.themeSettings ?? _ownedSettings;

  @override
  void dispose() {
    _ownedSettings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Services(
      auth: widget.auth,
      repository: widget.repository,
      themeSettings: _themeSettings,
      isDemo: widget.isDemo,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: _themeSettings,
        builder: (context, themeMode, _) => MaterialApp(
          title: 'Kinker',
          debugShowCheckedModeBanner: false,
          theme: KinkerApp.buildTheme(Brightness.light),
          darkTheme: KinkerApp.buildTheme(Brightness.dark),
          themeMode: themeMode,
          home: const RootPage(),
        ),
      ),
    );
  }
}
