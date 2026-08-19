import 'package:flutter/material.dart';
import 'package:prosaude/core/models/aluno/Aluno.dart';
import 'package:prosaude/core/models/turma/Turma.dart';
import 'package:prosaude/core/services/inscricao_service.dart';
import '../widgets/cards/inscritos_card_item.dart';
import '../widgets/dialogs/iniciar_chamada_dialog.dart';
import '../widgets/inputs/search_input_field.dart';
import 'AvaliacaoFormScreen.dart';
import 'chamada_screen.dart';
import 'historico_chamadas_screen.dart';

class ListaInscritosScreen extends StatefulWidget {
  final int turmaId;
  final String nomeTurma;

  const ListaInscritosScreen({
    super.key,
    required this.turmaId,
    required this.nomeTurma,
  });

  @override
  State<ListaInscritosScreen> createState() => _ListaInscritosScreenState();
}

class _ListaInscritosScreenState extends State<ListaInscritosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final InscricaoService _inscricaoService = InscricaoService();

  Turma? _turma;
  List<Aluno> _inscritosOriginal = [];
  List<Aluno> _inscritosFiltrados = [];
  bool _isLoading = true;
  String _erroMensagem = "";

  @override
  void initState() {
    super.initState();
    _carregarDadosDoBackend();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarDadosDoBackend() async {
    setState(() {
      _isLoading = true;
      _erroMensagem = "";
    });

    try {
      final resultados = await Future.wait([
        _inscricaoService.buscarTurmaPorId(widget.turmaId),
        _inscricaoService.listarInscritos(widget.turmaId),
      ]);

      setState(() {
        _turma = resultados[0] as Turma;
        _inscritosOriginal = resultados[1] as List<Aluno>;
        _inscritosFiltrados = _inscritosOriginal;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _erroMensagem = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  void _filtrar(String query) {
    setState(() {
      _inscritosFiltrados = _inscritosOriginal
          .where((aluno) =>
          aluno.nome.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _abrirModalChamada() {
    if (_turma == null) return;

    showDialog(
      context: context,
      builder: (context) => IniciarChamadaDialog(
        onConfirmar: (data) {
          final limiteVagas = _turma?.vagas ?? 0;
          final comVaga = _inscritosOriginal.take(limiteVagas).toList();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChamadaScreen(
                turma: _turma!,
                data: data,
                // Passa os alunos confirmados com vaga para a chamada
                alunosComVaga: comVaga,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int limiteVagas = _turma?.vagas ?? 0;
    final List<Aluno> comVaga = _inscritosFiltrados.take(limiteVagas).toList();
    final List<Aluno> filaEspera = _inscritosFiltrados.skip(limiteVagas).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Inscritos: ${widget.nomeTurma}"),
          actions: [
            if (!_isLoading && _turma != null) ...[
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: "Histórico de Chamadas",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoricoChamadasScreen(turma: _turma!),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.how_to_reg, color: Colors.tealAccent),
                tooltip: "Nova Chamada",
                onPressed: _abrirModalChamada,
              ),
            ]
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                text: "Com Vaga (${comVaga.length}/$limiteVagas)",
                icon: const Icon(Icons.check_circle_outline),
              ),
              Tab(
                text: "Fila de Espera (${filaEspera.length})",
                icon: const Icon(Icons.hourglass_empty),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            SearchInputField(
              controller: _searchController,
              onChanged: _filtrar, label: '',
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _erroMensagem.isNotEmpty
                  ? Center(child: Text("Erro ao carregar: $_erroMensagem"))
                  : TabBarView(
                children: [
                  _buildListaAlunos(
                    alunos: comVaga,
                    offsetPosicao: 0,
                    emFilaDeEspera: false,
                    mensagemVazia: "Nenhum aluno com vaga garantida.",
                  ),
                  _buildListaAlunos(
                    alunos: filaEspera,
                    offsetPosicao: limiteVagas,
                    emFilaDeEspera: true,
                    mensagemVazia: "Nenhum aluno na fila de espera.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaAlunos({
    required List<Aluno> alunos,
    required int offsetPosicao,
    required bool emFilaDeEspera,
    required String mensagemVazia,
  }) {
    if (alunos.isEmpty) {
      return Center(
        child: Text(
          mensagemVazia,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: alunos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final aluno = alunos[index];
        final posicaoReal = offsetPosicao + index + 1;

        return InscritosCardItem(
          aluno: aluno,
          ordem: posicaoReal,
          emFilaDeEspera: emFilaDeEspera,
          onIniciarAvaliacao: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AvaliacaoFormScreen(aluno: aluno),
              ),
            );
          },
        );
      },
    );
  }
}