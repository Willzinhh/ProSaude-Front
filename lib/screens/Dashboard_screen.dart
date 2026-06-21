import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:prosaude/core/models/turma/Turma.dart';
import 'package:prosaude/core/services/session_manager.dart';
import 'package:prosaude/core/services/turma_service.dart';
import 'package:prosaude/core/services/inscricao_service.dart'; // 🎯 Importe o seu serviço de inscrição
import 'package:prosaude/screens/AvaliacaoDetalhesScreen.dart';
import 'package:prosaude/screens/AvaliacaoHistoricoScreen.dart';
import 'package:prosaude/screens/EquipeManageScreen.dart';
import 'package:prosaude/screens/Home_screen.dart';
import 'package:prosaude/screens/TodasTurmasScreen.dart';
import 'package:prosaude/screens/TrumaManage_screen.dart';
import 'package:prosaude/screens/lista_inscritos_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _id;
  String _nome = "Carregando";
  String _perfil = "";
  late Future<List<Turma>> _futureTurmas;
  Future<List<dynamic>>? _futureHistorico; // 🎯 Variável para guardar o futuro do histórico

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

        // 🎯 Dispara a busca do histórico de inscrições assim que o ID do aluno estiver disponível
        if (_perfil == "ALUNO") {
          _futureHistorico = InscricaoService().buscarHistoricoAlunos(_id);
        }
        else if (_perfil == "BOLSISTA") {
        // 🎯 Chame a função do serviço correspondente ao histórico de turmas passadas do Bolsista
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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const HomePage(veioDoDashboard: true),
                ),
                    (Route<dynamic> route) => false,
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
            Text(
              "Olá, $_nome",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),

            // --- SEÇÃO DE AÇÕES DO COORDENADOR ---
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1.1,
              children: [
                if (_perfil == "COORDENADOR") ...[
                  _buildActionCard(
                    context,
                    icon: Icons.assignment,
                    label: "Gerenciar Turmas",
                    color: Colors.blue.shade700,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TurmaManageScreen()),
                    ),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.people_alt,
                    label: "Equipe e Designação",
                    color: Colors.orange.shade800,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EquipeManageScreen()),
                    ),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.backpack, // Ícone que representa as turmas/classes
                    label: "Ver Todas as Turmas",
                    color: Colors.teal.shade700,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TodasTurmasScreen()),
                      // 💡 Dica: A TurmaManageScreen já lista todas as turmas com filtros excelentes!
                    ),
                  ),
                ],

              ],
            ),

            // --- FLUXO DO ALUNO ---
            if (_perfil == "ALUNO") ...[
              const Text(
                "Minha Turma",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              FutureBuilder<List<Turma>>(
                future: _futureTurmas,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.teal));
                  }
                  if (snapshot.hasError) {
                    return const Text("Erro ao carregar turmas.");
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("Você não está vinculado a nenhuma turma neste semestre.");
                  }

                  final turmas = snapshot.data!;
                  return Column(
                    children: turmas.map((turma) => _buildWideTurmaCard(_perfil, context, turma)).toList(),
                  );
                },
              ),
              const SizedBox(height: 20),

              /// 🎯 --- SEÇÃO: HISTÓRICO DE MATRÍCULAS (EXPANSÍVEL) ---
              if (_futureHistorico != null)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    leading: const Icon(Icons.history, color: Colors.teal),
                    title: const Text(
                      "Histórico de Matrículas",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text("Clique para expandir e ver semestres anteriores"),
                    iconColor: Colors.teal,
                    textColor: Colors.teal,
                    shape: const Border(), // Remove as linhas divisórias feias do expansion
                    collapsedShape: const Border(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: FutureBuilder<List<dynamic>>(
                          future: _futureHistorico,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(color: Colors.teal),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return const Text("Erro ao carregar o histórico.");
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text("Nenhum histórico de turmas encontrado."),
                              );
                            }

                            final historico = snapshot.data!;

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: historico.length,
                              itemBuilder: (context, index) {
                                final item = historico[index];
                                final bool isAtivo = item['status'] == 'ATIVO';

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  color: Colors.grey.shade50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 1,
                                  child: ListTile(
                                    title: Text(
                                      item['nomeTurma'] ?? 'Modalidade',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text("Semestre: ${item['semestre']}"),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isAtivo ? Colors.green.shade100 : Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item['status'] ?? 'INATIVO',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isAtivo ? Colors.green.shade800 : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 25),

              // --- MEUS DADOS ---
              const Text(
                "Meus Dados",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildGridAcoes([
                _buildActionCard(
                  context,
                  icon: Icons.assignment,
                  label: "Avaliações",
                  color: Colors.blue.shade700,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AvaliacaoHistoricoScreen(id: _id),
                    ),
                  ),
                ),
              ]),
            ],

            // --- FLUXO DO BOLSISTA ---
            if (_perfil == "BOLSISTA") ...[
              const Text(
                "Minhas Turmas Ativas",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // Exibe as turmas carregadas como vigentes/principais no topo
              FutureBuilder<List<Turma>>(
                future: _futureTurmas,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.blue));
                  }
                  if (snapshot.hasError) {
                    return const Text("Erro ao carregar turmas.");
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("Você não está vinculado a nenhuma turma neste semestre.");
                  }

                  final turmas = snapshot.data!;
                  return Column(
                    children: turmas.map((turma) => _buildWideTurmaCard(_perfil, context, turma)).toList(),
                  );
                },
              ),
              const SizedBox(height: 20),

              // 🎯 --- SEÇÃO HISTÓRICO DE TURMAS DO BOLSISTA (EXPANSÍVEL) ---
              if (_futureHistorico != null)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    leading: const Icon(Icons.history, color: Colors.blue),
                    title: const Text(
                      "Histórico de Turmas Ministradas",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text("Clique para ver as turmas de semestres anteriores"),
                    iconColor: Colors.blue,
                    textColor: Colors.blue,
                    shape: const Border(),
                    collapsedShape: const Border(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: FutureBuilder<List<dynamic>>(
                          future: _futureHistorico,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(color: Colors.blue),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return const Text("Erro ao carregar o histórico de lecionados.");
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text("Nenhuma turma antiga encontrada."),
                              );
                            }

                            final historico = snapshot.data!;

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: historico.length,
                              itemBuilder: (context, index) {
                                final item = historico[index];

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  color: Colors.grey.shade50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 1,
                                  child: ListTile(
                                    title: Text(
                                      item['nome'] ?? 'Modalidade',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text("Semestre: ${item['semestre']}"),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 25),
            ],
          ],
        ),
      ),
    );
  }

  // O restante dos seus métodos auxiliares (_buildGridAcoes, _buildActionCard, diasAtivos, _buildWideTurmaCard) permanecem idênticos aqui embaixo...
  Widget _buildGridAcoes(List<Widget> cards) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double larguraMeia = (constraints.maxWidth / 2) - 8;
        double larguraCheia = constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: List.generate(cards.length, (index) {
            bool ehUltimoESozinho = (index == cards.length - 1) && (cards.length % 2 != 0);
            return SizedBox(
              width: ehUltimoESozinho ? larguraCheia : larguraMeia,
              height: 160,
              child: cards[index],
            );
          }),
        );
      },
    );
  }

  Widget _buildActionCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> diasAtivos(turma) {
    final diasAtivos = <String>[];
    if (turma.aulaSegunda == true) diasAtivos.add("SEG");
    if (turma.aulaTerca == true) diasAtivos.add("TER");
    if (turma.aulaQuarta == true) diasAtivos.add("QUA");
    if (turma.aulaQuinta == true) diasAtivos.add("QUI");
    if (turma.aulaSexta == true) diasAtivos.add("SEX");
    if (turma.aulaSabado == true) diasAtivos.add("SÁB");
    if (turma.aulaDomingo == true) diasAtivos.add("DOM");
    return diasAtivos;
  }

  Widget _buildWideTurmaCard(String _perfil, BuildContext context, Turma turma) {
    final diaAtivo = diasAtivos(turma);
    return InkWell(
      onTap: _perfil == "BOLSISTA"
          ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListaInscritosScreen(
              turmaId: turma.id!,
              nomeTurma: turma.nome,
            ),
          ),
        );
      }
          : null,
      child: Card(
        margin: const EdgeInsets.only(bottom: 15),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                turma.nome,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text("Horário: $diaAtivo"),
              const SizedBox(height: 10),
              if (_perfil == "BOLSISTA")
                const Text(
                  "Clique para ver a lista de inscritos",
                  style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }
}