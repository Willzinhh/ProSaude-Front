import 'package:dio/dio.dart';
import 'package:prosaude/core/models/aluno/Aluno.dart';

import '../models/usuario/Usuario.dart';
import 'session_manager.dart';

class AlunoService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8081/ProSaude"));

  AlunoService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await SessionManager.getToken();
            if (token != null && token.isNotEmpty) {
              options.headers["Authorization"] = "Bearer $token";
              // Print temporário para você ver no console se o token REALMENTE foi injetado:
              print("[DIO] Token injetado com sucesso: Bearer $token");
            } else {
              print("[DIO] AVISO: Nenhum token encontrado no SessionManager!");
            }
          } catch (e) {
            print("[DIO] Erro ao buscar token no interceptor: $e");
          }
          return handler.next(options); // Continua a requisição
        },
      ),
    );
  }

  Future<List<Usuario>> getAlunos() async {
    final response = await _dio.get("/usuarios/alunos");
    return (response.data as List)
        .map((data) => Usuario.fromJson(data))
        .toList();
  }


  Future<bool> salvarAluno(Usuario aluno) async {
    if (aluno.id == null) {
      final response = await _dio.post("/usuarios", data: aluno.toJson());
      return response.statusCode == 201;
    } else {
      final response = await _dio.put(
        "/usuarios/${aluno.id}",
        data: aluno.toJson(),
      );
      return response.statusCode == 200;
    }
  }

  Future<bool> excluirAluno(int id) async {
    final response = await _dio.delete("/usuarios/$id");
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<Usuario> getAluno() async { // Removemos o parâmetro (int id)
    try {
      // 🎯 Nova rota limpa que bate direto no perfil do token
      final response = await _dio.get("/usuarios/aluno/perfil");
      print('Dados recebidos com sucesso do Java: ${response.data}');

      return Usuario.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print("Erro definitivo no getAluno: $e");
      rethrow;
    }
  }
}