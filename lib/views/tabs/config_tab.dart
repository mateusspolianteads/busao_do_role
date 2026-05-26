import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme_controller.dart'; // Certifique-se que o caminho está correto

class ConfigTab extends StatefulWidget {
  const ConfigTab({super.key});

  @override
  State<ConfigTab> createState() => _ConfigTabState();
}

class _ConfigTabState extends State<ConfigTab> {
  // Notificações é um estado local, então mantemos aqui
  bool notificacoes = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    // CORRIGIDO: Adicionado o "!" para não ser nulo
    final subtitleColor = isDark ? const Color(0xFFA0A0A0) : Colors.grey[500]!;

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Configurações",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: textColor, // Padronizado com as outras abas
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Ajustes do sistema",
            style: TextStyle(
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 40),

          // Chamando o Widget extraído em vez do método
          ConfigItemCard(
            title: "Tema do Sistema",
            subtitle: "Trocar entre modo claro e escuro",
            icon: isDark ? LucideIcons.moon : LucideIcons.sun,
            value: isDark,
            onChanged: (v) {
              ThemeController.toggleTheme(v);
            },
          ),

          const SizedBox(height: 20),

          ConfigItemCard(
            title: "Notificações",
            subtitle: "Gerenciar avisos de novas vendas",
            icon: LucideIcons.bell,
            value: notificacoes,
            onChanged: (v) {
              setState(() {
                notificacoes = v;
              });
            },
          ),

          const SizedBox(height: 20),

          // --- IMPLEMENTADO: CARD DE LOGOUT COPIANDO O FRONTEND WEB ---
          LogoutCard(
            onLogoutPressed: () {
              // TODO: Insira aqui a sua lógica de logout do Firebase, Token, etc.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sessão encerrada com segurança!')),
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- WIDGET EXTRAÍDO PARA ISOLAR O ESTADO E MELHORAR PERFORMANCE --- //

class ConfigItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ConfigItemCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? const Color(0xFFA0A0A0) : Colors.grey[500]!;
    
    // CORRIGIDO: Agora a borda se adapta ao tema claro e escuro corretamente
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.1);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.red, // Mantendo o padrão visual vermelho do app
            size: 28,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.red,
          ),
        ],
      ),
    );
  }
}

// --- NOVO WIDGET: CARD EXCLUSIVO DE LOGOUT COM O BOTÃO DESGRUDADO --- //

class LogoutCard extends StatelessWidget {
  final VoidCallback onLogoutPressed;

  const LogoutCard({super.key, required this.onLogoutPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? const Color(0xFFA0A0A0) : Colors.grey[500]!;
    
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.1);

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Mantém alinhado no topo
        children: [
          const Icon(
            LucideIcons.logOut, // Ícone de Sair combinando com a proposta
            color: Colors.red,
            size: 28,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sair do Sistema",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Encerrar sua sessão de administrador com segurança",
                  style: TextStyle(
                    color: subtitleColor,
                  ),
                ),
                
                // === O SEU AJUSTE CSS AQUI NO FLUTTER ===
                // O SizedBox cria exatamente o mesmo efeito de desgrudar/afastar o botão
                const SizedBox(height: 18), 
                
                // Botão customizado igual ao do Frontend web
                OutlinedButton.icon(
                  onPressed: onLogoutPressed,
                  icon: const Icon(LucideIcons.logOut, size: 16, color: Color(0xFFFF4D4D)),
                  label: const Text(
                    "Sair da Conta",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF4D4D),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: const Color(0xFFFF4D4D).withOpacity(0.2)),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}