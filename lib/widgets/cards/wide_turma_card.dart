import 'package:flutter/material.dart';
import '../../core/models/turma/Turma.dart';
import '../../core/utils/date_time_utils.dart';

class WideTurmaCard extends StatelessWidget {
  final Turma turma;
  final String perfil;
  final VoidCallback? onTap;

  const WideTurmaCard({
    super.key,
    required this.turma,
    required this.perfil,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final diasAtivos = DateTimeUtils.obterDiasAtivos(turma).join(", ");

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: const EdgeInsets.only(bottom: 15),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      turma.nome,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text("Dias de aula: ${diasAtivos.isEmpty ? 'Não informado' : diasAtivos}"),
              if (perfil == "BOLSISTA") ...[
                const SizedBox(height: 10),
                const Text(
                  "Clique para ver a lista de inscritos",
                  style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isGarantida = status == "VAGA_GARANTIDA";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isGarantida ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isGarantida ? Colors.green.shade600 : Colors.orange.shade700,
        ),
      ),
      child: Text(
        isGarantida ? "Vaga Garantida" : "Fila de Espera",
        style: TextStyle(
          color: isGarantida ? Colors.green.shade800 : Colors.orange.shade900,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}