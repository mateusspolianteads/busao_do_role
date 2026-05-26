import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';

class EsqueciSenhaView extends StatefulWidget {
  const EsqueciSenhaView({super.key});

  @override
  State<EsqueciSenhaView> createState() => _EsqueciSenhaViewState();
}

class _EsqueciSenhaViewState extends State<EsqueciSenhaView> {
  final emailController = TextEditingController();
  bool carregando = false;

  Future<void> solicitarRecuperacao() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, digite um e-mail válido.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      final url = Uri.parse('http://127.0.0.1:8000/usuarios/esqueci-senha');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link de recuperação enviado com sucesso! Verifique seu e-mail.'),
            backgroundColor: Colors.green,
          ),
        );
        emailController.clear();
        
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });

      } else {
        final erroMsg = jsonDecode(response.body)['detail'] ?? 'Erro ao enviar e-mail';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(erroMsg), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Servidor offline ou erro de conexão.'),
          backgroundColor: Colors.redAccent,
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
                    padding: const EdgeInsets.fromLTRB(20, 35, 30, 25),
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
                        // Título
                        const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            "Recuperar senha",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontFamily: 'Inter',
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Digite o e-mail cadastrado na sua conta e enviaremos as instruções para você redefinir sua senha.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFA0A0A0),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),
                        
                        _buildExternalIconInput(
                          "E-mail",
                          "seu@email.com",
                          LucideIcons.mail,
                          controller: emailController,
                        ),

                        const SizedBox(height: 15),

                        Container(
                          margin: const EdgeInsets.only(left: 35),
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B0000), Color(0xFFFF0000)],
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: carregando ? null : solicitarRecuperacao,
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
                                    "Continuar",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 25),

                        // Botão Voltar
                        Padding(
                          padding: const EdgeInsets.only(left: 35),
                          child: Center(
                            child: TextButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                LucideIcons.arrowLeft,
                                size: 16,
                                color: Color(0xFFA0A0A0),
                              ),
                              label: const Text(
                                "Voltar para o login",
                                style: TextStyle(
                                  color: Color(0xFFA0A0A0),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
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
    bool isPassword = false,
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
              label.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFA0A0A0),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              icon: Icon(iconData, color: Colors.white, size: 20),
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF666666)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.03),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFFF0000)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}