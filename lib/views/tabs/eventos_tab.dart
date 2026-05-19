import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

class EventosTab extends StatefulWidget {
  const EventosTab({super.key});

  @override
  State<EventosTab> createState() => _EventosTabState();
}

class _EventosTabState extends State<EventosTab> {
  Map<String, dynamic>? eventoSelecionado;
  bool isEditingOrCreating = false;

  List eventos = [];
  List categorias = [];
  List clientes = [];

  bool carregandoClientes = false;
  bool isLoading = true;
  bool isSaving = false;

  int paginaAtual = 1;

  final int clientesPorPagina = 10;

  int totalClientes = 0;

  int get totalPaginas {
    if (totalClientes == 0) return 1;

    return (totalClientes / clientesPorPagina).ceil();
  }

  int? categoriaSelecionada;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _localController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();

  final String apiUrl = "http://127.0.0.1:8000/eventos";

  @override
  void initState() {
    super.initState();
    _fetchEventos();
    _fetchCategorias();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _dataController.dispose();
    _localController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  DateTime _parseData(String input) {
    // aceita 20/10/2026
    final partes = input.split('/');
    if (partes.length == 3) {
      final dia = int.parse(partes[0]);
      final mes = int.parse(partes[1]);
      final ano = int.parse(partes[2]);

      return DateTime(ano, mes, dia);
    }

    // fallback ISO
    return DateTime.parse(input);
  }

  Future<void> _fetchEventos() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse("$apiUrl/listar"));

