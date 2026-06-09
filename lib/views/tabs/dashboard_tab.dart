import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:busao_do_role/services/dio_client.dart';
import 'package:intl/intl.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  bool isLoading = true;

  String selectedVendedor = "TODOS";
  String selectedPeriodo = "TODOS";

  List<String> vendedores = [];
  List<String> periodos = [];

  List<dynamic> eventos = [];

  double totalVendas = 0;
  int ingressosVendidos = 0;
  int eventosComVenda = 0;

  final formatadorMoeda = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  @override
  void initState() {
    super.initState();
    carregarDashboard();
  }

  Future<void> carregarDashboard() async {
    setState(() {
      isLoading = true;
    });

    try {
      Map<String, String> queryParams = {};

      // Só envia filtro se NÃO for TODOS
      if (selectedVendedor != "TODOS") {
        queryParams["canal_venda"] = selectedVendedor;
      }

      if (selectedPeriodo != "TODOS") {
        queryParams["periodo"] = selectedPeriodo;
      }

      final response = await DioClient.dio.get(
        "/pedidos/dashboard",
        queryParameters: queryParams,
      );

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      setState(() {
        vendedores = [
          "TODOS",
          ...List<String>.from(
            data["filtros"]["vendedores"] ?? [],
          ),
        ];

        periodos = [
          "TODOS",
          ...List<String>.from(
            data["filtros"]["periodos"] ?? [],
          ),
        ];

        totalVendas = (data["totals"]["total_vendas"] ?? 0).toDouble();

        ingressosVendidos = data["totals"]["ingressos_vendidos"] ?? 0;

        eventosComVenda = data["totals"]["eventos_com_venda"] ?? 0;

        eventos = data["eventos"] ?? [];

        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERRO DASHBOARD: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : Colors.black87;

    final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: carregarDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Painel de Vendas",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "Puxe para baixo para atualizar",
              style: TextStyle(
                fontSize: 13,
                color: subtitleColor,
              ),
            ),

            const SizedBox(height: 20),

            // FILTRO VENDEDOR
            DropdownButtonFormField<String>(
              value: selectedVendedor,
              decoration: const InputDecoration(
                labelText: "Canal de Venda",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: vendedores.map((vendedor) {
                return DropdownMenuItem(
                  value: vendedor,
                  child: Text(
                    vendedor,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedVendedor = value ?? "TODOS";
                });

                carregarDashboard();
              },
            ),

            const SizedBox(height: 16),

            // FILTRO PERIODO
            DropdownButtonFormField<String>(
              value: selectedPeriodo,
              decoration: const InputDecoration(
                labelText: "Período",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: periodos.map((periodo) {
                return DropdownMenuItem(
                  value: periodo,
                  child: Text(
                    periodo,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPeriodo = value ?? "TODOS";
                });

                carregarDashboard();
              },
            ),

            const SizedBox(height: 24),

            // TOTAL VENDAS
            cardMetrica(
              "Total de Vendas",
              formatadorMoeda.format(totalVendas),
              isFullWidth: true,
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: cardMetrica(
                    "Ingressos",
                    ingressosVendidos.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: cardMetrica(
                    "Eventos",
                    eventosComVenda.toString(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            Text(
              "Eventos Vendidos",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
                color: Theme.of(context).cardColor,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      isDark
                          ? Colors.white.withOpacity(0.03)
                          : Colors.black.withOpacity(0.03),
                    ),
                    horizontalMargin: 16,
                    columnSpacing: 24,
                    columns: const [
                      DataColumn(
                        label: Text(
                          "Evento",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Ingressos",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Total",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Canal",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Período",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    rows: eventos.map<DataRow>((evento) {
                      final double valorEvento = double.tryParse(
                            evento["total_vendas"].toString(),
                          ) ??
                          0.0;

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              evento["evento_nome"].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              evento["total_pedidos"].toString(),
                            ),
                          ),
                          DataCell(
                            Text(
                              formatadorMoeda.format(
                                valorEvento,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              evento["canal_venda"] ?? "---",
                            ),
                          ),
                          DataCell(
                            Text(
                              evento["periodo"] ?? "---",
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cardMetrica(
    String titulo,
    String valor, {
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blueGrey.withOpacity(0.08),
        border: Border.all(
          color: Colors.blueGrey.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              valor,
              style: TextStyle(
                fontSize: isFullWidth ? 26 : 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
