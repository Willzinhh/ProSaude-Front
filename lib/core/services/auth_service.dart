import 'package:dio/dio.dart';
import 'package:prosaude/core/services/session_manager.dart';

import '../models/login/LoginResponse.dart';

class AuthService {
  // Configuração base do Dio (Como o RestTemplate do Spring)
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:8081/ProSaude",
      connectTimeout: const Duration(
        seconds: 5,
      ), // Evita que o app trave se o server cair
    ),
  );

  AuthService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Busca o token salvo no SessionManager
          final token = await SessionManager.getToken();
          if (token != null) {
            // Adiciona o Header automaticamente em TODAS as requisições
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<LoginResponse?> realizarLogin(String email, String senha) async {
    try {
      // O Dio já envia como JSON automaticamente se passar um Map
      final response = await _dio.post(
        "/login",
        data: {"email": email, "senha": senha},
      );

      if (response.statusCode == 200) {
        // O segredo está aqui: usamos o fromJson que o build_runner gerou!
        // response.data já é um Map, não precisa de jsonDecode()
        return LoginResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      // O Dio tem tratamento de erro específico para API
      if (e.response?.statusCode == 403) {
        throw Exception("E-mail ou senha incorretos.");
      }
      throw Exception("Erro de conexão: ${e.message}");
    }
  }
}
