import 'package:busao_do_role/services/dio_client.dart';
import 'package:busao_do_role/views/splash_view.dart';
import 'package:flutter/material.dart';
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
        return MaterialApp(
          title: 'Busão do Rolê',
          debugShowCheckedModeBanner: false,

          themeMode: currentMode,

          // ANIMAÇÃO GLOBAL DO TEMA
          themeAnimationDuration: const Duration(milliseconds: 500),
          themeAnimationCurve: Curves.easeOutCubic,

          builder: (context, child) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: child!,
            );
          },

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.bgDark,
            fontFamily: 'Inter',
            cardColor: const Color(0xFF121212),

            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,

            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.red,
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            fontFamily: 'Inter',
            cardColor: Colors.white,

            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,

            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          home: const SplashView(),
        );
      },
    );
  }
}