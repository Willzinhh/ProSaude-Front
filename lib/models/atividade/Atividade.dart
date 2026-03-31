import 'package:json_annotation/json_annotation.dart';
import 'package:prosaude/models/usuario/Usuario.dart';

part 'Atividade.g.dart';

@JsonSerializable(explicitToJson: true)
class Atividade {
  final int? id;
  final String codigo;
  final String nome;
  final String descricao;
  final Usuario? bolsistaResponsavel;
  final Usuario? monitor;

  Atividade({
    this.id,
    required this.codigo,
    required this.nome,
    required this.descricao,
    this.bolsistaResponsavel,
    this.monitor,
  });

  factory Atividade.fromJson(Map<String, dynamic> json) => _$AtividadeFromJson(json);

  // MUDANÇA AQUI: Conecta com o código que será gerado
  Map<String, dynamic> toJson() => _$AtividadeToJson(this);
}