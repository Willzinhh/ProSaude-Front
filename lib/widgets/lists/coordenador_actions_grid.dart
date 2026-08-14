import 'package:flutter/material.dart';
import 'package:prosaude/screens/EquipeManageScreen.dart';
import 'package:prosaude/screens/TrumaManage_screen.dart';
import 'package:prosaude/widgets/cards/action_card.dart';

import '../../screens/TodasTurmasScreen.dart';

class CoordenadorActionsGrid extends StatelessWidget {
  const CoordenadorActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 1.1,
      children: [
        ActionCard(
          icon: Icons.assignment,
          label: "Gerenciar Turmas",
          color: Colors.blue.shade700,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TurmaManageScreen()),
          ),
        ),
        ActionCard(
          icon: Icons.people_alt,
          label: "Equipe e Designação",
          color: Colors.orange.shade800,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EquipeManageScreen()),
          ),
        ),
        ActionCard(
          icon: Icons.backpack,
          label: "Ver Todas as Turmas",
          color: Colors.teal.shade700,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TodasTurmasScreen()),
          ),
        ),
      ],
    );
  }
}