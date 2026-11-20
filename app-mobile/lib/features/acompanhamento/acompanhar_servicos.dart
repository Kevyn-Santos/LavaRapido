import 'package:flutter/material.dart';
import 'package:flash_splash/core/utils/atualizacao_pagina.dart';

import 'package:flash_splash/core/data/repositorio.dart';
import 'package:flash_splash/core/models/agendamento.dart';
import 'package:flash_splash/core/utils/formatadores.dart';
import 'package:flash_splash/features/acompanhamento/status_chip.dart';

/// Acompanhamento dos serviços: mostra em que etapa cada agendamento está
/// (Pendente → Em andamento → Concluído).
class AcompanharServicos extends StatelessWidget {
  const AcompanharServicos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acompanhar serviços'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => AtualizacaoPagina.dadosCliente(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => AtualizacaoPagina.dadosCliente(context),
        child: ValueListenableBuilder<List<Agendamento>>(
        valueListenable: Repositorio.agendamentos,
        builder: (context, lista, _) {
          final ativos = lista.where((a) => a.status == StatusServico.pendente || a.status == StatusServico.emAndamento).toList();
          final concluidos = lista.where((a) => a.status == StatusServico.concluido).toList();
          final cancelados = lista.where((a) => a.status == StatusServico.cancelado).toList();

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(18),
            children: [
              if (lista.isEmpty)
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.timeline),
                    title: Text('Nada para acompanhar'),
                    subtitle: Text(
                      'Quando você agendar uma lavagem, ela aparece aqui '
                      'com a etapa em que está.',
                    ),
                  ),
                ),
              if (ativos.isNotEmpty) ...[
                const _Titulo('Em acompanhamento'),
                for (final a in ativos) _CartaoAcompanhamento(agendamento: a),
              ],
              if (concluidos.isNotEmpty) ...[
                const _Titulo('Concluídos'),
                for (final a in concluidos) _CartaoAcompanhamento(agendamento: a),
              ],
              if (cancelados.isNotEmpty) ...[
                const _Titulo('Cancelados'),
                for (final a in cancelados) _CartaoAcompanhamento(agendamento: a),
              ],
            ],
          );
        },
        ),
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  final String texto;

  const _Titulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _CartaoAcompanhamento extends StatelessWidget {
  final Agendamento agendamento;

  const _CartaoAcompanhamento({required this.agendamento});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(agendamento.servico.icone, color: cores.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    agendamento.servicos.map((s) => s.nome).join(', '),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                StatusChip(status: agendamento.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${Formatadores.dataHora(agendamento.dataHora)}\n'
              '${agendamento.veiculo.marca} ${agendamento.veiculo.modelo} • ${agendamento.veiculo.placa}',
              style: TextStyle(color: cores.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            if (agendamento.status == StatusServico.cancelado)
              const Text('Este agendamento foi cancelado.')
            else
              _Etapas(status: agendamento.status),
          ],
        ),
      ),
    );
  }
}

/// Linha do tempo com as 3 etapas.
class _Etapas extends StatelessWidget {
  final StatusServico status;

  const _Etapas({required this.status});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    const etapas = StatusServico.values;

    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0)
                Expanded(
                  child: Container(
                    height: 3,
                    color: i <= status.index
                        ? cores.primary
                        : cores.outlineVariant,
                  ),
                ),
              _Bolinha(ativa: i <= status.index, atual: i == status.index),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final e in etapas.take(3))
              Text(
                e.rotulo,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      e == status ? FontWeight.bold : FontWeight.normal,
                  color:
                      e.index <= status.index ? null : cores.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Bolinha extends StatelessWidget {
  final bool ativa;
  final bool atual;

  const _Bolinha({required this.ativa, required this.atual});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ativa ? cores.primary : Colors.transparent,
        border: Border.all(
          color: ativa ? cores.primary : cores.outline,
          width: 2,
        ),
      ),
      child: ativa
          ? Icon(
              atual ? Icons.more_horiz : Icons.check,
              size: 14,
              color: cores.onPrimary,
            )
          : null,
    );
  }
}
