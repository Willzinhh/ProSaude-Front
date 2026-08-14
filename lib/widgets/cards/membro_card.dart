import 'package:flutter/material.dart';
import 'package:prosaude/core/models/usuario/Usuario.dart';

class MembroCard extends StatelessWidget {
  final Usuario membro;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const MembroCard({
    super.key,
    required this.membro,
    required this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCoordenador = membro.perfil == "COORDENADOR";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCoordenador ? Colors.blueGrey[50] : Colors.teal[50],
          child: Icon(
            isCoordenador ? Icons.admin_panel_settings : Icons.school,
            color: isCoordenador ? Colors.blueGrey : Colors.teal,
          ),
        ),
        title: Text(
          membro.nome,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(membro.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.teal),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: onDelete == null ? Colors.grey.shade400 : Colors.red,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}