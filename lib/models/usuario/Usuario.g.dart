// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Usuario.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Usuario _$UsuarioFromJson(Map<String, dynamic> json) => Usuario(
      id: (json['id'] as num).toInt(),
      nome: json['nome'] as String,
      email: json['email'] as String,
      perfil: json['perfil'] as String,
      dados: json['dados'] == null
          ? null
          : DadosAluno.fromJson(json['dados'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UsuarioToJson(Usuario instance) => <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'email': instance.email,
      'perfil': instance.perfil,
      'dados': instance.dados,
    };

DadosAluno _$DadosAlunoFromJson(Map<String, dynamic> json) => DadosAluno(
      telefone: json['telefone'] as String?,
      observacaoMedica: json['observacaoMedica'] as String?,
      cpf: json['cpf'] as String?,
      dataNascimento: json['dataNascimento'] as String?,
    );

Map<String, dynamic> _$DadosAlunoToJson(DadosAluno instance) =>
    <String, dynamic>{
      'telefone': instance.telefone,
      'observacaoMedica': instance.observacaoMedica,
      'cpf': instance.cpf,
      'dataNascimento': instance.dataNascimento,
    };
