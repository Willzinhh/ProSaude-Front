import 'package:flutter/material.dart';
import '../../core/models/turma/Turma.dart';
import '../../core/utils/date_time_utils.dart';
import '../common/day_badge.dart';


class TurmaCard extends StatelessWidget {
  final Turma turma;
  final VoidCallback onTap;

  const TurmaCard({
    super.key,
    required this.turma,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final diasAtivos = DateTimeUtils.obterDiasAtivos(turma);
    final horaInicio = DateTimeUtils.formatarHora(turma.horaInicio);
    final horaFim = DateTimeUtils.formatarHora(turma.horaFim);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Wrap(
                spacing: 6,
                children: diasAtivos
                    .map((dia) => DayBadge(
                  dia: dia,
                  backgroundColor: Colors.teal.shade300,
                  textColor: Colors.black,
                ))
                    .toList(),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                "$horaInicio -- $horaFim",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}