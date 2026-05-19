/*import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';

class ClientesTab extends StatefulWidget {
  const ClientesTab({super.key});

  @override
  State<ClientesTab> createState() => _ClientesTabState();
}

class _ClientesTabState extends State<ClientesTab> {
  List clientes = [];
  bool isLoading = true;

  int paginaAtual = 1;
  final int clientesPorPagina = 10;

  int get totalPaginas {
    if (clientes.isEmpty) return 1;
    return (clientes.length / clientesPorPagina).ceil();
  }

  List get clientesPaginados {
    final inicio = (paginaAtual - 1) * clientesPorPagina;
    final fim = inicio + clientesPorPagina;

    return clientes.sublist(
      inicio,
      fim > clientes.length ? clientes.length : fim,
    );
  }

  @override
  void initState() {
    super.initState();
    fetchClientes();
  }

  Future<void> fetchClientes() async {
    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/clientes/listar"),
      );

      if (response.statusCode == 200) {
        final dados = jsonDecode(response.body);

        dados.sort(
          (a, b) => a['nome']
              .toString()
              .toLowerCase()
              .compareTo(
                b['nome'].toString().toLowerCase(),
              ),
        );

        setState(() {
          clientes = dados;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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

    fetchClientes();
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
      fetchClientes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Planilha importada com sucesso"),
        ),
      );
    }
  } catch (e) {
    print(e);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Erro ao importar planilha"),
      ),
    );
  }
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

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 900;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : Colors.black;

    final subtitleColor =
        isDark ? const Color(0xFFA0A0A0) : Colors.grey[700]!;

    final borderColor =
        isDark ? Colors.white.withOpacity(0.08) : Colors.black12;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Clientes",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                Text(
                  "Gerenciamento de usuários da base",
                  style: TextStyle(color: subtitleColor),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: _buildImportButton(context),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Clientes",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    Text(
                      "Gerenciamento de usuários da base",
                      style: TextStyle(color: subtitleColor),
                    ),
                  ],
                ),
                _buildImportButton(context),
              ],
            ),

          const SizedBox(height: 30),

          Expanded(
            child: isLoading
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
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
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
                                          color: subtitleColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),

                                    if (!isMobile)
                                      DataColumn(
                                        label: Text(
                                          "EMAIL",
                                          style: TextStyle(
                                            color: subtitleColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),

                                    DataColumn(
                                      label: Text(
                                        "STATUS",
                                        style: TextStyle(
                                          color: subtitleColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),

                                    if (!isMobile)
                                      DataColumn(
                                        label: Text(
                                          "AÇÕES",
                                          style: TextStyle(
                                            color: subtitleColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                  ],
                                  rows: clientesPaginados.map(
                                    (c) {
                                      return DataRow(
                                        onSelectChanged: (selected) {
                                          if (selected != null) {
                                            _mostrarDetalhesCliente(c);
                                          }
                                        },
                                        cells: [
                                          DataCell(
                                            SizedBox(
                                              width: 250,
                                              child: Text(
                                                c['nome'] ?? "",
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
                                                  c['email'] ?? "",
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

                                          const DataCell(
                                            Text(
                                              "Ativo",
                                              style: TextStyle(
                                                color:
                                                    Color(0xFF00FF88),
                                                fontWeight:
                                                    FontWeight.w600,
                                              ),
                                            ),
                                          ),

                                          if (!isMobile)
                                            DataCell(
                                              Container(
                                                decoration:
                                                    BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                              10),
                                                  color: Theme.of(
                                                          context)
                                                      .primaryColor
                                                      .withOpacity(
                                                          0.12),
                                                ),
                                                child: IconButton(
                                                  icon: Icon(
                                                    LucideIcons
                                                        .pencil,
                                                    color:
                                                        Theme.of(
                                                                context)
                                                            .primaryColor,
                                                    size: 18,
                                                  ),
                                                  onPressed: () =>
                                                      _mostrarDetalhesCliente(
                                                          c),
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ).toList(),
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
                                color: borderColor,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              _buildPaginationButton(
                                icon: LucideIcons.chevronLeft,
                                enabled: paginaAtual > 1,
                                onTap: () {
                                  setState(() {
                                    paginaAtual--;
                                  });
                                },
                              ),

                              const SizedBox(width: 18),

                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor,
                                  borderRadius:
                                      BorderRadius.circular(8),
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
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  "de $totalPaginas",
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ),

                              _buildPaginationButton(
                                icon: LucideIcons.chevronRight,
                                enabled:
                                    paginaAtual < totalPaginas,
                                onTap: () {
                                  setState(() {
                                    paginaAtual++;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.03)
              : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? Colors.white10
                : Colors.black12,
          ),
        ),
        child: Icon(
          icon,
          color: enabled
              ? (isDark ? Colors.white : Colors.black)
              : Colors.grey,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildImportButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ElevatedButton.icon(
      onPressed: importarPlanilha,
      icon: Icon(
        LucideIcons.fileSpreadsheet,
        size: 18,
        color: isDark ? Colors.white : Colors.black,
      ),
      label: Text(
        "Importar Planilha",
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.05),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
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
  State<ClienteDetalhesDialog> createState() =>
      _ClienteDetalhesDialogState();
}

class _ClienteDetalhesDialogState
    extends State<ClienteDetalhesDialog> {
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
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final textColor =
        isDark ? Colors.white : Colors.black;

    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      title: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
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
              color: isDark
                  ? Colors.white54
                  : Colors.black54,
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
                    backgroundColor:
                        Theme.of(context).primaryColor,
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
                        backgroundColor: isDark
                            ? Colors.grey[800]
                            : Colors.grey[300],
                      ),
                      child: Text(
                        "Cancelar",
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : Colors.black,
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
                        backgroundColor:
                            Theme.of(context).primaryColor,
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
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final textColor =
        isDark ? Colors.white : Colors.black;

    final subtitleColor =
        isDark ? const Color(0xFFA0A0A0) : Colors.grey[700]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 18,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                      contentPadding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.white10
                              : Colors.black12,
                        ),
                      ),
                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .primaryColor,
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
}*/