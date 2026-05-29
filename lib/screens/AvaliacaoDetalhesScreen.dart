import 'package:flutter/material.dart';
import '../core/models/avaliacao/Avaliacao.dart';
import 'GroupContainer.dart';

class AvaliacaoDetalhesScreen extends StatelessWidget {
  final String aluno;
  final AvaliacaoModel avaliacao;

  const AvaliacaoDetalhesScreen({
    super.key,
    required this.aluno,
    required this.avaliacao
  });

  // --- COMPONENTES AUXILIARES DE LEITURA (UI) ---

  Widget _buildDadoLinha({required String label, required String? valor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              (valor == null || valor.isEmpty) ? "Não informado" : valor,
              style: TextStyle(color: Colors.blueGrey.shade800, fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  // Novo widget para dar destaque visual aos parâmetros calculados importantes (IMC e RCQ)
  Widget _buildCardResultadoCalculado({
    required String titulo,
    required String valor,
    required String? classificacao,
  }) {
    final bool Alerta = classificacao != null &&
        (classificacao.contains("Grade") ||
            classificacao.contains("Obesidade") ||
            classificacao.contains("Alto") ||
            classificacao.contains("Sobrepeso"));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Alerta ? Colors.amber.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Alerta ? Colors.amber.shade300 : Colors.green.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900),
              ),
              const SizedBox(height: 4),
              Text(
                classificacao ?? "Sem classificação",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Alerta ? Colors.amber.shade900 : Colors.green.shade900
                ),
              ),
            ],
          ),
          Text(
            valor,
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Alerta ? Colors.amber.shade900 : Colors.green.shade900
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDadoFrequenciaSono({required String titulo, required int? valorIndex}) {
    final opcoes = [
      "Nenhuma vez",
      "Menos de uma vez por semana",
      "Uma ou duas vezes por semana",
      "Três vezes por semana ou mais"
    ];

    String resposta = "Não respondido";
    if (valorIndex != null && valorIndex >= 0 && valorIndex < opcoes.length) {
      resposta = opcoes[valorIndex];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(
              resposta,
              style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 13)
          ),
          const Divider(height: 12),
        ],
      ),
    );
  }

  // --- RENDERIZADORES DAS ABAS DE LEITURA ---

  Widget _buildAnamneseTab() {
    final mapaSono = avaliacao.dadosSono ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GroupContainer(
            title: 'Anamnese Geral',
            children: [
              _buildDadoLinha(label: 'Profissão', valor: avaliacao.anaProfi),
              _buildDadoLinha(label: 'Horas de Trabalho', valor: avaliacao.anaHsTrab?.toString()),
              _buildDadoLinha(label: 'Turno', valor: avaliacao.anaTurnTrab),
              _buildDadoLinha(label: 'Fuma?', valor: avaliacao.anaFuma ? "Sim (Há ${avaliacao.anaFumaTempo ?? 'tempo não informado'})" : "Não"),
              _buildDadoLinha(label: 'Consome Álcool?', valor: avaliacao.anaAlcool ? "Sim" : "Não"),
              _buildDadoLinha(label: 'Alimentação', valor: avaliacao.anaAlimentacao),
              _buildDadoLinha(label: 'Refeições/Dia', valor: avaliacao.anaRefDia?.toString()),
              _buildDadoLinha(label: 'Copos de Água/Dia', valor: avaliacao.anaCoposAguaDia?.toString()),
              _buildDadoLinha(label: 'Histórico Cirúrgico', valor: avaliacao.anaCirurgia),
              _buildDadoLinha(label: 'Cardiopatia Familiar', valor: avaliacao.anaProbCardiaco),
            ],
          ),
          GroupContainer(
            title: 'Qualidade de Sono (Pittsburgh)',
            children: [
              _buildDadoLinha(label: 'Horas médias de sono', valor: avaliacao.anaHsSono),
              const SizedBox(height: 10),
              const Text("Frequência de problemas para dormir no último mês:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 8),
              _buildDadoFrequenciaSono(titulo: "a) Demorar mais de 30 minutos para dormir", valorIndex: mapaSono['q5aDemoraDormir']),
              _buildDadoFrequenciaSono(titulo: "b) Acordar no meio da noite / manhã cedo", valorIndex: mapaSono['q5bAcordarNoite']),
              _buildDadoFrequenciaSono(titulo: "c) Levantar para ir ao banheiro", valorIndex: mapaSono['q5cBanheiroNoite']),
              _buildDadoFrequenciaSono(titulo: "d) Dificuldade para respirar", valorIndex: mapaSono['q5dDificuldadeRespirar']),
              _buildDadoFrequenciaSono(titulo: "e) Tossir ou roncar muito alto", valorIndex: mapaSono['q5eTossirRoncar']),
              _buildDadoFrequenciaSono(titulo: "f) Sentir muito frio", valorIndex: mapaSono['q5fSentirFrio']),
              _buildDadoFrequenciaSono(titulo: "g) Sentir muito calor", valorIndex: mapaSono['q5gSentirCalor']),
              _buildDadoFrequenciaSono(titulo: "h) Sonhos ruins ou pesadelos", valorIndex: mapaSono['q5hPesadelos']),
              _buildDadoFrequenciaSono(titulo: "i) Sentir dores", valorIndex: mapaSono['q5iSentirDores']),

              if (mapaSono['q5jOutraRazaoDescricao'] != null && mapaSono['q5jOutraRazaoDescricao'].toString().isNotEmpty) ...[
                _buildDadoLinha(label: 'Outra Razão', valor: mapaSono['q5jOutraRazaoDescricao']),
                _buildDadoFrequenciaSono(titulo: "Frequência da outra razão:", valorIndex: mapaSono['q5jOutraRazaoFrequencia']),
              ],
              _buildDadoLinha(label: 'Classificação do Sono', valor: avaliacao.anaQualiSono),
              _buildDadoFrequenciaSono(titulo: "7) Uso de medicamentos para dormir", valorIndex: mapaSono['q7RemedioFrequencia']),
              _buildDadoLinha(label: 'Medicamentos utilizados', valor: mapaSono['q7RemedioQuais']),
              _buildDadoFrequenciaSono(titulo: "8) Dificuldade de ficar acordado em atividades", valorIndex: mapaSono['q8FicarAcordadoAtividades']),

              _buildDadoLinha(
                  label: '9) Falta de entusiasmo',
                  valor: mapaSono['q9FaltaEntusiasmo'] != null
                  ? ["Nenhuma", "Pequena", "Moderada", "Muita"][mapaSono['q9FaltaEntusiasmo']] + " indisposição"
                  : null
              ),
              _buildDadoLinha(label: 'Comentários Q9', valor: mapaSono['q9Comentarios']),
              const Divider(),
              _buildDadoLinha(label: '10) Costuma cochilar?', valor: mapaSono['q10Cochila'] == true ? "Sim" : "Não"),
              _buildDadoLinha(label: 'Comentários Cochilo', valor: mapaSono['q10CochilaComentarios']),
              if (mapaSono['q10Cochila'] == true) ...[
                _buildDadoLinha(label: 'Cochila intencionalmente?', valor: mapaSono['q10CochilaIntencional'] == true ? "Sim" : "Não"),
                _buildDadoLinha(label: 'Motivo intencional', valor: mapaSono['q10CochilaIntencionalComentarios']),
                _buildDadoLinha(label: 'Significado do cochilo', valor: mapaSono['q10CochilarSignificado'] == "Outro" ? mapaSono['q10CochilarSignificadoOutro'] : mapaSono['q10CochilarSignificado']),
                _buildDadoLinha(label: 'Comentários significado', valor: mapaSono['q10CochilarSignificadoComentarios']),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAntropometricaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // AJUSTADO: Destaque dos Resultados Calculados pelo Back-end no topo
          GroupContainer(
            title: 'Parâmetros Calculados',
            children: [
              _buildCardResultadoCalculado(
                titulo: 'Índice de Massa Corporal (IMC)',
                valor: avaliacao.antImc != null ? avaliacao.antImc!.toStringAsFixed(2) : '--',
                classificacao: avaliacao.antImcClass,
              ),
              _buildCardResultadoCalculado(
                titulo: 'Relação Cintura-Quadril (RCQ)',
                valor: avaliacao.antRcq != null ? avaliacao.antRcq!.toStringAsFixed(2) : '--',
                classificacao: avaliacao.antRcqClass,
              ),
            ],
          ),
          GroupContainer(
            title: 'Massa e Estatura (Dados Coletados)',
            children: [
              _buildDadoLinha(label: 'Massa Corporal', valor: avaliacao.antPeso != null ? "${avaliacao.antPeso} kg" : null),
              _buildDadoLinha(label: 'Estatura', valor: avaliacao.antAltura != null ? "${avaliacao.antAltura} m" : null),
            ],
          ),
          GroupContainer(
            title: 'Perímetros',
            children: [
              _buildDadoLinha(label: 'Cintura', valor: avaliacao.antPeriCintura != null ? "${avaliacao.antPeriCintura} cm" : null),
              _buildDadoLinha(label: 'Quadril', valor: avaliacao.antPeriQuadril != null ? "${avaliacao.antPeriQuadril} cm" : null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoresTab() {
    final regioes = {
      "A": "Cabeça/Pescoço",
      "B": "Ombros",
      "C": "Braços",
      "D": "Coluna Dorsal",
      "E": "Coluna Lombar",
      "F": "Quadril",
      "G": "Joelhos",
      "H": "Pés"
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GroupContainer(
            title: 'Autoavaliação de Dores',
            children: [
              _buildDadoLinha(label: 'Sentindo dores no dia', valor: avaliacao.comDorehj ? "Sim" : "Não"),
              if (avaliacao.comDorehj) ...[
                const SizedBox(height: 10),
                const Text("Intensidade da dor por região (0 a 10):", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...regioes.entries.map((entry) {
                  int intensidade = avaliacao.comDores[entry.key] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Expanded(child: Text("${entry.key} - ${entry.value}")),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: intensidade > 5 ? Colors.red.shade100 : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Nota: $intensidade",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: intensidade > 5 ? Colors.red.shade900 : Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList()
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPosturalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GroupContainer(
            title: 'Vista Anterior',
            children: [
              _buildDadoLinha(label: '1 - Cabeça', valor: avaliacao.posAnteriorCabeca),
              _buildDadoLinha(label: '2 - Ombros', valor: avaliacao.posAnteriorOmbros),
              _buildDadoLinha(label: '3 - Comprimento Braços', valor: avaliacao.posAnteriorCompBracos),
              _buildDadoLinha(label: '4 - Triângulo de Tales', valor: avaliacao.posAnteriorTrianguloTales),
              _buildDadoLinha(label: '5 - Tronco', valor: avaliacao.posAnteriorTronco),
              _buildDadoLinha(label: '6 - Linha Mamilar', valor: avaliacao.posAnteriorLinhaMamilar),
              _buildDadoLinha(label: '7 - Horiz. Pélvico', valor: avaliacao.posAnteriorEquiHorizPelvico),
              _buildDadoLinha(label: '8 - Cicatriz Umbilical', valor: avaliacao.posAnteriorCicatrizUmbilical),
              _buildDadoLinha(label: '9 - Quadril', valor: avaliacao.posAnteriorQuadrilRod),
              _buildDadoLinha(label: '10 - Joelhos', valor: avaliacao.posAnteriorJoelhos),
              _buildDadoLinha(label: '11 - Pés', valor: avaliacao.posAnteriorPes),
            ],
          ),
          GroupContainer(
            title: 'Plano Sagital - Perfil',
            children: [
              _buildDadoLinha(label: '12 - Cabeça', valor: avaliacao.posPerfilCabeca),
              _buildDadoLinha(label: '13 - Ombros', valor: avaliacao.posPerfilOmbros),
              _buildDadoLinha(label: '14 - Membros Sup.', valor: avaliacao.posPerfilMembrosSuperiores),
            ],
          ),
          GroupContainer(
            title: 'Coluna Vertebral',
            children: [
              _buildDadoLinha(label: '15 - Cervical', valor: avaliacao.posColunaCervical),
              _buildDadoLinha(label: '16 - Dorsal', valor: avaliacao.posColunaDorsal),
              _buildDadoLinha(label: '17 - Lombar', valor: avaliacao.posColunaLombar),
              _buildDadoLinha(label: '18 - Quadril', valor: avaliacao.posColunaQuadril),
              _buildDadoLinha(label: '19 - Joelhos', valor: avaliacao.posColunaJoelhos),
            ],
          ),
          GroupContainer(
            title: 'Plano Dorsal',
            children: [
              _buildDadoLinha(label: '20 - Escoliose', valor: avaliacao.posPosteriorEscoliose),
              _buildDadoLinha(label: '21 - Gibosidade', valor: avaliacao.posPosteriorGibosidade),
              _buildDadoLinha(label: '22 - Tendão de Aquiles', valor: avaliacao.posPosteriorTendaoAquiles),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConcluirTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Observações Gerais coletadas:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  (avaliacao.obs == null || avaliacao.obs!.isEmpty) ? "Nenhuma observação cadastrada." : avaliacao.obs!,
                  style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue.shade900,
          foregroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Resultados: $aluno', style: const TextStyle(fontSize: 18)),
              Text(
                'Data da Ficha: ${avaliacao.dataAvaliacao?.day}/${avaliacao.dataAvaliacao?.month}/${avaliacao.dataAvaliacao?.year}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              )
            ],
          ),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Anamnese & Sono'),
              Tab(text: 'Antropometria'),
              Tab(text: 'Autoavaliação Dor'),
              Tab(text: 'Avaliação Postural'),
              Tab(text: 'Observações'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAnamneseTab(),
            _buildAntropometricaTab(),
            _buildDoresTab(),
            _buildPosturalTab(),
            _buildConcluirTab(),
          ],
        ),
      ),
    );
  }
}