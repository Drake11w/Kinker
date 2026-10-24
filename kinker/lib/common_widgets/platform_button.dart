import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'platform_widget.dart';

class PlatformButton extends PlatformWidget<CupertinoButton, TextButton> {
  const PlatformButton({super.key, required this.child, this.color, this.onPressed});
  final Widget child;
  final Color? color;
  final VoidCallback? onPressed;

  @override
  CupertinoButton buildCupertinoWidget(BuildContext context) {
    return CupertinoButton(
      color: color,
      pressedOpacity: 0.5,
      onPressed: onPressed,
      child: child,
    );
  }

  @override
  TextButton buildMaterialWidget(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(backgroundColor: color),
      onPressed: onPressed,
      child: child,
    );
  }
}
