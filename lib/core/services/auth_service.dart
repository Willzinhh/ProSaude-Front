import 'package:dio/dio.dart';
import 'package:prosaude/core/services/session_manager.dart';

import '../models/login/LoginResponse.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:8081/ProSaude",
      connectTimeout: const Duration(
        seconds: 5,
      ),
    ),
  );

  AuthService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SessionManager.getToken();
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<LoginResponse?> realizarLogin(String email, String senha) async {
    try {
      final response = await _dio.post(
        "/login",
        data: {"email": email, "senha": senha},
      );

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception("E-mail ou senha incorretos.");
      }
      throw Exception("Erro de conexão: ${e.message}");
    }
  }
}
