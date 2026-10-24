import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'platform_widget.dart';

class PlatformSwitch extends PlatformWidget<CupertinoSwitch, Switch> {
  const PlatformSwitch({super.key, required this.value, this.onChanged});
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  CupertinoSwitch buildCupertinoWidget(BuildContext context) {
    return CupertinoSwitch(value: value, onChanged: onChanged);
  }

  @override
  Switch buildMaterialWidget(BuildContext context) {
    return Switch(value: value, onChanged: onChanged);
  }
}
