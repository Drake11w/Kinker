import 'package:flutter/material.dart';

/// Base class to be extended by all platform aware widgets
abstract class PlatformWidget<C extends Widget, M extends Widget>
    extends StatelessWidget {
  const PlatformWidget({super.key});

  C buildCupertinoWidget(BuildContext context);
  M buildMaterialWidget(BuildContext context);

  static bool isCupertino(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  @override
  Widget build(BuildContext context) {
    if (isCupertino(context)) {
      // Use Cupertino on Apple platforms
      return buildCupertinoWidget(context);
    }
    // Use Material design on Android and other platforms
    return buildMaterialWidget(context);
  }
}
