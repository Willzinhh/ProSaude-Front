import 'package:flutter/material.dart';
import 'package:prosaude/core/models/turma/Turma.dart';
import 'package:prosaude/core/services/turma_service.dart';
import 'package:prosaude/core/services/inscricao_service.dart';
import 'package:prosaude/screens/AvaliacaoHistoricoScreen.dart';

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

  // Filtros dinâmicos
  late List<String> _opcoesSemestres;
  late String _semestreFiltroSelecionado;

  // Mapa para controlar os alunos carregados de cada turma expandida
  final Map<int, List<dynamic>> _alunosPorTurma = {};
  final Map<int, bool> _carregandoAlunos = {};

  @override
  void initState() {
    super.initState();
    _opcoesSemestres = _gerarListaSemestres();
    _semestreFiltroSelecionado = _gerarSemestreAtual();
    _carregarTurmas();
  }

  List<String> _gerarListaSemestres() {
    final List<String> semestres = [];
    final int anoAtual = DateTime.now().year;
    for (int i = 0; i <= 10; i++) {
      int ano = anoAtual + i;
      semestres.add("$ano/1");
      semestres.add("$ano/2");
    }
    return semestres;
  }

  String _gerarSemestreAtual() {
    final agora = DateTime.now();
    final semestre = agora.month <= 6 ? "1" : "2";
    return "${agora.year}/$semestre";
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
    final queryNome = _searchController.text.toLowerCase();
    setState(() {
      _turmasFiltradas = _turmas.where((turma) {
        final bateNome = turma.nome.toLowerCase().contains(queryNome);
        final bateSemestre = _semestreFiltroSelecionado == "TODOS" ||
            turma.semestre == _semestreFiltroSelecionado;
        return bateNome && bateSemestre;
      }).toList();
    });
  }

  // 🎯 Carrega os alunos quando o coordenador expande a turma
  Future<void> _carregarInscritosDaTurma(int turmaId) async {
    if (_alunosPorTurma.containsKey(turmaId)) return; // Já carregou antes

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

  // 🎯 Deleta a inscrição do aluno diretamente
  Future<void> _removerAluno(int turmaId, int alunoId, String nomeAluno) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar Remoção"),
        content: Text("Deseja realmente remover $nomeAluno desta turma?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
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
        _mostrarMensagem("Erro ao remover: $e", Colors.red);
      }
    }
  }

  void _mostrarMensagem(String msg, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: cor),
    );
  }

  /// 🎯 COMPONENTE ISOLADO: Acessa os dados como OBJETO (dynamic obtido da classe Aluno)
  Widget _buildItemAluno(dynamic aluno, int idTurma) {
    // Acessando as propriedades diretamente por ponto (.) já que é uma classe e não um Map
    final String nomeExibicao = aluno.nome?.toString() ?? 'Aluno sem nome';
    final String telefoneExibicao = aluno.telefone?.toString() ?? 'Não informado';
    final int? idDoAluno = aluno.id as int?;

    return ListTile(
      leading: const CircleAvatar(
        radius: 14,
        backgroundColor: Colors.teal,
        child: Icon(Icons.person, size: 16, color: Colors.white),
      ),
      title: Text(
          nomeExibicao,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
      ),
      subtitle: Text("Tel: $telefoneExibicao", style: const TextStyle(fontSize: 11)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.assignment_ind, color: Colors.blue, size: 20),
            tooltip: "Ver Avaliações",
            onPressed: idDoAluno == null
                ? null
                : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AvaliacaoHistoricoScreen(id: idDoAluno),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            tooltip: "Remover Aluno",
            onPressed: idDoAluno == null
                ? null
                : () => _removerAluno(idTurma, idDoAluno, nomeExibicao),
          ),
        ],
      ),
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
          // Filtro por Nome
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0, bottom: 6.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _aplicarFiltros(),
              decoration: InputDecoration(
                labelText: "Buscar por nome da turma...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Filtro Dropdown por Semestre
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
            child: DropdownButtonFormField<String>(
              value: _semestreFiltroSelecionado,
              decoration: InputDecoration(
                labelText: "Filtrar por Semestre Letivo",
                prefixIcon: const Icon(Icons.filter_alt, color: Colors.teal),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: ["TODOS", ..._opcoesSemestres]
                  .map((sem) => DropdownMenuItem(
                value: sem,
                child: Text(sem == "TODOS" ? "Todos os Semestres" : "Semestre $sem"),
              ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  _semestreFiltroSelecionado = val;
                  _aplicarFiltros();
                }
              },
            ),
          ),

          // Lista Principal de Turmas
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
                      if (expandido) {
                        _carregarInscritosDaTurma(idTurma);
                      }
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
                        ..._alunosPorTurma[idTurma]!.map((aluno) {
                          // Passa o objeto puro direto para o componente build
                          return _buildItemAluno(aluno, idTurma);
                        }).toList(),
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