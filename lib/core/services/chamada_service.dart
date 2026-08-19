import 'package:dio/dio.dart';
import 'package:prosaude/core/services/session_manager.dart';
import '../models/chamada/ChamadaDTO.dart';

class ChamadaService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://prosaude-back.onrender.com/ProSaude/chamadas",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  ChamadaService() {
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

  // GET: Buscar histórico de chamadas de uma turma
  Future<List<ChamadaDto>> listarPorTurma(int turmaId) async {
    try {
      final response = await _dio.get('/turma/$turmaId');

      if (response.statusCode == 200) {
        final List<dynamic> body = response.data;
        return body.map((item) => ChamadaDto.fromJson(item)).toList();
      } else {
        throw Exception('Falha ao carregar chamadas da turma');
      }
    } on DioException catch (e) {
      final mensagem = e.response?.data?['message'] ?? e.message;
      throw Exception('Erro ao carregar chamadas: $mensagem');
    }
  }

  // POST: Registrar nova chamada
  Future<ChamadaDto> salvarChamada(ChamadaDto dto) async {
    try {
      final response = await _dio.post(
        '',
        data: dto.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ChamadaDto.fromJson(response.data);
      } else {
        throw Exception('Falha ao registrar chamada');
      }
    } on DioException catch (e) {
      final mensagem = e.response?.data?['message'] ?? e.message;
      throw Exception('Erro ao salvar chamada: $mensagem');
    }
  }

  // PUT: Editar chamada existente
  Future<void> atualizarChamada(int chamadaId, ChamadaDto dto) async {
    try {
      final response = await _dio.put(
        '/$chamadaId',
        data: dto.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao atualizar chamada');
      }
    } on DioException catch (e) {
      final mensagem = e.response?.data?['message'] ?? e.message;
      throw Exception('Erro ao atualizar chamada: $mensagem');
    }
  }
}