import 'package:flutter/material.dart';

class DayBadge extends StatelessWidget {
  final String dia;
  final Color backgroundColor;
  final Color textColor;

  const DayBadge({
    super.key,
    required this.dia,
    this.backgroundColor = Colors.teal,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        dia.substring(0, dia.length > 3 ? 3 : dia.length),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}