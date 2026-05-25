import 'package:dio/dio.dart';

import '../models/usuario/Usuario.dart';
import 'session_manager.dart';

class EquipeService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8081/ProSaude"));

  EquipeService() {
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

  Future<bool> criarMembroEquipe() async {
    final response = await _dio.post("/usuario");
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> salvarMembroEquipe(Usuario userToSave) async {
    final response = await _dio.put("/usuario", data: userToSave.toJson());
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<List<Usuario>> listarEquipe() async {
    final response = await _dio.get(
      "/usuario/equipe",
    ); // Ajuste a rota do seu Spring
    return (response.data as List).map((i) => Usuario.fromJson(i)).toList();
  }

  Future<bool> excluirMembro(int id) async {
    final response = await _dio.delete("/usuario/$id");
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> atualizarSenhaPrimeiroAcesso(int usuarioId, String text) async {
    try {
      final response = await _dio.put(
        "/usuario/$usuarioId",
        data: {"senha": text},
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      print("Erro ao atualizar senha: ${e.message}");
      return false;
    }
  }
}
