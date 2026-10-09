import 'package:flutter/material.dart';

import 'package:flash_splash/core/data/repositorio.dart';
import 'package:flash_splash/core/models/agendamento.dart';
import 'package:flash_splash/core/utils/formatadores.dart';
import 'package:flash_splash/features/agendamentos/novo_agendamento.dart';

class Agendamentos extends StatelessWidget {
  const Agendamentos({super.key});

  Future<void> _confirmarCancelamento(
    BuildContext context,
    Agendamento agendamento,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancelar agendamento'),
          content: Text(
            'Deseja cancelar "${agendamento.servico.nome}" em '
            '${Formatadores.dataHora(agendamento.dataHora)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('NÃO'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('SIM, CANCELAR'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      Repositorio.cancelarAgendamento(agendamento);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus agendamentos'),
      ),
      body: ValueListenableBuilder<List<Agendamento>>(
        valueListenable: Repositorio.agendamentos,
        builder: (context, lista, _) {
          final cor = Theme.of(context).colorScheme.primary;
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              if (lista.isEmpty)
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.calendar_month,
                      color: cor,
                    ),
                    title: const Text('Nenhum agendamento'),
                    subtitle: const Text(
                      'Você ainda não possui horários marcados.',
                    ),
                  ),
                )
              else
                ...lista.map(
                  (agendamento) => Card(
                    child: ListTile(
                      leading: Icon(
                        agendamento.servico.icone,
                        color: cor,
                      ),
                      title: Text(agendamento.servico.nome),
                      subtitle: Text(
                        '${Formatadores.dataHora(agendamento.dataHora)}\n'
                        '${agendamento.veiculo.modelo} • '
                        '${agendamento.veiculo.placa}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        tooltip: 'Cancelar agendamento',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () =>
                            _confirmarCancelamento(context, agendamento),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NovoAgendamento(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('NOVO AGENDAMENTO'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
