import 'package:busao_do_role/services/dio_client.dart';
import 'package:busao_do_role/views/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_colors.dart';
import 'core/app_themes.dart';
import 'theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DioClient.init();
  await ThemeController.loadThemePreference();

  runApp(const BusaoDoRoleApp());
}

class BusaoDoRoleApp extends StatelessWidget {
  const BusaoDoRoleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeNotifier,
      builder: (context, ThemeMode currentMode, _) {
        final isDark = currentMode == ThemeMode.dark;

        final currentBgColor =
            isDark ? AppColors.bgDark : const Color(0xFFF5F5F5);

        final systemUiStyle = SystemUiOverlayStyle(
          statusBarColor: currentBgColor,
          statusBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness:
              isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: currentBgColor,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: systemUiStyle,
          child: MaterialApp(
            title: 'Busão do Rolê',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('pt', 'BR'),
            ],
            locale: const Locale('pt', 'BR'),
            themeMode: currentMode,
            themeAnimationDuration: const Duration(milliseconds: 500),
            themeAnimationCurve: Curves.easeOutCubic,
            darkTheme: AppThemes.darkTheme,
            theme: AppThemes.lightTheme,
            home: const SplashView(),
          ),
        );
      },
    );
  }
}