import 'package:flutter/material.dart';
import '../core/models/usuario/Usuario.dart';
import '../core/services/equipe_service.dart';

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
        onPressed: () => _abrirFormularioUsuario(null),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  // Use a mesma lógica do Modal que corrigimos antes!
  void _confirmarExclusao(Usuario u) {
    // ... showDialog chamando EquipeService().excluirMembro(u.id)
    // Depois do sucesso: Navigator.pop(context) e _carregarEquipe()
  }

  void _abrirFormularioUsuario(Usuario? usuario) {
    final _formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController(text: usuario?.nome ?? "");
    final emailController = TextEditingController(text: usuario?.email ?? "");
    final bool ehNovoUsuario = (usuario == null);

    // Estado inicial do perfil
    String perfilSelecionado = usuario?.perfil ?? "BOLSISTA";

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
            left: 24, right: 24, top: 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Indicador visual de "puxar" o modal
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                Text(
                  usuario == null ? "Cadastrar Novo Membro" : "Editar Dados",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (usuario == null)
                  const Text(
                    "Senha padrão: bolsista123 (O usuário deverá trocar no 1º acesso)",
                    style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),

                const SizedBox(height: 25),

                // CAMPO NOME
                TextFormField(
                  controller: nomeController,
                  decoration: InputDecoration(
                    labelText: "Nome Completo",
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v!.isEmpty ? "Informe o nome completo" : null,
                ),
                const SizedBox(height: 18),

                // CAMPO EMAIL
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "E-mail de Acesso",
                    prefixIcon: const Icon(Icons.alternate_email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v!.contains("@") ? null : "E-mail inválido",
                ),
                const SizedBox(height: 20),

                // SELEÇÃO DE PERFIL (Chips ou Radio)
                const Text("Nível de Acesso:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _perfilOption(
                      label: "BOLSISTA",
                      icon: Icons.school,
                      isSelected: perfilSelecionado == "BOLSISTA",
                      onTap: () => setModalState(() => perfilSelecionado = "BOLSISTA"),
                    ),
                    const SizedBox(width: 12),
                    _perfilOption(
                      label: "COORDENADOR",
                      icon: Icons.admin_panel_settings,
                      isSelected: perfilSelecionado == "COORDENADOR",
                      onTap: () => setModalState(() => perfilSelecionado = "COORDENADOR"),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // BOTÃO SALVAR
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {

                      // Criamos o objeto Usuario com a senha padrão se for NOVO
                      Usuario userToSave = Usuario(
                        nome: nomeController.text,
                        email: emailController.text,
                        perfil: perfilSelecionado,
                        // Se for novo, manda a senha padrão. Se for edição, mantém a do banco.
                        senha: 'bolsista123',
                      );

                      // AQUI VOCÊ CHAMA SEU SERVICE
                      bool sucesso = await EquipeService().salvarMembroEquipe(userToSave);

                      Navigator.pop(context);

                      _carregarEquipe();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(usuario == null ? "Membro cadastrado!" : "Dados atualizados!"),
                          backgroundColor: Colors.teal,
                        ),
                      );
                    }
                  },
                  child: Text(
                    usuario == null ? "CADASTRAR MEMBRO" : "SALVAR ALTERAÇÕES",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

// Widget auxiliar para as opções de perfil ficarem bonitas
  Widget _perfilOption({required String label, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.teal.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? Colors.teal : Colors.grey[300]!),
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
                      color: isSelected ? Colors.teal : Colors.grey[600]
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}