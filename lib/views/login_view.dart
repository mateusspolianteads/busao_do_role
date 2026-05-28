import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../services/auth_service.dart';
import 'home_view.dart';
import 'cadastro_view.dart';
import 'esqueci_senha_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool carregando = false;

  Future<void> realizarLogin() async {
    setState(() => carregando = true);

    try {
      final result = await AuthService.login(
        emailController.text.trim(),
        senhaController.text.trim(),
      );

      if (!mounted) return;

      if (result.sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeView()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.erro ?? 'Erro ao fazer login'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro de conexão: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1.0),
            radius: 1.1,
            colors: [
              Color(0xFF3a0000),
              Colors.transparent,
            ],
            stops: [0.0, 0.6],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            // Reduzido o padding externo para não empurrar o container
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360), // Reduzido ligeiramente a largura para achatar o design
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    // AJUSTE CRÍTICO: Padding vertical reduzido para o mínimo (12 acima e abaixo)
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Força o container a ter o tamanho exato dos filhos
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo maximizada com margens zeradas nas verticais
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                          child: Image.asset(
                            'assets/img/logo_branca.png',
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          "Bem-vindo de volta",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22, // Reduzido de 24 para 22 para economizar espaço vertical
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 2), // Espaço mínimo

                        const Text(
                          "Acesse sua conta para continuar.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFA0A0A0),
                            fontSize: 12, // Reduzido de 13 para 12
                          ),
                        ),

                        const SizedBox(height: 15), // Reduzido de 20 para 15

                        _input(
                          label: "Email",
                          hint: "Digite seu email",
                          icon: LucideIcons.mail,
                          controller: emailController,
                        ),

                        _input(
                          label: "Senha",
                          hint: "••••••••",
                          icon: LucideIcons.lock,
                          controller: senhaController,
                          isPassword: true,
                        ),

                        // Alinhamento do "Esqueceu a senha" colado no input
                        Transform.translate(
                          offset: const Offset(0, -8), // Puxa o botão para cima, eliminando o vazio
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EsqueciSenhaView(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Esqueceu a senha?",
                                style: TextStyle(
                                  color: Color(0xFFA0A0A0),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        SizedBox(
                          height: 46, // Reduzido de 50 para 46 (mais compacto)
                          child: ElevatedButton(
                            onPressed: carregando ? null : realizarLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF0000),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: carregando
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    "Entrar",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 5), // Espaço mínimo

                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 35),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CadastroView(),
                              ),
                            );
                          },
                          child: const Text(
                            "Não tem conta? Cadastre-se",
                            style: TextStyle(
                              color: Color(0xFFA0A0A0),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10), // Reduzido o espaçamento inferior de 14 para 10
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFA0A0A0),
              fontSize: 11, // Reduzido de 12 para 11
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 44, // Força os campos de texto a serem ligeiramente mais baixos/achatados
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: Colors.white, size: 18),
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF666666), fontSize: 14),
                filled: true,
                fillColor: Colors.white10,
                contentPadding: const EdgeInsets.symmetric(vertical: 10), // Centraliza o texto internamente
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}