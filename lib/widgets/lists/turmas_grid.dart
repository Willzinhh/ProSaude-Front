import 'package:flutter/material.dart';
import 'package:prosaude/core/models/turma/Turma.dart';
import '../cards/turma_card.dart';

class TurmasGrid extends StatelessWidget {
  final List<Turma> turmas;
  final Function(Turma) onTurmaSelected;
  final Function(Turma)? onTurmaEdit;
  final Function(Turma)? onTurmaDelete;

  const TurmasGrid({
    super.key,
    required this.turmas,
    required this.onTurmaSelected,
    this.onTurmaEdit,
    this.onTurmaDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: turmas.length,
      itemBuilder: (context, index) {
        final turma = turmas[index];
        return TurmaCard(
          turma: turma,
          onTap: () => onTurmaSelected(turma),
        );
      },
    );
  }
}