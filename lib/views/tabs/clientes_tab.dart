import 'dart:convert';
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
        setState(() {
          clientes = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
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
    // CORRIGIDO: Adicionado "!"
    final subtitleColor = isDark ? const Color(0xFFA0A0A0) : Colors.grey[700]!;
    final borderColor =
        isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.1);

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
                : AnimatedContainer(
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
                        child: DataTable(
                          showCheckboxColumn: false,
                          headingRowColor: WidgetStateProperty.all(
                            isDark
                                ? Colors.white.withOpacity(0.02)
                                : Colors.black.withOpacity(0.02),
                          ),
                          columnSpacing: isMobile ? 20 : 40,
                          columns: [
                            DataColumn(
                              label: Text(
                                "NOME",
                                style: TextStyle(color: subtitleColor),
                              ),
                            ),
                            if (!isMobile)
                              DataColumn(
                                label: Text(
                                  "EMAIL",
                                  style: TextStyle(color: subtitleColor),
                                ),
                              ),
                            DataColumn(
                              label: Text(
                                "STATUS",
                                style: TextStyle(color: subtitleColor),
                              ),
                            ),
                            if (!isMobile)
                              DataColumn(
                                label: Text(
                                  "AÇÕES",
                                  style: TextStyle(color: subtitleColor),
                                ),
                              ),
                          ],
                          rows: clientes
                              .map(
                                (c) => DataRow(
                                  onSelectChanged: (selected) {
                                    if (selected != null) {
                                      _mostrarDetalhesCliente(c);
                                    }
                                  },
                                  cells: [
                                    DataCell(
                                      Text(
                                        c['nome'] ?? "",
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (!isMobile)
                                      DataCell(
                                        Text(
                                          c['email'] ?? "",
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    const DataCell(
                                      Text(
                                        "Ativo",
                                        style: TextStyle(
                                          color: Color(0xFF00FF88),
                                        ),
                                      ),
                                    ),
                                    if (!isMobile)
                                      DataCell(
                                        IconButton(
                                          icon: Icon(
                                            LucideIcons.pencil,
                                            color: Theme.of(context)
                                                .primaryColor,
                                            size: 18,
                                          ),
                                          onPressed: () =>
                                              _mostrarDetalhesCliente(c),
                                        ),
                                      ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(
        LucideIcons.fileSpreadsheet,
        size: 18,
        color: isDark ? Colors.white : Colors.black,
      ),
      label: Text(
        "Importar Planilha",
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
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

// --- WIDGETS EXTRAÍDOS --- //

// 1. DIALOG ISOLADO PARA GERENCIAR CONTROLLERS CORRETAMENTE
class ClienteDetalhesDialog extends StatefulWidget {
  final Map cliente;
  final Function(String nome, String email, String cpf, String telefone) onSalvar;

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
    nomeController = TextEditingController(text: widget.cliente['nome'] ?? '');
    emailController = TextEditingController(text: widget.cliente['email'] ?? '');
    cpfController = TextEditingController(text: widget.cliente['cpf'] ?? '');
    telefoneController =
        TextEditingController(text: widget.cliente['telefone'] ?? '');
  }

  // IMPORTANTE: Evita Memory Leak!
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
        side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
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
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Editar Dados",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Salvar",
                        style: TextStyle(color: Colors.white),
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

// 2. COMPONENTE DE CAMPO EXTRAÍDO PARA LIMPAR O CÓDIGO DO DIALOG
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                    style: TextStyle(color: textColor),
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