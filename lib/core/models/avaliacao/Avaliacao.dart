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
  String? anaHsSono;
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

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'dataAvaliacao': dataAvaliacao?.toIso8601String().split('T')[0],
      'anaProfi': anaProfi,
      'anaHsTrab': anaHsTrab,
      'anaTurnTrab': anaTurnTrab,
      'anaFuma': anaFuma,
      'anaFumaTempo': anaFumaTempo,
      'anaAlcool': anaAlcool,
      'anaQualiSono': anaQualiSono,
      'anaHsSono': anaHsSono,
      'anaCoposAguaDia': anaCoposAguaDia,
      'anaAlimentacao': anaAlimentacao,
      'anaRefDia': anaRefDia,
      'anaCirurgia': anaCirurgia,
      'anaProbCardiaco': anaProbCardiaco,
      'antPeso': antPeso,
      'antAltura': antAltura,
      'antImc': antImc,
      'antImcClass': antImcClass,
      'antPeriCintura': antPeriCintura,
      'antPeriQuadril': antPeriQuadril,
      'antRcq': antRcq,
      'antRcqClass': antRcqClass,
      'comEscalaFig': comEscalaFig,
      'comEscalaFigQuer': comEscalaFigQuer,
      'comDorehj': comDorehj,
      'comDores': comDores,
      'dadosSono': dadosSono,
      'posAnteriorCabeca': posAnteriorCabeca,
      'posAnteriorOmbros': posAnteriorOmbros,
      'posAnteriorCompBracos': posAnteriorCompBracos,
      'posAnteriorTrianguloTales': posAnteriorTrianguloTales,
      'posAnteriorTronco': posAnteriorTronco,
      'posAnteriorLinhaMamilar': posAnteriorLinhaMamilar,
      'posAnteriorEquiHorizPelvico': posAnteriorEquiHorizPelvico,
      'posAnteriorCicatrizUmbilical': posAnteriorCicatrizUmbilical,
      'posAnteriorQuadrilRod': posAnteriorQuadrilRod,
      'posAnteriorJoelhos': posAnteriorJoelhos,
      'posAnteriorPes': posAnteriorPes,
      'posPerfilCabeca': posPerfilCabeca,
      'posPerfilOmbros': posPerfilOmbros,
      'posPerfilMembrosSuperiores': posPerfilMembrosSuperiores,
      'posColunaCervical': posColunaCervical,
      'posColunaDorsal': posColunaDorsal,
      'posColunaLombar': posColunaLombar,
      'posColunaQuadril': posColunaQuadril,
      'posColunaJoelhos': posColunaJoelhos,
      'posPosteriorEscoliose': posPosteriorEscoliose,
      'posPosteriorGibosidade': posPosteriorGibosidade,
      'posPosteriorTendaoAquiles': posPosteriorTendaoAquiles,
      'obs': obs,
    };
  }
}