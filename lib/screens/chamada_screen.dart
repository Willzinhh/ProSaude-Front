import 'package:flutter/material.dart';
import 'package:prosaude/core/models/aluno/Aluno.dart';
import 'package:prosaude/core/models/turma/Turma.dart';
import '../core/models/chamada/ChamadaDTO.dart';
import '../core/services/chamada_service.dart';

class ChamadaScreen extends StatefulWidget {
  final Turma turma;
  final DateTime data;
  final List<Aluno> alunosComVaga;
  final int? chamadaId; // Caso enviado, indica atualização de chamada existente
  final Map<int, bool>? presencasIniciais;

  const ChamadaScreen({
    super.key,
    required this.turma,
    required this.data,
    required this.alunosComVaga,
    this.chamadaId,
    this.presencasIniciais,
  });

  @override
  State<ChamadaScreen> createState() => _ChamadaScreenState();
}

class _ChamadaScreenState extends State<ChamadaScreen> {
  final ChamadaService _chamadaService = ChamadaService();
  final Map<int, bool> _presencas = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _inicializarPresencas();
  }

  void _inicializarPresencas() {
    if (widget.presencasIniciais != null && widget.presencasIniciais!.isNotEmpty) {
      _presencas.addAll(widget.presencasIniciais!);
    } else {
      for (var aluno in widget.alunosComVaga) {
        if (aluno.id != null) {
          _presencas[aluno.id!] = true;
        }
      }
    }
  }

  Future<void> _salvarChamada() async {
    if (widget.turma.id == null) return;
    setState(() => _isSaving = true);

    try {
      final dataFormatada = widget.data.toIso8601String().split('T')[0];

      final listaPresencas = _presencas.entries.map((entry) {
        return PresencaItemDto(
          alunoId: entry.key,
          presente: entry.value,
        );
      }).toList();

      final dto = ChamadaDto(
        id: widget.chamadaId,
        turmaId: widget.turma.id!,
        data: widget.data, // Sem o ponto sobressalente no final
        presencas: listaPresencas,
      );

      if (widget.chamadaId != null) {
        await _chamadaService.atualizarChamada(widget.chamadaId!, dto);
      } else {
        await _chamadaService.salvarChamada(dto);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.chamadaId != null
                ? 'Chamada atualizada com sucesso!'
                : 'Chamada registrada com sucesso!',
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar chamada: ${e.toString().replaceAll("Exception: ", "")}')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.chamadaId != null || widget.presencasIniciais != null;
    final dataFormatada =
        "${widget.data.day.toString().padLeft(2, '0')}/${widget.data.month.toString().padLeft(2, '0')}/${widget.data.year}";

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEditing ? 'Editar Chamada' : 'Nova Chamada'),
            Text('${widget.turma.nome} - $dataFormatada',
                style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: widget.alunosComVaga.isEmpty
          ? const Center(child: Text('Nenhum aluno cadastrado para chamada.'))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: widget.alunosComVaga.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final aluno = widget.alunosComVaga[index];
          final alunoId = aluno.id ?? index;
          final estaPresente = _presencas[alunoId] ?? true;

          return SwitchListTile(
            title: Text(aluno.nome, style: const TextStyle(fontWeight: FontWeight.w600)),
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
              setState(() => _presencas[alunoId] = value);
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
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
              _isSaving
                  ? 'SALVANDO...'
                  : isEditing
                  ? 'ATUALIZAR CHAMADA'
                  : 'SALVAR CHAMADA',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: _isSaving ? null : _salvarChamada,
          ),
        ),
      ),
    );
  }
}