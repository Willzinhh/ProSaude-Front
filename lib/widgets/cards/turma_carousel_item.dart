import 'package:flutter/material.dart';
import '../../core/models/turma/Turma.dart';
import '../../core/utils/date_time_utils.dart';
import '../common/day_badge.dart';

class TurmaCarouselItem extends StatelessWidget {
  final Turma turma;
  final VoidCallback onTap;

  const TurmaCarouselItem({
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
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade400, Colors.teal.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 30),
                  const Spacer(),
                  Wrap(
                    spacing: 6,
                    children: diasAtivos
                        .map((dia) => DayBadge(
                      dia: dia,
                      backgroundColor: Colors.white,
                      textColor: Colors.white,
                    ))
                        .toList(),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                turma.nome,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "$horaInicio -- $horaFim",
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}