
import 'package:json_annotation/json_annotation.dart';

part 'LoginResponse.g.dart';

@JsonSerializable()
class LoginResponse {
  final String? token;
  final String? nome;
  final String? perfil;
  final int? id;
  final bool? primeiroAcesso;


  LoginResponse({required this.token, required this.nome, required this.perfil, required this.id, this.primeiroAcesso});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);


  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}