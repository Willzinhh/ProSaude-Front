import 'package:flutter/material.dart';
import 'package:prosaude/core/models/turma/Turma.dart';

class TurmaFormDialog extends StatefulWidget {
  final Turma? turma;
  final Function(Turma turma) onSave;

  const TurmaFormDialog({
    super.key,
    this.turma,
    required this.onSave,
  });

  @override
  State<TurmaFormDialog> createState() => _TurmaFormDialogState();
}

class _TurmaFormDialogState extends State<TurmaFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  late TextEditingController _vagasController;
  late TextEditingController _semestreController;
  late TextEditingController _horaInicioController;
  late TextEditingController _horaFimController;

  late bool _seg, _ter, _qua, _qui, _sex, _sab, _dom;

  @override
  void initState() {
    super.initState();
    final t = widget.turma;
    _nomeController = TextEditingController(text: t?.nome ?? '');
    _descricaoController = TextEditingController(text: t?.descricao ?? '');
    _vagasController = TextEditingController(text: t?.vagas?.toString() ?? '');
    _semestreController = TextEditingController(text: t?.semestre ?? '');
    _horaInicioController = TextEditingController(text: t?.horaInicio ?? '');
    _horaFimController = TextEditingController(text: t?.horaFim ?? '');

    _seg = t?.aulaSegunda ?? false;
    _ter = t?.aulaTerca ?? false;
    _qua = t?.aulaQuarta ?? false;
    _qui = t?.aulaQuinta ?? false;
    _sex = t?.aulaSexta ?? false;
    _sab = t?.aulaSabado ?? false;
    _dom = t?.aulaDomingo ?? false;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _vagasController.dispose();
    _semestreController.dispose();
    _horaInicioController.dispose();
    _horaFimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.turma != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Turma' : 'Nova Turma'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome da Turma'),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _vagasController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Vagas'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _semestreController,
                      decoration: const InputDecoration(labelText: 'Semestre'),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _horaInicioController,
                      decoration: const InputDecoration(labelText: 'Início (Ex: 08:00)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _horaFimController,
                      decoration: const InputDecoration(labelText: 'Fim (Ex: 10:00)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Dias de Aula:', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Wrap(
                spacing: 4,
                children: [
                  FilterChip(label: const Text('Seg'), selected: _seg, onSelected: (v) => setState(() => _seg = v)),
                  FilterChip(label: const Text('Ter'), selected: _ter, onSelected: (v) => setState(() => _ter = v)),
                  FilterChip(label: const Text('Qua'), selected: _qua, onSelected: (v) => setState(() => _qua = v)),
                  FilterChip(label: const Text('Qui'), selected: _qui, onSelected: (v) => setState(() => _qui = v)),
                  FilterChip(label: const Text('Sex'), selected: _sex, onSelected: (v) => setState(() => _sex = v)),
                  FilterChip(label: const Text('Sáb'), selected: _sab, onSelected: (v) => setState(() => _sab = v)),
                  FilterChip(label: const Text('Dom'), selected: _dom, onSelected: (v) => setState(() => _dom = v)),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final novaTurma = Turma(
                id: widget.turma?.id,
                nome: _nomeController.text,
                descricao: _descricaoController.text,
                vagas: int.tryParse(_vagasController.text),
                semestre: _semestreController.text,
                horaInicio: _horaInicioController.text,
                horaFim: _horaFimController.text,
                bolsista_responsavel: widget.turma?.bolsista_responsavel,
                aulaSegunda: _seg,
                aulaTerca: _ter,
                aulaQuarta: _qua,
                aulaQuinta: _qui,
                aulaSexta: _sex,
                aulaSabado: _sab,
                aulaDomingo: _dom,
              );
              widget.onSave(novaTurma);
              Navigator.pop(context);
            }
          },
          child: Text(isEditing ? 'Atualizar' : 'Criar'),
        ),
      ],
    );
  }
}