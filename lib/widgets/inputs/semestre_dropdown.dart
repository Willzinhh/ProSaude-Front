import 'package:flutter/material.dart';

class SemestreDropdown extends StatelessWidget {
  final String value;
  final List<String> opcoes;
  final ValueChanged<String?> onChanged;
  final String label;

  const SemestreDropdown({
    super.key,
    required this.value,
    required this.opcoes,
    required this.onChanged,
    this.label = "Filtrar por Semestre Letivo",
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.filter_alt, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      items: ["TODOS", ...opcoes]
          .map((sem) => DropdownMenuItem(
        value: sem,
        child: Text(sem == "TODOS" ? "Todos os Semestres" : "Semestre $sem"),
      ))
          .toList(),
      onChanged: onChanged,
    );
  }
}