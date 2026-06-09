import 'dart:convert';
import 'package:busao_do_role/services/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
  int _totalPedidos = 0;
  bool _hasMore = true;

  int get _totalPaginas {
    if (_totalPedidos == 0) return 1;
    return (_totalPedidos / _limit).ceil();
  }

  @override
  void initState() {
    super.initState();
    _fetchEventos();
  }

  Future<void> _fetchEventos() async {
    try {
      final response = await DioClient.dio.get('/eventos/listar');

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = response.data is String
            ? json.decode(response.data)
            : response.data;
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

  Future<void> _fetchPedidos({int? pagina}) async {
    if (_eventoSelecionadoId == null) return;

    final paginaParaBuscar = pagina ?? _paginaAtual;

    setState(() {
      _isLoadingPedidos = true;
      _hasErrorPedidos = false;
    });

    int skip = (paginaParaBuscar - 1) * _limit;

    try {
      final response = await DioClient.dio.get(
        "/pedidos/evento/$_eventoSelecionadoId",
        queryParameters: {
          'skip': skip,
          'limit': _limit,
          'page': paginaParaBuscar,
          'pagina': paginaParaBuscar,
          'limite': _limit,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = response.data is String
            ? json.decode(response.data)
            : response.data;
        final List<dynamic> pedidosJson = jsonResponse['pedidos'] ?? [];
        List<PedidoModel> novosPedidos = pedidosJson
            .map((data) => PedidoModel.fromJson(data as Map<String, dynamic>))
            .toList();

        if (mounted) {
          setState(() {
            _pedidos = novosPedidos;
            _paginaAtual =
                paginaParaBuscar; // Atualiza o indicador de página apenas em caso de sucesso

            if (jsonResponse.containsKey('total')) {
              _totalPedidos = jsonResponse['total'] ?? 0;
              _hasMore = _paginaAtual * _limit < _totalPedidos;
            } else {
              _hasMore = novosPedidos.length == _limit;
              _totalPedidos = _hasMore
                  ? _paginaAtual * _limit + 1
                  : (_paginaAtual - 1) * _limit + novosPedidos.length;
            }
            _isLoadingPedidos = false;
          });
        }
      } else {
        throw Exception('Falha na API');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPedidos = false;
          _hasErrorPedidos = true;
        });
      }
    }
  }

  void _mudarEvento(int eventoId) {
    if (_eventoSelecionadoId == eventoId) return;

    setState(() {
      _eventoSelecionadoId = eventoId;
      _paginaAtual = 1;
      _totalPedidos = 0;
      _pedidos.clear();
    });

    _fetchPedidos();
  }

  void _proximaPagina() {
    if (_hasMore && !_isLoadingPedidos) {
      _fetchPedidos(pagina: _paginaAtual + 1);
    }
  }

  void _paginaAnterior() {
    if (_paginaAtual > 1 && !_isLoadingPedidos) {
      _fetchPedidos(pagina: _paginaAtual - 1);
    }
  }

  void _mostrarPopUpDetalhes(BuildContext context, PedidoModel pedido) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? const Color(0xFFA0A0A0) : Colors.grey[700]!;

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
                  _itemInfo("Status Pedido", pedido.statusPedido, labelStyle,
                      valStyle,
                      width: 210),
                  _itemInfo("Lote", pedido.lote, labelStyle, valStyle,
                      width: 210),
                  _itemInfo(
                      "Valor do Lote",
                      "R\$ ${pedido.valorLote.toStringAsFixed(2)}",
                      labelStyle,
                      valStyle,
                      width: 210),
                  _itemInfo("Canal", pedido.canalVenda, labelStyle, valStyle,
                      width: 210),
                  _itemInfo("Método Pagamento", pedido.metodoPagamento,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? const Color(0xFFA0A0A0) : Colors.grey[700]!;
    final borderColor =
        isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Pedidos",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: textColor)),
          const SizedBox(height: 8),
          _isLoadingEventos
              ? const Center(
                  child: SizedBox(
                      height: 32,
                      child: CircularProgressIndicator(strokeWidth: 2)))
              : _eventos.isEmpty
                  ? const Center(
                      child: Text("Nenhum evento encontrado.",
                          style: TextStyle(color: Colors.red, fontSize: 13)))
                  : Container(
                      width:
                          double.infinity, // Responsivo: Ocupa 100% da largura
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 0), // Altura reduzida
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _eventoSelecionadoId,
                          hint: Text("Selecione um evento",
                              style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 13)), // Fonte menor
                          icon: Icon(LucideIcons.chevronDown,
                              color: subtitleColor, size: 16), // Ícone menor
                          dropdownColor: Theme.of(context).cardColor,
                          isExpanded: true,
                          style: TextStyle(
                              color: textColor, fontSize: 13), // Fonte menor
                          items: _eventos.map((evento) {
                            return DropdownMenuItem<int>(
                              value: evento.id,
                              child: Text(evento.nome,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13)),
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
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  // Barra de progresso linear no topo do container quando carrega background
                  if (_isLoadingPedidos && _pedidos.isNotEmpty)
                    LinearProgressIndicator(
                      color: Theme.of(context).primaryColor,
                      backgroundColor: Colors.transparent,
                      minHeight: 2,
                    )
                  else
                    const SizedBox(height: 2),
                  Expanded(
                    child: _buildContent(
                        isDark, textColor, subtitleColor, borderColor),
                  ),
                  Divider(color: borderColor, height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.first_page, size: 18),
                          onPressed: (_paginaAtual > 1 && !_isLoadingPedidos)
                              ? () => _fetchPedidos(pagina: 1)
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_left, size: 18),
                          onPressed: (_paginaAtual > 1 && !_isLoadingPedidos)
                              ? () => _fetchPedidos(pagina: _paginaAtual - 1)
                              : null,
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Theme.of(context)
                                  .dividerColor
                                  .withOpacity(0.08),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Pág. $_paginaAtual de $_totalPaginas • $_totalPedidos itens",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, size: 18),
                          onPressed: (_paginaAtual < _totalPaginas &&
                                  !_isLoadingPedidos)
                              ? () => _fetchPedidos(
                                    pagina: _paginaAtual + 1,
                                  )
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.last_page, size: 18),
                          onPressed: (_paginaAtual < _totalPaginas &&
                                  !_isLoadingPedidos)
                              ? () => _fetchPedidos(
                                    pagina: _totalPaginas,
                                  )
                              : null,
                        ),
                      ],
                    ),
                  )
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
                onPressed: () => _fetchPedidos(),
                child: const Text('Tentar novamente'))
          ],
        ),
      );
    }
    // Mostra indicador central apenas na primeira carga do evento
    if (_isLoadingPedidos && _pedidos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_pedidos.isEmpty) return EmptyState(isDark: isDark);

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _pedidos.length,
      separatorBuilder: (context, index) =>
          Divider(color: borderColor, height: 1),
      itemBuilder: (context, index) {
        final pedido = _pedidos[index];
        return PedidoItemRow(
          pedido: pedido,
          textColor: textColor,
          subtitleColor: subtitleColor,
          onTap: () => _mostrarPopUpDetalhes(context, pedido),
        );
      },
    );
  }
}

class PedidoItemRow extends StatelessWidget {
  final PedidoModel pedido;
  final Color textColor;
  final Color subtitleColor;
  final VoidCallback onTap;

  const PedidoItemRow({
    super.key,
    required this.pedido,
    required this.textColor,
    required this.subtitleColor,
    required this.onTap,
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
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pedido.clienteNome,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Lote: ${pedido.lote}",
                    style: TextStyle(color: subtitleColor, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Data: ${formatarData(pedido.dataVenda)}",
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
          Icon(LucideIcons.mousePointerClick, size: 48, color: iconColor),
          const SizedBox(height: 12),
          Text(
            "Selecione um evento acima para carregar os pedidos",
            textAlign: TextAlign.center,
            style: TextStyle(color: emptyTextColor, fontSize: 14),
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
          Icon(LucideIcons.shoppingCart, size: 48, color: iconColor),
          const SizedBox(height: 10),
          Text("Nenhum pedido para este evento",
              style: TextStyle(color: emptyTextColor, fontSize: 14)),
        ],
      ),
    );
  }
}
