import 'package:busao_do_role/services/dio_client.dart';
import 'package:busao_do_role/views/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_colors.dart';
import 'theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DioClient.init();

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
              Locale('en', 'US'),
            ],

            locale: const Locale('pt', 'BR'),

            themeMode: currentMode,
            themeAnimationDuration: const Duration(milliseconds: 500),
            themeAnimationCurve: Curves.easeOutCubic,

            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: AppColors.bgDark,
              fontFamily: 'Inter',

              appBarTheme: const AppBarTheme(
                centerTitle: true,
                backgroundColor: AppColors.bgDark,
                elevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: AppColors.bgDark,
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                  systemNavigationBarColor: AppColors.bgDark,
                  systemNavigationBarIconBrightness: Brightness.light,
                ),
                titleTextStyle: TextStyle(
                  fontFamily: 'TitanOne',
                  fontSize: 22,
                  color: Colors.white,
                ),
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
            ),

            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: const Color(0xFFF5F5F5),
              fontFamily: 'Inter',

              appBarTheme: const AppBarTheme(
                centerTitle: true,
                backgroundColor: Color(0xFFF5F5F5),
                elevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Color(0xFFF5F5F5),
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light,
                  systemNavigationBarColor: Color(0xFFF5F5F5),
                  systemNavigationBarIconBrightness: Brightness.dark,
                ),
                titleTextStyle: TextStyle(
                  fontFamily: 'TitanOne',
                  fontSize: 22,
                  color: Colors.black,
                ),
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
            ),

            home: const SplashView(),
          ),
        );
      },
    );
  }
}