import 'package:flutter/material.dart';
import 'package:prosaude/core/models/aluno/Aluno.dart';
import 'package:prosaude/core/services/inscricao_service.dart';
import 'AvaliacaoFormScreen.dart';

class ListaInscritosScreen extends StatefulWidget {
  final int turmaId;
  final String nomeTurma;

  const ListaInscritosScreen(
      {super.key, required this.turmaId, required this.nomeTurma});

  @override
  State<ListaInscritosScreen> createState() => _ListaInscritosScreenState();
}

class _ListaInscritosScreenState extends State<ListaInscritosScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Aluno> _inscritosOriginal = [];
  List<Aluno> _inscritosFiltrados = [];
  bool _isLoading = true;
  String _erroMensagem = "";

  @override
  void initState() {
    super.initState();
    _carregarInscritos();
  }

  Future<void> _carregarInscritos() async {
    setState(() {
      _isLoading = true;
      _erroMensagem = "";
    });

    try {
      final lista = await InscricaoService().listarInscritos(widget.turmaId);
      setState(() {
        _inscritosOriginal = lista.cast<Aluno>();
        _inscritosFiltrados = lista.cast<Aluno>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _erroMensagem = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filtrar(String query) {
    setState(() {
      _inscritosFiltrados = _inscritosOriginal
          .where((aluno) =>
          aluno.nome.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inscritos: ${widget.nomeTurma}")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filtrar,
              decoration: InputDecoration(
                labelText: "Buscar aluno por nome...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filtrar("");
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _erroMensagem.isNotEmpty
                ? Center(child: Text("Erro: $_erroMensagem"))
                : _inscritosFiltrados.isEmpty
                ? const Center(
              child: Text(
                "Nenhum aluno encontrado.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _inscritosFiltrados.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final aluno = _inscritosFiltrados[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade800,
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    aluno.nome,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Tel: ${aluno.telefone}\nEmergência: ${aluno
                        .telefoneEmergencia}",
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.assignment_add,
                      color: Colors.teal,
                      size: 28,
                    ),
                    tooltip: 'Iniciar Avaliação Física',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AvaliacaoFormScreen(aluno: aluno),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}