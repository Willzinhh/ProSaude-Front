import 'package:flutter/material.dart';
import 'package:prosaude/core/models/turma/Turma.dart';
import 'package:prosaude/core/services/inscricao_service.dart';
import 'package:prosaude/core/services/session_manager.dart';
import 'package:prosaude/core/services/turma_service.dart';
import 'package:prosaude/screens/AvaliacaoHistoricoScreen.dart';
import 'package:prosaude/screens/Home_screen.dart';
import 'package:prosaude/screens/lista_inscritos_screen.dart';
import 'package:prosaude/widgets/widgets.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _id;
  String _nome = "Carregando...";
  String _perfil = "";
  late Future<List<Turma>> _futureTurmas;
  Future<List<dynamic>>? _futureHistorico;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
    _futureTurmas = TurmaService().carregarTurmasDashboard();
  }

  Future<void> _carregarDadosUsuario() async {
    final sessao = await SessionManager.getSession();
    if (sessao != null) {
      setState(() {
        _id = sessao.id!;
        _nome = sessao.nome ?? "Usuário";
        _perfil = sessao.perfil ?? "";

        if (_perfil == "ALUNO") {
          _futureHistorico = InscricaoService().buscarHistoricoAlunos(_id);
        } else if (_perfil == "BOLSISTA") {
          _futureHistorico = TurmaService().buscarHistoricoBolsista(_id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pro Saúde"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomePage(veioDoDashboard: true)),
                    (route) => false,
              );
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SessionManager.clearSession();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Olá, $_nome", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),

            if (_perfil == "COORDENADOR") const CoordenadorActionsGrid(),

            if (_perfil == "ALUNO") ...[
              const Text("Minha Turma", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildTurmasAtivasList(colorScheme: Colors.teal),
              const SizedBox(height: 20),
              if (_futureHistorico != null)
                HistoricoExpansionTile(
                  titulo: "Histórico de Matrículas",
                  subtitulo: "Clique para expandir e ver semestres anteriores",
                  cor: Colors.teal,
                  isBolsista: false,
                  futureHistorico: _futureHistorico,
                ),
              const SizedBox(height: 25),
              const Text("Meus Dados", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              ActionCard(
                icon: Icons.assignment,
                label: "Avaliações",
                color: Colors.blue.shade700,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AvaliacaoHistoricoScreen(id: _id)),
                ),
              ),
            ],

            if (_perfil == "BOLSISTA") ...[
              const Text("Minhas Turmas Ativas", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildTurmasAtivasList(colorScheme: Colors.blue),
              const SizedBox(height: 20),
              if (_futureHistorico != null)
                HistoricoExpansionTile(
                  titulo: "Histórico de Turmas Ministradas",
                  subtitulo: "Clique para ver as turmas de semestres anteriores",
                  cor: Colors.blue,
                  isBolsista: true,
                  futureHistorico: _futureHistorico,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTurmasAtivasList({required Color colorScheme}) {
    return FutureBuilder<List<Turma>>(
      future: _futureTurmas,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: colorScheme));
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("Você não está vinculado a nenhuma turma neste semestre.");
        }

        return Column(
          children: snapshot.data!.map((turma) {
            return WideTurmaCard(
              turma: turma,
              perfil: _perfil,
              
              onTap: _perfil == "BOLSISTA"
                  ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListaInscritosScreen(turmaId: turma.id!, nomeTurma: turma.nome),
                ),
              )
                  : null,
            );
          }).toList(),
        );
      },
    );
  }
}