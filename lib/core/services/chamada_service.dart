import 'package:dio/dio.dart';
import 'package:prosaude/core/services/session_manager.dart';
import '../models/chamada/ChamadaDTO.dart';

class ChamadaService {
  // 1. Usar a mesma baseUrl do TurmaService
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://prosaude-back.onrender.com/ProSaude",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  ChamadaService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SessionManager.getToken();

          if (token != null && token.isNotEmpty) {
            // Garante que o header é adicionado
            options.headers["Authorization"] = "Bearer $token";
          } else {
            print("⚠️ AVISO: Token retornado pelo SessionManager está nulo ou vazio!");
          }

          return handler.next(options);
        },
      ),
    );
  }

  // GET: Buscar histórico de chamadas de uma turma
  Future<List<ChamadaDto>> listarPorTurma(int turmaId) async {
    try {
      // 2. Usar o caminho completo da rota
      final response = await _dio.get('/chamadas/turma/$turmaId');

      if (response.statusCode == 200) {
        final List<dynamic> body = response.data;
        return body.map((item) => ChamadaDto.fromJson(item)).toList();
      } else {
        throw Exception('Falha ao carregar chamadas da turma');
      }
    } on DioException catch (e) {
      final mensagem = e.response?.data?['mensagem'] ?? e.response?.data?['message'] ?? e.message;
      throw Exception('Erro ao carregar chamadas: $mensagem');
    }
  }

  // POST: Registrar nova chamada
  Future<ChamadaDto> salvarChamada(ChamadaDto dto) async {
    try {
      // 2. Usar '/chamadas' em vez de ''
      final response = await _dio.post(
        '/chamadas',
        data: dto.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ChamadaDto.fromJson(response.data);
      } else {
        throw Exception('Falha ao registrar chamada');
      }
    } on DioException catch (e) {
      final mensagem = e.response?.data?['mensagem'] ?? e.response?.data?['message'] ?? e.message;
      throw Exception('Erro ao salvar chamada: $mensagem');
    }
  }

  // PUT: Editar chamada existente
  Future<void> atualizarChamada(int chamadaId, ChamadaDto dto) async {
    try {
      // 2. Usar '/chamadas/$chamadaId'
      final response = await _dio.put(
        '/chamadas/$chamadaId',
        data: dto.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao atualizar chamada');
      }
    } on DioException catch (e) {
      final mensagem = e.response?.data?['mensagem'] ?? e.response?.data?['message'] ?? e.message;
      throw Exception('Erro ao atualizar chamada: $mensagem');
    }
  }
}