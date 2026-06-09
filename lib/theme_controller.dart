import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);
  
  // Cache dos temas para evitar recriação
  static ThemeData? _cachedDarkTheme;
  static ThemeData? _cachedLightTheme;

  static bool get isDarkMode => themeNotifier.value == ThemeMode.dark;

  static Future<void> toggleTheme(bool isDark) async {
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    
    // Persistir preferência
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  static Future<void> loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('isDarkMode') ?? true;
      themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      debugPrint('Erro ao carregar preferência de tema: $e');
    }
  }

  static void setCachedThemes(ThemeData darkTheme, ThemeData lightTheme) {
    _cachedDarkTheme = darkTheme;
    _cachedLightTheme = lightTheme;
  }

  static ThemeData? getCachedDarkTheme() => _cachedDarkTheme;
  static ThemeData? getCachedLightTheme() => _cachedLightTheme;
}