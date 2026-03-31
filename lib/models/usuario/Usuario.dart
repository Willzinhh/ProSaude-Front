import 'package:json_annotation/json_annotation.dart';

part 'Usuario.g.dart';

@JsonSerializable()
class Usuario {
  final int? id;
  final String? nome;
  final String? email;
  final String? perfil;

  Usuario({this.id, this.nome, this.email, this.perfil});

  factory Usuario.fromJson(Map<String, dynamic> json) => _$UsuarioFromJson(json);
  Map<String, dynamic> toJson() => _$UsuarioToJson(this);
}