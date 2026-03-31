import 'package:flutter/material.dart';
import 'package:prosaude/services/session_manager.dart'; // Importe seu SessionManager
import 'package:prosaude/screens/home_screen.dart';     // Tela de Login/Home
import 'package:prosaude/screens/dashboard_screen.dart'; // Tela de destino após login

void main() async {
  // 1. Garante que os plugins do Flutter (como SharedPreferences) iniciem corretamente
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Tenta recuperar o token salvo no celular
  String? token = await SessionManager.getToken();

  // 3. Inicia o app passando a informação se está logado ou não
  runApp(ProSaudeApp(isLoggedIn: token != null));
}

class ProSaudeApp extends StatelessWidget {
  final bool isLoggedIn;

  const ProSaudeApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pro Saúde',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),

      // 4. Se estiver logado (token != null), vai direto para o Dashboard.
      // Caso contrário, vai para a tela de Login (HomePage).
      home: isLoggedIn ? const DashboardScreen() : const HomePage(),

      // Defina suas rotas aqui para usar o Navigator.pushReplacementNamed
      routes: {
        '/login': (context) => const HomePage(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}