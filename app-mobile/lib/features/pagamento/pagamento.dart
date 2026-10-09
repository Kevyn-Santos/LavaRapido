import 'package:flutter/material.dart';

import 'package:flash_splash/core/models/servico.dart';

class _FormaPagamento {
  final String nome;
  final IconData icone;

  const _FormaPagamento(this.nome, this.icone);
}

const List<_FormaPagamento> _formas = [
  _FormaPagamento('Pix', Icons.qr_code),
  _FormaPagamento('Cartão de crédito', Icons.credit_card),
  _FormaPagamento('Cartão de débito', Icons.payment),
];

/// Tela de pagamento. Se [servico] for informado, mostra o resumo do
/// serviço escolhido; sem ele, funciona como "Formas de pagamento".
class Pagamento extends StatefulWidget {
  final Servico? servico;

  const Pagamento({super.key, this.servico});

  @override
  State<Pagamento> createState() => _PagamentoState();
}

class _PagamentoState extends State<Pagamento> {
  String _formaSelecionada = 'Pix';

  void _confirmar() {
    final servico = widget.servico;

    final mensagem = servico == null
        ? 'Forma de pagamento escolhida: $_formaSelecionada.'
        : '${servico.nome} (${servico.precoFormatado}) '
            'por $_formaSelecionada.';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Pagamento'),
          content: Text(
            '$mensagem\n\nEsta é uma demonstração do aplicativo.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final servico = widget.servico;

    return Scaffold(
      appBar: AppBar(
        title: Text(servico == null ? 'Formas de pagamento' : 'Pagamento'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          if (servico != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      servico.icone,
                      size: 55,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      servico.nome,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Valor: ${servico.precoFormatado}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          const Text(
            'Escolha a forma de pagamento:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          for (final forma in _formas)
            Card(
              child: ListTile(
                leading: Icon(forma.icone),
                title: Text(forma.nome),
                trailing: Icon(
                  forma.nome == _formaSelecionada
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () {
                  setState(() {
                    _formaSelecionada = forma.nome;
                  });
                },
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: _confirmar,
              child: Text(
                servico == null
                    ? 'SALVAR FORMA DE PAGAMENTO'
                    : 'CONFIRMAR PAGAMENTO',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
