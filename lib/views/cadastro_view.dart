import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:busao_do_role/services/dio_client.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'login_view.dart';
import 'package:dio/dio.dart';

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
    if (carregando) return;

    if (nomeController.text.trim().isEmpty ||
        cpfController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        senhaController.text.trim().isEmpty ||
        confirmarSenhaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
      final payload = {
        "nome": nomeController.text.trim(),
        "cpf_cnpj": cpfController.text.trim(),
        "email": emailController.text.trim(),
        "senha": senhaController.text.trim(),
      };

      await DioClient.dio.post(
        "/usuarios/cadastrar",
        data: payload,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

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
    } on DioException catch (e) {
      print('STATUS: ${e.response?.statusCode}');
      print('DATA: ${e.response?.data}');
      print('REQUEST: ${e.requestOptions.data}');

      String mensagem = 'Erro ao cadastrar';
      final data = e.response?.data;

      if (data is Map) {
        final detail = data['detail'];
        if (detail is String) {
          mensagem = detail;
        } else if (detail is List && detail.isNotEmpty) {
          mensagem = detail.map((item) {
            if (item is Map) {
              final campo = item['loc'] is List && item['loc'].length > 1
                  ? item['loc'].last.toString()
                  : '';
              final erro = item['msg']?.toString() ?? '';
              return campo.isNotEmpty ? '$campo: $erro' : erro;
            }
            return item.toString();
          }).join('\n');
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(mensagem),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Erro: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double alturaTela = MediaQuery.of(context).size.height;

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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212).withOpacity(0.9),
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
                              Container(
                                height: alturaTela * 0.28,
                                width: alturaTela * 0.28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFFFF0000).withOpacity(0.15),
                                      Colors.transparent,
                                    ],
                                    radius: 0.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF0000).withOpacity(0.05),
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

                        const SizedBox(height: 10),

                        const Text(
                          "Crie sua conta",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          "Preencha os dados para começar a usar.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFFA0A0A0),
                            fontSize: 13,
                            letterSpacing: 0.2,
                          ),
                        ),

                        const SizedBox(height: 25),

                        _buildExternalIconInput(
                          "Usuário",
                          "Nome de usuário",
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
                          keyboardType: TextInputType.emailAddress,
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
                            onPressed: () =>
                                setState(() => ocultarSenha = !ocultarSenha),
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
                            onPressed: () => setState(() =>
                                ocultarConfirmarSenha = !ocultarConfirmarSenha),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Botão Entrar original adaptado para Cadastro
                        SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: carregando ? null : cadastrarUsuario,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF0000),
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
                                    "Cadastrar",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 35),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 36, bottom: 4),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFA0A0A0),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  iconData,
                  color: Colors.white,
                  size: 18,
                ),
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white10,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                suffixIcon: suffixIcon,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFFFF0000),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}