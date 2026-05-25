import 'package:dio/dio.dart';
import 'package:prosaude/models/aluno/Aluno.dart';
import 'package:prosaude/services/session_manager.dart';

class InscricaoService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:8081/ProSaude", // Endereço do seu Spring Boot
    ),
  );

  InscricaoService() {
    // Configura o "segurança" que coloca o token em todas as chamadas
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

  Future<void> enviarAutoCadastro(Map<String, dynamic> dados) async {
    print(dados.values);
    try {
      await _dio.post("/inscricao/autocadastro", data: dados);
    } on DioException catch (e) {
      // Repassa a mensagem de erro vinda do seu Service Java
      String mensagem =
          e.response?.data?.toString() ?? "Erro de conexão com o servidor";
      throw Exception(mensagem);
    }
  }

  Future<List<Aluno>> listarInscritos(int turmaId) async {
    try {
      final response = await _dio.get("/inscricao/turma/$turmaId");

      // O erro "toList isn't defined" acontece se o Dart não souber que isso é uma Lista
      final List<dynamic> dados = response.data;
      print(response.data);

      return dados.map((item) => Aluno.fromJson(item)).toList();
    } catch (e) {
      throw Exception("Erro ao buscar inscritos");
      return [];
    }
  }
}
