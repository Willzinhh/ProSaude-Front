import 'package:dio/dio.dart';

import '../models/usuario/Usuario.dart';
import 'session_manager.dart';

class AlunoService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8081/ProSaude"));

  AlunoService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SessionManager.getToken();
          options.headers["Authorization"] = "Bearer $token";
          return handler.next(options);
        },
      ),
    );
  }

  // Busca apenas quem é ALUNO (Crie esse endpoint no Spring depois)
  Future<List<Usuario>> getAlunos() async {
    final response = await _dio.get("/usuarios/alunos");
    return (response.data as List)
        .map((data) => Usuario.fromJson(data))
        .toList();
  }

  Future<bool> salvarAluno(Usuario aluno) async {
    if (aluno.id == null) {
      // Criar novo
      final response = await _dio.post("/usuarios", data: aluno.toJson());
      return response.statusCode == 201;
    } else {
      // Editar existente
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
}
