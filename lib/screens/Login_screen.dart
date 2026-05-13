import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:prosaude/core/models/login/LoginResponse.dart';
import 'package:prosaude/screens/Dashboard_screen.dart';
import 'package:prosaude/screens/TrocarSenha_screen.dart';
import 'package:prosaude/core/services/auth_service.dart';
import 'package:prosaude/core/services/session_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;



  // No topo do arquivo:
// import '../services/api_service.dart';

  void _handleLogin() async {
    int? uid;

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true); // Opcional: mostrar um loading

      try {
        final api = AuthService();
        final resultado = await api.realizarLogin(
            _emailController.text,
            _passwordController.text
        );

        if (resultado != null) {
          // --- A MUDANÇA ESTÁ AQUI ---
          // Em vez de passar token, nome e perfil separados, passamos o objeto 'resultado' todo
          await SessionManager.saveSession(resultado);

          final sessao = await SessionManager.getSession();
          if (sessao != null) {
            setState(() {
              uid = sessao.id;
            });
          }

          print("Sessão salva para o usuário: ${resultado.nome}");

          if (!mounted) return; // Boa prática para evitar erros de contexto no Navigator

          if (resultado.primeiroAcesso == true) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TrocarSenhaScreen(usuarioId: uid!),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
            );
          }
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Acesso Pro Saúde")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.health_and_safety, size: 80, color: Colors.teal),
                const SizedBox(height: 20),
                const Text(
                  "Bem-vindo ao Pro Saúde",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                // Campo de E-mail
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "E-mail ou Usuário",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Informe o usuário";
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Campo de Senha
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    labelText: "Senha",
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _isObscure = !_isObscure),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ) return "Senha muito curta";
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Botão de Entrar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin, // Desativa o botão enquanto carrega
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("ENTRAR"),
                  ),

                ),

                TextButton(
                  onPressed: () {}, // Lógica de "Esqueci a senha"
                  child: const Text("Esqueceu a senha?"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

