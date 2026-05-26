// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Usuario.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Usuario _$UsuarioFromJson(Map<String, dynamic> json) => Usuario(
  id: (json['id'] as num?)?.toInt(),
  nome: json['nome'] as String,
  email: json['email'] as String,
  senha: json['senha'] as String,
  perfil: json['perfil'] as String,
  telefone: json['telefone'] as String?,
  telefone_emergencia: json['telefone_emergencia'] as String?,
  cpf: json['cpf'] as String?,
  observacaoMedica: json['observacaoMedica'] as String?,
  data_nascimento: json['data_nascimento'] as String?,
  primeiroAcesso: json['primeiroAcesso'] as bool?,
);

Map<String, dynamic> _$UsuarioToJson(Usuario instance) => <String, dynamic>{
  'id': instance.id,
  'nome': instance.nome,
  'email': instance.email,
  'senha': instance.senha,
  'perfil': instance.perfil,
  'telefone': instance.telefone,
  'telefone_emergencia': instance.telefone_emergencia,
  'cpf': instance.cpf,
  'observacaoMedica': instance.observacaoMedica,
  'data_nascimento': instance.data_nascimento,
  'primeiroAcesso': instance.primeiroAcesso,
};
