import 'package:flutter/material.dart';
import 'package:prosaude/main.dart';
import 'package:prosaude/screens/home_screen.dart';

void main() {
  runApp(const ProSaudeApp());
}

class ProSaudeApp extends StatelessWidget {
  const ProSaudeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal, // Cor temática de saúde
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
