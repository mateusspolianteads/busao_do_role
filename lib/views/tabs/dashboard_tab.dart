import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:busao_do_role/services/dio_client.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

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
    setState(() => isLoading = true);

    try {
      final queryParams = <String, String>{};

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

      final data =
          response.data is String ? jsonDecode(response.data) : response.data;

      setState(() {
        vendedores = [
          "TODOS",
          ...List<String>.from(data["filtros"]["vendedores"] ?? [])
        ];
        periodos = [
          "TODOS",
          ...List<String>.from(data["filtros"]["periodos"] ?? [])
        ];
        totalVendas = (data["totals"]["total_vendas"] ?? 0).toDouble();
        ingressosVendidos = data["totals"]["ingressos_vendidos"] ?? 0;
        eventosComVenda = data["totals"]["eventos_com_venda"] ?? 0;
        eventos = data["eventos"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERRO DASHBOARD: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: carregarDashboard,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWideScreen = constraints.maxWidth > 900;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER ---
                    Text(
                      "Painel de Vendas",
                      style: TextStyle(
                        fontSize: isWideScreen ? 32 : 26,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Puxe para baixo para atualizar dados",
                      style: TextStyle(fontSize: 13, color: subtitleColor),
                    ),
                    const SizedBox(height: 24),

                    // --- FILTROS RESPONSIVOS ---
                    if (constraints.maxWidth > 600)
                      Row(
                        children: [
                          Expanded(child: _buildFiltroVendedor()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildFiltroPeriodo()),
                        ],
                      )
                    else ...[
                      _buildFiltroVendedor(),
                      const SizedBox(height: 16),
                      _buildFiltroPeriodo(),
                    ],

                    const SizedBox(height: 28),

                    // --- CARDS DE MÉTRICAS (Otimizado) ---
                    _PainelMetricas(
                      totalVendas: totalVendas,
                      ingressosVendidos: ingressosVendidos,
                      eventosComVenda: eventosComVenda,
                      formatadorMoeda: formatadorMoeda,
                      isWideScreen: isWideScreen,
                    ),

                    const SizedBox(height: 36),

                    // --- SEÇÃO RESPONSIVA: GRÁFICO & TABELA ---
                    if (isWideScreen)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionTitle(
                                    title: "Desempenho por Evento",
                                    color: textColor),
                                const SizedBox(height: 12),
                                _GraficoBarrasOtimizado(
                                    eventos: eventos,
                                    formatadorMoeda: formatadorMoeda),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionTitle(
                                    title: "Lista de Eventos",
                                    color: textColor),
                                const SizedBox(height: 12),
                                _TabelaEventosOtimizada(
                                  eventos: eventos,
                                  formatadorMoeda: formatadorMoeda,
                                  vendedorSelecionado: selectedVendedor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _SectionTitle(
                          title: "Desempenho por Evento", color: textColor),
                      const SizedBox(height: 12),
                      _GraficoBarrasOtimizado(
                          eventos: eventos, formatadorMoeda: formatadorMoeda),
                      const SizedBox(height: 36),
                      _SectionTitle(
                          title: "Lista de Eventos", color: textColor),
                      const SizedBox(height: 12),
                      _TabelaEventosOtimizada(
                          eventos: eventos,
                          formatadorMoeda: formatadorMoeda,
                          vendedorSelecionado: selectedVendedor),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFiltroVendedor() {
    return DropdownButtonFormField<String>(
      key: ValueKey("vendedor_$selectedVendedor"),
      initialValue: selectedVendedor,
      decoration: const InputDecoration(
        labelText: "Canal de Venda",
        prefixIcon: Icon(Icons.storefront),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      items: vendedores.map((vendedor) {
        return DropdownMenuItem(
            value: vendedor,
            child: Text(vendedor, style: const TextStyle(fontSize: 14)));
      }).toList(),
      onChanged: (value) {
        setState(() => selectedVendedor = value ?? "TODOS");
        carregarDashboard();
      },
    );
  }

  Widget _buildFiltroPeriodo() {
    return DropdownButtonFormField<String>(
      key: ValueKey("periodo_$selectedPeriodo"),
      initialValue: selectedPeriodo,
      decoration: const InputDecoration(
        labelText: "Período",
        prefixIcon: Icon(Icons.date_range),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      items: periodos.map((periodo) {
        return DropdownMenuItem(
            value: periodo,
            child: Text(periodo, style: const TextStyle(fontSize: 14)));
      }).toList(),
      onChanged: (value) {
        setState(() => selectedPeriodo = value ?? "TODOS");
        carregarDashboard();
      },
    );
  }
}

// --- SUB-WIDGETS ISOLADOS PARA EVITAR REBUILDS DESNECESSÁRIOS ---

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
    );
  }
}

class _PainelMetricas extends StatelessWidget {
  final double totalVendas;
  final int ingressosVendidos;
  final int eventosComVenda;
  final NumberFormat formatadorMoeda;
  final bool isWideScreen;

  const _PainelMetricas({
    required this.totalVendas,
    required this.ingressosVendidos,
    required this.eventosComVenda,
    required this.formatadorMoeda,
    required this.isWideScreen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listCards = [
      _CardMetrica(
          titulo: "Total de Vendas",
          valor: formatadorMoeda.format(totalVendas),
          icone: Icons.attach_money,
          corDestaque: theme.primaryColor),
      const _CardMetrica(
          titulo: "Ingressos",
          valor: "",
          icone: Icons.local_activity,
          corDestaque: Colors.orange,
          dynamicValor: true),
      const _CardMetrica(
          titulo: "Eventos",
          valor: "",
          icone: Icons.calendar_month,
          corDestaque: Colors.teal,
          dynamicValor: true),
    ];

    // Gambiarra limpa para injetar os valores dinâmicos sem quebrar const
    final updatedCards = [
      listCards[0],
      _CardMetrica(
          titulo: "Ingressos",
          valor: ingressosVendidos.toString(),
          icone: Icons.local_activity,
          corDestaque: Colors.orange),
      _CardMetrica(
          titulo: "Eventos",
          valor: eventosComVenda.toString(),
          icone: Icons.calendar_month,
          corDestaque: Colors.teal),
    ];

    if (isWideScreen) {
      return Row(
        children: updatedCards
            .map((card) => Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(right: 16), child: card)))
            .toList(),
      );
    } else {
      return Column(
        children: [
          updatedCards[0],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: updatedCards[1]),
              const SizedBox(width: 12),
              Expanded(child: updatedCards[2]),
            ],
          ),
        ],
      );
    }
  }
}

