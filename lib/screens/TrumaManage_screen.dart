import 'package:flutter/material.dart';
import 'package:prosaude/core/models/turma/Turma.dart';
import 'package:prosaude/core/models/usuario/Usuario.dart';
import 'package:prosaude/core/services/equipe_service.dart';
import 'package:prosaude/core/services/turma_service.dart';

class TurmaManageScreen extends StatefulWidget {
  const TurmaManageScreen({super.key});

  @override
  State<TurmaManageScreen> createState() => _TurmaManageScreenState();
}

class _TurmaManageScreenState extends State<TurmaManageScreen> {
  final TextEditingController _searchController = TextEditingController();
  final novaTurma = Turma(
    nome: 'nome',
    descricao: 'descrição',
    horaInicio: '12:30',
    horaFim: '12:30',
    vagas: 20);
  List<dynamic> _turmas = [];
  List<dynamic> _turmasFiltradas = [];
  bool _isLoading = true;

  List<String> _diasSelecionados = [];
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFim;

  final List<String> _todosDias = [
    "SEGUNDA",
    "TERCA",
    "QUARTA",
    "QUINTA",
    "SEXTA",
    "SABADO",
    "DOMINGO",
  ];

  List<Usuario> _apenasBolsistas = [];

  int? _idBolsistaSelecionado;

  bool _carregandoEquipe = true;

  @override
  void initState() {
    super.initState();
    _carregarTurmas();
    _carregarEquipe();
  }

