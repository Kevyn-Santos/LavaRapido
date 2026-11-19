import 'package:flutter/material.dart';

import 'package:flash_splash/core/data/repositorio.dart';
import 'package:flash_splash/core/api/api_exception.dart';
import 'package:flash_splash/core/api/model/status_enums.dart';
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
    if (agendamento == null) {
      await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
        title: const Text('Formas de pagamento'),
        content: const Text('A forma de pagamento será selecionada ao pagar um agendamento.'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ));
      return;
    }
    final forma = switch (_formaSelecionada) {
      'Cartão de crédito' => FormaPagamento.credito,
      'Cartão de débito' => FormaPagamento.debito,
      _ => FormaPagamento.pix,
    };
    try {
      await Repositorio.pagarAgendamento(agendamento, forma);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pagamento registrado com sucesso.')));
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensagem)));
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
                      agendamento.servicos.map((s) => s.nome).join(', '),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Valor: R\$ ${agendamento.valorTotal.toStringAsFixed(2).replaceAll('.', ',')}',
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
                    ? 'ESCOLHA UM AGENDAMENTO NA AGENDA'
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
