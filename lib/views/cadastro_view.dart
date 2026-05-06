import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/app_colors.dart';
import 'widgets/custom_input.dart';

class CadastroView extends StatelessWidget {
  const CadastroView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.bgDark,
          gradient: RadialGradient(
            center: Alignment(0, -1),
            radius: 1.2,
            colors: [Color(0xFF3a0000), AppColors.bgDark],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // --- LOGO COM IMAGEM ---
                Image.asset(
                  'assets/img/logo_branca.png', // O caminho que você criou
                  width: 230, // Largura exata do seu CSS
                  fit: BoxFit.contain,
                ),

                // -----------------------
                const SizedBox(height: 10), // Espaço entre logo e a box

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 380),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 30,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 35,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                const Text(
                                  "Crie sua conta",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textMain,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "Preencha os dados para começar a usar.",
                                  style: TextStyle(
                                    color: AppColors.textDim,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),

                          const CustomInput(
                            label: "Nome Completo",
                            placeholder: "Seu nome",
                            icon: LucideIcons.user,
                          ),
                          const CustomInput(
                            label: "CPF/CNPJ",
                            placeholder: "000.000.000-00",
                            icon: LucideIcons.fileText,
                          ),
                          const CustomInput(
                            label: "Email",
                            placeholder: "seu@email.com",
                            icon: LucideIcons.mail,
                          ),
                          const CustomInput(
                            label: "Senha",
                            placeholder: "••••••••",
                            icon: LucideIcons.lock,
                            isPassword: true,
                          ),

                          const SizedBox(height: 10),

                          Container(
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primaryDark,
                                  AppColors.primary,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryDark.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Cadastrar",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Center(
                            child: TextButton(
                              onPressed: () {},
                              child: const Text.rich(
                                TextSpan(
                                  text: "Já tem uma conta? ",
                                  style: TextStyle(color: AppColors.textDim),
                                  children: [
                                    TextSpan(
                                      text: "Faça login",
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