  Future<void> _carregarTurmas() async {
    setState(() => _isLoading = true);
    try {
      final lista = await TurmaService().getTurmas();
      setState(() {
        _turmas = lista;
        _turmasFiltradas = lista;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao conectar com o servidor: $e")),
      );
    }
  }

  Future<void> _carregarEquipe() async {
    try {
      final listaCompleta = await EquipeService().listarEquipe();
      print("passou aqui");

      setState(() {
        _apenasBolsistas = listaCompleta
            .where((u) => u.perfil == "BOLSISTA")
            .toList();
      });

      print("Bolsistas encontrados: ${_apenasBolsistas.length}");
    } catch (e) {
      setState(() => _carregandoEquipe = false);
      print("Erro ao carregar: $e");
    }
  }

  void _filtrar(String query) {
    setState(() {
      _turmasFiltradas = _turmas
          .where((at) => at.nome.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gerenciar Turmas")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filtrar,
              decoration: InputDecoration(
                labelText: "Buscar por nome...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: _turmasFiltradas.length,
              itemBuilder: (context, index) {
                final Turma item = _turmasFiltradas[index];

                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(
                      Icons.fitness_center,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    item.nome,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Editar Turma',
                        onPressed: () =>
                            _abrirFormulario(item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Excluir Turma',
                        onPressed: () {
                          if (item.id != null) {
                            _confirmarExclusao(item.id!);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _abrirFormulario(Turma? item) {
    final nomeController = TextEditingController(text: item?.nome ?? "");
    final descricaoController = TextEditingController(
      text: item?.descricao ?? "",
    );
    final inscritosController = TextEditingController(
      text: item?.vagas != null ? item!.vagas.toString() : "",
    );

    if (item != null && item.id != null) {
      _idBolsistaSelecionado = item.bolsista_responsavel?.id;
      _diasSelecionados = [];

      if (item.aulaSegunda == true) _diasSelecionados.add("SEGUNDA");
      if (item.aulaTerca == true) _diasSelecionados.add("TERCA");
      if (item.aulaQuarta == true) _diasSelecionados.add("QUARTA");
      if (item.aulaQuinta == true) _diasSelecionados.add("QUINTA");
      if (item.aulaSexta == true) _diasSelecionados.add("SEXTA");
      if (item.aulaSabado == true) _diasSelecionados.add("SABADO");
      if (item.aulaDomingo == true) _diasSelecionados.add("DOMINGO");

      if (item.horaInicio.isNotEmpty) {
        final partes = item.horaInicio.split(':');
        _horaInicio = TimeOfDay(
          hour: int.parse(partes[0]),
          minute: int.parse(partes[1]),
        );
      }
      if (item.horaFim.isNotEmpty) {
        final partes = item.horaFim.split(':');
        _horaFim = TimeOfDay(
          hour: int.parse(partes[0]),
          minute: int.parse(partes[1]),
        );
      }
    } else {
      _idBolsistaSelecionado = null;
      _diasSelecionados = [];
      _horaInicio = null;
      _horaFim = null;
    }

    final _formKeyModal = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Builder(
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(
                    context,
                  )
                      .viewInsets
                      .bottom,
                  left: 20,
                  right: 20,
                  top: 20,
                ),
                child: Form(
                  key: _formKeyModal,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        item == null ? "Nova Turma" : "Editar Turma",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: nomeController,
                        decoration: const InputDecoration(
                          labelText: "Nome da Turma",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.fitness_center),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Informe o nome" : null,
                      ),
                      const SizedBox(height: 15),

                      TextFormField(
                        controller: descricaoController,
                        decoration: const InputDecoration(
                          labelText: "Descrição da Turma",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.fitness_center),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Informe a Descrição" : null,
                      ),
                      const SizedBox(height: 15),

                      TextFormField(
                        controller: inscritosController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Quantidade Máxima de Inscritos",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.group),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Informe a quantidade limite de alunos";
                          }
                          if (int.tryParse(value) == null ||
                              int.parse(value) <= 0) {
                            return "Insira um número válido maior que 0";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<int>(
                        value:
                            _apenasBolsistas.any(
                              (b) => b.id == _idBolsistaSelecionado,
                            )
                            ? _idBolsistaSelecionado
                            : null,
                        decoration: const InputDecoration(
                          labelText: "Selecionar Bolsista",
                          prefixIcon: Icon(Icons.school),
                          border: OutlineInputBorder(),
                        ),
                        items: _apenasBolsistas
                            .map(
                              (b) => DropdownMenuItem(
                                value: b.id,
                                child: Text(b.nome),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setModalState(() => _idBolsistaSelecionado = val),
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.access_time),
                              label: Text(
                                _horaInicio == null
                                    ? "Início"
                                    : _horaInicio!.format(context),
                              ),
                              onPressed: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _horaInicio ?? TimeOfDay.now(),
                                  helpText: "SELECIONE O HORÁRIO DE INÍCIO",
                                  confirmText: "DEFINIR",
                                  cancelText: "VOLTAR",
                                  initialEntryMode: TimePickerEntryMode.input,
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Colors.teal,
                                          onSurface:
                                          Colors.black,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (time != null)
                                  setModalState(() => _horaInicio = time);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.timer_off),
                              label: Text(
                                _horaFim == null
                                    ? "Fim"
                                    : _horaFim!.format(context),
                              ),
                              onPressed: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _horaFim ?? TimeOfDay.now(),
                                  helpText: "SELECIONE O HORÁRIO DE FIM",
                                  confirmText: "DEFINIR",
                                  cancelText: "VOLTAR",
                                  initialEntryMode: TimePickerEntryMode.input,
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Colors.teal,
                                          onSurface:
                                          Colors.black,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (time != null)
                                  setModalState(() => _horaFim = time);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      const Text(
                        "Dias da Semana:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        spacing: 8,
                        children: _todosDias.map((dia) {
                          final selecionado = _diasSelecionados.contains(dia);
                          return FilterChip(
                            label: Text(dia.substring(0, 3)),
                            selected: selecionado,
                            onSelected: (bool value) {
                              setModalState(() {
                                if (value) {
                                  _diasSelecionados.add(dia);
                                } else {
                                  _diasSelecionados.remove(dia);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () async {
                          if (_formKeyModal.currentState!.validate()) {
                            if (_horaInicio == null ||
                                _horaFim == null ||
                                _idBolsistaSelecionado == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Preencha horários e selecione um bolsista!",
                                  ),
                                ),
                              );
                              return;
                            }

                            Usuario bolsistaEscolhido = _apenasBolsistas
                                .firstWhere(
                                  (b) => b.id == _idBolsistaSelecionado,
                                );

                            String formatTime(TimeOfDay t) =>
                                "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00";

                            Turma atv = Turma(
                              id: item?.id,
                              nome: nomeController.text,
                              descricao: descricaoController.text,
                              vagas: int.parse(inscritosController.text),
                              bolsista_responsavel: bolsistaEscolhido,
                              horaInicio: formatTime(_horaInicio!),
                              horaFim: formatTime(_horaFim!),
                              aulaSegunda: _diasSelecionados.contains(
                                "SEGUNDA",
                              ),
                              aulaTerca: _diasSelecionados.contains("TERCA"),
                              aulaQuarta: _diasSelecionados.contains("QUARTA"),
                              aulaQuinta: _diasSelecionados.contains("QUINTA"),
                              aulaSexta: _diasSelecionados.contains("SEXTA"),
                              aulaSabado: _diasSelecionados.contains("SABADO"),
                              aulaDomingo: _diasSelecionados.contains(
                                "DOMINGO",
                              ),
                            );

                            bool sucesso = await TurmaService().salvarTurma(
                              atv,
                            );

                            if (sucesso) {
                              Navigator.pop(context);

                              _carregarTurmas();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Salvo com sucesso!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        },

                        child: Text(
                          item == null ? "CADASTRAR" : "SALVAR ALTERAÇÕES",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmarExclusao(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir Turma?"),
        content: const Text("Isso removerá a turma permanentemente."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final service = TurmaService();
              bool sucesso = await service.excluirTurma(id);

              if (sucesso) {
                Navigator.pop(ctx);
                _carregarTurmas();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Excluído com sucesso!")),
                );
              }
            },
            child: const Text("Excluir"),
          ),
        ],
      ),
    );
  }
}
