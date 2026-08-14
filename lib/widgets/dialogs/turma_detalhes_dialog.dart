import 'package:flutter/material.dart';
import 'package:prosaude/core/models/turma/Turma.dart';
import 'package:prosaude/core/utils/date_time_utils.dart';
import 'package:prosaude/widgets/common/day_badge.dart';

class TurmaDetalhesDialog extends StatelessWidget {
  final Turma turma;
  final VoidCallback onInscreverPressed;

  const TurmaDetalhesDialog({
    super.key,
    required this.turma,
    required this.onInscreverPressed,
  });

  @override
  Widget build(BuildContext context) {
    final diasAtivos = DateTimeUtils.obterDiasAtivos(turma);
    final horaInicio = DateTimeUtils.formatarHora(turma.horaInicio);
    final horaFim = DateTimeUtils.formatarHora(turma.horaFim);

    return AlertDialog(
      title: Text(
        turma.nome,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: diasAtivos
                  .map((dia) => DayBadge(
                dia: dia,
                backgroundColor: Colors.teal.shade700,
                textColor: Colors.teal.shade900,
              ))
                  .toList(),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  "$horaInicio até $horaFim",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(turma.descricao),
            const Divider(),
            Text(
              "Bolsista Encarregado: ${turma.bolsista_responsavel?.nome.toUpperCase() ?? 'Não informado'}",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: onInscreverPressed,
          child: const Text("Inscrever-se"),
        ),
      ],
    );
  }
}