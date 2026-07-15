import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeControllerProvider = NotifierProvider<ThemeController, ThemeMode>(
  ThemeController.new,
);

class ThemeController extends Notifier<ThemeMode> {
  static const String _key = 'theme_mode';

  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString(_key);
      if (themeString != null) {
        switch (themeString) {
          case 'dark':
            state = ThemeMode.dark;
            break;
          case 'light':
            state = ThemeMode.light;
            break;
          case 'system':
          default:
            state = ThemeMode.system;
            break;
        }
      }
    } catch (e) {
      state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      String val = 'system';
      if (mode == ThemeMode.dark) {
        val = 'dark';
      } else if (mode == ThemeMode.light) {
        val = 'light';
      }
      await prefs.setString(_key, val);
    } catch (e) {
      // Ignored
    }
  }
}
