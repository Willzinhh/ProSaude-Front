import 'package:flutter/material.dart';
import 'package:prosaude/core/models/aluno/Aluno.dart';
import 'package:prosaude/core/services/inscricao_service.dart';

import 'AvaliacaoFormScreen.dart';

class ListaInscritosScreen extends StatelessWidget {
  final int turmaId;
  final String nomeTurma;

  const ListaInscritosScreen({required this.turmaId, required this.nomeTurma});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inscritos: $nomeTurma")),
      body: FutureBuilder<List<Aluno>>(
        future: InscricaoService().listarInscritos(turmaId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }

          final inscritos = snapshot.data!;
          if (inscritos.isEmpty) {
            return const Center(child: Text("Nenhum aluno inscrito ainda."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: inscritos.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final aluno = inscritos[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade800,
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  aluno.nome,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Tel: ${aluno.telefone}\nEmergência: ${aluno.telefoneEmergencia}",
                ),
                isThreeLine: true,

                // Adicionamos o botão de avaliação aqui no canto direito do item
                trailing: IconButton(
                  icon: const Icon(
                    Icons.assignment_add,
                    color: Colors.teal,
                    size: 28,
                  ),
                  tooltip: 'Iniciar Avaliação Física',
                  onPressed: () {
                    // Navega para a tela do formulário de avaliação física
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AvaliacaoFormScreen(aluno: aluno),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
