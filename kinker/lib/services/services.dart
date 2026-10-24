import 'package:flutter/widgets.dart';

import 'auth.dart';
import 'repository.dart';

/// Makes the app's services available to the widget tree.
class Services extends InheritedWidget {
  const Services({
    super.key,
    required this.auth,
    required this.repository,
    this.isDemo = false,
    required super.child,
  });

  final BaseAuth auth;
  final Repository repository;

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
      isDemo != oldWidget.isDemo;
}
