import 'package:flutter/material.dart';
import 'package:prosaude/services/equipe_service.dart'; // Supondo que o método esteja aqui

class TrocarSenhaScreen extends StatefulWidget {
  final int usuarioId;
  const TrocarSenhaScreen({super.key, required this.usuarioId});

  @override
  State<TrocarSenhaScreen> createState() => _TrocarSenhaScreenState();
}

class _TrocarSenhaScreenState extends State<TrocarSenhaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _novaSenhaController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _isLoading = false;

  void _enviarNovaSenha() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Você deve criar esse método no seu Service
        // Ele deve dar um PUT no Java enviando a nova senha e
        // o Java deve mudar o campo primeiroAcesso para false no DB.
        bool sucesso = await EquipeService().atualizarSenhaPrimeiroAcesso(
            widget.usuarioId,
            _novaSenhaController.text
        );

        if (sucesso && mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Senha atualizada com sucesso!")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao atualizar: $e"), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Definir Nova Senha"),
        automaticallyImplyLeading: false, // Remove botão de voltar
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 60, color: Colors.orange),
              const SizedBox(height: 20),
              const Text(
                "Este é seu primeiro acesso!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text("Para sua segurança, escolha uma senha pessoal."),
              const SizedBox(height: 30),
              TextFormField(
                controller: _novaSenhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Nova Senha", border: OutlineInputBorder()),
                validator: (v) => v!.length < 6 ? "Mínimo 6 caracteres" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _confirmarController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Confirmar Senha", border: OutlineInputBorder()),
                validator: (v) => v != _novaSenhaController.text ? "As senhas não coincidem" : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _enviarNovaSenha,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("ATUALIZAR E ENTRAR", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}