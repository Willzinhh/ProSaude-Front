import 'package:json_annotation/json_annotation.dart';

part 'Usuario.g.dart';

@JsonSerializable()
class Usuario {
  final int? id;
  final String nome;
  final String email;
  final String senha;
  final String perfil;
  final DadosAluno? dados; // O gerador vai entender que isso é outro objeto


  Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.perfil,
    this.dados,
  });

  // Métodos necessários para o json_serializable
  factory Usuario.fromJson(Map<String, dynamic> json) => _$UsuarioFromJson(json);
  Map<String, dynamic> toJson() => _$UsuarioToJson(this);
}

@JsonSerializable()
class DadosAluno {
  final String? telefone;
  final String? observacaoMedica;
  final String? cpf; // Adicionei o CPF que estava no seu SQL
  final String? dataNascimento; // String vinda do JSON (ISO 8601)

  DadosAluno({
    this.telefone,
    this.observacaoMedica,
    this.cpf,
    this.dataNascimento
  });

  factory DadosAluno.fromJson(Map<String, dynamic> json) => _$DadosAlunoFromJson(json);
  Map<String, dynamic> toJson() => _$DadosAlunoToJson(this);
}