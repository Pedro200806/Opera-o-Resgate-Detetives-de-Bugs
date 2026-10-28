import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/ocorrencia.dart';
import '../services/central_service.dart';
import 'detalhe_page.dart';

class CentralPage extends StatefulWidget {
  const CentralPage({super.key});

  @override
  State<CentralPage> createState() => _CentralPageState();
}

class _CentralPageState extends State<CentralPage> {
  final CentralService service = CentralService();

  final TextEditingController titulo = TextEditingController();
  final TextEditingController local = TextEditingController();
  final TextEditingController descricao = TextEditingController();

  bool somenteAbertos = false;
  bool cadastrando = false;

  @override
  void dispose() {
    titulo.dispose();
    local.dispose();
    descricao.dispose();
    super.dispose();
  }

  Future<void> cadastrar(BuildContext dialogContext) async {
    if (titulo.text.trim().isEmpty || local.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o título e o local.'),
        ),
      );
      return;
    }

    if (cadastrando) return;

    setState(() => cadastrando = true);

    try {
      await service.registrar(
        titulo: titulo.text,
        local: local.text,
        descricao: descricao.text,
      );

      titulo.clear();
      local.clear();
      descricao.clear();

      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível registrar: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => cadastrando = false);
      }
    }
  }

  void mostrarFormulario() {
    titulo.clear();
    local.clear();
    descricao.clear();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nova ocorrência'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titulo,
                  decoration: const InputDecoration(
                    labelText: 'Objeto',
                  ),
                ),
                TextField(
                  controller: local,
                  decoration: const InputDecoration(
                    labelText: 'Local',
                  ),
                ),
                TextField(
                  controller: descricao,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: cadastrando
                  ? null
                  : () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: cadastrando
                  ? null
                  : () => cadastrar(dialogContext),
              child: cadastrando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Registrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> sair() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Central de Achados'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: sair,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: mostrarFormulario,
        label: const Text('Registrar'),
        icon: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Somente não resolvidos'),
            value: somenteAbertos,
            onChanged: (value) {
              setState(() {
                somenteAbertos = value;
              });
            },
          ),
          Expanded(
        child: StreamBuilder<List<Ocorrencia>>(
              stream: service.acompanhar(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma ocorrência encontrada.'),
                  );
                }

                final todos = snapshot.data!;

                final itens = somenteAbertos
                    ? todos.where((o) => !o.resolvido).toList()
                    : todos;

                if (itens.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma ocorrência encontrada.'),
                  );
                }

                return ListView.builder(
                  itemCount: itens.length,
                  itemBuilder: (context, index) {
                    final ocorrencia = itens[index];

                    return Card(
                      child: ListTile(
                        title: Text(ocorrencia.titulo),
                        subtitle: Text(
                          '${ocorrencia.local} • '
                          '${ocorrencia.resolvido ? "Resolvido" : "Em aberto"}\n'
                          'Por ${ocorrencia.autorNome}',
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetalhePage(
                                ocorrencia: ocorrencia,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}