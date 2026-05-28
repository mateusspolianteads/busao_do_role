import 'package:busao_do_role/services/dio_client.dart';
import 'package:busao_do_role/views/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        
        // Define a cor sólida de fundo baseada no tema para evitar frestas na Web
        final currentBgColor = isDark ? AppColors.bgDark : const Color(0xFFF5F5F5);

        // Estilo global da barra do sistema de acordo com o tema atual
        final systemUiStyle = SystemUiOverlayStyle(
          statusBarColor: currentBgColor, // Ajustado: Cor sólida para cobrir qualquer vazamento
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark, // Ícones (Wi-Fi, Bateria)
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // Necessário para iOS
          
          // Ajusta a barra de navegação inferior (botões virtuais do celular)
          systemNavigationBarColor: currentBgColor,
          systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: systemUiStyle,
          child: MaterialApp(
            title: 'Busão do Rolê',
            debugShowCheckedModeBanner: false,

            themeMode: currentMode,
            themeAnimationDuration: const Duration(milliseconds: 500),
            themeAnimationCurve: Curves.easeOutCubic,

            // ================= TEMA ESCURO (DARK) =================
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: AppColors.bgDark,
              fontFamily: 'Inter',

              // Copia as configurações de estilo para todas as app bars e telas do tema escuro
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                backgroundColor: AppColors.bgDark,
                elevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: AppColors.bgDark, // Ajustado: Cor sólida no topo do Dark Mode
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

            // ================= TEMA CLARO (LIGHT) =================
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: AppColors.primary, 
              scaffoldBackgroundColor: const Color(0xFFF5F5F5),
              fontFamily: 'Inter',

              // Copia as configurações de estilo para todas as app bars e telas do tema claro
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                backgroundColor: Color(0xFFF5F5F5),
                elevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Color(0xFFF5F5F5), // Ajustado: Cor sólida no topo do Light Mode
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