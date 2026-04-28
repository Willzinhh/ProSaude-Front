import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prosaude/services/inscricao_service.dart';

class FormularioInscricaoScreen extends StatefulWidget {
  final int? turmaId; // Para saber em qual turma ele quer entrar após se cadastrar
  const FormularioInscricaoScreen({required this.turmaId});

  @override
  State<FormularioInscricaoScreen> createState() => _FormularioInscricaoScreenState();
}

class _FormularioInscricaoScreenState extends State<FormularioInscricaoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _inscricaoService = InscricaoService();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emergenciaController = TextEditingController();
  final _doencasController = TextEditingController();
  String? _caminhoAtestado;

  String _gerarSemestreAtual() {
    final agora = DateTime.now();
    final ano = agora.year;
    // Se o mês for menor ou igual a 6 (Junho), é o 1º semestre.
    // Caso contrário, é o 2º semestre.
    final semestre = agora.month <= 6 ? 1 : 2;

    return "$ano/$semestre";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Formulário de Inscrição")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nomeController, "Nome Completo", Icons.person),
              _buildTextField(_emailController, "E-mail", Icons.email),
              _buildTextField(_cpfController, "CPF", Icons.badge),
              _buildTextField(_whatsappController, "WhatsApp", Icons.phone),
              _buildTextField(_emergenciaController, "Contato de Emergência", Icons.emergency),

              const SizedBox(height: 10),
              TextFormField(
                controller: _doencasController,
                maxLines: 3,
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _finalizarInscricao,
                  child: const Text("CONCLUIR INSCRIÇÃO"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _selecionarArquivo() async {
    // Aqui você usaria o FilePicker para selecionar o PDF/Imagem
    // Ex: FilePickerResult? result = await FilePicker.platform.pickFiles();
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
        // 1. Prepara o mapa de dados
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

        // 2. CHAMA O SERVICE (A UI não sabe que existe Dio aqui)
        print("******* ${_nomeController}");
        await _inscricaoService.enviarAutoCadastro(dados);
      // Agora sim o pop faz sentido: ele fecha o CircularProgressIndicator
        if (!mounted) return;
        Navigator.pop(context);

        _showSucessoDialog();

      } catch (e) {
        // Se deu erro, também precisamos fechar o loading antes de mostrar o erro
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
        content: const Text("Sua inscrição foi realizada. Use seu CPF para realizar o primeiro login."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text("OK"),
          )
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
        behavior: SnackBarBehavior.floating, // Faz a snackbar "flutuar" sobre o conteúdo
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
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}