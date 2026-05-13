import 'package:flutter/material.dart';
import 'package:prosaude/app_widget.dart';
import 'package:prosaude/core/services/session_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Tenta recuperar o token salvo no celular
  final token = await SessionManager.getToken();

  final bool Logado = token != null && token.isNotEmpty;

  runApp(MyApp(isLoggedIn: Logado,));
}
