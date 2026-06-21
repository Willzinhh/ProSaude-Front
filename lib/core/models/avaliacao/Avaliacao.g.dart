// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Avaliacao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvaliacaoModel _$AvaliacaoModelFromJson(
  Map<String, dynamic> json,
) => AvaliacaoModel()
  ..id = (json['id'] as num?)?.toInt()
  ..dataAvaliacao = json['dataAvaliacao'] == null
      ? null
      : DateTime.parse(json['dataAvaliacao'] as String)
  ..anaProfi = json['anaProfi'] as String?
  ..anaHsTrab = (json['anaHsTrab'] as num?)?.toDouble()
  ..anaTurnTrab = json['anaTurnTrab'] as String?
  ..anaFuma = json['anaFuma'] as bool
  ..anaFumaTempo = json['anaFumaTempo'] as String?
  ..anaAlcool = json['anaAlcool'] as bool
  ..anaQualiSono = json['anaQualiSono'] as String?
  ..anaHsSono = (json['anaHsSono'] as num?)?.toDouble()
  ..anaCoposAguaDia = (json['anaCoposAguaDia'] as num?)?.toDouble()
  ..anaAlimentacao = json['anaAlimentacao'] as String?
  ..anaRefDia = (json['anaRefDia'] as num?)?.toDouble()
  ..anaCirurgia = json['anaCirurgia'] as String?
  ..anaProbCardiaco = json['anaProbCardiaco'] as String?
  ..antPeso = (json['antPeso'] as num?)?.toDouble()
  ..antAltura = (json['antAltura'] as num?)?.toDouble()
  ..antImc = (json['antImc'] as num?)?.toDouble()
  ..antImcClass = json['antImcClass'] as String?
  ..antPeriCintura = (json['antPeriCintura'] as num?)?.toDouble()
  ..antPeriQuadril = (json['antPeriQuadril'] as num?)?.toDouble()
  ..antRcq = (json['antRcq'] as num?)?.toDouble()
  ..antRcqClass = json['antRcqClass'] as String?
  ..comEscalaFig = (json['comEscalaFig'] as num?)?.toDouble()
  ..comEscalaFigQuer = (json['comEscalaFigQuer'] as num?)?.toDouble()
  ..comDorehj = json['comDorehj'] as bool
  ..comDores = Map<String, int>.from(json['comDores'] as Map)
  ..dadosSono = json['dadosSono'] as Map<String, dynamic>
  ..posAnteriorCabeca = json['posAnteriorCabeca'] as String?
  ..posAnteriorOmbros = json['posAnteriorOmbros'] as String?
  ..posAnteriorCompBracos = json['posAnteriorCompBracos'] as String?
  ..posAnteriorTrianguloTales = json['posAnteriorTrianguloTales'] as String?
  ..posAnteriorTronco = json['posAnteriorTronco'] as String?
  ..posAnteriorLinhaMamilar = json['posAnteriorLinhaMamilar'] as String?
  ..posAnteriorEquiHorizPelvico = json['posAnteriorEquiHorizPelvico'] as String?
  ..posAnteriorCicatrizUmbilical =
      json['posAnteriorCicatrizUmbilical'] as String?
  ..posAnteriorQuadrilRod = json['posAnteriorQuadrilRod'] as String?
  ..posAnteriorJoelhos = json['posAnteriorJoelhos'] as String?
  ..posAnteriorPes = json['posAnteriorPes'] as String?
  ..posPerfilCabeca = json['posPerfilCabeca'] as String?
  ..posPerfilOmbros = json['posPerfilOmbros'] as String?
  ..posPerfilMembrosSuperiores = json['posPerfilMembrosSuperiores'] as String?
  ..posColunaCervical = json['posColunaCervical'] as String?
  ..posColunaDorsal = json['posColunaDorsal'] as String?
  ..posColunaLombar = json['posColunaLombar'] as String?
  ..posColunaQuadril = json['posColunaQuadril'] as String?
  ..posColunaJoelhos = json['posColunaJoelhos'] as String?
  ..posPosteriorEscoliose = json['posPosteriorEscoliose'] as String?
  ..posPosteriorGibosidade = json['posPosteriorGibosidade'] as String?
  ..posPosteriorTendaoAquiles = json['posPosteriorTendaoAquiles'] as String?
  ..obs = json['obs'] as String?;

Map<String, dynamic> _$AvaliacaoModelToJson(AvaliacaoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dataAvaliacao': instance.dataAvaliacao?.toIso8601String(),
      'anaProfi': instance.anaProfi,
      'anaHsTrab': instance.anaHsTrab,
      'anaTurnTrab': instance.anaTurnTrab,
      'anaFuma': instance.anaFuma,
      'anaFumaTempo': instance.anaFumaTempo,
      'anaAlcool': instance.anaAlcool,
      'anaQualiSono': instance.anaQualiSono,
      'anaHsSono': instance.anaHsSono,
      'anaCoposAguaDia': instance.anaCoposAguaDia,
      'anaAlimentacao': instance.anaAlimentacao,
      'anaRefDia': instance.anaRefDia,
      'anaCirurgia': instance.anaCirurgia,
      'anaProbCardiaco': instance.anaProbCardiaco,
      'antPeso': instance.antPeso,
      'antAltura': instance.antAltura,
      'antImc': instance.antImc,
      'antImcClass': instance.antImcClass,
      'antPeriCintura': instance.antPeriCintura,
      'antPeriQuadril': instance.antPeriQuadril,
      'antRcq': instance.antRcq,
      'antRcqClass': instance.antRcqClass,
      'comEscalaFig': instance.comEscalaFig,
      'comEscalaFigQuer': instance.comEscalaFigQuer,
      'comDorehj': instance.comDorehj,
      'comDores': instance.comDores,
      'dadosSono': instance.dadosSono,
      'posAnteriorCabeca': instance.posAnteriorCabeca,
      'posAnteriorOmbros': instance.posAnteriorOmbros,
      'posAnteriorCompBracos': instance.posAnteriorCompBracos,
      'posAnteriorTrianguloTales': instance.posAnteriorTrianguloTales,
      'posAnteriorTronco': instance.posAnteriorTronco,
      'posAnteriorLinhaMamilar': instance.posAnteriorLinhaMamilar,
      'posAnteriorEquiHorizPelvico': instance.posAnteriorEquiHorizPelvico,
      'posAnteriorCicatrizUmbilical': instance.posAnteriorCicatrizUmbilical,
      'posAnteriorQuadrilRod': instance.posAnteriorQuadrilRod,
      'posAnteriorJoelhos': instance.posAnteriorJoelhos,
      'posAnteriorPes': instance.posAnteriorPes,
      'posPerfilCabeca': instance.posPerfilCabeca,
      'posPerfilOmbros': instance.posPerfilOmbros,
      'posPerfilMembrosSuperiores': instance.posPerfilMembrosSuperiores,
      'posColunaCervical': instance.posColunaCervical,
      'posColunaDorsal': instance.posColunaDorsal,
      'posColunaLombar': instance.posColunaLombar,
      'posColunaQuadril': instance.posColunaQuadril,
      'posColunaJoelhos': instance.posColunaJoelhos,
      'posPosteriorEscoliose': instance.posPosteriorEscoliose,
      'posPosteriorGibosidade': instance.posPosteriorGibosidade,
      'posPosteriorTendaoAquiles': instance.posPosteriorTendaoAquiles,
      'obs': instance.obs,
    };
