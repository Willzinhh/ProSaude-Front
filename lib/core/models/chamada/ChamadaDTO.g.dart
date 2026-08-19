// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ChamadaDTO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChamadaDto _$ChamadaDtoFromJson(Map<String, dynamic> json) => ChamadaDto(
  id: (json['id'] as num?)?.toInt(),
  turmaId: (json['turmaId'] as num).toInt(),
  data: DateTime.parse(json['data'] as String),
  presencas: (json['presencas'] as List<dynamic>)
      .map((e) => PresencaItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ChamadaDtoToJson(ChamadaDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'turmaId': instance.turmaId,
      'data': instance.data.toIso8601String(),
      'presencas': instance.presencas,
    };

PresencaItemDto _$PresencaItemDtoFromJson(Map<String, dynamic> json) =>
    PresencaItemDto(
      alunoId: (json['alunoId'] as num).toInt(),
      presente: json['presente'] as bool,
    );

Map<String, dynamic> _$PresencaItemDtoToJson(PresencaItemDto instance) =>
    <String, dynamic>{
      'alunoId': instance.alunoId,
      'presente': instance.presente,
    };
