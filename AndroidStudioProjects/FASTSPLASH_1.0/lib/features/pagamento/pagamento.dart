import 'package:flutter/material.dart';

import 'package:flash_splash/core/data/repositorio.dart';
import 'package:flash_splash/core/models/agendamento.dart';
import 'package:flash_splash/core/utils/formatadores.dart';

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

/// Tela de pagamento. Só se paga um serviço que já tenha agendamento:
/// com [agendamento] mostra o resumo e confirma o pagamento; sem ele,
/// funciona apenas como "Formas de pagamento".
class Pagamento extends StatefulWidget {
  final Agendamento? agendamento;

  const Pagamento({super.key, this.agendamento});

  @override
  State<Pagamento> createState() => _PagamentoState();
}

class _PagamentoState extends State<Pagamento> {
  String _formaSelecionada = 'Pix';

  Future<void> _confirmar() async {
    final agendamento = widget.agendamento;

    final mensagem = agendamento == null
        ? 'Forma de pagamento escolhida: $_formaSelecionada.'
        : '${agendamento.servico.nome} '
            '(${agendamento.servico.precoFormatado}) '
            'por $_formaSelecionada.';

    await showDialog<void>(
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

    if (!mounted) return;
    if (agendamento != null) {
      Repositorio.marcarComoPago(agendamento);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final agendamento = widget.agendamento;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          agendamento == null ? 'Formas de pagamento' : 'Pagamento',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          if (agendamento != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      agendamento.servico.icone,
                      size: 55,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      agendamento.servico.nome,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Valor: ${agendamento.servico.precoFormatado}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${Formatadores.dataHora(agendamento.dataHora)} • '
                      '${agendamento.veiculo.placa}',
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
                agendamento == null
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
