import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../models/atividade/Atividade.dart';
import 'session_manager.dart';

class TurmaService {

  // A URL base agora vai até o ProSaude, o resto a gente completa nos métodos
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8081/ProSaude"));

  TurmaService() {
    // Configura o "segurança" que coloca o token em todas as chamadas
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SessionManager.getToken();
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        return handler.next(options);
      },
    ));
  }

  /// 1. LISTAR (READ)
  Future<List<Atividade>> getAtividades() async {
    final response = await _dio.get("/turma");
    // response.data já é uma lista, não precisa de json.decode
    return (response.data as List).map((data) => Atividade.fromJson(data)).toList();
  }

  // 2. CRIAR (CREATE)
  Future<bool> criarAtividade(Atividade turma) async {
    // Note: Não precisa mais buscar o token aqui, o Interceptor faz isso!
    // E não precisa de jsonEncode, o Dio aceita o .toJson() direto
    final response = await _dio.post("/turma", data: turma.toJson());
    return response.statusCode == 201;
  }

  // 3. EDITAR (UPDATE)
  Future<bool> salvarAtividade(Atividade turma) async {
    final response = await _dio.put("/turma", data: turma.toJson());
    return response.statusCode == 200;
  }

  // 4. EXCLUIR (DELETE)
  Future<bool> excluirAtividade(int id) async {
    final response = await _dio.delete("/turma/$id");
    return response.statusCode == 204 || response.statusCode == 200;
  }
}