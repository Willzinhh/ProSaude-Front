import 'package:flutter/material.dart';
import 'package:prosaude/core/models/aluno/Aluno.dart';

import '../models/avaliacao/Avaliacao.dart';
import 'GroupContainer.dart';

class AvaliacaoFormScreen extends StatefulWidget {
  final Aluno aluno;

  const AvaliacaoFormScreen({super.key, required this.aluno});

  @override
  State<AvaliacaoFormScreen> createState() => _AvaliacaoFormScreenState();
}

class _AvaliacaoFormScreenState extends State<AvaliacaoFormScreen> {
  final AvaliacaoModel _avaliacao = AvaliacaoModel();

  // Estados locais para a lógica dos campos do Pittsburgh (Sono)
  int? _q5a, _q5b, _q5c, _q5d, _q5e, _q5f, _q5g, _q5h, _q5i;
  int? _q7Frequencia, _q8Frequencia, _q9FaltaEntusiasmo;
  bool _q10Cochila = false;
  bool _q10CochilaIntencional = false;
  String? _q10Significado;

  @override
  void initState() {
    super.initState();
    // Vincula a data padrão ao abrir o formulário
    _avaliacao.dataAvaliacao = DateTime.now();
  }

  // Helper para Inputs de Texto Padrão
  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    bool isNumber = false,
  }) {
    return TextFormField(
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: onChanged,
    );
  }

  // Helper para as perguntas de Rádio de Frequência do Sono (0 a 3)
  Widget _buildFrequenciaSono({
    required String titulo,
    required int? valorAtual,
    required Function(int?) onChanged,
  }) {
    final opcoes = [
      "Nenhuma vez",
      "Menos de uma vez por semana",
      "Uma ou duas vezes por semana",
      "Três vezes por semana ou mais",
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        ...List.generate(opcoes.length, (index) {
          return RadioListTile<int>(
            title: Text(opcoes[index]),
            value: index,
            groupValue: valorAtual,
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: Colors.blue.shade800,
            onChanged: (val) {
              onChanged(val);
              _salvarDadosSonoMapeados();
            },
          );
        }),
        const SizedBox(height: 10),
      ],
    );
  }

  // Helper para Dropdowns na área de Postura
  Widget _buildPosturaDropdown({
    required String label,
    required String? valorAtual,
    required List<String> opcoes,
    required Function(String?) onChanged,
    required List<String> opces,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: valorAtual,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: opcoes.map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // Consolida o dicionário interno do sono antes de enviar para o modelo principal
  void _salvarDadosSonoMapeados() {
    _avaliacao.dadosSono = {
      'q5aDemoraDormir': _q5a,
      'q5bAcordarNoite': _q5b,
      'q5cBanheiroNoite': _q5c,
      'q5dDificuldadeRespirar': _q5d,
      'q5eTossirRoncar': _q5e,
      'q5fSentirFrio': _q5f,
      'q5gSentirCalor': _q5g,
      'q5hPesadelos': _q5h,
      'q5iSentirDores': _q5i,
      'q7RemedioFrequencia': _q7Frequencia,
      'q8FicarAcordadoAtividades': _q8Frequencia,
      'q9FaltaEntusiasmo': _q9FaltaEntusiasmo,
      'q10Cochila': _q10Cochila,
      'q10CochilaIntencional': _q10CochilaIntencional,
      'q10CochilarSignificado': _q10Significado,
    };
  }

  // --- RENDERIZADORES DAS ABAS (TABS) ---

  // ABAL 1: ANAMNESE E SONO
  Widget _buildAnamneseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GroupContainer(
            title: 'Dados Profissionais e Hábitos',
            children: [
              _buildTextField(
                label: 'Profissão',
                onChanged: (val) => _avaliacao.anaProfi = val,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Horas de Trabalho Diárias',
                isNumber: true,
                onChanged: (val) => _avaliacao.anaHsTrab = double.tryParse(val),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Turno de Trabalho',
                onChanged: (val) => _avaliacao.anaTurnTrab = val,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text("Fuma?"),
                value: _avaliacao.anaFuma,
                onChanged: (val) => setState(() => _avaliacao.anaFuma = val),
              ),
              if (_avaliacao.anaFuma)
                _buildTextField(
                  label: 'Há quanto tempo fuma?',
                  onChanged: (val) => _avaliacao.anaFumaTempo = val,
                ),
              SwitchListTile(
                title: const Text("Consome Álcool regularmente?"),
                value: _avaliacao.anaAlcool,
                onChanged: (val) => setState(() => _avaliacao.anaAlcool = val),
              ),
            ],
          ),
          GroupContainer(
            title: 'Qualidade do Sono (Pittsburgh - PSQI)',
            children: [
              _buildTextField(
                label: 'Horas médias de sono por noite',
                isNumber: true,
                onChanged: (val) => _avaliacao.anaHsSono = val,
              ),
              const SizedBox(height: 15),
              _buildFrequenciaSono(
                titulo: "a) Demorar mais de 30 minutos para dormir",
                valorAtual: _q5a,
                onChanged: (val) => setState(() => _q5a = val),
              ),
              _buildFrequenciaSono(
                titulo: "b) Acordar no meio da noite ou manhã cedo",
                valorAtual: _q5b,
                onChanged: (val) => setState(() => _q5b = val),
              ),
              _buildFrequenciaSono(
                titulo: "c) Levantar para ir ao banheiro",
                valorAtual: _q5c,
                onChanged: (val) => setState(() => _q5c = val),
              ),
              _buildFrequenciaSono(
                titulo: "h) Ter sonhos ruins ou pesadelos",
                valorAtual: _q5h,
                onChanged: (val) => setState(() => _q5h = val),
              ),
              _buildFrequenciaSono(
                titulo: "i) Sentir dores durante a noite",
                valorAtual: _q5i,
                onChanged: (val) => setState(() => _q5i = val),
              ),

              const Divider(),
              _buildFrequenciaSono(
                titulo: "7) Tomou algum remédio para dormir?",
                valorAtual: _q7Frequencia,
                onChanged: (val) => setState(() => _q7Frequencia = val),
              ),
              if (_q7Frequencia != null && _q7Frequencia! > 0)
                _buildTextField(
                  label: 'Qual(is) remédios?',
                  onChanged: (val) =>
                      _avaliacao.dadosSono['q7RemedioQuais'] = val,
                ),

              const Divider(),
              SwitchListTile(
                title: const Text("10) Você costuma cochilar?"),
                value: _q10Cochila,
                onChanged: (val) => setState(() {
                  _q10Cochila = val;
                  _salvarDadosSonoMapeados();
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ABA 2: ANTROPOMÉTRICA (Conforme o teu print padrão)
  Widget _buildAntropometricaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GroupContainer(
            title: 'Massa e Estatura',
            children: [
              _buildTextField(
                label: 'Massa Corporal (kg)',
                isNumber: true,
                onChanged: (val) => _avaliacao.antPeso = double.tryParse(val),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Estatura (cm)',
                isNumber: true,
                onChanged: (val) => _avaliacao.antAltura = double.tryParse(val),
              ),
            ],
          ),
          GroupContainer(
            title: 'Perímetros',
            children: [
              _buildTextField(
                label: 'Cintura (cm)',
                isNumber: true,
                onChanged: (val) =>
                    _avaliacao.antPeriCintura = double.tryParse(val),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Quadril (cm)',
                isNumber: true,
                onChanged: (val) =>
                    _avaliacao.antPeriQuadril = double.tryParse(val),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ABA 3: MAPA DE DORES (COM)
  Widget _buildTestesFisicosDoresTab() {
    final regioesCorpo = [
      "A - Cabeça/Pescoço",
      "B - Ombros",
      "C - Braços",
      "D - Coluna Dorsal",
      "E - Coluna Lombar",
      "F - Quadril",
      "G - Joelhos",
      "H - Pés",
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GroupContainer(
            title: 'Autoavaliação de Dor Física',
            children: [
              SwitchListTile(
                title: const Text("Está sentindo alguma dor hoje?"),
                value: _avaliacao.comDorehj,
                onChanged: (val) => setState(() => _avaliacao.comDorehj = val),
              ),
              if (_avaliacao.comDorehj) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Informe a intensidade da dor para cada região (1 a 10):",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ...regioesCorpo.map((regiao) {
                  String letraChave = regiao.split(" - ")[0];
                  return Row(
                    children: [
                      Expanded(flex: 2, child: Text(regiao)),
                      Expanded(
                        flex: 1,
                        child: Slider(
                          value: (_avaliacao.comDores[letraChave] ?? 0)
                              .toDouble(),
                          min: 0,
                          max: 10,
                          divisions: 10,
                          label: (_avaliacao.comDores[letraChave] ?? 0)
                              .toString(),
                          onChanged: (double esc) {
                            setState(
                              () =>
                                  _avaliacao.comDores[letraChave] = esc.toInt(),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ABA 4: AVALIAÇÃO POSTURAL COMPLETA (Concatenando Lados)
  Widget _buildPosturalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GroupContainer(
            title: 'Vista Anterior',
            children: [
              _buildPosturaDropdown(
                label: '1 - Cabeça',
                valorAtual: _avaliacao.posAnteriorCabeca,
                opces: [
                  "Normal",
                  "Inclinada para a Direita",
                  "Inclinada para a Esquerda",
                  "Rotada para a Direita",
                  "Rotada para a Esquerda",
                ],
                onChanged: (val) =>
                    setState(() => _avaliacao.posAnteriorCabeca = val),
                opcoes: [],
              ),
              _buildPosturaDropdown(
                label: '2 - Ombros',
                valorAtual: _avaliacao.posAnteriorOmbros,
                opces: [
                  "Normal",
                  "Elevado Direito",
                  "Elevado Esquerdo",
                  "Elevados Ambos",
                  "Caídos",
                ],
                onChanged: (val) =>
                    setState(() => _avaliacao.posAnteriorOmbros = val),
                opcoes: [],
              ),
              _buildPosturaDropdown(
                label: '10 - Joelhos',
                valorAtual: _avaliacao.posAnteriorJoelhos,
                opces: [
                  "Normais",
                  "Valgo Direito",
                  "Valgo Esquerdo",
                  "Valgo Ambos",
                  "Varo Direito",
                  "Varo Esquerdo",
                  "Varo Ambos",
                ],
                onChanged: (val) =>
                    setState(() => _avaliacao.posAnteriorJoelhos = val),
                opcoes: [],
              ),
            ],
          ),
          GroupContainer(
            title: 'Plano Sagital - Vista Perfil',
            children: [
              _buildPosturaDropdown(
                label: '12 - Cabeça',
                valorAtual: _avaliacao.posPerfilCabeca,
                opces: ["Normal", "Anteriorizada", "Posteriorizada"],
                onChanged: (val) =>
                    setState(() => _avaliacao.posPerfilCabeca = val),
                opcoes: [],
              ),
              _buildPosturaDropdown(
                label: '13 - Ombros',
                valorAtual: _avaliacao.posPerfilOmbros,
                opces: ["Normais", "Anteriorizados", "Posteriorizados"],
                onChanged: (val) =>
                    setState(() => _avaliacao.posPerfilOmbros = val),
                opcoes: [],
              ),
            ],
          ),
          GroupContainer(
            title: 'Plano Dorsal - Coluna Posterior',
            children: [
              _buildPosturaDropdown(
                label: '20 - Escoliose',
                valorAtual: _avaliacao.posPosteriorEscoliose,
                opces: [
                  "Não apresenta",
                  "Sim - Local: Lombar",
                  "Sim - Local: Torácica",
                  "Sim - Local: Cervical",
                ],
                onChanged: (val) =>
                    setState(() => _avaliacao.posPosteriorEscoliose = val),
                opcoes: [],
              ),
              _buildPosturaDropdown(
                label: '21 - Teste de Flexão / Gibosidade',
                valorAtual: _avaliacao.posPosteriorGibosidade,
                opces: [
                  "Não apresenta Gibosidade",
                  "Apresenta Gibosidade - Local: Lombar",
                  "Apresenta Gibosidade - Local: Torácica",
                ],
                onChanged: (val) =>
                    setState(() => _avaliacao.posPosteriorGibosidade = val),
                opcoes: [],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ABA 5: OBSERVAÇÕES E SALVAMENTO
  Widget _buildRelatorioTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Avaliação do Aluno: ${widget.aluno.nome}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: TextFormField(
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Observações Gerais do Avaliador',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => _avaliacao.obs = val,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: Colors.blue.shade900,
              ),
              onPressed: () {
                final jsonFinal = _avaliacao.toJson();
                print("JSON PRONTO PARA SUBIR PRO SPRING BOOT:");
                print(jsonFinal);
                // Aqui você injeta o seu HTTP Client / Dio para fazer o POST
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Avaliação enviada com sucesso!'),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text(
                'FINALIZAR E SALVAR FICHA',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
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
          title: Text('Avaliando: ${widget.aluno.nome}'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Anamnese'),
              Tab(text: 'Antropométrica'),
              Tab(text: 'Autoavaliação Dor'),
              Tab(text: 'Postural'),
              Tab(text: 'Concluir'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAnamneseTab(),
            _buildAntropometricaTab(),
            _buildTestesFisicosDoresTab(),
            _buildPosturalTab(),
            _buildRelatorioTab(),
          ],
        ),
      ),
    );
  }
}
