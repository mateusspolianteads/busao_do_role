import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  // Inicializa direto com light ou dark (o loadThemePreference mudará depois)
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);
  
  // Guardar a instância do SharedPreferences em memória evita lag de leitura/escrita múltipla
  static SharedPreferences? _prefs;

  // Cache estático dos temas configurados na inicialização do app
  static ThemeData? _cachedDarkTheme;
  static ThemeData? _cachedLightTheme;

  static bool get isDarkMode => themeNotifier.value == ThemeMode.dark;

  // Inicialização única executada no seu main.dart
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final isDark = _prefs?.getBool('isDarkMode') ?? true;
      themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      debugPrint('Erro ao inicializar ThemeController: $e');
    }
  }

  static void toggleTheme(bool isDark) {
    // 1. Mudança visual instantânea (Sem await aqui)
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    
    // 2. Gravação em background (Não bloqueia a animação da UI)
    if (_prefs != null) {
      _prefs!.setBool('isDarkMode', isDark);
    } else {
      // Fallback caso mude antes de iniciar as preferências
      SharedPreferences.getInstance().then((prefs) {
        _prefs = prefs;
        prefs.setBool('isDarkMode', isDark);
      });
    }
  }

  // Mantido por compatibilidade se preferir chamar isolado, mas o init() é melhor
  static Future<void> loadThemePreference() async {
    if (_prefs == null) {
      await init();
    }
  }

  // Garante que o MaterialApp use EXATAMENTE a mesma instância da memória, evitando refazer cálculos de layout
  static void setCachedThemes(ThemeData darkTheme, ThemeData lightTheme) {
    _cachedDarkTheme = darkTheme;
    _cachedLightTheme = lightTheme;
  }

  static ThemeData? getCachedDarkTheme() => _cachedDarkTheme;
  static ThemeData? getCachedLightTheme() => _cachedLightTheme;
}