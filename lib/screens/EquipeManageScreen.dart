import 'package:flutter/material.dart';
import '../models/usuario/Usuario.dart';
import '../services/equipe_service.dart';

class EquipeManageScreen extends StatefulWidget {
  const EquipeManageScreen({super.key});

  @override
  State<EquipeManageScreen> createState() => _EquipeManageScreenState();
}

class _EquipeManageScreenState extends State<EquipeManageScreen> {
  List<Usuario> _equipe = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarEquipe();
  }

  Future<void> _carregarEquipe() async {
    setState(() => _isLoading = true);
    try {
      final lista = await EquipeService().listarEquipe();
      setState(() {
        _equipe = lista;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gerenciar Equipe")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _equipe.length,
        itemBuilder: (context, index) {
          final membro = _equipe[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text("${membro.nome}"),
              subtitle: Text("${membro.email} • ${membro.perfil}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmarExclusao(membro),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormularioNovoBolsista(),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  // Use a mesma lógica do Modal que corrigimos antes!
  void _confirmarExclusao(Usuario u) {
    // ... showDialog chamando EquipeService().excluirMembro(u.id)
    // Depois do sucesso: Navigator.pop(context) e _carregarEquipe()
  }

  void _abrirFormularioNovoBolsista() {
    // Aqui você abre o Modal para cadastrar um novo email/senha no Spring
  }
}