import 'package:flutter/material.dart';
import 'package:prosaude/core/models/aluno/Aluno.dart';
import 'package:prosaude/core/models/usuario/Usuario.dart';

import '../core/models/avaliacao/Avaliacao.dart';
import '../core/services/avaliacao_service.dart';
import 'GroupContainer.dart';


class AvaliacaoFormScreen extends StatefulWidget {
  final Aluno aluno;

  const AvaliacaoFormScreen({super.key, required this.aluno});

  @override
  State<AvaliacaoFormScreen> createState() => _AvaliacaoFormScreenState();
}

class _AvaliacaoFormScreenState extends State<AvaliacaoFormScreen> {
  final AvaliacaoModel _avaliacao = AvaliacaoModel();

  final TextEditingController _q5jDescricaoCtrl = TextEditingController();
  final TextEditingController _q7RemedioQuaisCtrl = TextEditingController();
  final TextEditingController _q9ComentariosCtrl = TextEditingController();
  final TextEditingController _q10CochilaComentariosCtrl = TextEditingController();
  final TextEditingController _q10CochilaIntencionalComentariosCtrl = TextEditingController();
  final TextEditingController _q10CochilarSignificadoOutroCtrl = TextEditingController();
  final TextEditingController _q10CochilarSignificadoComentariosCtrl = TextEditingController();

  final TextEditingController _escolioseLocalCtrl = TextEditingController();
  final TextEditingController _gibosidadeLocalCtrl = TextEditingController();

  int? _q5a, _q5b, _q5c, _q5d, _q5e, _q5f, _q5g, _q5h, _q5i, _q5jFreq;
  int? _q7Freq, _q8Freq, _q9FaltaEntusiasmo;

  bool _q10Cochila = false;
  bool _q10CochilaIntencional = false;
  String? _q10Significado;

  @override
  void initState() {
    super.initState();
    _avaliacao.dataAvaliacao = DateTime.now();
  }

  @override
  void dispose() {
    _q5jDescricaoCtrl.dispose();
    _q7RemedioQuaisCtrl.dispose();
    _q9ComentariosCtrl.dispose();
    _q10CochilaComentariosCtrl.dispose();
    _q10CochilaIntencionalComentariosCtrl.dispose();
    _q10CochilarSignificadoOutroCtrl.dispose();
    _q10CochilarSignificadoComentariosCtrl.dispose();
    _escolioseLocalCtrl.dispose();
    _gibosidadeLocalCtrl.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    bool isNumber = false,
    TextEditingController? controller,
    String? valorInicial,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? valorInicial : null,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildFrequenciaSono({required String titulo, required int? valorAtual, required Function(int?) onChanged}) {
    final opcoes = [
      "Nenhuma vez",
      "Menos de uma vez por semana",
      "Uma ou duas vezes por semana",
      "Três vezes por semana ou mais"
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          child: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
        const Divider(),
      ],
    );
  }

