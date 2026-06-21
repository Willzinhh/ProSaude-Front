import 'package:flutter/material.dart';
import 'package:prosaude/core/services/aluno_service.dart';
import 'package:prosaude/core/services/inscricao_service.dart';
// ⚠️ Certifique-se de que o caminho do seu SessionManager está correto:
import 'package:prosaude/core/services/session_manager.dart';
import 'package:prosaude/core/services/auth_service.dart'; // Seus dados virão daqui

class FormularioInscricaoScreen extends StatefulWidget {
  final int? turmaId;

  const FormularioInscricaoScreen({required this.turmaId});

  @override
  State<FormularioInscricaoScreen> createState() =>
      _FormularioInscricaoScreenState();
}

class _FormularioInscricaoScreenState extends State<FormularioInscricaoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _inscricaoService = InscricaoService();
  final _alunoService = AlunoService(); // Instanciado para buscar os dados do aluno

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emergenciaController = TextEditingController();
  final _doencasController = TextEditingController();
  String? _caminhoAtestado;

  bool _estaCarregandoPerfil = false;
  bool _camposBloqueados = false; // Define se vamos travar os inputs após preencher

  @override
  void initState() {
    super.initState();
    _verificarSeUsuarioEstaLogado();
  }

  Future<void> _verificarSeUsuarioEstaLogado() async {
    try {
      final session = await SessionManager.getSession();
      print("Usuário na sessão: ${session?.nome}");

      if (session != null && session.id != null) {
        print('Iniciando preenchimento automático para o aluno...');
        setState(() {
          _estaCarregandoPerfil = true;
        });

        // Busca os dados cadastrados no Back-end
        final dadosAluno = await _alunoService.getAluno();

        setState(() {
          _nomeController.text = dadosAluno.nome ?? '';
          _emailController.text = dadosAluno.email ?? '';
          _cpfController.text = dadosAluno.cpf ?? '';
          _whatsappController.text = dadosAluno.telefone ?? '';
          _emergenciaController.text = dadosAluno.telefone_emergencia ?? '';
          _doencasController.text = dadosAluno.observacaoMedica ?? '';

          _camposBloqueados = true;
          _estaCarregandoPerfil = false;
        });
      } else {
        setState(() {
          _estaCarregandoPerfil = false;
        });
      }
    } catch (e) {
      print("Erro capturado no fluxo de auto-preenchimento: $e");
      // Se a API falhar (ex: 403), desliga o loading para o aluno conseguir digitar na raça
      setState(() {
        _estaCarregandoPerfil = false;
        _camposBloqueados = false;
      });
    }
  }

  String _gerarSemestreAtual() {
    final agora = DateTime.now();
    final ano = agora.year;
    final semestre = agora.month <= 6 ? 1 : 2;

    return "$ano/$semestre";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Formulário de Inscrição")),
      body: _estaCarregandoPerfil
          ? const Center(child: CircularProgressIndicator()) // Feedback visual de carregamento
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nomeController, "Nome Completo", Icons.person),
              _buildTextField(_emailController, "E-mail", Icons.email),
              _buildTextField(_cpfController, "CPF", Icons.badge),
              _buildTextField(_whatsappController, "WhatsApp", Icons.phone),
              _buildTextField(
                _emergenciaController,
                "Contato de Emergência",
                Icons.emergency,
              ),

              const SizedBox(height: 10),
              TextFormField(
                controller: _doencasController,
                maxLines: 3,
                readOnly: _camposBloqueados, // Bloqueia se já vier do banco
                decoration: const InputDecoration(
                  labelText: "Possui doenças crônicas? Se sim, quais?",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // Botão de Anexo
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: Text(_caminhoAtestado ?? "Anexar Atestado Médico"),
                onTap: _selecionarArquivo,
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _finalizarInscricao,
                  child: const Text("CONCLUIR INSCRIÇÃO"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selecionarArquivo() async {
    setState(() {
      _caminhoAtestado = "atestado_selecionado.pdf";
    });
  }

  void _finalizarInscricao() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final dados = {
          "nome": _nomeController.text,
          "email": _emailController.text,
          "cpf": _cpfController.text,
          "telefone": _whatsappController.text,
          "contatoEmergencia": _emergenciaController.text,
          "doencasCronicas": _doencasController.text,
          "turmaId": widget.turmaId,
          "semestre": _gerarSemestreAtual(),
          "dataNascimento": "2000-01-01",
        };

        print("******* ${_nomeController.text}");
        await _inscricaoService.enviarAutoCadastro(dados);
        if (!mounted) return;
        Navigator.pop(context);

        _showSucessoDialog();
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);

        _mostrarErro(e.toString().replaceAll("Exception: ", ""));
      }
    }
  }

  void _showSucessoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sucesso!"),
        content: Text(_camposBloqueados
            ? "Sua inscrição nesta turma foi realizada com sucesso!"
            : "Sua inscrição foi realizada. Use seu CPF para realizar o primeiro login."),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(mensagem)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: "OK",
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: _camposBloqueados, // 🎯 Bloqueia o campo para edição se o aluno já estiver logado
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          filled: _camposBloqueados,
          fillColor: _camposBloqueados ? Colors.grey[100] : null, // Efeito visual cinza se bloqueado
        ),
        keyboardType: (label == "CPF" || label == "WhatsApp" || label == "Contato de Emergência")
            ? TextInputType.number
            : (label == "E-mail") ? TextInputType.emailAddress : TextInputType.text,

        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'O campo $label é obrigatório.';
          }
          if (label == "Nome Completo" && value.trim().length < 3) {
            return 'O nome deve conter pelo menos 3 letras.';
          }
          if (label == "E-mail") {
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value.trim())) {
              return 'Insira um e-mail válido.';
            }
          }
          if (label == "CPF") {
            final apenasNumeros = value.replaceAll(RegExp(r'[^0-9]'), '');
            if (apenasNumeros.length != 11) {
              return 'O CPF deve ter exatamente 11 dígitos.';
            }
          }
          if (label == "WhatsApp" || label == "Contato de Emergência") {
            final apenasNumeros = value.replaceAll(RegExp(r'[^0-9]'), '');
            if (apenasNumeros.length < 10) {
              return 'Insira um número válido com DDD.';
            }
          }
          return null;
        },
      ),
    );
  }
}