import 'package:flutter/material.dart';
import 'views/cadastro_view.dart';
import 'core/app_colors.dart';
import 'theme_controller.dart';

void main() {
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

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.bgDark,
            fontFamily: 'Inter',
            cardColor: const Color(0xFF121212),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
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
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          home: const CadastroView(),
        );
      },
    );
  }
}