class _CardMetrica extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;
  final Color corDestaque;
  final bool dynamicValor;

  const _CardMetrica({
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.corDestaque,
    this.dynamicValor = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(
            color:
                isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: corDestaque.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icone, color: corDestaque, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    valor,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
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

class _GraficoBarrasOtimizado extends StatelessWidget {
  final List<dynamic> eventos;
  final NumberFormat formatadorMoeda;

  const _GraficoBarrasOtimizado(
      {required this.eventos, required this.formatadorMoeda});

  @override
  Widget build(BuildContext context) {
    if (eventos.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    double maxValor = 100;
    for (var e in eventos) {
      double v = double.tryParse(e["total_vendas"].toString()) ?? 0;
      if (v > maxValor) maxValor = v;
    }
    maxValor = maxValor * 1.15;

    // Define passos fixos inteligentes para o eixo Y não gerar linhas encavaladas
    double intervaloY;
    if (maxValor <= 500) {
      intervaloY = 100;
    } else if (maxValor <= 2000) {
      intervaloY =
          200; // Vai pular de 200 em 200 (ex: 200, 400, 600, 800, 1000, 1200)
    } else if (maxValor <= 5000) {
      intervaloY = 1000;
    } else if (maxValor <= 20000) {
      intervaloY = 2000;
    } else {
      intervaloY = (maxValor / 5).ceilToDouble();
    }

    return RepaintBoundary(
      child: Container(
        height: 300,
        padding: const EdgeInsets.fromLTRB(12, 24, 16, 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color:
                  isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.2)),
        ),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxValor,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) =>
                    isDark ? Colors.grey[800]! : Colors.grey[200]!,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  String nomeEvento = eventos[group.x.toInt()]["evento_nome"];
                  return BarTooltipItem(
                    "$nomeEvento\n",
                    TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: formatadorMoeda.format(rod.toY),
                        style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < eventos.length) {
                      String label = eventos[index]["evento_nome"].toString();
                      if (label.length > 8)
                        label = "${label.substring(0, 6)}..";
                      return SideTitleWidget(
                        meta: meta,
                        space: 4,
                        child: Text(label,
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w500)),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 45,
                  interval:
                      intervaloY, // <-- Força o gráfico a respeitar o intervalo calculado
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return const SizedBox.shrink();

                    if (value > maxValor - (intervaloY / 2)) {
                      return const SizedBox.shrink();
                    }

                    String text;

                    if (value >= 1000) {
                      final valorK = value / 1000;
                      text = valorK % 1 == 0
                          ? "${valorK.toStringAsFixed(0)}k"
                          : "${valorK.toStringAsFixed(1)}k";
                    } else {
                      text = value.toStringAsFixed(0);
                    }

                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        "R\$$text",
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval:
                  intervaloY, // <-- Faz as linhas de grade baterem certinho com os textos
              getDrawingHorizontalLine: (value) => FlLine(
                color: isDark ? Colors.white10 : Colors.black12,
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: eventos.asMap().entries.map((entry) {
              int idx = entry.key;
              double faturamento =
                  double.tryParse(entry.value["total_vendas"].toString()) ??
                      0.0;

              return BarChartGroupData(
                x: idx,
                barRods: [
                  BarChartRodData(
                    toY: faturamento,
                    color: theme.primaryColor,
                    width: min(24, 150 / eventos.length),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxValor,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.black.withValues(alpha: 0.02),
                    ),
                  )
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// --- TABELA OTIMIZADA ---
// --- TABELA E CARDS OTIMIZADOS COM RESPONSIVIDADE PARA TELAS MAIORES ---
class _TabelaEventosOtimizada extends StatelessWidget {
  final List<dynamic> eventos;
  final NumberFormat formatadorMoeda;
  final String vendedorSelecionado;

  const _TabelaEventosOtimizada({
    required this.eventos,
    required this.formatadorMoeda,
    required this.vendedorSelecionado,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 800;

    if (eventos.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
        child: const Center(
          child: Text(
            "Nenhum faturamento registrado.",
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final textoCanal =
        vendedorSelecionado == "TODOS" ? "TODOS" : vendedorSelecionado;

    // Se a tela for mobile, usamos a estrutura adaptativa de Cards/Grid
    if (isMobile) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // Define a quantidade de colunas baseado no espaço disponível na seção
          int crossAxisCount = 1;
          if (constraints.maxWidth > 1100) {
            crossAxisCount = 3;
          } else if (constraints.maxWidth > 650) {
            crossAxisCount = 2;
          }

          if (crossAxisCount > 1) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: eventos.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                mainAxisExtent:
                    185, // Altura fixa confortável para o conteúdo do card
              ),
              itemBuilder: (context, index) {
                return _buildCardEvento(
                    eventos[index], theme, isDark, textoCanal);
              },
            );
          }

          // Fallback padrão para telas bem estreitas (1 coluna por linha)
          return Column(
            children: eventos.map<Widget>((evento) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCardEvento(evento, theme, isDark, textoCanal),
              );
            }).toList(),
          );
        },
      );
    }

    // Mantém a visualização em tabela caso a tela mude explicitamente para o modo Desktop lado a lado amplo
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.2),
        ),
        color: theme.cardColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03),
            ),
            horizontalMargin: 16,
            columnSpacing: 24,
            columns: const [
              DataColumn(label: Text("Evento")),
              DataColumn(label: Text("Ingressos"), numeric: true),
              DataColumn(label: Text("Total"), numeric: true),
              DataColumn(label: Text("Canal")),
              DataColumn(label: Text("Período")),
            ],
            rows: eventos.map<DataRow>((evento) {
              final double valorEvento =
                  double.tryParse(evento["total_vendas"].toString()) ?? 0.0;

              return DataRow(
                cells: [
                  DataCell(Text(evento["evento_nome"].toString())),
                  DataCell(Text(evento["total_pedidos"].toString())),
                  DataCell(
                    Text(
                      formatadorMoeda.format(valorEvento),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  DataCell(Text(textoCanal)),
                  DataCell(Text(evento["periodo"] ?? "---")),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Helper isolado para renderizar a estrutura visual do Card
  Widget _buildCardEvento(
      dynamic evento, ThemeData theme, bool isDark, String canal) {
    final double valorEvento =
        double.tryParse(evento["total_vendas"].toString()) ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment
            .spaceBetween, // Garante alinhamento vertical uniforme no Grid
        children: [
          Text(
            evento["evento_nome"].toString(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            runSpacing: 6,
            spacing: 16,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_activity, size: 18),
                  const SizedBox(width: 6),
                  Text("${evento["total_pedidos"]} ingressos"),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 18,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    formatadorMoeda.format(valorEvento),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 16, thickness: 0.5),
          Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.storefront, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      canal,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.date_range, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      evento["periodo"] ?? "---",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
