import 'package:flutter/material.dart';
import 'package:prosaude/models/atividade/Atividade.dart';
import 'package:prosaude/services/turma_service.dart';
// import '../models/atividade.dart';
// import '../services/atividade_service.dart';

class AtividadeManageScreen extends StatefulWidget {
  const AtividadeManageScreen({super.key});

  @override
  State<AtividadeManageScreen> createState() => _AtividadeManageScreenState();
}

class _AtividadeManageScreenState extends State<AtividadeManageScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _atividades = []; // Lista original da API
  List<dynamic> _atividadesFiltradas = []; // Lista que aparece na tela
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarAtividades();
  }

  Future<void> _carregarAtividades() async {
    setState(() => _isLoading = true);
    try {
      final lista = await TurmaService().getAtividades();
      setState(() {
        _atividades = lista;
        _atividadesFiltradas = lista;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao conectar com o servidor: $e")),
      );
    }
  }

  void _filtrar(String query) {
    setState(() {
      _atividadesFiltradas = _atividades
          .where((at) => at['nome'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gerenciar Atividades")),
      body: Column(
        children: [
          // BARRA DE BUSCA
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filtrar,
              decoration: InputDecoration(
                labelText: "Buscar por nome...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),

          // LISTA DE ATIVIDADES
          Expanded(
            child: ListView.builder(
              itemCount: _atividadesFiltradas.length,
              itemBuilder: (context, index) {
                // Agora o 'item' é uma instância da classe Atividade
                final Atividade item = _atividadesFiltradas[index];

                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.fitness_center, color: Colors.white, size: 20),
                  ),
                  title: Text(
                    item.nome,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Código: ${item.codigo}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Editar Atividade',
                        onPressed: () => _abrirFormulario(item), // Passa o objeto Atividade
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Excluir Atividade',
                        onPressed: () {
                          // Garante que o ID não é nulo antes de tentar excluir
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
      // BOTÃO DE CRIAR NOVA
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: () => _abrirFormulario(),
    //     child: const Icon(Icons.add),
    //   ),
    );
  }

  // Métodos auxiliares para Criar/Editar e Excluir
  void _abrirFormulario(Atividade item) {
    // Se 'item' existe, preenchemos os campos (Edição). Se não, ficam vazios (Criação).
    final nomeController = TextEditingController(text: item?.nome ?? "");
    final codigoController = TextEditingController(text: item?.codigo ?? "");
    final descricaoController = TextEditingController(text: item?.descricao ?? "");
    final _formKeyModal = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Importante para o teclado não cobrir o campo
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // Ajusta o espaço do teclado
          left: 20, right: 20, top: 20,
        ),
        child: Form(
          key: _formKeyModal,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                item == null ? "Nova Atividade" : "Editar Atividade",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: "Nome da Atividade",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                validator: (value) => value!.isEmpty ? "Informe o nome" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: codigoController,
                decoration: const InputDecoration(
                  labelText: "Código da Turma",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.code),
                ),
                validator: (value) => value!.isEmpty ? "Informe o código" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: descricaoController,
                decoration: const InputDecoration(
                  labelText: "Descrição da Atividade",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                validator: (value) => value!.isEmpty ? "Informe a Descrição" : null,
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () async {
                  if (_formKeyModal.currentState!.validate()) { // Valida antes de salvar
                    Atividade atv = Atividade(
                      id: item.id,
                      nome: nomeController.text,
                      codigo: codigoController.text,
                      descricao: descricaoController.text,
                    );

                    // 1. Chama o serviço e espera terminar (await)
                    bool sucesso = await TurmaService().salvarAtividade(atv);

                    if (sucesso) {
                      // 2. Fecha o Modal
                      Navigator.pop(context);

                      // 3. Recarrega a lista do banco (Isso atualiza a tela automaticamente)
                      _carregarAtividades();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Salvo com sucesso!"), backgroundColor: Colors.green),
                      );
                    }
                  }
                },

                child: Text(
                  item == null ? "CADASTRAR" : "SALVAR ALTERAÇÕES",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmarExclusao(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir Turma?"),
        content: const Text("Isso removerá a atividade permanentemente."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final service = TurmaService();
              // O token deve vir do seu Provider ou SharedPreferences
              bool sucesso = await service.excluirAtividade(id);

              if (sucesso) {
                Navigator.pop(ctx);
                _carregarAtividades(); // Recarrega a lista
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