import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';

import 'login_view.dart';

class CadastroView extends StatefulWidget {
  const CadastroView({super.key});

  @override
  State<CadastroView> createState() => _CadastroViewState();
}

class _CadastroViewState extends State<CadastroView> {
  final nomeController = TextEditingController();
  final cpfController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  bool carregando = false;
  bool ocultarSenha = true;
  bool ocultarConfirmarSenha = true;

  Future<void> cadastrarUsuario() async {
    if (senhaController.text != confirmarSenhaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não coincidem!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      final url = Uri.parse('https://busao-api.onrender.com/usuarios/cadastrar');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nome': nomeController.text,
          'cpf_cnpj': cpfController.text,
          'email': emailController.text,
          'senha': senhaController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginView(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar (${response.statusCode})'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro de conexão: $e'),
        ),
      );
    } finally {
      setState(() {
        carregando = false;
      });
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 25, 30, 25),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset(
                          'assets/img/logo_branca.png',
                          width: 640,
                          height: 250,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Crie sua conta",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Preencha os dados para começar a usar.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFA0A0A0),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 25),
                        _buildExternalIconInput(
                          "Usuario",
                          "Usuario",
                          LucideIcons.user,
                          controller: nomeController,
                        ),
                        _buildExternalIconInput(
                          "CPF/CNPJ",
                          "000.000.000-00",
                          LucideIcons.fileText,
                          controller: cpfController,
                        ),
                        _buildExternalIconInput(
                          "Email",
                          "seu@email.com",
                          LucideIcons.mail,
                          controller: emailController,
                        ),
                        _buildExternalIconInput(
                          "Senha",
                          "••••••••",
                          LucideIcons.lock,
                          controller: senhaController,
                          obscureText: ocultarSenha,
                          suffixIcon: IconButton(
                            icon: Icon(
                              ocultarSenha ? LucideIcons.eye : LucideIcons.eyeOff,
                              color: const Color(0xFF666666),
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                ocultarSenha = !ocultarSenha;
                              });
                            },
                          ),
                        ),
                        _buildExternalIconInput(
                          "Confirmar Senha",
                          "••••••••",
                          LucideIcons.lock,
                          controller: confirmarSenhaController,
                          obscureText: ocultarConfirmarSenha,
                          suffixIcon: IconButton(
                            icon: Icon(
                              ocultarConfirmarSenha ? LucideIcons.eye : LucideIcons.eyeOff,
                              color: const Color(0xFF666666),
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                ocultarConfirmarSenha = !ocultarConfirmarSenha;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          margin: const EdgeInsets.only(left: 35),
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF8B0000),
                                Color(0xFFFF0000),
                              ],
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: carregando ? null : cadastrarUsuario,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: carregando
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
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
                        Padding(
                          padding: const EdgeInsets.only(left: 35),
                          child: Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginView(),
                                  ),
                                );
                              },
                              child: const Text.rich(
                                TextSpan(
                                  text: "Já tem uma conta? ",
                                  style: TextStyle(
                                    color: Color(0xFFA0A0A0),
                                    fontSize: 13,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Faça login",
                                      style: TextStyle(
                                        color: Color(0xFFFF0000),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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

  Widget _buildExternalIconInput(
    String label,
    String hint,
    IconData iconData, {
    bool obscureText = false,
    Widget? suffixIcon,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 48, bottom: 4),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFA0A0A0),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              icon: Icon(
                iconData,
                color: Colors.white,
                size: 20,
              ),
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF666666),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.03),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: suffixIcon,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.white10,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFFF0000),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}