      if (response.statusCode == 200) {
        setState(() {
          eventos = jsonDecode(response.body);
        });
      } else {
        eventos = [];
      }
    } catch (_) {
      eventos = [];
    }

    setState(() => isLoading = false);
  }

  Future<void> _fetchCategorias() async {
    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/categorias/listar"),
      );

      if (response.statusCode == 200) {
        setState(() {
          categorias = jsonDecode(response.body);
        });
      }
    } catch (_) {}
  }

  Future<void> _salvarEvento() async {
    if (!_formKey.currentState!.validate()) return;
    if (categoriaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Selecione uma categoria!"),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => isSaving = true);

    final dataFormatada = _parseData(_dataController.text).toIso8601String();

    final mapDados = {
      "nome": _nomeController.text,
      "categoria_id": categoriaSelecionada,
      "data_evento": dataFormatada,
      "local": _localController.text,
      "valor_passagem": double.parse(_valorController.text),
    };

    try {
      http.Response response;

      if (eventoSelecionado == null) {
        response = await http.post(
          Uri.parse("$apiUrl/cadastrar"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(mapDados),
        );
      } else {
        response = await http.put(
          Uri.parse("$apiUrl/atualizar/${eventoSelecionado!['id']}"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(mapDados),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        _voltarParaEventos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Evento salvo com sucesso!'),
                backgroundColor: Colors.green),
          );
        }
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> _deletarEvento(dynamic id) async {
    try {
      await http.delete(Uri.parse("$apiUrl/deletar/$id"));
      _fetchEventos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Evento deletado!'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao deletar: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> importarPlanilha() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null) return;

      final file = result.files.first;

      FormData formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(
          file.bytes!,
          filename: file.name,
        ),
        "evento_id": eventoSelecionado!['id'],
      });

      final response = await Dio().post(
        "http://127.0.0.1:8000/clientes/importar-planilha",
        data: formData,
      );

      if (response.statusCode == 201) {
        await _fetchClientesDoEvento(eventoSelecionado!['id']);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Planilha importada com sucesso"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro ao importar planilha"),
        ),
      );
    }
  }

  Future<void> editarCliente(
    int id,
    String nome,
    String email,
    String cpf,
    String telefone,
  ) async {
    await http.put(
      Uri.parse("http://127.0.0.1:8000/clientes/atualizar/$id"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'cpf': cpf,
        'telefone': telefone,
      }),
    );

    await _fetchClientesDoEvento(eventoSelecionado!['id']);
  }

  void _mostrarDetalhesCliente(Map cliente) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClienteDetalhesDialog(
          cliente: cliente,
          onSalvar: (nome, email, cpf, telefone) async {
            await editarCliente(
              cliente['id'],
              nome,
              email,
              cpf,
              telefone,
            );
          },
        );
      },
    );
  }

  Future<void> _fetchClientesDoEvento(int eventoId) async {
    setState(() {
      carregandoClientes = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          "http://127.0.0.1:8000/clientes/evento/$eventoId?pagina=$paginaAtual&limite=$clientesPorPagina",
        ),
      );

      if (response.statusCode == 200) {
        final dados = jsonDecode(response.body);

        setState(() {
          clientes = dados['clientes'];

          totalClientes = dados['total'];

          carregandoClientes = false;
        });
      }
    } catch (e) {
      setState(() {
        carregandoClientes = false;
      });

      print(e);
    }
  }

  void _abrirFormulario({Map<String, dynamic>? evento}) {
    setState(() {
      eventoSelecionado = evento;
      isEditingOrCreating = true;
    });

    if (evento != null) {
      _nomeController.text = evento['nome'] ?? '';
      categoriaSelecionada = evento['categoria_id'];
      _dataController.text = evento['data_evento'] ?? '';
      _localController.text = evento['local'] ?? '';
      _valorController.text = evento['valor_passagem'].toString();
    } else {
      _nomeController.clear();
      _dataController.clear();
      _localController.clear();
      _valorController.clear();
      categoriaSelecionada = null;
    }
  }

  void _abrirDetalhesEvento(Map<String, dynamic> evento) async {
    setState(() {
      eventoSelecionado = evento;
      isEditingOrCreating = false;
    });

    await _fetchClientesDoEvento(evento['id']);
  }

  void _voltarParaEventos() {
    setState(() {
      eventoSelecionado = null;
      isEditingOrCreating = false;
    });
    _fetchEventos();
  }

  @override
  Widget build(BuildContext context) {
    Widget telaAtual;

    if (isEditingOrCreating) {
      telaAtual = _buildFormularioDaUI(context);
    } else if (eventoSelecionado != null && !isEditingOrCreating) {
      telaAtual = _buildTelaDoEventoDetalhado(context);
    } else {
      telaAtual = _buildTelaDeEventos(context);
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: telaAtual,
    );
  }

  Widget _buildTelaDeEventos(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? const Color(0xFFA0A0A0) : Colors.grey[700]!;

    return Padding(
      key: const ValueKey('TelaEventos'),
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Eventos",
                        style: TextStyle(
                            fontSize: isMobile ? 28 : 32,
                            fontWeight: FontWeight.w800,
                            color: textColor)),
                    Text("Gerencie seus rolês, locais e valores",
                        style: TextStyle(color: subtitleColor)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _abrirFormulario(),
                icon: Icon(LucideIcons.plus,
                    size: 18, color: isDark ? Colors.white : Colors.black),
                label: isMobile
                    ? const SizedBox.shrink()
                    : Text("Adicionar",
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05),
                  padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 15 : 20,
                      vertical: isMobile ? 15 : 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor))
                : eventos.isEmpty
                    ? Center(
                        child: Text(
                            "Nenhum evento encontrado.\nCrie seu primeiro rolê!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: subtitleColor)),
                      )
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isMobile ? 1 : 3,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 2.3,
                        ),
                        itemCount: eventos.length,
                        itemBuilder: (context, index) {
                          return _buildEventoCard(eventos[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventoCard(Map evento) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final borderColor =
        isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.1);
    final textColor = isDark ? Colors.white : Colors.black;

    // Tentativa de formatar a data de forma amigável se vier como ISO
    String dataDisplay = evento['data_evento'] ?? '--/--/----';
    if (dataDisplay.contains('T')) {
      try {
        final d = DateTime.parse(dataDisplay);
        dataDisplay =
            "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
      } catch (_) {}
    }

    return InkWell(
      onTap: () => _abrirDetalhesEvento(Map<String, dynamic>.from(evento)),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    evento['nome'] ?? 'Sem Nome',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(LucideIcons.pencil,
                          size: 16,
                          color: isDark
                              ? const Color(0xFFA0A0A0)
                              : Colors.grey[700]),
                      onPressed: () => _abrirFormulario(
                          evento: Map<String, dynamic>.from(evento)),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2,
                          size: 16, color: Colors.red),
                      onPressed: () => _deletarEvento(evento['id']),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(LucideIcons.mapPin,
                    size: 14, color: Color(0xFFB30000)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    evento['local'] ?? 'Sem local',
                    style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(LucideIcons.calendar,
                    size: 14, color: Color(0xFFB30000)),
                const SizedBox(width: 5),
                Text(dataDisplay,
                    style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 13)),
                const SizedBox(width: 15),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "R\$ ${evento['valor_passagem'] ?? '0.0'}",
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.green,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormularioDaUI(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final cardColor = Theme.of(context).cardColor;
    final borderColor =
        isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.1);

    bool isEditing = eventoSelecionado != null;

    return Padding(
      key: const ValueKey('TelaFormulario'),
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                  icon: Icon(LucideIcons.arrowLeft, color: textColor),
                  onPressed: _voltarParaEventos),
              const SizedBox(width: 10),
              Text(
                isEditing ? "Editar Evento" : "Novo Evento",
                style: TextStyle(
                    fontSize: isMobile ? 24 : 32,
                    fontWeight: FontWeight.w800,
                    color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      TextFormField(
                        controller: _nomeController,
                        style: TextStyle(color: textColor),
                        decoration: _buildInputDecoration(
                            "Nome do Evento (Ex: BGS 2026)", LucideIcons.type),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Informe o nome do evento'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<int>(
                        value: categoriaSelecionada,
                        dropdownColor: cardColor,
                        style: TextStyle(color: textColor),
                        decoration:
                            _buildInputDecoration("Categoria", LucideIcons.tag),
                        items: categorias.map<DropdownMenuItem<int>>((c) {
                          return DropdownMenuItem(
                            value: c['id'],
                            child: Text(c['nome']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            categoriaSelecionada = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Selecione uma categoria' : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _dataController,
                        style: TextStyle(color: textColor),
                        decoration: _buildInputDecoration(
                            "Data (Ex: 20/10/2026)", LucideIcons.calendar),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Informe a data'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _localController,
                        style: TextStyle(color: textColor),
                        decoration: _buildInputDecoration(
                            "Local do Evento", LucideIcons.mapPin),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Informe o local'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _valorController,
                        style: TextStyle(color: textColor),
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration(
                            "Valor da Passagem (Ex: 150.00)",
                            LucideIcons.dollarSign),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Informe o valor'
                            : null,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : _salvarEvento,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB30000),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isSaving
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text("SALVAR EVENTO",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
      prefixIcon: Icon(icon, color: isDark ? Colors.white54 : Colors.black54),
      filled: true,
      fillColor: isDark
          ? Colors.white.withOpacity(0.02)
          : Colors.black.withOpacity(0.02),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFB30000), width: 2),
      ),
    );
  }

  Widget _buildTelaDoEventoDetalhado(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 900;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : Colors.black;

    return Padding(
      key: const ValueKey('TelaDetalhesEvento'),
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  LucideIcons.arrowLeft,
                  color: textColor,
                ),
                onPressed: _voltarParaEventos,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  eventoSelecionado!['nome'],
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: importarPlanilha,
            icon: const Icon(LucideIcons.fileSpreadsheet),
            label: const Text("Importar Planilha"),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: carregandoClientes
                ? Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black12,
                      ),
                    ),
                    child: clientes.isEmpty
                        ? Center(
                            child: Text(
                              "Nenhum cliente nesse evento",
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: SingleChildScrollView(
                                      child: DataTable(
                                        horizontalMargin: 30,
                                        columnSpacing: isMobile ? 25 : 60,
                                        dataRowMinHeight: 65,
                                        dataRowMaxHeight: 75,
                                        headingRowHeight: 60,
                                        showCheckboxColumn: false,
                                        headingRowColor:
                                            WidgetStateProperty.all(
                                          isDark
                                              ? Colors.white.withOpacity(0.02)
                                              : Colors.black.withOpacity(0.02),
                                        ),
                                        columns: [
                                          DataColumn(
                                            label: Text(
                                              "NOME",
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.white70
                                                    : Colors.black54,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          if (!isMobile)
                                            DataColumn(
                                              label: Text(
                                                "EMAIL",
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          DataColumn(
                                            label: Text(
                                              "CPF",
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.white70
                                                    : Colors.black54,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          if (!isMobile)
                                            DataColumn(
                                              label: Text(
                                                "AÇÕES",
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                        ],
                                        rows: clientes.map<DataRow>((cliente) {
                                          return DataRow(
                                            onSelectChanged: (selected) {
                                              if (selected != null) {
                                                _mostrarDetalhesCliente(
                                                    cliente);
                                              }
                                            },
                                            cells: [
                                              DataCell(
                                                SizedBox(
                                                  width: 250,
                                                  child: Text(
                                                    cliente['nome'] ?? "",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: textColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (!isMobile)
                                                DataCell(
                                                  SizedBox(
                                                    width: 320,
                                                    child: Text(
                                                      cliente['email'] ?? "",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: isDark
                                                            ? Colors.white70
                                                            : Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              DataCell(
                                                Text(
                                                  cliente['cpf'] ?? "",
                                                  style: TextStyle(
                                                    color: isDark
                                                        ? Colors.white70
                                                        : Colors.black87,
                                                  ),
                                                ),
                                              ),
                                              if (!isMobile)
                                                DataCell(
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: Theme.of(context)
                                                          .primaryColor
                                                          .withOpacity(0.12),
                                                    ),
                                                    child: IconButton(
                                                      icon: Icon(
                                                        LucideIcons.pencil,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        size: 18,
                                                      ),
                                                      onPressed: () =>
                                                          _mostrarDetalhesCliente(
                                                              cliente),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: isDark
                                          ? Colors.white10
                                          : Colors.black12,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: paginaAtual > 1
                                          ? () async {
                                              setState(() {
                                                paginaAtual--;
                                              });

                                              await _fetchClientesDoEvento(
                                                eventoSelecionado!['id'],
                                              );
                                            }
                                          : null,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.white.withOpacity(0.03)
                                              : Colors.black.withOpacity(0.03),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isDark
                                                ? Colors.white10
                                                : Colors.black12,
                                          ),
                                        ),
                                        child: Icon(
                                          LucideIcons.chevronLeft,
                                          color: paginaAtual > 1
                                              ? (isDark
                                                  ? Colors.white
                                                  : Colors.black)
                                              : Colors.grey,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "$paginaAtual",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        "de $totalPaginas",
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black54,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: paginaAtual < totalPaginas
                                          ? () async {
                                              setState(() {
                                                paginaAtual++;
                                              });

                                              await _fetchClientesDoEvento(
                                                eventoSelecionado!['id'],
                                              );
                                            }
                                          : null,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.white.withOpacity(0.03)
                                              : Colors.black.withOpacity(0.03),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isDark
                                                ? Colors.white10
                                                : Colors.black12,
                                          ),
                                        ),
                                        child: Icon(
                                          LucideIcons.chevronRight,
                                          color: paginaAtual < totalPaginas
                                              ? (isDark
                                                  ? Colors.white
                                                  : Colors.black)
                                              : Colors.grey,
                                          size: 20,
                                        ),
                                      ),
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
}

class ClienteDetalhesDialog extends StatefulWidget {
  final Map cliente;

  final Function(
    String nome,
    String email,
    String cpf,
    String telefone,
  ) onSalvar;

  const ClienteDetalhesDialog({
    super.key,
    required this.cliente,
    required this.onSalvar,
  });

  @override
  State<ClienteDetalhesDialog> createState() => _ClienteDetalhesDialogState();
}

class _ClienteDetalhesDialogState extends State<ClienteDetalhesDialog> {
  late TextEditingController nomeController;
  late TextEditingController emailController;
  late TextEditingController cpfController;
  late TextEditingController telefoneController;

  bool editando = false;

  @override
  void initState() {
    super.initState();

    nomeController = TextEditingController(
      text: widget.cliente['nome'] ?? '',
    );

    emailController = TextEditingController(
      text: widget.cliente['email'] ?? '',
    );

    cpfController = TextEditingController(
      text: widget.cliente['cpf'] ?? '',
    );

    telefoneController = TextEditingController(
      text: widget.cliente['telefone'] ?? '',
    );
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    cpfController.dispose();
    telefoneController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : Colors.black;

    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Dados do Cliente",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(
              LucideIcons.x,
              color: isDark ? Colors.white54 : Colors.black54,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CampoClienteCard(
              label: "Nome",
              controller: nomeController,
              icon: LucideIcons.user,
              editando: editando,
            ),
            CampoClienteCard(
              label: "Email",
              controller: emailController,
              icon: LucideIcons.mail,
              editando: editando,
            ),
            CampoClienteCard(
              label: "CPF",
              controller: cpfController,
              icon: LucideIcons.fileText,
              editando: editando,
            ),
            CampoClienteCard(
              label: "Telefone",
              controller: telefoneController,
              icon: LucideIcons.phone,
              editando: editando,
            ),
            const SizedBox(height: 20),
            if (!editando)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      editando = true;
                    });
                  },
                  icon: const Icon(
                    LucideIcons.pencil,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Editar Dados",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                  ),
                ),
              ),
            if (editando)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          editando = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? Colors.grey[800] : Colors.grey[300],
                      ),
                      child: Text(
                        "Cancelar",
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await widget.onSalvar(
                          nomeController.text,
                          emailController.text,
                          cpfController.text,
                          telefoneController.text,
                        );

                        if (!mounted) return;

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: const Text(
                        "Salvar",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
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

class CampoClienteCard extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool editando;

  const CampoClienteCard({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    required this.editando,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : Colors.black;

    final subtitleColor = isDark ? const Color(0xFFA0A0A0) : Colors.grey[700]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                if (!editando)
                  Text(
                    controller.text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (editando)
                  TextField(
                    controller: controller,
                    style: TextStyle(
                      color: textColor,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withOpacity(0.03)
                          : Colors.black.withOpacity(0.03),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
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
