import 'package:flutter/material.dart';

import 'package:flash_splash/core/data/repositorio.dart';
import 'package:flash_splash/core/api/api_client.dart';
import 'package:flash_splash/core/api/cliente_api.dart';
import 'package:flash_splash/core/api/model/cliente_model.dart';
import 'package:flash_splash/core/models/agendamento.dart';
import 'package:flash_splash/core/models/servico.dart';
import 'package:flash_splash/core/utils/formatadores.dart';
import 'package:flash_splash/features/agendamentos/novo_agendamento.dart';
import 'package:flash_splash/features/home/servico_card.dart';
import 'package:flash_splash/features/pagamento/pagamento.dart';

class InicioCliente extends StatefulWidget {
  const InicioCliente({super.key});
  @override
  State<InicioCliente> createState() => _InicioClienteState();
}

class _InicioClienteState extends State<InicioCliente> {
  late Future<ClienteModel> _cliente;

  @override
  void initState() {
    super.initState();
    _cliente = ClienteApi(apiClient: APIClient()).buscar();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

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
            FutureBuilder<ClienteModel>(
              future: _cliente,
              builder: (context, snapshot) => Text(
                'Olá, ${snapshot.data?.nome.split(' ').first ?? 'cliente'}! 👋',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
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
                                    : '${proximo.servicos.map((s) => s.nome).join(', ')}\n'
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
            const SizedBox(height: 4),
            Text(
              'Toque em um serviço para agendar.',
              style: TextStyle(color: cores.onSurfaceVariant),
            ),
            const SizedBox(height: 12),

            // Espaço dos serviços: a lista vem do Repositorio (o back
            // fornece os 4 tipos de serviço).
            ValueListenableBuilder<List<Servico>>(
              valueListenable: Repositorio.servicos,
              builder: (context, lista, _) {
                if (lista.isEmpty) {
                  return const Text('Não foi possível carregar os serviços. Verifique se a API está ligada.');
                }
                return Column(
                  children: [
                    for (final servico in lista)
                      ServicoCard(
                        servico: servico,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NovoAgendamento(
                                servicoInicial: servico,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            ),

            // Pagamento: só existe quando há um agendamento a pagar.
            const SizedBox(height: 15),
            ValueListenableBuilder<List<Agendamento>>(
              valueListenable: Repositorio.agendamentos,
              builder: (context, _, __) {
                final aPagar = Repositorio.proximoAPagar();
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: aPagar == null
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        Pagamento(agendamento: aPagar),
                                  ),
                                );
                              },
                        icon: const Icon(Icons.payment),
                        label: const Text('IR PARA PAGAMENTO'),
                      ),
                    ),
                    if (aPagar == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Agende um serviço para liberar o pagamento.',
                          style: TextStyle(color: cores.onSurfaceVariant),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
