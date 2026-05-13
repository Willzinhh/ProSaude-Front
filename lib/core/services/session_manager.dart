import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login/LoginResponse.dart';

class SessionManager {
  static const String _sessionKey = "user_session";

  // Salva o objeto LoginResponse inteiro
  static Future<void> saveSession(LoginResponse data) async {
    final prefs = await SharedPreferences.getInstance();
    // Usa o toJson() que o build_runner criou para você!
    String jsonString = jsonEncode(data.toJson());
    await prefs.setString(_sessionKey, jsonString);
  }

  // Recupera o objeto LoginResponse completo
  static Future<LoginResponse?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_sessionKey);

    if (jsonString != null) {
      // Usa o fromJson() automático para reconstruir o objeto
      return LoginResponse.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  // Atalho para pegar apenas o Token (útil para o Dio)
  static Future<String?> getToken() async {
    final session = await getSession();
    return session?.token;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}