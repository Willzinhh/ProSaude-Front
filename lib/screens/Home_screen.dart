import 'package:carousel_slider/carousel_slider.dart' as slider;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // 🎯 Importe o Dio para fazer a requisição direta
import 'package:prosaude/screens/FormularioInscricao_screen.dart';
import 'package:prosaude/screens/Login_screen.dart';

import '../core/models/turma/Turma.dart';
import '../core/services/inscricao_service.dart';
import '../core/services/session_manager.dart';
import '../core/services/turma_service.dart';

class HomePage extends StatefulWidget {
  final bool veioDoDashboard;

  const HomePage({super.key, this.veioDoDashboard = false});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Turma>> _futureTurmas;
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://sua-api-url:8080")); // 🎯 Ajuste para a URL do seu backend/Docker

  @override
  void initState() {
    super.initState();
    if (!widget.veioDoDashboard) {
      _verificarSessaoAtiva();
    }
    _futureTurmas = TurmaService().carregarTurmasPorSemestre(_gerarSemestreAtual());
  }

  Future<void> _verificarSessaoAtiva() async {
    final token = await SessionManager.getToken();
    if (token != null && token.isNotEmpty) {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/dashboard');
      });
    }
  }

  // 🎯 Calcula dinamicamente o semestre atual (Ex: "2026/1" ou "2026/2")
  String _gerarSemestreAtual() {
    final agora = DateTime.now();
    final ano = agora.year;
    final semestre = agora.month <= 6 ? "1" : "2";
    return "$ano/$semestre";
  }



  final InscricaoService _inscricaoService = InscricaoService();

  void _executarInscricaoRapida(int? turmaId) async {
    if (turmaId == null) return;

    // Mostra o loading na tela
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.teal)),
    );

    try {
      final session = await SessionManager.getSession();

      final dadosInscricao = {
        "alunoId": session?.id, // Envia o ID numérico direto do celular
        "turmaId": turmaId,
        "semestre": _gerarSemestreAtual(), // Ex: "2026/1"
      };

      // 🎯 Chama o método do seu serviço (ele já cuida do endpoint e do Token!)
      await _inscricaoService.enviarAutoCadastro(dadosInscricao);

      Navigator.pop(context); // Fecha o loading

      _exibirPopupFeedback(
        titulo: "Inscrição Confirmada!",
        mensagem: "Sua vaga foi garantida para o semestre ${_gerarSemestreAtual()} com sucesso.",
        isErro: false,
      );

    } catch (e) {
      Navigator.pop(context); // Fecha o loading

      // Como o seu service já joga a mensagem limpa no throw Exception(mensagem)
      // Nós apenas limpamos o texto "Exception: " caso ele apareça
      String msgErro = e.toString().replaceAll("Exception: ", "");

      _exibirPopupFeedback(
        titulo: "Inscrição Recusada",
        mensagem: msgErro,
        isErro: true,
      );
    }
  }

  // 🎯 Janela de aviso amigável com base na resposta do Java
  void _exibirPopupFeedback({required String titulo, required String mensagem, required bool isErro}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(
              isErro ? Icons.cancel : Icons.check_circle,
              color: isErro ? Colors.red : Colors.green,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(mensagem, style: const TextStyle(fontSize: 16)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: isErro ? Colors.red : Colors.teal),
            onPressed: () => Navigator.pop(context),
            child: const Text("Entendido", style: TextStyle(color: Colors.white)),
          ),
        ],
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

  void _abrirModalDetalhes(Turma turma) {
    final diasAtivo = diasAtivos(turma);
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
                spacing: 6,
                runSpacing: 6,
                children: diasAtivo.map((dia) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade700.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      dia.substring(0, 3),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(turma.descricao),
              const Divider(),
              Text(
                "Bolsista Encarregado: ${turma.bolsista_responsavel?.nome.toUpperCase() ?? 'Não informado'}",
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final token = await SessionManager.getToken();
              Navigator.pop(context); // Fecha a modal de detalhes

              if (token != null && token.isNotEmpty) {
                // 🎯 SE ESTIVER LOGADO: Executa a inscrição rápida direto pelo back-end
                _executarInscricaoRapida(turma.id);
              } else {
                // SE FOR ANÔNIMO: Segue o fluxo normal perguntando se tem conta
                _verificarUsuario(context, turma.id);
              }
            },
            child: const Text("Inscrever-se"),
          ),
        ],
      ),
    );
  }

  List<Turma> _obterTurmasDeHoje(List<Turma> todas) {
    int diaNum = DateTime.now().weekday;
    Map<int, String> mapaDias = {
      1: "SEGUNDA", 2: "TERCA", 3: "QUARTA", 4: "QUINTA", 5: "SEXTA", 6: "SABADO", 7: "DOMINGO",
    };
    String hoje = mapaDias[diaNum] ?? "";
    return todas.where((t) {
      switch (hoje) {
        case "SEGUNDA": return t.aulaSegunda;
        case "TERCA": return t.aulaTerca;
        case "QUARTA": return t.aulaQuarta;
        case "QUINTA": return t.aulaQuinta;
        case "SEXTA": return t.aulaSexta;
        case "SABADO": return t.aulaSabado;
        case "DOMINGO": return t.aulaDomingo;
        default: return false;
      }
    }).toList();
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
                onPressed: () async {
                  final token = await SessionManager.getToken();
                  if (token != null && token.isNotEmpty) {
                    Navigator.pushNamed(context, '/dashboard');
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  }
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
              return const Center(child: CircularProgressIndicator(color: Colors.teal));
            } else if (snapshot.hasError) {
              return Center(child: Text("Ops! Erro ao carregar turmas.\n${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Nenhuma turma disponível no momento."));
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ),
                  slider.CarouselSlider(
                    options: slider.CarouselOptions(
                      height: 180.0,
                      autoPlay: turmasDeHoje.isNotEmpty,
                      viewportFraction: turmasDeHoje.isEmpty ? 1.0 : 0.85,
                      enlargeCenterPage: turmasDeHoje.isNotEmpty,
                      aspectRatio: 16 / 9,
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enableInfiniteScroll: turmasDeHoje.length > 1,
                    ),
                    items: turmasDeHoje.isEmpty
                        ? [_buildCardVazio()]
                        : turmasDeHoje.map((t) => _buildCarouselItem(t)).toList(),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Todas as Modalidades",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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

  Widget _buildCarouselItem(Turma turma) {
    final diasAtivo = diasAtivos(turma);
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
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 4))],
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
                    spacing: 6,
                    children: diasAtivo.map((dia) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          dia.substring(0, 3),
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                turma.nome,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "${formatarHora(turma.horaInicio)} -- ${formatarHora(turma.horaFim)}",
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatarHora(String? hora) {
    if (hora == null || hora.isEmpty) return "--:--";
    return hora.substring(0, 5);
  }

  Widget _buildCardTurma(Turma turma) {
    final diasAtivosCard = diasAtivos(turma);
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
                spacing: 6,
                children: diasAtivosCard.map((dia) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade300.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      dia.substring(0, 3),
                      style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
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
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
    DateTime hoje = DateTime.now();
    List<String> diasPt = ["Segunda-feira", "Terça-feira", "Quarta-feira", "Quinta-feira", "Sexta-feira", "Sábado", "Domingo"];
    String nomeDia = diasPt[hoje.weekday - 1];
    String dataFormatada = "${hoje.day.toString().padLeft(2, '0')}/${hoje.month.toString().padLeft(2, '0')}";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event_busy, size: 50),
          const SizedBox(height: 15),
          const Text("Sem atividades hoje", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("$nomeDia, $dataFormatada", style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 14)),
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
          content: const Text("Para continuar com a inscrição, precisamos saber se você já é aluno do Pró-Saúde."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FormularioInscricaoScreen(turmaId: turmaId)),
                );
              },
              child: const Text("NÃO TENHO CONTA"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
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