import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as slider;
import 'package:prosaude/screens/FormularioInscricao_screen.dart';
import 'package:prosaude/screens/Login_screen.dart';
import '../models/turma/Turma.dart';
import '../services/turma_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Turma>> _futureTurmas;

  @override
  void initState() {
    super.initState();
    _futureTurmas = TurmaService().getTurmas();
  }

  void _abrirModalDetalhes(Turma turma) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          turma.nome,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 6, // Espaço horizontal entre os dias
                runSpacing: 6,
                children: turma.diasSemana!.map((dia) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade700.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      dia.substring(0, 3),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  const Icon(Icons.access_time, size: 18, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text(
                    "${formatarHora(turma.horaInicio)} até ${formatarHora(turma.horaFim)}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(turma.descricao),
              const Divider(),
              Text(
                "Bolsista Encaregado: ${turma.bolsistaResponsavel?.nome.toUpperCase() ?? 'Não informado'}",
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),

        actions: [
          ElevatedButton(
            onPressed: () {
              final int? idSelecionado = turma.id;
              _verificarUsuario(context, turma.id); // Chama o diálogo aqui
              child: const Text("INSCREVER-SE");
            },
            child: const Text("Inscrever-se"),
          ),
        ],
      ),
    );
  }

  List<Turma> _obterTurmasDeHoje(List<Turma> todas) {
    // Pega o número do dia (1 = Segunda, 7 = Domingo)
    int diaNum = DateTime.now().weekday;

    // Mapeia para o padrão que salvamos no Java (Enum String)
    Map<int, String> mapaDias = {
      1: "SEGUNDA",
      2: "TERCA",
      3: "QUARTA",
      4: "QUINTA",
      5: "SEXTA",
      6: "SABADO",
      7: "DOMINGO",
    };

    String hoje = mapaDias[diaNum] ?? "";

    // Filtra as turmas que CONTÉM o dia de hoje na lista delas
    return todas.where((t) => t.diasSemana?.contains(hoje) ?? false).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "PróSaude",
          style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              child: IconButton(
                icon: const Icon(Icons.person, color: Colors.teal),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _futureTurmas = TurmaService().getTurmas();
          });
        },
        child: FutureBuilder<List<Turma>>(
          future: _futureTurmas,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.teal),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Ops! Erro ao carregar turmas.\n${snapshot.error}"),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text("Nenhuma turma disponível no momento."),
              );
            }

            final todasAsTurmas = snapshot.data!;
            final turmasDeHoje = _obterTurmasDeHoje(todasAsTurmas);

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Atividades de Hoje",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),

                  // IMPLEMENTAÇÃO DO CARROSSEL COM DADOS DO BANCO
                  slider.CarouselSlider(
                    options: slider.CarouselOptions(
                      height: 180.0,
                      // SÓ ATIVA O AUTOPLAY SE TIVER ITENS
                      autoPlay: turmasDeHoje.isNotEmpty,
                      // SE ESTIVER VAZIO, OCUPA 100% DA LARGURA (P/ CENTRALIZAR), SENÃO 85%
                      viewportFraction: turmasDeHoje.isEmpty ? 1.0 : 0.85,
                      enlargeCenterPage: turmasDeHoje.isNotEmpty,
                      aspectRatio: 16 / 9,
                      autoPlayCurve: Curves.fastOutSlowIn,
                      // SÓ FAZ O LOOP INFINITO SE TIVER MAIS DE 1 TURMA
                      enableInfiniteScroll: turmasDeHoje.length > 1,
                    ),
                    items: turmasDeHoje.isEmpty
                        ? [_buildCardVazio()]
                        : turmasDeHoje
                              .map((t) => _buildCarouselItem(t))
                              .toList(),
                  ),

                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Todas as Modalidades",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),

                  // Mantendo o GridView abaixo para listagem completa
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.1,
                        ),
                    itemCount: todasAsTurmas.length,
                    itemBuilder: (context, index) {
                      return _buildCardTurma(todasAsTurmas[index]);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget para o item individual do Carrossel
  Widget _buildCarouselItem(Turma turma) {
    if (turma == null) {}
    return InkWell(
      onTap: () => _abrirModalDetalhes(turma),
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade400, Colors.teal.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 30),
                  const Spacer(),
                  Wrap(
                    spacing: 6, // Espaço horizontal entre os dias
                    children: turma.diasSemana!.map((dia) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          dia.substring(0, 3),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const Spacer(),

              Text(
                turma.nome,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${formatarHora(turma.horaInicio)} -- ${formatarHora(turma.horaFim)}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Função auxiliar para limpar a string "08:30:00" -> "08:30"
  String formatarHora(String? hora) {
    if (hora == null || hora.isEmpty) return "--:--";
    return hora.substring(0, 5);
  }

  Widget _buildCardTurma(Turma turma) {
    return InkWell(
      onTap: () => _abrirModalDetalhes(turma),
      borderRadius: BorderRadius.circular(15),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Wrap(
                spacing: 6, // Espaço horizontal entre os dias
                children: turma.diasSemana!.map((dia) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade300.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      dia.substring(0, 3),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  turma.nome,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${formatarHora(turma.horaInicio)} -- ${formatarHora(turma.horaFim)}",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardVazio() {
    // Pega a data de hoje formatada
    DateTime hoje = DateTime.now();

    // Lista manual para o nome do dia em português (ou use o pacote intl)
    List<String> diasPt = [
      "Segunda-feira",
      "Terça-feira",
      "Quarta-feira",
      "Quinta-feira",
      "Sexta-feira",
      "Sábado",
      "Domingo",
    ];
    String nomeDia = diasPt[hoje.weekday - 1];
    String dataFormatada =
        "${hoje.day.toString().padLeft(2, '0')}/${hoje.month.toString().padLeft(2, '0')}";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1), // Estilo fosco/glassmorphism
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event_busy, size: 50),
          const SizedBox(height: 15),
          const Text(
            "Sem atividades hoje",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            "$nomeDia, $dataFormatada",
            style: TextStyle(
              color: Colors.black.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _verificarUsuario(BuildContext context, int? turmaId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Já possui cadastro?"),
          content: const Text(
              "Para continuar com a inscrição, precisamos saber se você já é aluno do Pró-Saúde."
          ),
          actions: [
            // OPÇÃO 1: NÃO TEM CONTA
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o diálogo
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormularioInscricaoScreen(turmaId: turmaId),
                  ),
                );
              },
              child: const Text("NÃO TENHO CONTA"),
            ),

            // OPÇÃO 2: JÁ TEM CONTA
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o diálogo
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text("JÁ TENHO CONTA"),
            ),
          ],
        );
      },
    );
  }
}
