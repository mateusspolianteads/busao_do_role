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

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

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
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final alturaTela = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF080808), // Cor de fundo original
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Fundo Gradiente Radial Original
            Container(
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
            ),

            Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxWidth: 360), // Sua largura original
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                          sigmaX: 10, sigmaY: 10), // Seu blur original
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(
                            20, 16, 20, 16), // Padding vertical seguro
                        decoration: BoxDecoration(
                          color: const Color(0xFF121212).withOpacity(
                              0.9), // Sua cor de container original
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: 0),
                                  // Container com efeito de brilho de fundo (Glow Effect)
                                  Container(
                                    height: alturaTela * 0.25,
                                    width: alturaTela * 0.25,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          const Color(0xFFFF0000)
                                              .withOpacity(0.15),
                                          Colors.transparent,
                                        ],
                                        radius: 0.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFF0000)
                                              .withOpacity(0.05),
                                          blurRadius: 30,
                                          spreadRadius: 5,
                                        )
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: Image.asset(
                                      'assets/img/logo_branca.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                                height: 10), // Espaçamento mais respirável

                            Text(
                              "Bem-vindo de volta",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800, // Mais encorpado
                                letterSpacing:
                                    -0.5, // Toque premium de UI moderna
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              "Acesse sua conta para continuar.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFFA0A0A0),
                                fontSize: 13,
                                letterSpacing: 0.2,
                              ),
                            ),

                            const SizedBox(height: 25),

                            // Input de Email
                            _input(
                              label: "Email",
                              hint: "Digite seu email",
                              icon: LucideIcons.mail,
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            // Input de Senha
                            _input(
                              label: "Senha",
                              hint: "••••••••",
                              icon: LucideIcons.lock,
                              controller: senhaController,
                              isPassword: true,
                            ),

                            // "Esqueceu a senha" alinhado de forma limpa e colada
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const EsqueciSenhaView(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Esqueceu a senha?",
                                    style: TextStyle(
                                      color:
                                          Color(0xFFA0A0A0), // Sua cor original
                                      fontSize: 12, // Seu tamanho original
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Botão Entrar original
                            SizedBox(
                              height: 46, // Sua altura original
                              child: ElevatedButton(
                                onPressed: carregando ? null : realizarLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(
                                      0xFFFF0000), // Seu vermelho original
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                child: carregando
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        "Entrar",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Botão Cadastre-se original
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
                                  color: Color(0xFFA0A0A0), // Sua cor original
                                  fontSize: 13, // Seu tamanho original
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
          ],
        ),
      ),
    );
  }

  // Widget de input com as cores, textos, cantos e paddings idênticos ao seu original
  Widget _input({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10), // Seu espaçamento original
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFA0A0A0), // Sua cor original
              fontSize: 11, // Seu tamanho original
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            style: const TextStyle(
                color: Colors.white, fontSize: 14), // Suas fontes originais
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.white, size: 18),
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Color(0xFF666666), fontSize: 14),
              filled: true,
              fillColor: Colors.white10, // Sua cor de preenchimento original
              // Mantém o visual achatado através do padding interno sem estourar a tela vermelha
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
