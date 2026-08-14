import 'package:flutter/material.dart';
import 'package:prosaude/core/models/turma/Turma.dart';
import 'package:prosaude/core/services/inscricao_service.dart';
import 'package:prosaude/core/services/turma_service.dart';
import 'package:prosaude/screens/AvaliacaoHistoricoScreen.dart';
import 'package:prosaude/widgets/widgets.dart';

class TodasTurmasScreen extends StatefulWidget {
  const TodasTurmasScreen({super.key});

  @override
  State<TodasTurmasScreen> createState() => _TodasTurmasScreenState();
}

class _TodasTurmasScreenState extends State<TodasTurmasScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Turma> _turmas = [];
  List<Turma> _turmasFiltradas = [];
  bool _isLoading = true;

  late List<String> _opcoesSemestres;
  late String _semestreFiltroSelecionado;

  final Map<int, List<dynamic>> _alunosPorTurma = {};
  final Map<int, bool> _carregandoAlunos = {};

  @override
  void initState() {
    super.initState();
    _opcoesSemestres = List.generate(20, (i) => "${DateTime.now().year + (i ~/ 2)}/${(i % 2) + 1}");
    _semestreFiltroSelecionado = "${DateTime.now().year}/${DateTime.now().month <= 6 ? "1" : "2"}";
    _carregarTurmas();
  }

  Future<void> _carregarTurmas() async {
    setState(() => _isLoading = true);
    try {
      final lista = await TurmaService().getTurmas();
      setState(() {
        _turmas = lista;
        _isLoading = false;
        _aplicarFiltros();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarMensagem("Erro ao carregar turmas: $e", Colors.red);
    }
  }

  void _aplicarFiltros() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _turmasFiltradas = _turmas.where((turma) {
        final bateNome = turma.nome.toLowerCase().contains(query);
        final bateSemestre = _semestreFiltroSelecionado == "TODOS" || turma.semestre == _semestreFiltroSelecionado;
        return bateNome && bateSemestre;
      }).toList();
    });
  }

  Future<void> _carregarInscritosDaTurma(int turmaId) async {
    if (_alunosPorTurma.containsKey(turmaId)) return;
    setState(() => _carregandoAlunos[turmaId] = true);
    try {
      final alunos = await InscricaoService().listarInscritos(turmaId);
      setState(() {
        _alunosPorTurma[turmaId] = alunos;
        _carregandoAlunos[turmaId] = false;
      });
    } catch (e) {
      setState(() => _carregandoAlunos[turmaId] = false);
      _mostrarMensagem("Erro ao carregar alunos: $e", Colors.red);
    }
  }

  Future<void> _removerAluno(int turmaId, dynamic aluno) async {
    final int? alunoId = aluno.id as int?;
    final String nomeAluno = aluno.nome?.toString() ?? "Aluno";

    if (alunoId == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar Remoção"),
        content: Text("Deseja realmente remover $nomeAluno desta turma?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Remover", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        bool sucesso = await InscricaoService().deletarInscricao(turmaId, alunoId);
        if (sucesso) {
          _mostrarMensagem("$nomeAluno removido com sucesso!", Colors.green);
          setState(() => _alunosPorTurma.remove(turmaId));
          _carregarInscritosDaTurma(turmaId);
        }
      } catch (e) {
        _mostrarMensagem("Erro ao remover aluno: $e", Colors.red);
      }
    }
  }

  void _mostrarMensagem(String msg, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: cor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel Geral de Turmas"),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SearchInputField(
              controller: _searchController,
              label: "Buscar por nome da turma...",
              onChanged: (_) => _aplicarFiltros(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: SemestreDropdown(
              value: _semestreFiltroSelecionado,
              opcoes: _opcoesSemestres,
              onChanged: (val) {
                if (val != null) {
                  _semestreFiltroSelecionado = val;
                  _aplicarFiltros();
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                : _turmasFiltradas.isEmpty
                ? const Center(child: Text("Nenhuma turma encontrada."))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _turmasFiltradas.length,
              itemBuilder: (context, index) {
                final turma = _turmasFiltradas[index];
                final idTurma = turma.id!;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 2,
                  child: ExpansionTile(
                    title: Text(turma.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Semestre: ${turma.semestre} | Prof: ${turma.bolsista_responsavel?.nome ?? 'Sem Prof'}"),
                    leading: const Icon(Icons.class_, color: Colors.teal),
                    onExpansionChanged: (expandido) {
                      if (expandido) _carregarInscritosDaTurma(idTurma);
                    },
                    children: [
                      if (_carregandoAlunos[idTurma] == true)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(color: Colors.teal),
                        )
                      else if (_alunosPorTurma[idTurma] == null || _alunosPorTurma[idTurma]!.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("Nenhum aluno inscrito nesta turma.", style: TextStyle(fontStyle: FontStyle.italic)),
                        )
                      else
                        ..._alunosPorTurma[idTurma]!.map(
                              (aluno) => AlunoListTile(
                            aluno: aluno,
                            onVerHistorico: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AvaliacaoHistoricoScreen(id: aluno.id)),
                            ),
                            onRemover: () => _removerAluno(idTurma, aluno),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}