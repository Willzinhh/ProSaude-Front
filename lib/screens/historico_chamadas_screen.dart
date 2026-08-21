import 'package:flutter/material.dart';
import 'package:prosaude/core/models/turma/Turma.dart';
import 'package:prosaude/core/services/inscricao_service.dart';
import 'package:prosaude/core/models/aluno/Aluno.dart';
import '../core/models/chamada/ChamadaDTO.dart';
import '../core/services/chamada_service.dart';
import 'chamada_screen.dart';

class HistoricoChamadasScreen extends StatefulWidget {
  final Turma turma;

  const HistoricoChamadasScreen({super.key, required this.turma});

  @override
  State<HistoricoChamadasScreen> createState() => _HistoricoChamadasScreenState();
}

class _HistoricoChamadasScreenState extends State<HistoricoChamadasScreen> {
  final ChamadaService _chamadaService = ChamadaService();
  final InscricaoService _inscricaoService = InscricaoService();

  List<ChamadaDto> _historico = [];
  List<Aluno> _alunosComVaga = [];
  bool _isLoading = true;
  String _erroMensagem = '';

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    if (widget.turma.id == null) return;

    setState(() {
      _isLoading = true;
      _erroMensagem = '';
    });

    try {
      final resultados = await Future.wait([
        _chamadaService.listarPorTurma(widget.turma.id!),
        _inscricaoService.listarInscritos(widget.turma.id!),
      ]);

      final chamadas = resultados[0] as List<ChamadaDto>;
      final inscritos = resultados[1] as List<Aluno>;
      final limiteVagas = widget.turma.vagas ?? 0;

      setState(() {
        _historico = chamadas;
        _alunosComVaga = inscritos.take(limiteVagas).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _erroMensagem = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  DateTime _parseData(dynamic data) {
    if (data is DateTime) return data;
    if (data != null) {
      return DateTime.tryParse(data.toString()) ?? DateTime.now();
    }
    return DateTime.now();
  }

  void _editarChamada(ChamadaDto chamada) async {
    final Map<int, bool> presencasMap = {
      for (var item in chamada.presencas)
        int.parse(item.alunoId.toString()): item.presente
    };

    final DateTime dataParsed = _parseData(chamada.data);

    final foiAtualizado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ChamadaScreen(
          turma: widget.turma,
          data: dataParsed,
          alunosComVaga: _alunosComVaga,
          chamadaId: chamada.id,
          presencasIniciais: presencasMap,
        ),
      ),
    );

    if (foiAtualizado == true) {
      _carregarDados();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chamadas: ${widget.turma.nome}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _erroMensagem.isNotEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Erro ao carregar histórico: $_erroMensagem',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _carregarDados,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              )
            ],
          ),
        ),
      )
          : _historico.isEmpty
          ? const Center(
        child: Text('Nenhuma chamada realizada para esta turma.'),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _historico.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final chamada = _historico[index];
          final dataParsed = _parseData(chamada.data);

          final dataStr =
              "${dataParsed.day.toString().padLeft(2, '0')}/${dataParsed.month.toString().padLeft(2, '0')}/${dataParsed.year}";

          final totalPresentes =
              chamada.presencas.where((p) => p.presente).length;

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(Icons.event_available,
                    color: Colors.white),
              ),
              title: Text('Aula do dia $dataStr',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold)),
              subtitle: Text(
                  'Presentes: $totalPresentes / ${chamada.presencas.length}'),
              trailing:
              const Icon(Icons.edit, color: Colors.blue),
              onTap: () => _editarChamada(chamada),
            ),
          );
        },
      ),
    );
  }
}