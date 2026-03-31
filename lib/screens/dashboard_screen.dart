import 'package:flutter/material.dart';
import 'package:prosaude/models/usuario/Usuario.dart';
import 'package:prosaude/screens/EquipeManageScreen.dart';
import 'package:prosaude/screens/atividade_manage_screen.dart';
import 'package:prosaude/services/session_manager.dart';

class DashboardScreen extends StatefulWidget {

  const DashboardScreen({
    super.key,

  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
  }


  class _DashboardScreenState extends State<DashboardScreen> {
    String _nome = "Carregando...";
    String _perfil = "";

    @override
    void initState() {
      super.initState();
      _carregarDadosUsuario();
    }

    Future<void> _carregarDadosUsuario() async {
      // BUSCA O OBJETO INTEIRO (Conforme a "limpa" que fizemos no SessionManager)
      final sessao = await SessionManager.getSession();

      if (sessao != null) {
        setState(() {
          _nome = sessao.nome;
          _perfil = sessao.perfil;
        });
      }
    }
      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Pro Saúde"),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await SessionManager.clearSession();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              )
            ],
          ),
          body: Column(
            children: [
              Text("Olá, $_nome", style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                children: [
                  // CARD 1: GERENCIAR ATIVIDADES (CRUD)
                  // Disponível para Coordenador e talvez Monitores
                  _buildActionCard(
                    context,
                    icon: Icons.assignment,
                    label: "Atividades",
                    color: Colors.blue.shade700,
                    onTap: () =>
                        Navigator.push(context,
                            MaterialPageRoute(builder: (
                                context) => const AtividadeManageScreen())
                        ),
                  ),

                  // CARD 2: GERENCIAR EQUIPE (Bolsistas/Monitores)
                  // EXCLUSIVO PARA COORDENADOR
                  if (_perfil == "COORDENADOR")
                    _buildActionCard(
                      context,
                      icon: Icons.people_alt,
                      label: "Equipe e Designação",
                      color: Colors.orange.shade800,
                      onTap: () =>
                          Navigator.push(context,
                              MaterialPageRoute(builder: (
                                  context) => const EquipeManageScreen())
                          ),
                    ),

                  // Outros cards...
                ],
              ),
            ],
          ),
        );
      }

      Widget _buildActionCard(BuildContext context,
          {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(height: 12),
                Text(label, textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }
    }


