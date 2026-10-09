import 'package:flutter/material.dart';

import 'package:flash_splash/core/data/repositorio.dart';
import 'package:flash_splash/core/models/veiculo.dart';

class MeusVeiculos extends StatelessWidget {
  const MeusVeiculos({super.key});

  Future<void> _adicionar(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    final veiculo = await showDialog<Veiculo>(
      context: context,
      builder: (_) => const _NovoVeiculoDialog(),
    );

    if (veiculo == null) return;

    Repositorio.adicionarVeiculo(veiculo);
    messenger.showSnackBar(
      const SnackBar(content: Text('Veículo adicionado.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus veículos'),
      ),
      body: ValueListenableBuilder<List<Veiculo>>(
        valueListenable: Repositorio.veiculos,
        builder: (context, lista, _) {
          final cor = Theme.of(context).colorScheme.primary;
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              if (lista.isEmpty)
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.directions_car,
                      color: cor,
                    ),
                    title: const Text('Nenhum veículo cadastrado'),
                  ),
                ),
              for (final veiculo in lista)
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.directions_car,
                      color: cor,
                    ),
                    title: Text(veiculo.modelo),
                    subtitle: Text(
                      'Placa: ${veiculo.placa}\nCor: ${veiculo.cor}',
                    ),
                    isThreeLine: true,
                  ),
                ),
              const SizedBox(height: 15),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _adicionar(context),
                  icon: const Icon(Icons.add),
                  label: const Text('ADICIONAR VEÍCULO'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NovoVeiculoDialog extends StatefulWidget {
  const _NovoVeiculoDialog();

  @override
  State<_NovoVeiculoDialog> createState() => _NovoVeiculoDialogState();
}

class _NovoVeiculoDialogState extends State<_NovoVeiculoDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _modelo = TextEditingController();
  final TextEditingController _placa = TextEditingController();
  final TextEditingController _cor = TextEditingController();

  // Aceita ABC-1234, ABC1234 e o padrão Mercosul (ABC1D23).
  static final RegExp _regexPlaca =
      RegExp(r'^[A-Za-z]{3}-?[0-9][A-Za-z0-9][0-9]{2}$');

  @override
  void dispose() {
    _modelo.dispose();
    _placa.dispose();
    _cor.dispose();
    super.dispose();
  }

  String? _obrigatorio(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Campo obrigatório.';
    return null;
  }

  String? _validarPlaca(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Campo obrigatório.';
    if (!_regexPlaca.hasMatch(valor.trim())) return 'Placa inválida.';
    return null;
  }

  void _salvar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Navigator.pop(
      context,
      Veiculo(
        modelo: _modelo.text.trim(),
        placa: _placa.text.trim().toUpperCase(),
        cor: _cor.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo veículo'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _modelo,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: _obrigatorio,
                decoration: const InputDecoration(labelText: 'Modelo'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _placa,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                validator: _validarPlaca,
                decoration: const InputDecoration(
                  labelText: 'Placa',
                  hintText: 'ABC-1234',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cor,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                validator: _obrigatorio,
                onFieldSubmitted: (_) => _salvar(),
                decoration: const InputDecoration(labelText: 'Cor'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR'),
        ),
        TextButton(
          onPressed: _salvar,
          child: const Text('SALVAR'),
        ),
      ],
    );
  }
}
