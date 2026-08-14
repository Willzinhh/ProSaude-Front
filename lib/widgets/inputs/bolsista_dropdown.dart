import 'package:flutter/material.dart';
import 'package:prosaude/core/models/usuario/Usuario.dart';

class BolsistaDropdown extends StatelessWidget {
  final int? value;
  final List<Usuario> bolsistas;
  final ValueChanged<int?> onChanged;
  final String label;

  const BolsistaDropdown({
    super.key,
    required this.value,
    required this.bolsistas,
    required this.onChanged,
    this.label = "Filtrar por Bolsista Responsável",
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int?>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.school, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text("Todos os Bolsistas"),
        ),
        ...bolsistas.map(
              (b) => DropdownMenuItem<int?>(
            value: b.id,
            child: Text(b.nome),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}