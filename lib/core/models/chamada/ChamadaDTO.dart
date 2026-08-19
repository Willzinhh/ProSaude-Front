import 'package:prosaude/core/models/aluno/Aluno.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ChamadaDTO.g.dart';



@JsonSerializable()
class ChamadaDto {
  final int? id;
  final int turmaId;
  final DateTime data;
  @JsonKey(name: 'presencas') // Conecta o nome do campo retornado pelo Spring Boot
  final List<PresencaItemDto> presencas;

  ChamadaDto({
    this.id,
    required this.turmaId,
    required this.data,
    required this.presencas,  });

  // 2. Conecta os métodos gerados automaticamente no .g.dart
  factory ChamadaDto.fromJson(Map<String, dynamic> json) => _$ChamadaDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ChamadaDtoToJson(this);
}

@JsonSerializable()
class PresencaItemDto {
  final int alunoId;
  final bool presente;

  PresencaItemDto({
    required this.alunoId,
    required this.presente,
  });

  factory PresencaItemDto.fromJson(Map<String, dynamic> json) => _$PresencaItemDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PresencaItemDtoToJson(this);
}