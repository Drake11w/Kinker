import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The user's light/dark preference, saved on the device.
class ThemeSettings extends ValueNotifier<ThemeMode> {
  ThemeSettings([super.value = ThemeMode.system, this._prefs]);

  static const _key = 'themeMode';

  final SharedPreferences? _prefs;

  /// Loads the saved preference. Falls back to following the system setting
  /// (and not persisting) if device storage is unavailable.
  static Future<ThemeSettings> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_key);
      final mode = ThemeMode.values.firstWhere(
        (m) => m.name == saved,
        orElse: () => ThemeMode.system,
      );
      return ThemeSettings(mode, prefs);
    } catch (e) {
      debugPrint('Theme preference unavailable: $e');
      return ThemeSettings();
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    value = mode;
    await _prefs?.setString(_key, mode.name);
  }
}
