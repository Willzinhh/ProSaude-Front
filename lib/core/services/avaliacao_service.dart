import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:prosaude/core/services/session_manager.dart';

import '../models/avaliacao/Avaliacao.dart';

class AvaliacaoService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "http://10.0.2.2:8081/ProSaude",
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  AvaliacaoService() {
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

  Future<bool> salvarAvaliacao({
    required AvaliacaoModel avaliacao,
    required int alunoId,
    required int avaliadorId,
  }) async {
    final String rotaRelativa = "/avaliacoes/aluno/$alunoId/avaliador/$avaliadorId";

    try {
      print("Disparando POST via Dio para: ${_dio.options.baseUrl}$rotaRelativa");

      final response = await _dio.post(
        rotaRelativa,
        data: avaliacao.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Avaliação cadastrada com sucesso via Dio!");
        return true;
      }
      return false;

    } on DioException catch (e) {
      print("Erro de requisição no Dio: ${e.type}");
      if (e.response != null) {
        print("Dados do erro do servidor: ${e.response?.data}");
        print("Status Code do erro: ${e.response?.statusCode}");
      } else {
        print("Erro de envio/conexão: ${e.message}");
      }
      return false;
    } catch (e) {
      print("Falha inesperada no serviço de avaliação: $e");
      return false;
    }
  }

  Future<List<AvaliacaoModel>> buscarAvaliacoesPorAluno(int alunoId) async {
    try {
      final response = await _dio.get('/avaliacoes/aluno/$alunoId');

      if (response.statusCode == 200) {
        final List<dynamic> dadosJson = response.data;

        // Converte cada item da lista JSON em uma instância de AvaliacaoModel
        return dadosJson.map((json) => AvaliacaoModel.fromJson(json)).toList();
      }

      return [];
    } on DioException catch (e) {
      debugPrint('Erro Dio ao buscar avaliações do aluno $alunoId: ${e.message}');
      throw Exception('Falha ao conectar com o servidor local.');
    } catch (e) {
      debugPrint('Erro geral ao buscar avaliações: $e');
      throw Exception('Erro inesperado ao carregar dados.');
    }
  }
}