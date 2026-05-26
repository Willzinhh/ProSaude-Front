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
    try {
      if (userToSave.id == null) {
        final response = await _dio.post("/usuario", data: userToSave.toJson());
        return response.statusCode == 200 || response.statusCode == 204;
      } else {
        final response = await _dio.put("/usuario", data: userToSave.toJson());
        return response.statusCode == 200 || response.statusCode == 204;
      }
    } catch (e) {
      print("Erro ao salvar: $e");
      return false;
    }
  }

  Future<List<Usuario>> listarEquipe() async {
    final response = await _dio.get(
      "/usuario/equipe",
    );
    return (response.data as List).map((i) => Usuario.fromJson(i)).toList();
  }

  Future<String?> excluirMembro(int id) async {
    try {
      final response = await _dio.delete("/usuario/$id");

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null; // Sucesso absoluto!
      }

      return "Não foi possível excluir o usuário. Verifique os vínculos e tente novamente.";
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return "Este bolsista está vinculado a uma turma ativa. Remova-o da turma antes de excluí-lo.";
      }

      if (e.response != null) {
        return "Erro no servidor (${e.response?.statusCode}). Tente novamente mais tarde.";
      }

      return "Erro de conexão com o servidor. Verifique sua internet.";
    } catch (e) {
      return "Ocorreu um erro inesperado: $e";
    }
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
