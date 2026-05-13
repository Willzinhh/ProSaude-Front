import 'package:flutter/material.dart';
import 'package:prosaude/screens/Dashboard_screen.dart';
import 'package:prosaude/screens/Home_screen.dart';

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

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