  Widget _buildPosturaDropdown({required String label, required String? valorAtual, required List<String> opcoes, required Function(String?) onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: valorAtual,
        isExpanded: true,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
        items: opcoes.map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 14)));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

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
      'q5jOutraRazaoDescricao': _q5jDescricaoCtrl.text,
      'q5jOutraRazaoFrequencia': _q5jFreq,
      'q7RemedioFrequencia': _q7Freq,
      'q7RemedioQuais': _q7RemedioQuaisCtrl.text,
      'q8FicarAcordadoAtividades': _q8Freq,
      'q9FaltaEntusiasmo': _q9FaltaEntusiasmo,
      'q9Comentarios': _q9ComentariosCtrl.text,
      'q10Cochila': _q10Cochila,
      'q10CochilaComentarios': _q10CochilaComentariosCtrl.text,
      'q10CochilaIntencional': _q10CochilaIntencional,
      'q10CochilaIntencionalComentarios': _q10CochilaIntencionalComentariosCtrl.text,
      'q10CochilarSignificado': _q10Significado,
      'q10CochilarSignificadoOutro': _q10CochilarSignificadoOutroCtrl.text,
      'q10CochilarSignificadoComentarios': _q10CochilarSignificadoComentariosCtrl.text,
    };
  }


  Widget _buildAnamneseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GroupContainer(
            title: 'Anamnese Geral',
            children: [
              _buildTextField(label: 'Profissão', valorInicial: _avaliacao.anaProfi, onChanged: (val) => _avaliacao.anaProfi = val),
              const SizedBox(height: 12),
              _buildTextField(label: 'Horas de Trabalho Diárias', isNumber: true, valorInicial: _avaliacao.anaHsTrab?.toString(), onChanged: (val) => _avaliacao.anaHsTrab = double.tryParse(val)),
              const SizedBox(height: 12),
              _buildTextField(label: 'Turno de Trabalho', valorInicial: _avaliacao.anaTurnTrab, onChanged: (val) => _avaliacao.anaTurnTrab = val),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text("Fuma?"),
                value: _avaliacao.anaFuma,
                onChanged: (val) => setState(() => _avaliacao.anaFuma = val),
              ),
              if (_avaliacao.anaFuma) ...[
                _buildTextField(label: 'Há quanto tempo fuma?', valorInicial: _avaliacao.anaFumaTempo, onChanged: (val) => _avaliacao.anaFumaTempo = val),
                const SizedBox(height: 12),
              ],
              SwitchListTile(
                title: const Text("Consome Álcool?"),
                value: _avaliacao.anaAlcool,
                onChanged: (val) => setState(() => _avaliacao.anaAlcool = val),
              ),
              DropdownButtonFormField<String>(
                value: _avaliacao.anaAlimentacao,
                decoration: const InputDecoration(labelText: 'Qualidade Geral da Alimentação', border: OutlineInputBorder()),
                items: ["BOA", "REGULAR", "RUIM"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => _avaliacao.anaAlimentacao = val,
              ),
              const SizedBox(height: 12),
              _buildTextField(label: 'Refeições ao Dia', isNumber: true, valorInicial: _avaliacao.anaRefDia?.toString(), onChanged: (val) => _avaliacao.anaRefDia = double.tryParse(val)),
              const SizedBox(height: 12),
              _buildTextField(label: 'Copos de Água ao Dia', isNumber: true, valorInicial: _avaliacao.anaCoposAguaDia?.toString(), onChanged: (val) => _avaliacao.anaCoposAguaDia = double.tryParse(val)),
              const SizedBox(height: 12),
              _buildTextField(label: 'Histórico de Cirurgias', valorInicial: _avaliacao.anaCirurgia, onChanged: (val) => _avaliacao.anaCirurgia = val),
              const SizedBox(height: 12),
              _buildTextField(label: 'Problemas Cardíacos na Família', valorInicial: _avaliacao.anaProbCardiaco, onChanged: (val) => _avaliacao.anaProbCardiaco = val),
            ],
          ),
          GroupContainer(
            title: 'Questionário de Qualidade de Sono (Pittsburgh)',
            children: [
              _buildTextField(label: 'Horas médias de sono por noite', valorInicial: _avaliacao.anaHsSono, onChanged: (val) => _avaliacao.anaHsSono = val),
              const SizedBox(height: 15),
              const Text("5) Durante o mês passado, com que frequência teve problemas para dormir por causa de:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 10),
              _buildFrequenciaSono(titulo: "a) Demorar mais de 30 minutes para pegar no sono", valorAtual: _q5a, onChanged: (val) => setState(() => _q5a = val)),
              _buildFrequenciaSono(titulo: "b) Acordar no meio da noite ou de manhã muito cedo", valorAtual: _q5b, onChanged: (val) => setState(() => _q5b = val)),
              _buildFrequenciaSono(titulo: "c) Levantar-se para ir ao banheiro", valorAtual: _q5c, onChanged: (val) => setState(() => _q5c = val)),
              _buildFrequenciaSono(titulo: "d) Ter dificuldade para respirar", valorAtual: _q5d, onChanged: (val) => setState(() => _q5d = val)),
              _buildFrequenciaSono(titulo: "e) Tossir ou roncar muito alto", valorAtual: _q5e, onChanged: (val) => setState(() => _q5e = val)),
              _buildFrequenciaSono(titulo: "f) Sentir muito frio", valorAtual: _q5f, onChanged: (val) => setState(() => _q5f = val)),
              _buildFrequenciaSono(titulo: "g) Sentir muito calor", valorAtual: _q5g, onChanged: (val) => setState(() => _q5g = val)),
              _buildFrequenciaSono(titulo: "h) Ter sonhos ruins ou pesadelos", valorAtual: _q5h, onChanged: (val) => setState(() => _q5h = val)),
              _buildFrequenciaSono(titulo: "i) Sentir dores", valorAtual: _q5i, onChanged: (val) => setState(() => _q5i = val)),

              const Text("j) Outra razão, por favor descreva:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              _buildTextField(
                  label: 'Descreva a outra razão',
                  controller: _q5jDescricaoCtrl,
                  onChanged: (val) => _salvarDadosSonoMapeados()
              ),
              _buildFrequenciaSono(titulo: "Frequência da outra razão:", valorAtual: _q5jFreq, onChanged: (val) => setState(() => _q5jFreq = val)),

              DropdownButtonFormField<String>(
                value: _avaliacao.anaQualiSono,
                decoration: const InputDecoration(labelText: '6) Como classificaria a qualidade geral do sono?', border: OutlineInputBorder()),
                items: ["Muito boa", "Boa", "Ruim", "Muito ruim"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _avaliacao.anaQualiSono = val),
              ),
              const SizedBox(height: 15),

              _buildFrequenciaSono(titulo: "7) Medicamento p/ dormir (com ou sem receita)?", valorAtual: _q7Freq, onChanged: (val) => setState(() => _q7Freq = val)),
              _buildTextField(
                  label: 'Qual(is) remédios tomou?',
                  controller: _q7RemedioQuaisCtrl,
                  onChanged: (val) => _salvarDadosSonoMapeados()
              ),
              const SizedBox(height: 15),

              _buildFrequenciaSono(titulo: "8) Problemas p/ ficar acordado no trânsito/refeições/atividades?", valorAtual: _q8Freq, onChanged: (val) => setState(() => _q8Freq = val)),

              const Text("9) Indisposição ou falta de entusiasmo para realizar atividades diárias:", style: TextStyle(fontWeight: FontWeight.bold)),
              ...List.generate(4, (index) {
                final labels = ["Nenhuma indisposição", "Pequena indisposição", "Moderada indisposição", "Muita indisposição"];
                return RadioListTile<int>(
                  title: Text(labels[index]),
                  value: index,
                  groupValue: _q9FaltaEntusiasmo,
                  dense: true,
                  onChanged: (val) => setState(() {
                    _q9FaltaEntusiasmo = val;
                    _salvarDadosSonoMapeados();
                  }),
                );
              }),
              _buildTextField(label: 'Comentários da questão 9', controller: _q9ComentariosCtrl, onChanged: (val) => _salvarDadosSonoMapeados()),

              const Divider(),
              SwitchListTile(
                title: const Text("10) Você cochila?"),
                value: _q10Cochila,
                onChanged: (val) => setState(() { _q10Cochila = val; _salvarDadosSonoMapeados(); }),
              ),
              _buildTextField(label: 'Comentários sobre o cochilo', controller: _q10CochilaComentariosCtrl, onChanged: (val) => _salvarDadosSonoMapeados()),

              if (_q10Cochila) ...[
                SwitchListTile(
                  title: const Text("Cochila intencionalmente?"),
                  value: _q10CochilaIntencional,
                  onChanged: (val) => setState(() { _q10CochilaIntencional = val; _salvarDadosSonoMapeados(); }),
                ),
                _buildTextField(label: 'Por que cochila intencionalmente?', controller: _q10CochilaIntencionalComentariosCtrl, onChanged: (val) => _salvarDadosSonoMapeados()),

                const Text("Para você, cochilar é:", style: TextStyle(fontWeight: FontWeight.bold)),
                ...["Um prazer", "Uma necessidade", "Outro"].map((s) => RadioListTile<String>(
                  title: Text(s), value: s, groupValue: _q10Significado,
                  dense: true,
                  onChanged: (val) => setState(() { _q10Significado = val; _salvarDadosSonoMapeados(); }),
                )).toList(),
                if (_q10Significado == "Outro")
                  _buildTextField(label: 'Qual outro significado?', controller: _q10CochilarSignificadoOutroCtrl, onChanged: (val) => _salvarDadosSonoMapeados()),
                _buildTextField(label: 'Comentários gerais do significado', controller: _q10CochilarSignificadoComentariosCtrl, onChanged: (val) => _salvarDadosSonoMapeados()),
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
          GroupContainer(
            title: 'Massa e Estatura',
            children: [
              _buildTextField(label: 'Massa Corporal (kg)', isNumber: true, valorInicial: _avaliacao.antPeso?.toString(), onChanged: (val) => _avaliacao.antPeso = double.tryParse(val)),
              const SizedBox(height: 12),
              _buildTextField(label: 'Estatura (cm)', isNumber: true, valorInicial: _avaliacao.antAltura?.toString(), onChanged: (val) => _avaliacao.antAltura = double.tryParse(val)),
            ],
          ),
          GroupContainer(
            title: 'Perímetros',
            children: [
              _buildTextField(label: 'Cintura (cm)', isNumber: true, valorInicial: _avaliacao.antPeriCintura?.toString(), onChanged: (val) => _avaliacao.antPeriCintura = double.tryParse(val)),
              const SizedBox(height: 12),
              _buildTextField(label: 'Quadril (cm)', isNumber: true, valorInicial: _avaliacao.antPeriQuadril?.toString(), onChanged: (val) => _avaliacao.antPeriQuadril = double.tryParse(val)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoresTab() {
    final regioes = ["A - Cabeça/Pescoço", "B - Ombros", "C - Braços", "D - Coluna Dorsal", "E - Coluna Lombar", "F - Quadril", "G - Joelhos", "H - Pés"];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GroupContainer(
            title: 'Autoavaliação de Dores',
            children: [
              SwitchListTile(
                title: const Text("Está sentindo dores no dia de hoje?"),
                value: _avaliacao.comDorehj,
                onChanged: (val) => setState(() => _avaliacao.comDorehj = val),
              ),
              if (_avaliacao.comDorehj) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("Arraste para selecionar a intensidade de dor (0 a 10):", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ...regioes.map((reg) {
                  String letra = reg.split(" - ")[0];
                  return Row(
                    children: [
                      Expanded(flex: 2, child: Text(reg)),
                      Expanded(
                        flex: 3,
                        child: Slider(
                          value: (_avaliacao.comDores[letra] ?? 0).toDouble(),
                          min: 0, max: 10, divisions: 10,
                          label: (_avaliacao.comDores[letra] ?? 0).toString(),
                          onChanged: (double value) {
                            setState(() => _avaliacao.comDores[letra] = value.toInt());
                          },
                        ),
                      ),
                    ],
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
              _buildPosturaDropdown(
                label: '1 - CABEÇA',
                valorAtual: _avaliacao.posAnteriorCabeca,
                opcoes: ["1 - Normal", "2 - Inclinada para a direita", "3 - Inclinada para a esquerda", "4 - Rotada para a direita", "5 - Rotada para a esquerda"],
                onChanged: (val) => setState(() => _avaliacao.posAnteriorCabeca = val),
              ),
              _buildPosturaDropdown(
                label: '2 - OMBROS',
                valorAtual: _avaliacao.posAnteriorOmbros,
                opcoes: ["1 - Normal", "2 - Elevado direito", "3 - Elevado esquerdo", "4 - Elevados direito e esquerdo", "5 - Caídos"],
                onChanged: (val) => setState(() => _avaliacao.posAnteriorOmbros = val),
              ),
              _buildPosturaDropdown(
                label: '3 - COMPRIMENTO DOS BRAÇOS',
                valorAtual: _avaliacao.posAnteriorCompBracos,
                opcoes: ["1 - Normal", "2 - Mais comprido à Direita (D)", "2 - Mais comprido à Esquerda (E)"],
                onChanged: (val) => setState(() => _avaliacao.posAnteriorCompBracos = val),
              ),
              _buildPosturaDropdown(
                label: '4 - TRIÂNGULO DE TALES',
                valorAtual: _avaliacao.posAnteriorTrianguloTales,
                opcoes: ["1 - Normal", "2 - Maior à Direita (D)", "2 - Maior à Esquerda (E)"],
                onChanged: (val) => setState(() => _avaliacao.posAnteriorTrianguloTales = val),
              ),
              _buildPosturaDropdown(
                label: '5 - TRONCO',
                valorAtual: _avaliacao.posAnteriorTronco,
                opcoes: ["1 - Normal", "2 - Rotação à Direita (D)", "2 - Rotação à Esquerda (E)", "3 - Inclinação à Direita (D)", "3 - Inclinação à Esquerda (E)"],
                onChanged: (val) => setState(() => _avaliacao.posAnteriorTronco = val),
              ),
              _buildPosturaDropdown(
                label: '6 - LINHA MAMILAR',
                valorAtual: _avaliacao.posAnteriorLinhaMamilar,
                opcoes: ["1 - Niveladas", "2 - Desniveladas"],
                onChanged: (val) => setState(() => _avaliacao.posAnteriorLinhaMamilar = val),
              ),
              _buildPosturaDropdown(
                label: '7 - EQUILÍBRIO HORIZONTAL PÉLVICO',
                valorAtual: _avaliacao.posAnteriorEquiHorizPelvico,
                opcoes: ["1 - Niveladas", "2 - Desniveladas"],
                onChanged: (val) => setState(() => _avaliacao.posAnteriorEquiHorizPelvico = val),
              ),
              _buildPosturaDropdown(
                label: '8 - CICATRIZ UMBILICAL',
                valorAtual: _avaliacao.posAnteriorCicatrizUmbilical,
                opcoes: ["1 - Centralizada", "2 - Mais à Direita (D)", "2 - Mais à Esquerda (E)"],
                onChanged: (val) => setState(() => _avaliacao.posAnteriorCicatrizUmbilical = val),
              ),
              _buildPosturaDropdown(
                label: '9 - QUADRIL',
                valorAtual: _avaliacao.posAnteriorQuadrilRod,
                opcoes: ["1 - Normal", "2 - Rodado à Direita (D)", "2 - Rodado à Esquerda (E)"],
                onChanged: (val) => setState(() => _avaliacao.posAnteriorQuadrilRod = val),
              ),
              _buildPosturaDropdown(
                label: '10 - JOELHOS',
                valorAtual: _avaliacao.posAnteriorJoelhos,
                opcoes: ["1 - Normais", "2 - Valgo Direito (D)", "2 - Valgo Esquerdo (E)", "2 - Valgo Ambos", "3 - Varo Direito (D)", "3 - Varo Esquerdo (E)", "3 - Varo Ambos", "4 - Rotação interna", "5 - Rotação externa"],
                onChanged: (val) => setState(() => _avaliacao.posAnteriorJoelhos = val),
              ),
              _buildPosturaDropdown(
                label: '11 - PÉS',
                valorAtual: _avaliacao.posAnteriorPes,
                opcoes: ["1 - Normais", "2 - Plano Direito (D)", "2 - Plano Esquerdo (E)", "2 - Plano Ambos", "3 - Cavo Direito (D)", "3 - Cavo Esquerdo (E)", "3 - Cavo Ambos"],
                onChanged: (val) => setState(() => _avaliacao.posAnteriorPes = val),
              ),
            ],
          ),
          GroupContainer(
            title: 'Plano Sagital - Vista Perfil',
            children: [
              _buildPosturaDropdown(
                label: '12 - CABEÇA',
                valorAtual: _avaliacao.posPerfilCabeca,
                opcoes: ["1 - Normal", "2 - Anteriorizada", "3 - Posteriorizada"],
                onChanged: (val) => setState(() => _avaliacao.posPerfilCabeca = val),
              ),
              _buildPosturaDropdown(
                label: '13 - OMBROS',
                valorAtual: _avaliacao.posPerfilOmbros,
                opcoes: ["1 - Normais", "2 - Anteriorizados", "3 - Posteriorizados"],
                onChanged: (val) => setState(() => _avaliacao.posPerfilOmbros = val),
              ),
              _buildPosturaDropdown(
                label: '14 - MEMBROS SUPERIORES',
                valorAtual: _avaliacao.posPerfilMembrosSuperiores,
                opcoes: ["1 - Antepulsão Direito (D)", "1 - Antepulsão Esquerdo (E)", "1 - Antepulsão Ambos", "2 - Retropulsão Direito (D)", "2 - Retropulsão Esquerdo (E)", "2 - Retropulsão Ambos", "3 - Flexão do cotovelo", "4 - Alinhados"],
                onChanged: (val) => setState(() => _avaliacao.posPerfilMembrosSuperiores = val),
              ),
            ],
          ),
          GroupContainer(
            title: 'Coluna Vertebral',
            children: [
              _buildPosturaDropdown(
                label: '15 - CERVICAL',
                valorAtual: _avaliacao.posColunaCervical,
                opcoes: ["1 - Normal", "2 - Hiperlordose", "3 - Retificação", "4 - Inversão"],
                onChanged: (val) => setState(() => _avaliacao.posColunaCervical = val),
              ),
              _buildPosturaDropdown(
                label: '16 - DORSAL',
                valorAtual: _avaliacao.posColunaDorsal,
                opcoes: ["1 - Normal", "2 - Retificação", "3 - Hipercifose", "4 - Inversão"],
                onChanged: (val) => setState(() => _avaliacao.posColunaDorsal = val),
              ),
              _buildPosturaDropdown(
                label: '17 - LOMBAR',
                valorAtual: _avaliacao.posColunaLombar,
                opcoes: ["1 - Normal", "2 - Retificada", "3 - Hiperlordose", "4 - Inversão"],
                onChanged: (val) => setState(() => _avaliacao.posColunaLombar = val),
              ),
              _buildPosturaDropdown(
                label: '18 - QUADRIL',
                valorAtual: _avaliacao.posColunaQuadril,
                opcoes: ["1 - Normal", "2 - Anteversão", "3 - Retroversão"],
                onChanged: (val) => setState(() => _avaliacao.posColunaQuadril = val),
              ),
              _buildPosturaDropdown(
                label: '19 - JOELHOS',
                valorAtual: _avaliacao.posColunaJoelhos,
                opcoes: ["1 - Normais", "2 - Recurvado Direito (D)", "2 - Recurvado Esquerdo (E)", "2 - Recurvado Ambos", "3 - Semi-flexão Direito (D)", "3 - Semi-flexão Esquerdo (E)", "3 - Semi-flexão Ambos"],
                onChanged: (val) => setState(() => _avaliacao.posColunaJoelhos = val),
              ),
            ],
          ),
          GroupContainer(
            title: 'Plano Dorsal - Vista Posterior Coluna Vertebral',
            children: [
              _buildPosturaDropdown(
                label: '20 - ESCOLIOSE',
                valorAtual: _avaliacao.posPosteriorEscoliose == null ? null : (_avaliacao.posPosteriorEscoliose!.startsWith("Sim") ? "Sim" : "Não"),
                opcoes: ["Não", "Sim"],
                onChanged: (val) {
                  setState(() {
                    if (val == "Não") {
                      _avaliacao.posPosteriorEscoliose = "Não";
                    } else {
                      _avaliacao.posPosteriorEscoliose = "Sim - Local: ${_escolioseLocalCtrl.text}";
                    }
                  });
                },
              ),
              if (_avaliacao.posPosteriorEscoliose != null && _avaliacao.posPosteriorEscoliose!.startsWith("Sim")) ...[
                _buildTextField(
                  label: 'Local da Escoliose:',
                  controller: _escolioseLocalCtrl,
                  onChanged: (val) => setState(() => _avaliacao.posPosteriorEscoliose = "Sim - Local: $val"),
                ),
                const SizedBox(height: 10),
              ],
              _buildPosturaDropdown(
                label: '21 - TESTE DE FLEXÃO ANTERIOR (Gibosidade)',
                valorAtual: _avaliacao.posPosteriorGibosidade == null ? null : (_avaliacao.posPosteriorGibosidade!.startsWith("Apresenta") ? "Apresenta Gibosidade" : "1 - Não apresenta Gibosidade"),
                opcoes: ["1 - Não apresenta Gibosidade", "Apresenta Gibosidade"],
                onChanged: (val) {
                  setState(() {
                    if (val!.contains("Não apresenta")) {
                      _avaliacao.posPosteriorGibosidade = "1 - Não apresenta Gibosidade";
                    } else {
                      _avaliacao.posPosteriorGibosidade = "2 - Apresenta Gibosidade - Local: ${_gibosidadeLocalCtrl.text}";
                    }
                  });
                },
              ),
              if (_avaliacao.posPosteriorGibosidade != null && _avaliacao.posPosteriorGibosidade!.contains("2 - Apresenta")) ...[
                _buildTextField(
                  label: 'Local da Gibosidade:',
                  controller: _gibosidadeLocalCtrl,
                  onChanged: (val) => setState(() => _avaliacao.posPosteriorGibosidade = "2 - Apresenta Gibosidade - Local: $val"),
                ),
                const SizedBox(height: 10),
              ],
              _buildPosturaDropdown(
                label: '22 - TENDÃO DE AQUILES',
                valorAtual: _avaliacao.posPosteriorTendaoAquiles,
                opcoes: ["1 - Normal", "2 - Varo Direito (D)", "2 - Varo Esquerdo (E)", "2 - Varo Ambos", "3 - Valgo Direito (D)", "3 - Valgo Esquerdo (E)", "3 - Valgo Ambos"],
                onChanged: (val) => setState(() => _avaliacao.posPosteriorTendaoAquiles = val),
              ),
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
          Text("Aluno: ${widget.aluno.nome}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: TextFormField(
              initialValue: _avaliacao.obs,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Observações Gerais (Opcional)',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => _avaliacao.obs = val,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: Colors.blue.shade900,
              ),
              onPressed: () async {
                _salvarDadosSonoMapeados();

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );

                const int avaliadorIdLogado = 1;

                bool sucesso = await AvaliacaoService().salvarAvaliacao(
                  avaliacao: _avaliacao,
                  alunoId: widget.aluno.id!,
                  avaliadorId: avaliadorIdLogado,
                );

                Navigator.pop(context);

                if (sucesso) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Avaliação física salva com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Falha ao salvar ficha. Verifique o servidor local.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('FINALIZAR E SALVAR FICHA', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          )
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
              Tab(text: 'Anamnese & Sono'),
              Tab(text: 'Antropometria'),
              Tab(text: 'Autoavaliação Dor'),
              Tab(text: 'Avaliação Postural'),
              Tab(text: 'Concluir'),
            ],
          ),
        ),
        // MODIFICADO: Agora cada método de aba está encapsulado pelo Wrapper de KeepAlive
        body: TabBarView(
          children: [
            AnamneseTabPage(child: _buildAnamneseTab()),
            AntropometriaTabPage(child: _buildAntropometricaTab()),
            DoresTabPage(child: _buildDoresTab()),
            PosturalTabPage(child: _buildPosturalTab()),
            _buildConcluirTab(),
          ],
        ),
      ),
    );
  }
}

// --- CLASSES SUPORTE ADICIONADAS ABAIXO PARA PRESERVAR OS DADOS EM TELA ---

class AnamneseTabPage extends StatefulWidget {
  final Widget child;
  const AnamneseTabPage({super.key, required this.child});
  @override
  State<AnamneseTabPage> createState() => _AnamneseTabPageState();
}
class _AnamneseTabPageState extends State<AnamneseTabPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class AntropometriaTabPage extends StatefulWidget {
  final Widget child;
  const AntropometriaTabPage({super.key, required this.child});
  @override
  State<AntropometriaTabPage> createState() => _AntropometriaTabPageState();
}
class _AntropometriaTabPageState extends State<AntropometriaTabPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class DoresTabPage extends StatefulWidget {
  final Widget child;
  const DoresTabPage({super.key, required this.child});
  @override
  State<DoresTabPage> createState() => _DoresTabPageState();
}
class _DoresTabPageState extends State<DoresTabPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class PosturalTabPage extends StatefulWidget {
  final Widget child;
  const PosturalTabPage({super.key, required this.child});
  @override
  State<PosturalTabPage> createState() => _PosturalTabPageState();
}
class _PosturalTabPageState extends State<PosturalTabPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}