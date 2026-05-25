class Aluno {
  final String nome;
  final String cpf;
  final String telefone;
  final String telefoneEmergencia;
  final String? dataInscricao;

  Aluno({
    required this.nome,
    required this.cpf,
    required this.telefone,
    required this.telefoneEmergencia,
    this.dataInscricao,
  });

  // Converte o JSON que vem do Java (Map) para o objeto AlunoInscrito
  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      // O operador ?? garante que se o campo vier nulo, o app não quebre
      nome: json['nome'] ?? "Nome não informado",

      // Aqui tratamos a confusão de 'cpf' vs 'CPF'
      cpf: (json['cpf'] ?? json['CPF'] ?? "---").toString(),

      telefone: json['telefone'] ?? "Sem contato",

      telefoneEmergencia: json['telefoneEmergencia'] ?? "Sem Contato",

      dataInscricao: json['dataInscricao']?.toString(),
    );
  }
}
