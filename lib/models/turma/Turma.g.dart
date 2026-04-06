// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Turma.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Turma _$TurmaFromJson(Map<String, dynamic> json) => Turma(
      id: (json['id'] as num?)?.toInt(),
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      bolsistaResponsavel: json['bolsistaResponsavel'] == null
          ? null
          : Usuario.fromJson(
              json['bolsistaResponsavel'] as Map<String, dynamic>),
      horaInicio: json['horaInicio'] as String,
      horaFim: json['horaFim'] as String,
      diasSemana: (json['diasSemana'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$TurmaToJson(Turma instance) => <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'descricao': instance.descricao,
      'bolsistaResponsavel': instance.bolsistaResponsavel?.toJson(),
      'horaInicio': instance.horaInicio,
      'horaFim': instance.horaFim,
      'diasSemana': instance.diasSemana,
    };
