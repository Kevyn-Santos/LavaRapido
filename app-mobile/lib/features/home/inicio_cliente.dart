import 'package:flutter/material.dart';

import 'package:flash_splash/core/data/repositorio.dart';
import 'package:flash_splash/core/models/agendamento.dart';
import 'package:flash_splash/core/models/servico.dart';
import 'package:flash_splash/core/utils/formatadores.dart';
import 'package:flash_splash/features/home/servico_card.dart';
import 'package:flash_splash/features/pagamento/pagamento.dart';

class InicioCliente extends StatefulWidget {
  const InicioCliente({super.key});

  @override
  State<InicioCliente> createState() => _InicioClienteState();
}

class _InicioClienteState extends State<InicioCliente> {
  Servico? _servicoSelecionado;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final servicoSelecionado = _servicoSelecionado;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FAST SPLASH',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Olá, cliente! 👋',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Deixe seu carro brilhando.',
              style: TextStyle(
                color: cores.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 25),

            // Próximo agendamento
            ValueListenableBuilder<List<Agendamento>>(
              valueListenable: Repositorio.agendamentos,
              builder: (context, _, __) {
                final proximo = Repositorio.proximoAgendamento();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_car_wash,
                          color: cores.primary,
                          size: 45,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Próximo agendamento',
                                style: TextStyle(
                                  color: cores.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                proximo == null
                                    ? 'Nenhum agendamento'
                                    : '${proximo.servico.nome}\n'
                                        '${Formatadores.dataHora(proximo.dataHora)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            const Text(
              'Serviços',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            for (final servico in Repositorio.servicos)
              ServicoCard(
                servico: servico,
                selecionado: servico == servicoSelecionado,
                onTap: () {
                  setState(() {
                    _servicoSelecionado = servico;
                  });
                },
              ),

            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: servicoSelecionado == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Pagamento(
                              servico: servicoSelecionado,
                            ),
                          ),
                        );
                      },
                icon: const Icon(Icons.payment),
                label: const Text('IR PARA PAGAMENTO'),
              ),
            ),
            if (servicoSelecionado == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    'Toque em um serviço para continuar.',
                    style: TextStyle(color: cores.onSurfaceVariant),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
