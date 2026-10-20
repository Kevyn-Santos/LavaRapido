import 'package:flutter/material.dart';

import 'package:flash_splash/core/data/repositorio.dart';
import 'package:flash_splash/core/models/veiculo.dart';

class MeusVeiculos extends StatelessWidget {
  const MeusVeiculos({super.key});

  /// Abre o formulário. Com [veiculo], é edição; sem, é cadastro novo.
  Future<void> _abrirFormulario(
    BuildContext context, {
    Veiculo? veiculo,
  }) async {
    final messenger = ScaffoldMessenger.of(context);

    final resultado = await showDialog<Veiculo>(
      context: context,
      builder: (_) => _VeiculoDialog(veiculo: veiculo),
    );

    if (resultado == null) return;

    if (veiculo == null) {
      Repositorio.adicionarVeiculo(resultado);
      messenger.showSnackBar(
        const SnackBar(content: Text('Veículo adicionado.')),
      );
    } else {
      Repositorio.atualizarVeiculo(resultado);
      messenger.showSnackBar(
        const SnackBar(content: Text('Veículo atualizado.')),
      );
    }
  }

  Future<void> _apagar(BuildContext context, Veiculo veiculo) async {
    final messenger = ScaffoldMessenger.of(context);

    if (Repositorio.veiculoEmUso(veiculo)) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Este veículo tem um serviço em aberto. Cancele ou conclua o '
            'agendamento antes de apagar.',
          ),
        ),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Apagar veículo'),
          content: Text(
            'Deseja apagar "${veiculo.modelo}" (${veiculo.placa})?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('NÃO'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('SIM, APAGAR'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    Repositorio.removerVeiculo(veiculo);
    messenger.showSnackBar(
      const SnackBar(content: Text('Veículo apagado.')),
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Editar veículo',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () =>
                              _abrirFormulario(context, veiculo: veiculo),
                        ),
                        IconButton(
                          tooltip: 'Apagar veículo',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _apagar(context, veiculo),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 15),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _abrirFormulario(context),
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

/// Formulário de cadastro/edição de veículo.
class _VeiculoDialog extends StatefulWidget {
  final Veiculo? veiculo;

  const _VeiculoDialog({this.veiculo});

  @override
  State<_VeiculoDialog> createState() => _VeiculoDialogState();
}

class _VeiculoDialogState extends State<_VeiculoDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _modelo =
      TextEditingController(text: widget.veiculo?.modelo ?? '');
  late final TextEditingController _placa =
      TextEditingController(text: widget.veiculo?.placa ?? '');
  late final TextEditingController _cor =
      TextEditingController(text: widget.veiculo?.cor ?? '');

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
    if (Repositorio.placaExiste(valor, ignorarId: widget.veiculo?.id)) {
      return 'Já existe um veículo com esta placa.';
    }
    return null;
  }

  void _salvar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final modelo = _modelo.text.trim();
    final placa = _placa.text.trim().toUpperCase();
    final cor = _cor.text.trim();
    final original = widget.veiculo;

    Navigator.pop(
      context,
      original == null
          ? Veiculo(modelo: modelo, placa: placa, cor: cor)
          : original.copiarCom(modelo: modelo, placa: placa, cor: cor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.veiculo == null ? 'Novo veículo' : 'Editar veículo'),
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
