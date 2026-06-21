import 'package:flutter/material.dart';

import '../core/models/usuario/Usuario.dart';
import '../core/services/equipe_service.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: $e")));
    }
  }

  void _filtrar(String query) {
    setState(() {
      _equipeFiltrada = _equipe
          .where((u) => u.nome.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final coordenadores = _equipeFiltrada.where((u) =>
    u.perfil == "COORDENADOR").toList();
    final bolsistas = _equipeFiltrada
        .where((u) => u.perfil == "BOLSISTA")
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Gerenciar Equipe")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filtrar,
              decoration: InputDecoration(
                labelText: "Buscar membro por nome...",
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

          // CONTEÚDO PRINCIPAL (Loading ou Listas)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _equipeFiltrada.isEmpty
                ? const Center(
              child: Text(
                "Nenhum membro encontrado.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionHeader(
                      "Coordenadores", Icons.admin_panel_settings,
                      Colors.blueGrey, coordenadores.length),
                  if (coordenadores.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("Nenhum coordenador nesta busca.",
                          style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: coordenadores.length,
                      itemBuilder: (context, index) =>
                          _buildMembroCard(coordenadores[index]),
                    ),

                  const SizedBox(height: 15),

                  _buildSectionHeader(
                      "Bolsistas", Icons.school, Colors.teal, bolsistas.length),
                  if (bolsistas.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("Nenhum bolsista nesta busca.",
                          style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: bolsistas.length,
                      itemBuilder: (context, index) =>
                          _buildMembroCard(bolsistas[index]),
                    ),
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

  Widget _buildSectionHeader(String title, IconData icon, Color color,
      int length) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            "$title ($length) ",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: color.withOpacity(0.3), thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildMembroCard(Usuario membro) {
    final bool isCoordenador = membro.perfil == "COORDENADOR";

    // 🎯 REGRA NO FRONT: Verifica se o card que está sendo renderizado é o do próprio usuário logado
    // Substitua 'admin@admin' pela variável onde você armazena o e-mail do usuário logado no App, se houver.
    final bool ehOProprioUsuarioLogado = membro.email == "admin@admin";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCoordenador ? Colors.blueGrey[50] : Colors.teal[50],
          child: Icon(
              isCoordenador ? Icons.admin_panel_settings : Icons.school,
              color: isCoordenador ? Colors.blueGrey : Colors.teal
          ),
        ),
        title: Text("${membro.nome}",
            style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text("${membro.email}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.teal),
              onPressed: () => _abrirFormularioUsuario(membro),
            ),
            IconButton(
              // 🎯 Deixa o ícone cinza se for o próprio usuário logado
              icon: Icon(
                  Icons.delete,
                  color: ehOProprioUsuarioLogado ? Colors.grey.shade400 : Colors.red
              ),
              // 🎯 Bloqueia o clique passando 'null' se ele tentar se autoexcluir
              onPressed: ehOProprioUsuarioLogado
                  ? null
                  : () => _confirmarExclusao(membro),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarExclusao(Usuario u) {
    if (u.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro: ID do usuário inválido.")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red[700],
                  size: 28),
              const SizedBox(width: 10),
              const Text(
                "Excluir Membro?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text.rich(
            TextSpan(
              text: "Tem certeza que deseja remover ",
              style: const TextStyle(fontSize: 15),
              children: [
                TextSpan(
                  text: "${u.nome}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const TextSpan(
                    text: " da equipe?\n\nEsta ação não poderá ser desfeita."),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 8),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              onPressed: () => Navigator.pop(ctx),
              child: const Text("CANCELAR"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                setState(() => _isLoading = true);

                String? erroMensagem = await EquipeService().excluirMembro(
                    u.id!);

                if (erroMensagem == null) {
                  _carregarEquipe();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${u.nome} foi removido com sucesso!"),
                      backgroundColor: Colors.green[700],
                    ),
                  );
                } else {
                  setState(() => _isLoading = false);

                  showDialog(
                    context: context,
                    builder: (context) =>
                        AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.orange,
                                  size: 28),
                              SizedBox(width: 10),
                              Text("Ação Bloqueada", style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                            ],
                          ),
                          content: Text(
                            erroMensagem,
                            // A mensagem explicativa do Service aparece aqui
                            style: const TextStyle(fontSize: 15),
                          ),
                          actions: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal),
                              onPressed: () => Navigator.pop(context),
                              child: const Text("ENTENDI",
                                  style: TextStyle(color: Colors.white)),
                            )
                          ],
                        ),
                  );
                }
              },
              child: const Text(
                  "EXCLUIR", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _abrirFormularioUsuario(Usuario? usuario) {
    final uid = usuario?.id;
    final _formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController(text: usuario?.nome ?? "");
    final emailController = TextEditingController(text: usuario?.email ?? "");
    final bool ehNovoUsuario = (usuario == null);

    String perfilSelecionado = usuario?.perfil ?? "BOLSISTA";

    bool resetarAcesso = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                Text(
                  usuario == null ? "Cadastrar Novo Membro" : "Editar Dados",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  usuario == null || resetarAcesso
                      ? "Senha padrão: bolsista123 (O usuário deverá trocar no 1º acesso)"
                      : "O usuário já possui acesso ativo.",
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),

                const SizedBox(height: 25),

                TextFormField(
                  controller: nomeController,
                  decoration: InputDecoration(
                    labelText: "Nome Completo",
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? "Informe o nome completo" : null,
                ),
                const SizedBox(height: 18),

                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "E-mail de Acesso",
                    prefixIcon: const Icon(Icons.alternate_email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) => v!.contains("@") ? null : "E-mail inválido",
                ),
                const SizedBox(height: 20),

                const Text(
                  "Nível de Acesso:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _perfilOption(
                      label: "BOLSISTA",
                      icon: Icons.school,
                      isSelected: perfilSelecionado == "BOLSISTA",
                      onTap: () =>
                          setModalState(() => perfilSelecionado = "BOLSISTA"),
                    ),
                    const SizedBox(width: 12),
                    _perfilOption(
                      label: "COORDENADOR",
                      icon: Icons.admin_panel_settings,
                      isSelected: perfilSelecionado == "COORDENADOR",
                      onTap: () => setModalState(
                        () => perfilSelecionado = "COORDENADOR",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (usuario != null) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: SwitchListTile(
                      title: const Text(
                        "Forçar Primeiro Acesso?",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: const Text(
                        "Ative se o usuário esqueceu a senha. Reseta para 'bolsista123'",
                        style: TextStyle(fontSize: 12),
                      ),
                      activeColor: Colors.orange,
                      value: resetarAcesso,
                      onChanged: (bool value) {
                        setModalState(() {
                          resetarAcesso = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                // BOTÃO SALVAR
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      Usuario userToSave = Usuario(
                        id: uid,
                        nome: nomeController.text,
                        email: emailController.text,
                        perfil: perfilSelecionado,
                        primeiroAcesso: usuario == null ? true : resetarAcesso,
                        senha: 'bolsista123',
                      );

                      bool sucesso = await EquipeService().salvarMembroEquipe(
                        userToSave,
                      );

                      Navigator.pop(context);

                      _carregarEquipe();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            usuario == null
                                ? "Membro cadastrado!"
                                : "Dados atualizados!",
                          ),
                          backgroundColor: Colors.teal,
                        ),
                      );
                    }
                  },
                  child: Text(
                    usuario == null ? "CADASTRAR MEMBRO" : "SALVAR ALTERAÇÕES",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _perfilOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.teal.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.teal : Colors.grey[300]!,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.teal : Colors.grey),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.teal : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
