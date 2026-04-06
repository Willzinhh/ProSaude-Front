import 'package:json_annotation/json_annotation.dart';
import 'package:prosaude/models/usuario/Usuario.dart';

part 'Turma.g.dart';

@JsonSerializable(explicitToJson: true)
class Turma {
  final int? id;
  final String nome;
  final String descricao;
  final Usuario? bolsistaResponsavel;
  final String horaInicio;
  final String horaFim;
  final List<String>? diasSemana; // Vem como lista de Strings do JSON

  Turma({
    this.id,
    required this.nome,
    required this.descricao,
    this.bolsistaResponsavel,
    required this.horaInicio,
    required this.horaFim,
    this.diasSemana
  });

  factory Turma.fromJson(Map<String, dynamic> json) => _$TurmaFromJson(json);

  // MUDANÇA AQUI: Conecta com o código que será gerado
  Map<String, dynamic> toJson() => _$TurmaToJson(this);
}