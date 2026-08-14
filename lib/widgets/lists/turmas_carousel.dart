import 'package:carousel_slider/carousel_slider.dart' as slider;
import 'package:flutter/material.dart';
import 'package:prosaude/core/models/turma/Turma.dart';

import '../cards/turma_carousel_item.dart';

class TurmasCarousel extends StatelessWidget {
  final List<Turma> turmasDeHoje;
  final Function(Turma) onTurmaSelected;

  const TurmasCarousel({
    super.key,
    required this.turmasDeHoje,
    required this.onTurmaSelected,
  });

  @override
  Widget build(BuildContext context) {
    return slider.CarouselSlider(
      options: slider.CarouselOptions(
        height: 180.0,
        autoPlay: turmasDeHoje.isNotEmpty,
        viewportFraction: turmasDeHoje.isEmpty ? 1.0 : 0.85,
        enlargeCenterPage: turmasDeHoje.isNotEmpty,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: turmasDeHoje.length > 1,
      ),
      items: turmasDeHoje.isEmpty
          ? [_buildCardVazio()]
          : turmasDeHoje
          .map((t) => TurmaCarouselItem(
        turma: t,
        onTap: () => onTurmaSelected(t),
      ))
          .toList(),
    );
  }

  Widget _buildCardVazio() {
    final hoje = DateTime.now();
    const diasPt = [
      "Segunda-feira",
      "Terça-feira",
      "Quarta-feira",
      "Quinta-feira",
      "Sexta-feira",
      "Sábado",
      "Domingo"
    ];
    final nomeDia = diasPt[hoje.weekday - 1];
    final dataFormatada =
        "${hoje.day.toString().padLeft(2, '0')}/${hoje.month.toString().padLeft(2, '0')}";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event_busy, size: 50),
          const SizedBox(height: 15),
          const Text(
            "Sem atividades hoje",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            "$nomeDia, $dataFormatada",
            style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 14),
          ),
        ],
      ),
    );
  }
}