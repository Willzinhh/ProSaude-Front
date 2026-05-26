import 'package:dio/dio.dart';
import 'package:prosaude/core/models/aluno/Aluno.dart';
import 'package:prosaude/core/models/usuario/Usuario.dart';
import 'package:prosaude/core/services/session_manager.dart';

class InscricaoService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:8081/ProSaude",
    ),
  );

  InscricaoService() {
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
      String mensagem =
          e.response?.data?.toString() ?? "Erro de conexão com o servidor";
      throw Exception(mensagem);
    }
  }

  Future<List<Aluno>> listarInscritos(int turmaId) async {
    try {
      final response = await _dio.get("/inscricao/turma/$turmaId");

      final List<dynamic> dados = response.data;
      print(response.data);

      return dados.map((item) => Aluno.fromJson(item)).toList();
    } catch (e) {
      throw Exception("Erro ao buscar inscritos");
    }
  }
}
