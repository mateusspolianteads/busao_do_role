/* import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme_controller.dart';
import '../../services/auth_service.dart';
import '../login_view.dart';

class ConfigTab extends StatefulWidget {
  const ConfigTab({super.key});

  @override
  State<ConfigTab> createState() => _ConfigTabState();
}

class _ConfigTabState extends State<ConfigTab> {
  // 💡 REMOVIDO: Variável 'notificacoes' retirada daqui.

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
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
              color: textColor,
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
          LogoutCard(
            onLogoutPressed: () async {
              print("====== INICIANDO LOGOUT ======");

              // 1. Limpa os tokens
              await AuthService.logout();
              print("1. Tokens removidos do SharedPreferences");

              if (!context.mounted) {
                print("Erro: Contexto não está mais montado");
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sessão encerrada com segurança!'),
                  backgroundColor: Colors.blueGrey,
                ),
              );

              print(
                  "2. Redirecionando para a LoginView usando rootNavigator...");

              // O 'rootNavigator: true' obriga o Flutter a fechar as Abas e resetar o app todo
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginView()),
                (route) => false,
              );

              print("====== LOGOUT CONCLUÍDO ======");
            },
          ),
        ],
      ),
    );
  }
}

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

    final borderColor =
        isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.1);

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
            color: Colors.red,
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

class LogoutCard extends StatelessWidget {
  final VoidCallback onLogoutPressed;

  const LogoutCard({super.key, required this.onLogoutPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? const Color(0xFFA0A0A0) : Colors.grey[500]!;

    final borderColor =
        isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.1);

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            LucideIcons.logOut,
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
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: onLogoutPressed,
                  icon: const Icon(LucideIcons.logOut,
                      size: 16, color: Color(0xFFFF4D4D)),
                  label: const Text(
                    "Sair da Conta",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF4D4D),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: const Color(0xFFFF4D4D).withOpacity(0.2)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 12),
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
} */