import 'package:flutter/material.dart';

import 'package:flash_splash/core/models/agendamento.dart';
import 'package:flash_splash/core/models/servico.dart';
import 'package:flash_splash/core/models/veiculo.dart';

/// Dados do app guardados em memória (somem ao fechar o app).

class Repositorio {
  Repositorio._();

  static const List<Servico> servicos = [
    Servico(
      id: 'completa',
      nome: 'Lavagem completa',
      descricao: 'Lavagem externa + interna',
      preco: 50,
      icone: Icons.water_drop,
    ),
    Servico(
      id: 'premium',
      nome: 'Lavagem premium',
      descricao: 'Limpeza + acabamento',
      preco: 80,
      icone: Icons.auto_awesome,
    ),
  ];

  static final ValueNotifier<List<Veiculo>> veiculos =
      ValueNotifier<List<Veiculo>>([
    const Veiculo(modelo: 'Nissan Skyline', placa: 'ABC-1234', cor: 'Azul'),
  ]);

  static final ValueNotifier<List<Agendamento>> agendamentos =
      ValueNotifier<List<Agendamento>>([]);

  static void adicionarVeiculo(Veiculo veiculo) {
    veiculos.value = [...veiculos.value, veiculo];
  }

  static void adicionarAgendamento(Agendamento agendamento) {
    final lista = [...agendamentos.value, agendamento]
      ..sort((a, b) => a.dataHora.compareTo(b.dataHora));
    agendamentos.value = lista;
  }

  static void cancelarAgendamento(Agendamento agendamento) {
    agendamentos.value =
        agendamentos.value.where((a) => a != agendamento).toList();
  }

  /// Primeiro agendamento que ainda não passou, ou null.
  static Agendamento? proximoAgendamento() {
    final agora = DateTime.now();
    for (final agendamento in agendamentos.value) {
      if (agendamento.dataHora.isAfter(agora)) return agendamento;
    }
    return null;
  }
}
