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
      final data = e.response?.data;
      // 1. Mudamos de 403 para 401 (Padrão do Spring Security para Bad Credentials)
      if (e.response?.statusCode == 401) {
        // Captura a String "mensagem" vinda do seu record 'DadosErroSimples' do Java
        if (data is Map<String, dynamic>) {
          throw MensagemDeErro(data['mensagem'] ?? "E-mail ou senha incorretos.");
        }
        throw MensagemDeErro("E-mail ou senha incorretos.");
      }

      // 2. Tratamento para o Erro 400 (Campos inválidos / Erro de validação do Spring)
      if (e.response?.statusCode == 400) {
        // Se o Java devolver uma Lista [ ], mapeamos os erros internos
        if (data is List) {
          // Pega a mensagem do primeiro erro de validação da lista
          final primeiroErro = data.first;
          if (primeiroErro is Map<String, dynamic>) {
            throw MensagemDeErro("${primeiroErro['campo']}: ${primeiroErro['mensagem']}");
          }
        }

        if (data is Map<String, dynamic>) {
          throw MensagemDeErro(data['mensagem'] ?? "Dados inválidos.");
        }
        throw MensagemDeErro("Dados de requisição inválidos.");
      }

      // 2. Se o erro for um 403 real (Acesso proibido/permissão de perfil)
      if (e.response?.statusCode == 403) {
        if (data is Map<String, dynamic>) {
          throw MensagemDeErro(data['mensagem'] ?? "Acesso negado.");
        }
        throw MensagemDeErro("Você não tem permissão para acessar este recurso.");
      }
      // Trata erros de timeout ou servidor fora do ar de forma amigável
      throw MensagemDeErro("Não foi possível conectar ao servidor ProSaude.");
    }
  }
}

class MensagemDeErro extends Error {
  final String mensagem;
  MensagemDeErro(this.mensagem);

  @override
  String toString() => mensagem; // Retorna apenas o texto limpo
}
