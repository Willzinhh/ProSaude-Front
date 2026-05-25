import 'package:json_annotation/json_annotation.dart';

part 'Usuario.g.dart';

@JsonSerializable()
class Usuario {
  final int? id;
  final String nome;
  final String email;
  final String senha;
  final String perfil;
  final String? telefone;
  final String? telefone_emergencia;
  final String? cpf;
  final String? observacaoMedica;
  final String? data_nascimento;

  Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.perfil,
    this.telefone,
    this.telefone_emergencia,
    this.cpf,
    this.observacaoMedica,
    this.data_nascimento,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) =>
      _$UsuarioFromJson(json);

  Map<String, dynamic> toJson() => _$UsuarioToJson(this);
}
