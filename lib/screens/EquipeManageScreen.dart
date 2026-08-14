import 'package:flutter/material.dart';
import 'package:prosaude/core/models/usuario/Usuario.dart';
import 'package:prosaude/core/services/equipe_service.dart';
import 'package:prosaude/widgets/widgets.dart';

class EquipeManageScreen extends StatefulWidget {
  const EquipeManageScreen({super.key});

  @override
  State<EquipeManageScreen> createState() => _EquipeManageScreenState();
}

class _EquipeManageScreenState extends State<EquipeManageScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Usuario> _equipe = [];
  List<Usuario> _equipeFiltrada = [];
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
        _equipeFiltrada = lista;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    }
  }

  void _filtrar(String query) {
    setState(() {
      _equipeFiltrada = _equipe
          .where((u) => u.nome.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _confirmarExclusao(Usuario u) {
    if (u.id == null) return;
    showDialog(
      context: context,
      builder: (ctx) => ConfirmActionDialog(
        title: "Excluir Membro?",
        message: "Tem certeza que deseja remover ${u.nome} da equipe?\n\nEsta ação não poderá ser desfeita.",
        onConfirm: () async {
          setState(() => _isLoading = true);
          String? erroMensagem = await EquipeService().excluirMembro(u.id!);
          if (erroMensagem == null) {
            _carregarEquipe();
          } else {
            setState(() => _isLoading = false);
            _exibirAcaoBloqueadaDialog(erroMensagem);
          }
        },
      ),
    );
  }

  void _exibirAcaoBloqueadaDialog(String erroMensagem) {
    showDialog(
      context: context,
      builder: (context) => FeedbackDialog(
        titulo: "Ação Bloqueada",
        mensagem: erroMensagem,
        isErro: true,
      ),
    );
  }

  void _abrirFormularioUsuario(Usuario? usuario) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => UsuarioFormDialog(
        usuario: usuario,
        onSuccess: _carregarEquipe,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coordenadores = _equipeFiltrada.where((u) => u.perfil == "COORDENADOR").toList();
    final bolsistas = _equipeFiltrada.where((u) => u.perfil == "BOLSISTA").toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Gerenciar Equipe")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SearchInputField(
              controller: _searchController,
              label: "Buscar membro por nome...",
              onChanged: _filtrar,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _equipeFiltrada.isEmpty
                ? const Center(
              child: Text("Nenhum membro encontrado.", style: TextStyle(color: Colors.grey, fontSize: 16)),
            )
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(
                    title: "Coordenadores",
                    icon: Icons.admin_panel_settings,
                    color: Colors.blueGrey,
                    count: coordenadores.length,
                  ),
                  ...coordenadores.map((membro) => MembroCard(
                    membro: membro,
                    onEdit: () => _abrirFormularioUsuario(membro),
                    onDelete: membro.email == "admin@admin" ? null : () => _confirmarExclusao(membro),
                  )),
                  const SizedBox(height: 15),
                  SectionHeader(
                    title: "Bolsistas",
                    icon: Icons.school,
                    color: Colors.teal,
                    count: bolsistas.length,
                  ),
                  ...bolsistas.map((membro) => MembroCard(
                    membro: membro,
                    onEdit: () => _abrirFormularioUsuario(membro),
                    onDelete: () => _confirmarExclusao(membro),
                  )),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormularioUsuario(null),
        child: const Icon(Icons.person_add),
      ),
    );
  }
}