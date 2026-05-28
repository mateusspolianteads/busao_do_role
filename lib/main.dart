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

          themeAnimationDuration: const Duration(milliseconds: 500),
          themeAnimationCurve: Curves.easeOutCubic,

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.bgDark,
            fontFamily: 'Inter',
            
            // 💡 ADICIONADO: Força todas as AppBars do app no modo Dark a usarem a TitanOne
            appBarTheme: const AppBarTheme(
              centerTitle: true,
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

            // 💡 ADICIONADO: Força todas as AppBars do app no modo Light a usarem a TitanOne
            appBarTheme: const AppBarTheme(
              centerTitle: true,
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