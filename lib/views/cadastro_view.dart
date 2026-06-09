import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:busao_do_role/services/dio_client.dart';
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
    // 1. VALIDAÇÃO DE CAMPOS VAZIOS: Verifica localmente antes de qualquer ação
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
      return; // Para a execução e não chama a API
    }

    // 2. VALIDAÇÃO DE SENHAS COINCIDENTES
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
      final response = await DioClient.dio.post(
        '/usuarios/cadastrar',
        data: {
          'nome': nomeController.text.trim(),
          'cpf_cnpj': cpfController.text.trim(),
          'email': emailController.text.trim(),
          'senha': senhaController.text,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
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
        String mensagem = 'Erro ao cadastrar';

        try {
          final data = response.data is String ? jsonDecode(response.data) : response.data;

          if (data['detail'] != null) {
            final detail = data['detail'];

            if (detail is String) {
              mensagem = detail;
            } else if (detail is List && detail.isNotEmpty) {
              mensagem = detail[0]['msg'] ?? 'Erro de validação';
            }
          }
        } catch (_) {
          mensagem = 'Erro ao cadastrar (${response.statusCode})';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              mensagem,
              style: const TextStyle(color: Colors.white), // Alterado para branco para melhor leitura
            ),
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
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), // Reduzido o padding externo vertical
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360), // Largura igualada ao Login
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12), // Container mais justo sem padding no topo
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
                        // Logo Maximizada (Preenche as laterais perfeitamente)
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
                          "Crie sua conta",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22, // Equalizado com o Login
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        
                        const SizedBox(height: 2),
                        
                        const Text(
                          "Preencha os dados para começar a usar.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFA0A0A0),
                            fontSize: 12,
                          ),
                        ),
                        
                        const SizedBox(height: 15), // Espaçamento reduzido antes dos inputs
                        
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
                            onPressed: () => setState(() => ocultarSenha = !ocultarSenha),
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
                            onPressed: () => setState(() => ocultarConfirmarSenha = !ocultarConfirmarSenha),
                          ),
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Botão Cadastrar compacto e estilizado
                        SizedBox(
                          height: 46,
                          child: Container(
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
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 5),
                        
                        // Link de voltar para o Login limpo e com paddings zerados
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10), // Reduzido de 14 para 10 para achatar verticalmente
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 36, bottom: 4), // Alinhado ao início do TextField remodelado
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
            height: 44, // Força a altura exata igualada ao LoginView
            child: TextField(
              controller: controller,
              obscureText: obscureText,
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
                fillColor: Colors.white10, // Cor de fundo igual ao login
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