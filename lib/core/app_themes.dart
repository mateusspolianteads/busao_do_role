import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// Constantes de tema para evitar recriação desnecessária
class AppThemes {
  AppThemes._(); // Constructor privado para evitar instanciação

  static const _appBarThemeStyle = TextStyle(
    fontFamily: 'TitanOne',
    fontSize: 22,
    color: Colors.white,
  );

  static const _appBarThemeLightStyle = TextStyle(
    fontFamily: 'TitanOne',
    fontSize: 22,
    color: Colors.black,
  );

  static const _statusBarStyleDark = SystemUiOverlayStyle(
    statusBarColor: AppColors.bgDark,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.bgDark,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static const _statusBarStyleLight = SystemUiOverlayStyle(
    statusBarColor: Color(0xFFF5F5F5),
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFFF5F5F5),
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.bgDark,
    fontFamily: 'Inter',
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.bgDark,
      elevation: 0,
      systemOverlayStyle: _statusBarStyleDark,
      titleTextStyle: _appBarThemeStyle,
    ),
    cardColor: const Color(0xFF121212),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Colors.red,
      contentTextStyle: TextStyle(
        color: Color.fromARGB(255, 27, 27, 27),
        fontSize: 14,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    fontFamily: 'Inter',
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Color(0xFFF5F5F5),
      elevation: 0,
      systemOverlayStyle: _statusBarStyleLight,
      titleTextStyle: _appBarThemeLightStyle,
    ),
    cardColor: Colors.white,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}
