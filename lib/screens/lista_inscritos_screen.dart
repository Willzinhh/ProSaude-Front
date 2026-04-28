import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prosaude/models/aluno/Aluno.dart';
import 'package:prosaude/services/inscricao_service.dart';

class ListaInscritosScreen extends StatelessWidget {
  final int turmaId;
  final String nomeTurma;

  const ListaInscritosScreen({ required this.turmaId, required this.nomeTurma});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inscritos: $nomeTurma")),
      body: FutureBuilder<List<Aluno>>( // Use o nome da classe que criamos no aluno.dart
        future: InscricaoService().listarInscritos(turmaId), // Crie esse método no service
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Erro: ${snapshot.error}"));

          final inscritos = snapshot.data!;
          if (inscritos.isEmpty) return const Center(child: Text("Nenhum aluno inscrito ainda."));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: inscritos.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final aluno = inscritos[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade800,
                  child: Text("${index + 1}", style: const TextStyle(color: Colors.white)),
                ),
                title: Text(aluno.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("CPF: ${aluno.cpf}\nTel: ${aluno.telefone}"),
                isThreeLine: true,
                // trailing: IconButton(
                //   icon: const Icon( color: Colors.green),
                //   onPressed: () { /* Lógica para abrir WhatsApp */ },
                // ),
              );
            },
          );
        },
      ),
    );
  }
}