import 'package:flutter/material.dart';
import 'views/cadastro_view.dart'; // Importa a tela que criamos
import 'core/app_colors.dart';    // Importa suas cores

void main() {
  runApp(const BusaoDoRoleApp());
}

class BusaoDoRoleApp extends StatelessWidget {
  const BusaoDoRoleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Busão do Rolê',
      debugShowCheckedModeBanner: false, // Tira aquela faixa de "Debug" do canto
      
      // Configuração de Tema Global
      theme: ThemeData(
        brightness: Brightness.dark, // Define que o app é Dark Mode por padrão
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.bgDark,
        
        // Aqui você define a fonte 'Inter' globalmente (precisa adicionar no pubspec.yaml)
        fontFamily: 'Inter', 
        
        // Ajuste fino para os botões do app
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      
      // Define a tela de cadastro como a página inicial
      home: const CadastroView(),
    );
  }
}