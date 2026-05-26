import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/login/LoginResponse.dart';

class SessionManager {
  static const String _sessionKey = "user_session";

  static Future<void> saveSession(LoginResponse data) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(data.toJson());
    await prefs.setString(_sessionKey, jsonString);
  }

  static Future<LoginResponse?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_sessionKey);

    if (jsonString != null) {
      return LoginResponse.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  static Future<String?> getToken() async {
    final session = await getSession();
    return session?.token;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
