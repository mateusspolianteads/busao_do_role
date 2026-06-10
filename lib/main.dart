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

  try {
    await DioClient.init();
    
    await ThemeController.init();
    
    ThemeController.setCachedThemes(AppThemes.darkTheme, AppThemes.lightTheme);
  } catch (e) {
    debugPrint("Erro durante a inicialização do sistema: $e");
  }

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
        final currentBgColor = isDark ? AppColors.bgDark : const Color(0xFFF5F5F5);

        final systemUiStyle = SystemUiOverlayStyle(
          statusBarColor: currentBgColor,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: currentBgColor,
          systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
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
            themeAnimationDuration: const Duration(milliseconds: 300), // Reduzido levemente para dar sensação de maior fluidez
            themeAnimationCurve: Curves.easeInOut,
            darkTheme: ThemeController.getCachedDarkTheme() ?? AppThemes.darkTheme,
            theme: ThemeController.getCachedLightTheme() ?? AppThemes.lightTheme,
            home: const SplashView(),
          ),
        );
      },
    );
  }
}