import 'package:flutter/material.dart';

class AlunoListTile extends StatelessWidget {
  final dynamic aluno;
  final VoidCallback onVerHistorico;
  final VoidCallback onRemover; // Adicionado

  const AlunoListTile({
    super.key,
    required this.aluno,
    required this.onVerHistorico,
    required this.onRemover, // Adicionado
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        radius: 14,
        backgroundColor: Colors.teal,
        child: Icon(Icons.person, size: 16, color: Colors.white),
      ),
      title: Text(
        aluno.nome ?? 'Aluno sem nome',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        "Tel: ${aluno.telefone ?? 'Não informado'}",
        style: const TextStyle(fontSize: 11),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.assignment_ind, color: Colors.blue, size: 20),
            onPressed: onVerHistorico,
            tooltip: "Ver Histórico de Avaliações",
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            tooltip: "Remover Aluno",
            onPressed: onRemover, // Atualizado
          ),
        ],
      ),
    );
  }
}