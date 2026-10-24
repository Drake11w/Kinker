import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'platform_widget.dart';

class PlatformAlertDialog extends PlatformWidget<CupertinoAlertDialog, AlertDialog> {
  const PlatformAlertDialog({
    super.key,
    required this.title,
    required this.content,
    this.cancelText,
    required this.confirmText,
  });

  final String title;
  final String content;
  final String? cancelText;
  final String confirmText;

  @override
  AlertDialog buildMaterialWidget(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _actions(context, cancelText, confirmText),
    );
  }

  @override
  CupertinoAlertDialog buildCupertinoWidget(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _actions(context, cancelText, confirmText),
    );
  }

  List<Widget> _actions(
      BuildContext context, String? cancelText, String confirmText) {
    var actions = <Widget>[];
    if (cancelText != null) {
      actions.add(PlatformAlertDialogAction(
        child: Text(cancelText),
        onPressed: () => _dismiss(context, false),
      ));
    }
    actions.add(PlatformAlertDialogAction(
      child: Text(confirmText),
      onPressed: () => _dismiss(context, true),
    ));
    return actions;
  }

  Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: !PlatformWidget.isCupertino(context),
      builder: (context) => this,
    );
    // showDialog returns null if the dialog has been dismissed with the back
    // button on Android.
    // here we ensure that we return only true or false
    return result ?? false;
  }

  void _dismiss(BuildContext context, bool value) {
    Navigator.of(context, rootNavigator: true).pop(value);
  }
}

class PlatformAlertDialogAction extends PlatformWidget<CupertinoDialogAction, TextButton> {
  const PlatformAlertDialogAction({super.key, required this.child, this.onPressed});
  final Widget child;
  final VoidCallback? onPressed;

  @override
  TextButton buildMaterialWidget(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: child,
    );
  }

  @override
  CupertinoDialogAction buildCupertinoWidget(BuildContext context) {
    return CupertinoDialogAction(
      onPressed: onPressed,
      child: child,
    );
  }
}
