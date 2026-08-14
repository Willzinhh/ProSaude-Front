import 'package:flutter/material.dart';

class HistoricoExpansionTile extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final Color cor;
  final bool isBolsista;
  final Future<List<dynamic>>? futureHistorico;

  const HistoricoExpansionTile({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.cor,
    required this.isBolsista,
    required this.futureHistorico,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(Icons.history, color: cor),
        title: Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitulo),
        iconColor: cor,
        textColor: cor,
        shape: const Border(),
        collapsedShape: const Border(),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: FutureBuilder<List<dynamic>>(
              future: futureHistorico,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: cor),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Text(isBolsista
                      ? "Erro ao carregar o histórico de lecionados."
                      : "Erro ao carregar o histórico.");
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(isBolsista
                        ? "Nenhuma turma antiga encontrada."
                        : "Nenhum histórico de turmas encontrado."),
                  );
                }

                final historico = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: historico.length,
                  itemBuilder: (context, index) {
                    final item = historico[index];

                    if (isBolsista) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        color: Colors.grey.shade50,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 1,
                        child: ListTile(
                          title: Text(
                            item['nome'] ?? 'Modalidade',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("Semestre: ${item['semestre']}"),
                        ),
                      );
                    }

                    final bool isAtivo = item['status'] == 'ATIVO';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: Colors.grey.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 1,
                      child: ListTile(
                        title: Text(
                          item['nomeTurma'] ?? 'Modalidade',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("Semestre: ${item['semestre']}"),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAtivo ? Colors.green.shade100 : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['status'] ?? 'INATIVO',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isAtivo ? Colors.green.shade800 : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}