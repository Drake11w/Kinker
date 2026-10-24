import 'package:flutter/widgets.dart';

import 'auth.dart';
import 'repository.dart';
import 'theme_settings.dart';

/// Makes the app's services available to the widget tree.
class Services extends InheritedWidget {
  const Services({
    super.key,
    required this.auth,
    required this.repository,
    required this.themeSettings,
    this.isDemo = false,
    required super.child,
  });

  final BaseAuth auth;
  final Repository repository;
  final ThemeSettings themeSettings;

  /// True when running against local in-memory data instead of Firebase.
  final bool isDemo;

  static Services of(BuildContext context) {
    final services = context.dependOnInheritedWidgetOfExactType<Services>();
    assert(services != null, 'No Services found in context');
    return services!;
  }

  @override
  bool updateShouldNotify(Services oldWidget) =>
      auth != oldWidget.auth ||
      repository != oldWidget.repository ||
      themeSettings != oldWidget.themeSettings ||
      isDemo != oldWidget.isDemo;
}
