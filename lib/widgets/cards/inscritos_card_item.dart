import 'package:flutter/material.dart';
import 'package:prosaude/core/models/aluno/Aluno.dart';

class InscritosCardItem extends StatelessWidget {
  final Aluno aluno;
  final int ordem;
  final bool emFilaDeEspera;
  final VoidCallback onIniciarAvaliacao;

  const InscritosCardItem({
    super.key,
    required this.aluno,
    required this.ordem,
    this.emFilaDeEspera = false, // Padrão como false para manter compatibilidade
    required this.onIniciarAvaliacao,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: emFilaDeEspera ? Colors.orange.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: emFilaDeEspera ? Colors.orange.shade800 : Colors.blue.shade800,
          child: Text(
            "$ordem",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                aluno.nome,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: emFilaDeEspera ? Colors.orange.shade100 : Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                emFilaDeEspera ? "Fila de Espera" : "Vaga Garantida",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: emFilaDeEspera ? Colors.orange.shade900 : Colors.green.shade900,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          "Tel: ${aluno.telefone}\nEmergência: ${aluno.telefoneEmergencia}",
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(
            Icons.assignment_add,
            color: Colors.teal,
            size: 28,
          ),
          tooltip: 'Iniciar Avaliação Física',
          onPressed: onIniciarAvaliacao,
        ),
      ),
    );
  }
}