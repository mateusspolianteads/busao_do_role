import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.dark);

  static final ValueNotifier<bool> loadingNotifier =
      ValueNotifier(false);

  static SharedPreferences? _prefs;

  static ThemeData? _cachedDarkTheme;
  static ThemeData? _cachedLightTheme;

  static bool get isDarkMode => themeNotifier.value == ThemeMode.dark;

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final isDark = _prefs?.getBool('isDarkMode') ?? true;
      themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      debugPrint('Erro ao inicializar ThemeController: $e');
    }
  }

  static Future<void> toggleTheme(bool isDark) async {
    loadingNotifier.value = true;

    await Future.delayed(const Duration(milliseconds: 150));

    themeNotifier.value =
        isDark ? ThemeMode.dark : ThemeMode.light;

    if (_prefs != null) {
      await _prefs!.setBool('isDarkMode', isDark);
    } else {
      _prefs = await SharedPreferences.getInstance();
      await _prefs!.setBool('isDarkMode', isDark);
    }

    loadingNotifier.value = false;
  }

  static Future<void> loadThemePreference() async {
    if (_prefs == null) {
      await init();
    }
  }

  static void setCachedThemes(
    ThemeData darkTheme,
    ThemeData lightTheme,
  ) {
    _cachedDarkTheme = darkTheme;
    _cachedLightTheme = lightTheme;
  }

  static ThemeData? getCachedDarkTheme() => _cachedDarkTheme;

  static ThemeData? getCachedLightTheme() => _cachedLightTheme;
}