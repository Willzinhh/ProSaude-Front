import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chamada/ChamadaDTO.dart';

class ChamadaService {
  final String baseUrl = "https://prosaude-back.onrender.com/ProSaude/chamadas"; // Substitua pela sua URL

  // GET: Buscar histórico de chamadas de uma turma
  Future<List<ChamadaDto>> listarPorTurma(int turmaId) async {
    final response = await http.get(Uri.parse('$baseUrl/turma/$turmaId'));

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => ChamadaDto.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar chamadas da turma');
    }
  }

  // POST: Registrar nova chamada
  Future<ChamadaDto> salvarChamada(ChamadaDto dto) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return ChamadaDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao registrar chamada');
    }
  }

  // PUT: Editar chamada existente
  Future<void> atualizarChamada(int chamadaId, ChamadaDto dto) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$chamadaId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar chamada');
    }
  }
}