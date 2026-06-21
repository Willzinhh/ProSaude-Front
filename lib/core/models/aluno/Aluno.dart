class Aluno {
  final int id;
  final String nome;
  final String cpf;
  final String telefone;
  final String telefoneEmergencia;
  final String? dataInscricao;

  Aluno({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.telefone,
    required this.telefoneEmergencia,
    this.dataInscricao,
  });

  // Converte o JSON que vem do Java (Map) para o objeto AlunoInscrito
  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(

      id: (json['id']),

      nome: json['nome'] ?? "Nome não informado",

      cpf: (json['cpf'] ?? json['CPF'] ?? "---").toString(),

      telefone: json['telefone'] ?? "Sem contato",

      telefoneEmergencia: json['telefoneEmergencia'] ?? "Sem Contato",

      dataInscricao: json['dataInscricao']?.toString(),
    );
  }

  String? operator [](String other) {}
}
