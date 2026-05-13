// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Turma.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Turma _$TurmaFromJson(Map<String, dynamic> json) => Turma(
  id: (json['id'] as num?)?.toInt(),
  nome: json['nome'] as String,
  descricao: json['descricao'] as String,
  bolsista_responsavel: json['bolsista_responsavel'] == null
      ? null
      : Usuario.fromJson(json['bolsista_responsavel'] as Map<String, dynamic>),
  horaInicio: json['horaInicio'] as String,
  horaFim: json['horaFim'] as String,
  aulaSegunda: json['SEGUNDA'] as bool? ?? false,
  aulaTerca: json['TERCA'] as bool? ?? false,
  aulaQuarta: json['QUARTA'] as bool? ?? false,
  aulaQuinta: json['QUINTA'] as bool? ?? false,
  aulaSexta: json['SEXTA'] as bool? ?? false,
  aulaSabado: json['SABADO'] as bool? ?? false,
  aulaDomingo: json['DOMINGO'] as bool? ?? false,
);

Map<String, dynamic> _$TurmaToJson(Turma instance) => <String, dynamic>{
  'id': instance.id,
  'nome': instance.nome,
  'descricao': instance.descricao,
  'bolsista_responsavel': instance.bolsista_responsavel?.toJson(),
  'horaInicio': instance.horaInicio,
  'horaFim': instance.horaFim,
  'SEGUNDA': instance.aulaSegunda,
  'TERCA': instance.aulaTerca,
  'QUARTA': instance.aulaQuarta,
  'QUINTA': instance.aulaQuinta,
  'SEXTA': instance.aulaSexta,
  'SABADO': instance.aulaSabado,
  'DOMINGO': instance.aulaDomingo,
};
