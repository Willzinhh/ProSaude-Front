import 'package:flutter/material.dart';
import 'package:prosaude/core/models/usuario/Usuario.dart';
import 'package:prosaude/core/services/equipe_service.dart';
import 'package:prosaude/widgets/widgets.dart';

class UsuarioFormDialog extends StatefulWidget {
  final Usuario? usuario;
  final VoidCallback onSuccess;

  const UsuarioFormDialog({
    super.key,
    this.usuario,
    required this.onSuccess,
  });

  @override
  State<UsuarioFormDialog> createState() => _UsuarioFormDialogState();
}

class _UsuarioFormDialogState extends State<UsuarioFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late String _perfilSelecionado;
  late bool _primeiroAcesso; // 🟢 Recuperado

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.usuario?.nome ?? "");
    _emailController = TextEditingController(text: widget.usuario?.email ?? "");
    _perfilSelecionado = widget.usuario?.perfil ?? "BOLSISTA";
    _primeiroAcesso = widget.usuario?.primeiroAcesso ?? true; // Default true para novos
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormModalContainer(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.usuario == null ? "Cadastrar Novo Membro" : "Editar Dados",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: "Nome Completo",
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Informe o nome completo" : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "E-mail de Acesso",
                prefixIcon: Icon(Icons.alternate_email),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.contains("@") ? null : "E-mail inválido",
            ),
            const SizedBox(height: 15),

            // 🟢 Opção de Troca de Senha Recuperada
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: Colors.teal,
              title: const Text(
                "Exigir troca de senha no próximo login",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                "O usuário precisará redefinir a senha ao entrar",
                style: TextStyle(fontSize: 12),
              ),
              value: _primeiroAcesso,
              onChanged: (val) => setState(() => _primeiroAcesso = val),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                PerfilSelectorTile(
                  label: "BOLSISTA",
                  icon: Icons.school,
                  isSelected: _perfilSelecionado == "BOLSISTA",
                  onTap: () => setState(() => _perfilSelecionado = "BOLSISTA"),
                ),
                const SizedBox(width: 12),
                PerfilSelectorTile(
                  label: "COORDENADOR",
                  icon: Icons.admin_panel_settings,
                  isSelected: _perfilSelecionado == "COORDENADOR",
                  onTap: () => setState(() => _perfilSelecionado = "COORDENADOR"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Para edição, não enviamos o campo de senha para não sobrescrevê-lo no banco
                  final usuarioParaSalvar = Usuario(
                    id: widget.usuario?.id,
                    nome: _nomeController.text,
                    email: _emailController.text,
                    perfil: _perfilSelecionado,
                    primeiroAcesso: _primeiroAcesso,
                    // Se for um novo usuário, passa a senha padrão. Se for edição, envia null para a API preservar a senha atual.
                    senha: widget.usuario == null ? 'bolsista123' : null,
                  );

                  await EquipeService().salvarMembroEquipe(usuarioParaSalvar);
                  if (mounted) {
                    Navigator.pop(context);
                    widget.onSuccess();
                  }
                }
              },
              child: Text(
                widget.usuario == null ? "CADASTRAR MEMBRO" : "SALVAR ALTERAÇÕES",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}