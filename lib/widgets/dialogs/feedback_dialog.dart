import 'package:flutter/material.dart';

class FeedbackDialog extends StatelessWidget {
  final String titulo;
  final String mensagem;
  final bool isErro;

  const FeedbackDialog({
    super.key,
    required this.titulo,
    required this.mensagem,
    required this.isErro,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Row(
        children: [
          Icon(
            isErro ? Icons.cancel : Icons.check_circle,
            color: isErro ? Colors.red : Colors.green,
            size: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Text(mensagem, style: const TextStyle(fontSize: 16)),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isErro ? Colors.red : Colors.teal,
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text("Entendido", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}