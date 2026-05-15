import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PedidosTab extends StatelessWidget {
  const PedidosTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? const Color(0xFFA0A0A0) : Colors.grey[700]!;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.1);

    // Dados fictícios
    const mockPedidos = [
      {"id": "#1042", "cliente": "Ana Silva", "data": "14 Mai 2026", "valor": "R\$ 120,00", "status": "Aprovado"},
      {"id": "#1043", "cliente": "Carlos Eduardo", "data": "14 Mai 2026", "valor": "R\$ 45,00", "status": "Pendente"},
      {"id": "#1044", "cliente": "Mariana Souza", "data": "13 Mai 2026", "valor": "R\$ 210,00", "status": "Cancelado"},
      {"id": "#1045", "cliente": "Roberto Carlos", "data": "12 Mai 2026", "valor": "R\$ 80,00", "status": "Aprovado"},
      {"id": "#1046", "cliente": "Julia Mendes", "data": "11 Mai 2026", "valor": "R\$ 350,00", "status": "Aprovado"},
    ];

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Pedidos",
              style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.w800, color: textColor)),
          Text("Gerenciamento de vendas e ingressos",
              style: TextStyle(color: subtitleColor)),
          const SizedBox(height: 30),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: mockPedidos.isEmpty
                  ? EmptyState(isDark: isDark) // Extraído para Widget (melhor performance)
                  : ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: mockPedidos.length,
                      separatorBuilder: (context, index) => Divider(color: borderColor, height: 32),
                      itemBuilder: (context, index) {
                        return PedidoListItem(
                          pedido: mockPedidos[index],
                          textColor: textColor,
                          subtitleColor: subtitleColor,
                          isDark: isDark,
                        );
                      },
                    ),
            ),
          )
        ],
      ),
    );
  }
}

// --- WIDGETS EXTRAÍDOS PARA MELHORAR PERFORMANCE (Evita reconstruir a tela toda) --- //

class EmptyState extends StatelessWidget {
  final bool isDark;
  const EmptyState({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final iconColor = isDark ? Colors.white10 : Colors.black12;
    final emptyTextColor = isDark ? Colors.white24 : Colors.black38;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.shoppingCart, size: 60, color: iconColor),
          const SizedBox(height: 10),
          Text("Nenhum pedido recente", style: TextStyle(color: emptyTextColor)),
        ],
      ),
    );
  }
}

class PedidoListItem extends StatelessWidget {
  final Map<String, String> pedido;
  final Color textColor;
  final Color subtitleColor;
  final bool isDark;

  const PedidoListItem({
    super.key,
    required this.pedido,
    required this.textColor,
    required this.subtitleColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (pedido["status"]) {
      case "Aprovado":
        statusColor = Colors.green;
        break;
      case "Pendente":
        statusColor = Colors.orange;
        break;
      case "Cancelado":
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(LucideIcons.receipt, color: textColor, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pedido["cliente"]!,
                  style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "${pedido["id"]} • ${pedido["data"]}",
                  style: TextStyle(color: subtitleColor, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              pedido["valor"]!,
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                pedido["status"]!,
                style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }
}