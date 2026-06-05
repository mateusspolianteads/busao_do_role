import 'dart:convert';
import 'package:busao_do_role/services/auth_service.dart';
import 'package:busao_do_role/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PedidoModel {
  final int id;
  final String clienteNome;
  final String eventoNome;
  final String dataVenda;
  final double valorLote;
  final String statusPedido;
  final String statusIngresso;
  final String lote;
  final String canalVenda;
  final String metodoPagamento;
  final bool transferido;
  final bool aprovado;

  PedidoModel({
    required this.id,
    required this.clienteNome,
    required this.eventoNome,
    required this.dataVenda,
    required this.valorLote,
    required this.statusPedido,
    required this.statusIngresso,
    required this.lote,
    required this.canalVenda,
    required this.metodoPagamento,
    required this.transferido,
    required this.aprovado,
  });

  factory PedidoModel.fromJson(Map<String, dynamic> json) {
    return PedidoModel(
      id: json['id'] ?? 0,
      clienteNome: json['cliente_nome'] ?? 'Cliente Desconhecido',
      eventoNome: json['evento_nome'] ?? '---',
      dataVenda: json['data_venda'] ?? '',
      valorLote: (json['valor_lote'] ?? 0.0).toDouble(),
      statusPedido: json['status_pedido'] ?? 'Indefinido',
      statusIngresso: json['status_ingresso'] ?? '---',
      lote: json['lote'] ?? '---',
      canalVenda: json['canal_venda'] ?? '---',
      metodoPagamento: json['metodo_pagamento'] ?? '---',
      transferido: json['transferido'] == true,
      aprovado: json['aprovado'] == true,
    );
  }
}

class EventoModel {
  final int id;
  final String nome;

  EventoModel({required this.id, required this.nome});

  factory EventoModel.fromJson(Map<String, dynamic> json) {
    return EventoModel(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? 'Evento sem nome',
    );
  }
}

class PedidosTab extends StatefulWidget {
  const PedidosTab({super.key});

  @override
  State<PedidosTab> createState() => _PedidosTabState();
}

class _PedidosTabState extends State<PedidosTab> {
  List<EventoModel> _eventos = [];
  int? _eventoSelecionadoId;
  bool _isLoadingEventos = true;

  List<PedidoModel> _pedidos = [];
  bool _isLoadingPedidos = false;
  bool _hasErrorPedidos = false;

  int _paginaAtual = 1;
  final int _limit = 10;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchEventos();
  }

  Future<void> _fetchEventos() async {
    try {
      final response = await ApiClient.request('/eventos/listar');

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse =
            json.decode(utf8.decode(response.bodyBytes));
        List<EventoModel> eventosCarregados =
            jsonResponse.map((data) => EventoModel.fromJson(data)).toList();

        setState(() {
          _eventos = eventosCarregados;
          _isLoadingEventos = false;
        });
      } else {
        throw Exception('Falha ao carregar eventos');
      }
    } catch (e) {
      setState(() {
        _isLoadingEventos = false;
      });
    }
  }

  Future<void> _fetchPedidos() async {
    if (_eventoSelecionadoId == null) return;

    setState(() {
      _isLoadingPedidos = true;
      _hasErrorPedidos = false;
    });

    int skip = (_paginaAtual - 1) * _limit;

    try {
      final response = await ApiClient.request(
        "/pedidos/evento/$_eventoSelecionadoId?skip=$skip&limit=$_limit",
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
            json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> pedidosJson = jsonResponse['pedidos'];
        List<PedidoModel> novosPedidos = pedidosJson
            .map((data) => PedidoModel.fromJson(data as Map<String, dynamic>))
            .toList();

        setState(() {
          _pedidos = novosPedidos;
          _hasMore = novosPedidos.length == _limit;
          _isLoadingPedidos = false;
        });
      } else {
        throw Exception('Falha na API');
      }
    } catch (e) {
      setState(() {
        _isLoadingPedidos = false;
        _hasErrorPedidos = true;
      });
    }
  }

  void _mudarEvento(int eventoId) {
    if (_eventoSelecionadoId == eventoId) return;

    setState(() {
      _eventoSelecionadoId = eventoId;
      _paginaAtual = 1;
      _pedidos.clear();
    });

    _fetchPedidos();
  }

  void _proximaPagina() {
    if (_hasMore && !_isLoadingPedidos) {
      setState(() => _paginaAtual++);
      _fetchPedidos();
    }
  }

  void _paginaAnterior() {
    if (_paginaAtual > 1 && !_isLoadingPedidos) {
      setState(() => _paginaAtual--);
      _fetchPedidos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? const Color(0xFFA0A0A0) : Colors.grey[700]!;
    final borderColor =
        isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Pedidos",
              style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.w800, color: textColor)),
          Text("Filtre os pedidos por evento",
              style: TextStyle(color: subtitleColor)),
          const SizedBox(height: 24),
          _isLoadingEventos
              ? const SizedBox(
                  height: 50,
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: CircularProgressIndicator()))
              : _eventos.isEmpty
                  ? const Text("Nenhum evento encontrado.",
                      style: TextStyle(color: Colors.red))
                  : Container(
                      width: 350,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _eventoSelecionadoId,
                          hint: Text("Selecione um evento",
                              style: TextStyle(color: subtitleColor)),
                          icon: Icon(LucideIcons.chevronDown,
                              color: subtitleColor, size: 20),
                          dropdownColor: Theme.of(context).cardColor,
                          isExpanded: true,
                          style: TextStyle(color: textColor, fontSize: 16),
                          items: _eventos.map((evento) {
                            return DropdownMenuItem<int>(
                              value: evento.id,
                              child: Text(evento.nome,
                                  overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (novoValor) {
                            if (novoValor != null) {
                              _mudarEvento(novoValor);
                            }
                          },
                        ),
                      ),
                    ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: _buildContent(
                        isDark, textColor, subtitleColor, borderColor),
                  ),
                  Divider(color: borderColor, height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                          onPressed: (_paginaAtual > 1 &&
                                  !_isLoadingPedidos &&
                                  _eventoSelecionadoId != null)
                              ? _paginaAnterior
                              : null,
                          color: textColor,
                          disabledColor: textColor.withOpacity(0.2),
                        ),
                        Text(
                          "Página $_paginaAtual",
                          style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 18),
                          onPressed: (_hasMore &&
                                  !_isLoadingPedidos &&
                                  _eventoSelecionadoId != null)
                              ? _proximaPagina
                              : null,
                          color: textColor,
                          disabledColor: textColor.withOpacity(0.2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildContent(
      bool isDark, Color textColor, Color subtitleColor, Color borderColor) {
    if (_eventoSelecionadoId == null) return InitialState(isDark: isDark);
    if (_hasErrorPedidos) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Erro ao carregar os pedidos.',
                style: TextStyle(color: Colors.red)),
            TextButton(
                onPressed: _fetchPedidos, child: const Text('Tentar novamente'))
          ],
        ),
      );
    }
    if (_isLoadingPedidos)
      return const Center(child: CircularProgressIndicator());
    if (_pedidos.isEmpty) return EmptyState(isDark: isDark);

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: _pedidos.length,
      separatorBuilder: (context, index) =>
          Divider(color: borderColor, height: 32),
      itemBuilder: (context, index) {
        return PedidoListItem(
          pedido: _pedidos[index],
          textColor: textColor,
          subtitleColor: subtitleColor,
          isDark: isDark,
        );
      },
    );
  }
}

