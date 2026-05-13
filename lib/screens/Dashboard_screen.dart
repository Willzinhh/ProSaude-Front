import 'package:flutter/material.dart';
import 'package:prosaude/core/models/turma/Turma.dart';
import 'package:prosaude/screens/EquipeManageScreen.dart';
import 'package:prosaude/screens/TrumaManage_screen.dart';
import 'package:prosaude/screens/lista_inscritos_screen.dart';
import 'package:prosaude/core/services/session_manager.dart';
import 'package:prosaude/core/services/turma_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _nome = "Carregando...";
  String _perfil = "";
  late Future<List<Turma>> _futureTurmas;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
    // Inicializamos o future aqui para evitar múltiplas chamadas na reconstrução do widget

    _futureTurmas = TurmaService().carregarTurmasDashboard();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pro Saúde"),
        elevation: 0,
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

            // --- SEÇÃO DE AÇÕES (GRID QUADRADO) ---
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1.1,
              // Ajusta a altura dos cards do grid
              children: [
                if (_perfil == "COORDENADOR") ...[
                  _buildActionCard(
                    context,
                    icon: Icons.assignment,
                    label: "Gerenciar Turmas",
                    color: Colors.blue.shade700,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TurmaManageScreen(),
                      ),
                    ),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.people_alt,
                    label: "Equipe e Designação",
                    color: Colors.orange.shade800,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EquipeManageScreen(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
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
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Text("Erro ao carregar turmas.");
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text(
                      "Você não está vinculado a nenhuma turma.",
                    );
                  }

                  final turmas = snapshot.data!;

                  return Column(
                    children: turmas
                        .map(
                          (turma) =>
                              _buildWideTurmaCard(_perfil, context, turma),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 15),

              const Text(
                "Meus Dados",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildGridAcoes([
                _buildActionCard(
                  context,
                  icon: Icons.assignment,
                  label: "Avaliaçoes",
                  color: Colors.blue.shade700,
                  onTap: () {
                    print("e");
                  },
                  // () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ())),

                ),
                  _buildActionCard(
                  context,
                  icon: Icons.assignment,
                  label: "Avaliaçoes",
                  color: Colors.blue.shade700,
                  onTap: () {
                  print("e");
                  },)
              ]),
            ],
            // --- SEÇÃO DE TURMAS (CARDS LARGOS - FULL WIDTH) ---
            if (_perfil == "BOLSISTA") ...[
              const Text(
                "Minhas Turmas Ativas",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              FutureBuilder<List<Turma>>(
                future: _futureTurmas,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Text("Erro ao carregar turmas.");
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text(
                      "Você não está vinculado a nenhuma turma.",
                    );
                  }

                  final turmas = snapshot.data!;

                  return Column(
                    children: turmas
                        .map(
                          (turma) =>
                              _buildWideTurmaCard(_perfil, context, turma),
                        )
                        .toList(),
                  );
                },
              ),
            ],

            // --- SEÇÃO DE TURMAS (CARDS LARGOS - FULL WIDTH) ---
          ],
        ),
      ),
    );
  }

  Widget _buildGridAcoes(List<Widget> cards) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Definimos que cada card normal ocupa 50% da largura (menos o espaçamento)
        double larguraMeia = (constraints.maxWidth / 2) - 8;
        double larguraCheia = constraints.maxWidth;

        return Wrap(
          spacing: 16, // Espaço entre os cards na horizontal
          runSpacing: 16, // Espaço entre as linhas
          children: List.generate(cards.length, (index) {
            // Se for o último item e o total de itens for ímpar
            bool ehUltimoESozinho =
                (index == cards.length - 1) && (cards.length % 2 != 0);

            return SizedBox(
              width: ehUltimoESozinho ? larguraCheia : larguraMeia,
              height: 160, // Altura fixa para manter o alinhamento
              child: cards[index],
            );
          }),
        );
      },
    );
  }

  // Widget para os botões quadrados do Grid
  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
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

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      // Importante zerar para o Wrap controlar o espaço
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          // Adicionado padding para respiro interno
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

  // Widget para os cards de Turma que ocupam a largura total (Full Width)
  Widget _buildWideTurmaCard(
    String _perfil,
    BuildContext context,
    Turma turma,
  ) {
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("Horário: $diaAtivo"),
              const SizedBox(height: 10),
              if (_perfil == "BOLSISTA")
                const Text(
                  "Clique para ver a lista de inscritos",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
