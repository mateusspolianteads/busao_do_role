import 'package:flutter/material.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    // CORRIGIDO: Adicionado o "!" no final para garantir que não é nulo
    final subtitleColor = isDark ? const Color(0xFFA0A0A0) : Colors.grey[700]!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Painel de Vendas",
              style: TextStyle(
                  fontSize: isMobile ? 28 : 32,
                  fontWeight: FontWeight.w800,
                  color: textColor)),
          Text("Olá, Admin 👋",
              style: TextStyle(
                  color: subtitleColor, fontSize: isMobile ? 14 : 16)),
          const SizedBox(height: 40),
          
          // Cards renderizados com const para evitar rebuilds desnecessários
          if (isMobile)
            const Column(
              children: [
                MetricCard(
                    title: "Total de Vendas",
                    value: "R\$ 12.450,00",
                    trend: "+15% este mês",
                    isPositive: true,
                    isMobile: true),
                SizedBox(height: 15),
                MetricCard(
                    title: "Ingressos Vendidos",
                    value: "458",
                    trend: "85% da meta",
                    isPositive: false,
                    isMobile: true),
                SizedBox(height: 15),
                MetricCard(
                    title: "Eventos Ativos",
                    value: "12",
                    trend: null,
                    isPositive: true,
                    isMobile: true),
              ],
            )
          else
            const Row(
              children: [
                Expanded(
                  child: MetricCard(
                      title: "Total de Vendas",
                      value: "R\$ 12.450,00",
                      trend: "+15% este mês",
                      isPositive: true),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: MetricCard(
                      title: "Ingressos Vendidos",
                      value: "458",
                      trend: "85% da meta",
                      isPositive: false),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: MetricCard(
                      title: "Eventos Ativos",
                      value: "12",
                      trend: null,
                      isPositive: true),
                ),
              ],
            ),
          const SizedBox(height: 40),
          
          Text("Últimas Transações",
              style: TextStyle(
                  fontSize: isMobile ? 20 : 22,
                  fontWeight: FontWeight.bold,
                  color: textColor)),
          const SizedBox(height: 20),

          // Tabela isolada em seu próprio Widget
          TransactionsTable(isMobile: isMobile),
        ],
      ),
    );
  }
}

// --- WIDGETS EXTRAÍDOS PARA MAXIMIZAR PERFORMANCE --- //

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? trend;
  final bool isPositive;
  final bool isMobile;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.trend,
    required this.isPositive,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? const Color(0xFFA0A0A0) : Colors.grey[700]!;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.1);

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      constraints: BoxConstraints(minHeight: isMobile ? 120 : 160),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      color: subtitleColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14)),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value,
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: textColor)),
              ),
            ],
          ),
          if (trend != null)
            Text(trend!,
                style: TextStyle(
                    color: isPositive ? const Color(0xFF00FF88) : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 13))
          else
            const SizedBox(height: 15),
        ],
      ),
    );

    return isMobile ? SizedBox(width: double.infinity, child: content) : content;
  }
}

class TransactionsTable extends StatelessWidget {
  final bool isMobile;

  const TransactionsTable({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.1);
    final subtitleColor = isDark ? const Color(0xFFA0A0A0) : Colors.grey[700]!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: isMobile ? MediaQuery.of(context).size.width - 40 : 0),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(isDark
                  ? Colors.white.withOpacity(0.02)
                  : Colors.black.withOpacity(0.02)),
              columnSpacing: isMobile ? 20 : 40,
              columns: [
                DataColumn(
                    label: Text("CLIENTE", style: TextStyle(color: subtitleColor))),
                DataColumn(
                    label: Text("EVENTO", style: TextStyle(color: subtitleColor))),
                DataColumn(
                    label: Text("DATA", style: TextStyle(color: subtitleColor))),
                DataColumn(
                    label: Text("STATUS", style: TextStyle(color: subtitleColor))),
                DataColumn(
                    label: Text("VALOR", style: TextStyle(color: subtitleColor))),
              ],
              rows: [
                _buildDataRow(context, "João Silva", "Festa Universitária",
                    "22/05/2026", "Pago", "R\$ 80,00"),
                _buildDataRow(context, "Maria Souza", "Show Sertanejo",
                    "23/05/2026", "Pago", "R\$ 150,00"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // DataRow não é um Widget (é apenas uma configuração da tabela), 
  // então mantemos como método dentro da classe extraída.
  DataRow _buildDataRow(BuildContext context, String nome, String evento,
      String data, String status, String valor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? const Color(0xFFA0A0A0) : Colors.grey[700]!;

    return DataRow(cells: [
      DataCell(Text(nome,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold))),
      DataCell(Text(evento, style: TextStyle(color: subtitleColor))),
      DataCell(Text(data, style: TextStyle(color: subtitleColor))),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Text(status,
            style: const TextStyle(
                color: Color(0xFF00FF88),
                fontWeight: FontWeight.bold,
                fontSize: 12)),
      )),
      DataCell(Text(valor,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold))),
    ]);
  }
}