import 'package:flutter/material.dart';

import 'package:flash_splash/core/models/agendamento.dart';
import 'package:flash_splash/core/models/servico.dart';
import 'package:flash_splash/core/models/veiculo.dart';

/// Dados do app guardados em memória (somem ao fechar o app).
/// Quando houver backend, é aqui que a troca acontece.
class Repositorio {
  Repositorio._();

  // ---------------------------------------------------------------------
  // SERVIÇOS
  // Espaço reservado para a integração back x banco x mobile: o back vai
  // fornecer os 4 tipos de serviço. Enquanto isso, 4 itens numerados com
  // preços diferentes. Para integrar, chame [definirServicos] com a lista
  // que vier da API (os nomes, preços e ids virão de lá).
  // ---------------------------------------------------------------------
  static final ValueNotifier<List<Servico>> servicos =
      ValueNotifier<List<Servico>>(const [
    Servico(id: 'servico_1', nome: 'Serviço 1', preco: 30),
    Servico(id: 'servico_2', nome: 'Serviço 2', preco: 50),
    Servico(id: 'servico_3', nome: 'Serviço 3', preco: 80),
    Servico(id: 'servico_4', nome: 'Serviço 4', preco: 120),
  ]);

  static void definirServicos(List<Servico> novos) {
    servicos.value = List.unmodifiable(novos);
  }

  // ---------------------------------------------------------------------
  // VEÍCULOS
  // ---------------------------------------------------------------------
  static final ValueNotifier<List<Veiculo>> veiculos =
      ValueNotifier<List<Veiculo>>([
    Veiculo(
      id: 'veiculo_exemplo',
      modelo: 'Nissan Skyline',
      placa: 'ABC-1234',
      cor: 'Azul',
    ),
  ]);

  static final ValueNotifier<List<Agendamento>> agendamentos =
      ValueNotifier<List<Agendamento>>([]);

  static String _normalizarPlaca(String placa) =>
      placa.replaceAll('-', '').trim().toUpperCase();

  /// Já existe outro veículo com essa placa? ([ignorarId] = o que está
  /// sendo editado.)
  static bool placaExiste(String placa, {String? ignorarId}) {
    final alvo = _normalizarPlaca(placa);
    return veiculos.value.any(
      (v) => v.id != ignorarId && _normalizarPlaca(v.placa) == alvo,
    );
  }

  static void adicionarVeiculo(Veiculo veiculo) {
    veiculos.value = [...veiculos.value, veiculo];
  }

  /// Atualiza o veículo (mesmo id) e os agendamentos que o usam.
  static void atualizarVeiculo(Veiculo atualizado) {
    veiculos.value = [
      for (final v in veiculos.value) v.id == atualizado.id ? atualizado : v,
    ];
    agendamentos.value = [
      for (final a in agendamentos.value)
        a.veiculo.id == atualizado.id ? a.copiarCom(veiculo: atualizado) : a,
    ];
  }

  /// Veículo com serviço ainda não concluído não pode ser apagado.
  static bool veiculoEmUso(Veiculo veiculo) {
    return agendamentos.value.any(
      (a) => a.veiculo.id == veiculo.id && a.status != StatusServico.concluido,
    );
  }

  static void removerVeiculo(Veiculo veiculo) {
    veiculos.value = veiculos.value.where((v) => v != veiculo).toList();
  }

  // ---------------------------------------------------------------------
  // AGENDAMENTOS
  // ---------------------------------------------------------------------
  static void adicionarAgendamento(Agendamento agendamento) {
    final lista = [...agendamentos.value, agendamento]
      ..sort((a, b) => a.dataHora.compareTo(b.dataHora));
    agendamentos.value = lista;
  }

  static void cancelarAgendamento(Agendamento agendamento) {
    agendamentos.value =
        agendamentos.value.where((a) => a != agendamento).toList();
  }

  static void _alterarAgendamento(
    Agendamento alvo,
    Agendamento Function(Agendamento) alterar,
  ) {
    agendamentos.value = [
      for (final a in agendamentos.value) a == alvo ? alterar(a) : a,
    ];
  }

  static void marcarComoPago(Agendamento agendamento) {
    _alterarAgendamento(agendamento, (a) => a.copiarCom(pago: true));
  }

  /// Muda a etapa do serviço. Quem usa isso é o back/funcionário; no app
  /// há um botão de demonstração na tela "Acompanhar".
  static void atualizarStatus(Agendamento agendamento, StatusServico status) {
    _alterarAgendamento(agendamento, (a) => a.copiarCom(status: status));
  }

  /// Primeiro agendamento ainda não concluído, ou null.
  static Agendamento? proximoAgendamento() {
    for (final agendamento in agendamentos.value) {
      if (agendamento.status != StatusServico.concluido) return agendamento;
    }
    return null;
  }

  /// Primeiro agendamento ainda não pago, ou null.
  /// O pagamento só existe quando há um agendamento.
  static Agendamento? proximoAPagar() {
    for (final agendamento in agendamentos.value) {
      if (!agendamento.pago) return agendamento;
    }
    return null;
  }
}
