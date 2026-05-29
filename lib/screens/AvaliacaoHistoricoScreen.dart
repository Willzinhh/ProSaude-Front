import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:prosaude/core/models/aluno/Aluno.dart';
import '../core/models/avaliacao/Avaliacao.dart';
import '../core/services/avaliacao_service.dart';
import '../core/services/session_manager.dart';
import 'AvaliacaoDetalhesScreen.dart'; // A tela que criamos antes

class AvaliacaoHistoricoScreen extends StatefulWidget {
  final int id;

  const AvaliacaoHistoricoScreen({super.key, required this.id });

  @override
  State<AvaliacaoHistoricoScreen> createState() => _AvaliacaoHistoricoScreenState();
}

class _AvaliacaoHistoricoScreenState extends State<AvaliacaoHistoricoScreen> {
  String _nome = "Carregando";
  String _perfil = "";
  late Future<List<AvaliacaoModel>> _futureAvaliacoes;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
    // TODO: Ajuste o método de busca do seu service se ele tiver um nome diferente, ex: buscarPorAluno(id)
    _futureAvaliacoes = AvaliacaoService().buscarAvaliacoesPorAluno(widget.id);
  }
  Future<void> _carregarDadosUsuario() async {
    final sessao = await SessionManager.getSession();
    if (sessao != null) {
      setState(() {

        _nome = sessao.nome ?? "Usuário";
        _perfil = sessao.perfil ?? "";
      });
    }
  }

  // Função auxiliar para formatar a data sem precisar de pacotes externos
  String _formatarData(DateTime? data) {
    if (data == null) return "Sem data";
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year;
    return "$dia/$mes/$ano";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Histórico de Avaliações', style: TextStyle(fontSize: 18)),
            Text(
              _nome,
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<AvaliacaoModel>>(
        future: _futureAvaliacoes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Erro ao carregar histórico: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final avaliacoes = snapshot.data ?? [];

          if (avaliacoes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_late_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma avaliação encontrada\npara este aluno.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // Garante que a lista está ordenada da data mais recente para a mais antiga
          avaliacoes.sort((a, b) {
            final dataA = a.dataAvaliacao ?? DateTime.fromMillisecondsSinceEpoch(0);
            final dataB = b.dataAvaliacao ?? DateTime.fromMillisecondsSinceEpoch(0);
            return dataB.compareTo(dataA);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: avaliacoes.length,
            itemBuilder: (context, index) {
              final avaliacao = avaliacoes[index];
              final dataFormatada = _formatarData(avaliacao.dataAvaliacao);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(Icons.description, color: Colors.blue.shade900),
                  ),
                  title: Text(
                    'Avaliação Física',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('Data: $dataFormatada', style: const TextStyle(color: Colors.black87)),
                          ],
                        ),
                        if (avaliacao.antPeso != null && avaliacao.antAltura != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Massa: ${avaliacao.antPeso} kg | Estatura: ${avaliacao.antAltura} cm',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ]
                      ],
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue.shade900),
                  onTap: () {
                    // Navega direto para a tela de visualização de detalhes que criamos antes
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AvaliacaoDetalhesScreen(
                          aluno: _nome,
                          avaliacao: avaliacao,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}