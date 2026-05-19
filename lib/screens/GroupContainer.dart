import 'package:flutter/material.dart';

class GroupContainer extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const GroupContainer({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade600),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Título posicionado na borda superior
          Positioned(
            top: -24,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          // Conteúdo interno (os inputs)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ],
      ),
    );
  }
}