import 'package:json_annotation/json_annotation.dart';
import '../usuario/Usuario.dart';

part 'Turma.g.dart';

@JsonSerializable(explicitToJson: true)
class Turma {
  final int? id;
  final String nome;
  final String descricao;
  final int? vagas;
  final Usuario? bolsista_responsavel;
  final String horaInicio;
  final String horaFim;
  @JsonKey(name: 'SEGUNDA')
  bool aulaSegunda;
  @JsonKey(name: 'TERCA')
  bool aulaTerca;
  @JsonKey(name: 'QUARTA')
  bool aulaQuarta;
  @JsonKey(name: 'QUINTA')
  bool aulaQuinta;
  @JsonKey(name: 'SEXTA')
  bool aulaSexta;
  @JsonKey(name: 'SABADO')
  bool aulaSabado;
  @JsonKey(name: 'DOMINGO')
  bool aulaDomingo;

  Turma({
    this.id,
    required this.nome,
    required this.descricao,
    required this.vagas,
    this.bolsista_responsavel,
    required this.horaInicio,
    required this.horaFim,
    this.aulaSegunda = false,
    this.aulaTerca = false,
    this.aulaQuarta = false,
    this.aulaQuinta = false,
    this.aulaSexta = false,
    this.aulaSabado = false,
    this.aulaDomingo = false,
  });

  factory Turma.fromJson(Map<String, dynamic> json) => _$TurmaFromJson(json);

  // MUDANÇA AQUI: Conecta com o código que será gerado
  Map<String, dynamic> toJson() => _$TurmaToJson(this);
}