import 'package:flutter/material.dart';
import 'package:prosaude/core/models/aluno/Aluno.dart';
import 'package:prosaude/core/models/turma/Turma.dart';

class ChamadaScreen extends StatefulWidget {
  final Turma turma;
  final DateTime data;
  final List<Aluno> alunosComVaga;

  const ChamadaScreen({
    super.key,
    required this.turma,
    required this.data,
    required this.alunosComVaga,
  });

  @override
  State<ChamadaScreen> createState() => _ChamadaScreenState();
}

class _ChamadaScreenState extends State<ChamadaScreen> {
  // Mapa para controlar a presença <idDoAluno, estaPresente>
  final Map<int, bool> _presencas = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _inicializarPresencas();
  }

  void _inicializarPresencas() {
    // Inicializa todos os alunos da lista como PRESENTES por padrão
    for (var aluno in widget.alunosComVaga) {
      if (aluno.id != null) {
        _presencas[aluno.id!] = true;
      }
    }
  }

  Future<void> _salvarChamada() async {
    setState(() => _isSaving = true);

    try {
      // TODO: Enviar o mapa _presencas, widget.data e widget.turma.id para a API
      await Future.delayed(const Duration(milliseconds: 600)); // Simulação

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chamada registrada com sucesso!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar chamada: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataFormatada =
        "${widget.data.day.toString().padLeft(2, '0')}/${widget.data.month.toString().padLeft(2, '0')}/${widget.data.year}";

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chamada: ${widget.turma.nome}'),
            Text('Data: $dataFormatada', style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: widget.alunosComVaga.isEmpty
          ? const Center(
        child: Text(
          'Nenhum aluno com vaga nesta turma para realizar chamada.',
          style: TextStyle(color: Colors.grey),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: widget.alunosComVaga.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final aluno = widget.alunosComVaga[index];
          final alunoId = aluno.id ?? index;
          final estaPresente = _presencas[alunoId] ?? true;

          return SwitchListTile(
            title: Text(
              aluno.nome,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              estaPresente ? 'Presente' : 'Ausente',
              style: TextStyle(
                color: estaPresente ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            value: estaPresente,
            activeColor: Colors.green,
            inactiveThumbColor: Colors.red,
            onChanged: (bool value) {
              setState(() {
                _presencas[alunoId] = value;
              });
            },
          );
        },
      ),
      bottomNavigationBar: widget.alunosComVaga.isEmpty
          ? null
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              minimumSize: const Size.fromHeight(48),
            ),
            icon: _isSaving
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
                : const Icon(Icons.check, color: Colors.white),
            label: Text(
              _isSaving ? 'SALVANDO...' : 'SALVAR CHAMADA',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: _isSaving ? null : _salvarChamada,
          ),
        ),
      ),
    );
  }
}