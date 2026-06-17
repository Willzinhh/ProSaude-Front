import 'package:dio/dio.dart';

import '../models/turma/Turma.dart';
import 'session_manager.dart';

class TurmaService {
  // A URL base agora vai até o ProSaude, o resto a gente completa nos métodos
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8081/ProSaude"));

  TurmaService() {
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

  Future<List<Turma>> getTurmas() async {
    final response = await _dio.get("/turma");
    return (response.data as List).map((data) => Turma.fromJson(data)).toList();
  }

  Future<bool> criarTurma(Turma turma) async {
    final response = await _dio.post("/turma", data: turma.toJson());
    return response.statusCode == 201;
  }

  Future<bool> salvarTurma(Turma turma) async {
    final response = await _dio.put("/turma", data: turma.toJson());
    return response.statusCode == 200;
  }

  Future<void> excluirTurma(int id) async {
    try {
      await _dio.delete("/turma/$id");
    } on DioException catch (e) {
      final data = e.response?.data;

      // Se houver conflito de integridade no banco (Status 409)
      if (e.response?.statusCode == 409) {
        if (data is Map<String, dynamic>) {
          throw MensagemDeErro(data['mensagem'] ?? "Não é possível excluir esta turma.");
        }
      }
      throw MensagemDeErro("Erro ao tentar excluir a turma.");
    }
  }

  Future<List<Turma>> carregarTurmasDashboard() async {
    final session = await SessionManager.getSession();
    final perfil = session?.perfil;
    final id = session?.id;
    final semestre = _gerarSemestreAtual();
    print("$id");
    print("$semestre");

    if (perfil == "BOLSISTA") {
      final response = await _dio.get("/turma/minhas-turmas/$id");
      return (response.data as List).map((i) => Turma.fromJson(i)).toList();
    }
    if (perfil == "ALUNO") {
      print("entrou");
      final response = await _dio.get("/inscricao/$id/$semestre");
      print("erro aqui");
      return (response.data as List).map((i) => Turma.fromJson(i)).toList();
    } else {
      // Coordenador vê tudo
      final response = await _dio.get("/turma");
      return (response.data as List).map((i) => Turma.fromJson(i)).toList();
    }
  }

  String _gerarSemestreAtual() {
    final agora = DateTime.now();
    final ano = agora.year;
    final semestre = agora.month <= 6 ? 1 : 2;

    return "$ano/$semestre";
  }
}
class MensagemDeErro extends Error {
  final String mensagem;
  MensagemDeErro(this.mensagem);

  @override
  String toString() => mensagem; // Retorna apenas o texto limpo
}
