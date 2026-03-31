// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Atividade.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Atividade _$AtividadeFromJson(Map<String, dynamic> json) => Atividade(
      id: (json['id'] as num?)?.toInt(),
      codigo: json['codigo'] as String,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      bolsistaResponsavel: json['bolsistaResponsavel'] == null
          ? null
          : Usuario.fromJson(
              json['bolsistaResponsavel'] as Map<String, dynamic>),
      monitor: json['monitor'] == null
          ? null
          : Usuario.fromJson(json['monitor'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AtividadeToJson(Atividade instance) => <String, dynamic>{
      'id': instance.id,
      'codigo': instance.codigo,
      'nome': instance.nome,
      'descricao': instance.descricao,
      'bolsistaResponsavel': instance.bolsistaResponsavel?.toJson(),
      'monitor': instance.monitor?.toJson(),
    };