class InitialState extends StatelessWidget {
  final bool isDark;
  const InitialState({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final iconColor = isDark ? Colors.white10 : Colors.black12;
    final emptyTextColor = isDark ? Colors.white54 : Colors.black54;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.mousePointerClick, size: 60, color: iconColor),
          const SizedBox(height: 16),
          Text(
            "Selecione um evento acima para carregar os pedidos",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: emptyTextColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

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
          Text("Nenhum pedido para este evento",
              style: TextStyle(color: emptyTextColor)),
        ],
      ),
    );
  }
}

class PedidoListItem extends StatelessWidget {
  final PedidoModel pedido;
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

  String formatarData(String dataIso) {
    if (dataIso.isEmpty) return "Data não informada";
    try {
      final dateTime = DateTime.parse(dataIso);
      return DateFormat('dd MMM yyyy', 'pt_BR').format(dateTime);
    } catch (e) {
      return dataIso;
    }
  }

  String formatarMoeda(double valor) {
    final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatador.format(valor);
  }

  void _mostrarPopUpDetalhes(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final labelStyle = TextStyle(
            color: subtitleColor, fontSize: 13, fontWeight: FontWeight.w500);
        final valStyle = TextStyle(
            color: textColor, fontSize: 15, fontWeight: FontWeight.bold);

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Theme.of(context).cardColor,
          title: Row(
            children: [
              Icon(LucideIcons.receipt, color: textColor),
              const SizedBox(width: 10),
              Text("Pedido #${pedido.id}",
                  style:
                      TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Wrap(
                runSpacing: 16,
                spacing: 24,
                children: [
                  _itemInfo(
                      "ID do Pedido", "#${pedido.id}", labelStyle, valStyle,
                      width: 130),
                  _itemInfo("Cliente", pedido.clienteNome, labelStyle, valStyle,
                      width: 300),
                  _itemInfo("Evento", pedido.eventoNome, labelStyle, valStyle,
                      width: 210),
                  _itemInfo("Data Venda", formatarData(pedido.dataVenda),
                      labelStyle, valStyle,
                      width: 210),
                  _itemInfo("Status Pedido", pedido.statusPedido, labelStyle,
                      valStyle,
                      width: 210),
                  _itemInfo("Status Ingresso", pedido.statusIngresso,
                      labelStyle, valStyle,
                      width: 210),
                  _itemInfo("Lote", pedido.lote, labelStyle, valStyle,
                      width: 210),
                  _itemInfo("Valor do Lote", formatarMoeda(pedido.valorLote),
                      labelStyle, valStyle,
                      width: 210),
                  _itemInfo("Canal", pedido.canalVenda, labelStyle, valStyle,
                      width: 210),
                  _itemInfo("Método Pagamento", pedido.metodoPagamento,
                      labelStyle, valStyle,
                      width: 210),
                  _itemInfo("Transferido", pedido.transferido ? "Sim" : "Não",
                      labelStyle, valStyle,
                      width: 210),
                  _itemInfo("Aprovado", pedido.aprovado ? "Sim" : "Não",
                      labelStyle, valStyle,
                      width: 210),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: textColor),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Fechar",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }

  Widget _itemInfo(
      String label, String valor, TextStyle labelStyle, TextStyle valStyle,
      {double? width}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 4),
          Text(valor,
              style: valStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (pedido.statusPedido.toLowerCase()) {
      case "aprovado":
        statusColor = Colors.green;
        break;
      case "pendente":
        statusColor = Colors.orange;
        break;
      case "cancelado":
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return InkWell(
      onTap: () => _mostrarPopUpDetalhes(context),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(LucideIcons.receipt, color: textColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pedido.clienteNome,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "#${pedido.id} • ${formatarData(pedido.dataVenda)}",
                    style: TextStyle(color: subtitleColor, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatarMoeda(pedido.valorLote),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    pedido.statusPedido,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
