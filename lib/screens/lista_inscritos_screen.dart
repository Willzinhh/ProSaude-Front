import 'package:flutter/material.dart';
import 'package:prosaude/core/models/aluno/Aluno.dart';
import 'package:prosaude/core/models/turma/Turma.dart';
import 'package:prosaude/core/services/inscricao_service.dart';
import '../widgets/cards/inscritos_card_item.dart';
import 'AvaliacaoFormScreen.dart';

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
      // Executa as duas requisições ao mesmo tempo
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

  @override
  Widget build(BuildContext context) {
    // Pega o limite de vagas retornado do backend através do objeto Turma
    final int limiteVagas = _turma?.vagas ?? 0;

    // Separa os alunos que estão dentro do limite de vagas e os excedentes
    final List<Aluno> comVaga = _inscritosFiltrados.take(limiteVagas).toList();
    final List<Aluno> filaEspera = _inscritosFiltrados.skip(limiteVagas).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Inscritos: ${widget.nomeTurma}"),
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
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                onChanged: _filtrar,
                decoration: InputDecoration(
                  labelText: "Buscar aluno por nome...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _filtrar("");
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
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