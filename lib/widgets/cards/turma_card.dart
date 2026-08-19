import 'package:flutter/material.dart';
import '../../core/models/turma/Turma.dart';
import '../../core/utils/date_time_utils.dart';
import '../common/day_badge.dart';

class TurmaCard extends StatelessWidget {
  final Turma turma;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onChamada;

  const TurmaCard({
    super.key,
    required this.turma,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onChamada,
  });

  @override
  Widget build(BuildContext context) {
    final diasAtivos = DateTimeUtils.obterDiasAtivos(turma);
    final horaInicio = DateTimeUtils.formatarHora(turma.horaInicio);
    final horaFim = DateTimeUtils.formatarHora(turma.horaFim);
    final hasActions = onEdit != null || onDelete != null || onChamada != null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: diasAtivos
                          .map((dia) => DayBadge(
                        dia: dia,
                        backgroundColor: Colors.teal.shade300,
                        textColor: Colors.black,
                      ))
                          .toList(),
                    ),
                  ),
                  if (hasActions)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.more_vert, size: 20),
                        onSelected: (value) {
                          if (value == 'chamada' && onChamada != null) onChamada!();
                          if (value == 'edit' && onEdit != null) onEdit!();
                          if (value == 'delete' && onDelete != null) onDelete!();
                        },
                        itemBuilder: (context) => [
                          if (onChamada != null)
                            const PopupMenuItem(
                              value: 'chamada',
                              child: Row(
                                children: [
                                  Icon(Icons.how_to_reg, size: 18, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('Realizar Chamada'),
                                ],
                              ),
                            ),
                          if (onEdit != null)
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                          if (onDelete != null)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Excluir'),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  turma.nome,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              Text(
                "$horaInicio - $horaFim",
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}