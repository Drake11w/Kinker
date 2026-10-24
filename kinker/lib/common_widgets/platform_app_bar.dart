import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'platform_widget.dart';

class PlatformAppBar extends PlatformWidget<CupertinoNavigationBar, AppBar> {
  const PlatformAppBar({super.key, this.leading, this.title, this.actions = const []});
  final Widget? leading;
  final Widget? title;
  final List<Widget> actions;

  @override
  CupertinoNavigationBar buildCupertinoWidget(BuildContext context) {
    return CupertinoNavigationBar(
      leading: leading,
      middle: title,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: actions,
      ),
    );
  }

  @override
  AppBar buildMaterialWidget(BuildContext context) {
    return AppBar(
      leading: leading,
      title: title,
      actions: actions,
    );
  }
}
