import 'package:dio/dio.dart';

import '../models/turma/Turma.dart';
import 'session_manager.dart';

class TurmaService {
  // A URL base agora vai até o ProSaude, o resto a gente completa nos métodos 10.0.2.2:8081
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://prosaude-back.onrender.com/ProSaude"));

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
          throw MensagemDeErro(data['mensagem'] ?? "Não é possível excluir esta turma\nRemova Alunos Inscritos e tente novamente.");
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
    // final semestre = '2026/2';

    print("$id");
    print("$semestre");
    final semestreUrl = semestre.replaceAll('/', '-');

    if (perfil == "BOLSISTA") {
      final response = await _dio.get("/turma/minhas-turmas/$id/$semestreUrl");
      return (response.data as List).map((i) => Turma.fromJson(i)).toList();
    }
    if (perfil == "ALUNO") {
      print("entrou");
      final response = await _dio.get("/inscricao/$id/$semestre");
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

  Future<List<Turma>> carregarTurmasPorSemestre(String semestre) async {
    try {
      final semestreUrl = semestre.replaceAll('/', '-');
      final response = await _dio.get("/turma/disponiveis/$semestreUrl");

      // Caso o backend retorne uma lista direta:
      if (response.data is List) {
        return (response.data as List)
            .map((item) => Turma.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      // Caso o backend retorne um Map com uma chave contendo a lista:
      if (response.data is Map<String, dynamic>) {
        final List rawList = response.data['turmas'] ?? response.data['content'] ?? [];
        return rawList
            .map((item) => Turma.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("🚨 Erro na requisição de turmas: $e");
      throw Exception("Erro ao carregar turmas");
    }
  }

  Future<List<dynamic>>? buscarHistoricoBolsista(int id) async {
    try {
      final response = await _dio.get("/turma/historico/$id");
      return response.data; // Retorna a lista de turmas passadas
    } catch (e) {
      throw Exception("Erro ao carregar histórico");
    }
  }

}
class MensagemDeErro extends Error {
  final String mensagem;
  MensagemDeErro(this.mensagem);

  @override
  String toString() => mensagem; // Retorna apenas o texto limpo
}
