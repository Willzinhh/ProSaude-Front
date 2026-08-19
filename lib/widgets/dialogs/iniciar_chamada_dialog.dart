import 'package:flutter/material.dart';

class IniciarChamadaDialog extends StatefulWidget {
  final Function(DateTime data) onConfirmar;

  const IniciarChamadaDialog({super.key, required this.onConfirmar});

  @override
  State<IniciarChamadaDialog> createState() => _IniciarChamadaDialogState();
}

class _IniciarChamadaDialogState extends State<IniciarChamadaDialog> {
  DateTime _dataSelecionada = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final dataFormatada = "${_dataSelecionada.day.toString().padLeft(2, '0')}/${_dataSelecionada.month.toString().padLeft(2, '0')}/${_dataSelecionada.year}";

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.how_to_reg, color: Colors.blue, size: 28),
          SizedBox(width: 10),
          Text('Realizar Chamada', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Selecione a data da aula para registrar a presença:'),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today),
            label: Text('Data: $dataFormatada'),
            onPressed: () async {
              final data = await showDatePicker(
                context: context,
                initialDate: _dataSelecionada,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (data != null) {
                setState(() => _dataSelecionada = data);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onConfirmar(_dataSelecionada);
          },
          child: const Text('INICIAR'),
        ),
      ],
    );
  }
}