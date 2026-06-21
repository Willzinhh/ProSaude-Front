import 'package:json_annotation/json_annotation.dart';

part 'Avaliacao.g.dart';
@JsonSerializable(explicitToJson: true)
class AvaliacaoModel {
  int? id;
  DateTime? dataAvaliacao;

  // Anamnese
  String? anaProfi;
  double? anaHsTrab;
  String? anaTurnTrab;
  bool anaFuma = false;
  String? anaFumaTempo;
  bool anaAlcool = false;
  String? anaQualiSono;
  double? anaHsSono;
  double? anaCoposAguaDia;
  String? anaAlimentacao;
  double? anaRefDia;
  String? anaCirurgia;
  String? anaProbCardiaco;

  // Antropometria
  double? antPeso;
  double? antAltura;
  double? antImc;
  String? antImcClass;
  double? antPeriCintura;
  double? antPeriQuadril;
  double? antRcq;
  String? antRcqClass;

  // Dores
  double? comEscalaFig;
  double? comEscalaFigQuer;
  bool comDorehj = false;
  Map<String, int> comDores = {};


  Map<String, dynamic> dadosSono = {};

  // Postura (Textos)
  String? posAnteriorCabeca;
  String? posAnteriorOmbros;
  String? posAnteriorCompBracos;
  String? posAnteriorTrianguloTales;
  String? posAnteriorTronco;
  String? posAnteriorLinhaMamilar;
  String? posAnteriorEquiHorizPelvico;
  String? posAnteriorCicatrizUmbilical;
  String? posAnteriorQuadrilRod;
  String? posAnteriorJoelhos;
  String? posAnteriorPes;
  String? posPerfilCabeca;
  String? posPerfilOmbros;
  String? posPerfilMembrosSuperiores;
  String? posColunaCervical;
  String? posColunaDorsal;
  String? posColunaLombar;
  String? posColunaQuadril;
  String? posColunaJoelhos;
  String? posPosteriorEscoliose;
  String? posPosteriorGibosidade;
  String? posPosteriorTendaoAquiles;
  String? obs;

  AvaliacaoModel();

  factory AvaliacaoModel.fromJson(Map<String, dynamic> json) => _$AvaliacaoModelFromJson(json);

  Map<String, dynamic> toJson() => _$AvaliacaoModelToJson(this);



}