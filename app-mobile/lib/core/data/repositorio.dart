import 'package:flutter/material.dart';

import 'package:flash_splash/core/api/api_client.dart';
import 'package:flash_splash/core/api/api_exception.dart';
import 'package:flash_splash/core/api/agendamento_api.dart';
import 'package:flash_splash/core/api/horario_api.dart';
import 'package:flash_splash/core/api/model/agendamento_model.dart';
import 'package:flash_splash/core/api/model/status_enums.dart';
import 'package:flash_splash/core/api/servico_api.dart';
import 'package:flash_splash/core/api/veiculo_api.dart';
import 'package:flash_splash/core/models/agendamento.dart';
import 'package:flash_splash/core/models/servico.dart';
import 'package:flash_splash/core/models/veiculo.dart';

/// Estado em memória alimentado exclusivamente pela API. Não mantém mais
/// serviços, veículos ou agendamentos fictícios.
class Repositorio {
  Repositorio._();

  static final APIClient _client = APIClient();
  static final ServicoApi _servicoApi = ServicoApi(apiClient: _client);
  static final VeiculoApi _veiculoApi = VeiculoApi(apiClient: _client);
  static final AgendamentoApi _agendamentoApi = AgendamentoApi(apiClient: _client);
  static final HorarioApi _horarioApi = HorarioApi(apiClient: _client);

  static final ValueNotifier<List<Servico>> servicos = ValueNotifier(const []);
  static final ValueNotifier<List<Veiculo>> veiculos = ValueNotifier(const []);
  static final ValueNotifier<List<Agendamento>> agendamentos = ValueNotifier(const []);

  static String? erroCatalogo;
  static bool carregandoCatalogo = false;

  static Future<void> carregarCatalogo() async {
    carregandoCatalogo = true;
    try {
      final dados = await _servicoApi.listar();
      servicos.value = List.unmodifiable(dados.map((s) => Servico(
        id: s.id, nome: s.nome, descricao: s.descricao, preco: s.preco,
      )));
      erroCatalogo = null;
    } on ApiException catch (e) {
      erroCatalogo = e.mensagem;
      rethrow;
    } finally {
      carregandoCatalogo = false;
    }
  }

  static Future<void> carregarDadosCliente() async {
    final veiculosApi = await _veiculoApi.listar();
    final agendamentosApi = await _agendamentoApi.listar();
    final novosVeiculos = veiculosApi.map((v) => Veiculo(
      id: v.id, marca: v.marca, modelo: v.modelo, placa: v.placa, cor: v.cor,
    )).toList();
    veiculos.value = List.unmodifiable(novosVeiculos);
    agendamentos.value = List.unmodifiable(agendamentosApi.map((a) => _converterAgendamento(a, novosVeiculos)));
  }

  static Agendamento _converterAgendamento(AgendamentoModel a, List<Veiculo> listaVeiculos) {
    final encontrados = listaVeiculos.where((v) => v.id == a.idVeiculo).toList();
    final veiculo = encontrados.isNotEmpty ? encontrados.first :
        Veiculo(id: a.idVeiculo, marca: 'Veículo', modelo: 'não identificado', placa: '', cor: '');
    final servicosDoAgendamento = a.servicos.map((s) => Servico(
      id: s.id, nome: s.nome, preco: s.valor,
    )).toList();
    Servico servicoPrincipal;
    if (servicosDoAgendamento.isNotEmpty) {
      servicoPrincipal = servicosDoAgendamento.first;
    } else {
      final encontradosServicos = servicos.value.where((s) => a.idServicos.contains(s.id)).toList();
      servicoPrincipal = encontradosServicos.isNotEmpty ? encontradosServicos.first :
          Servico(id: a.idServicos.isNotEmpty ? a.idServicos.first : '', nome: 'Serviço', preco: a.total);
    }
    final status = a.status == StatusAgendamento.cancelado
        ? StatusServico.cancelado
        : switch (a.statusAtendimento) {
            StatusAtendimento.emLavagem => StatusServico.emAndamento,
            StatusAtendimento.finalizado => StatusServico.concluido,
            StatusAtendimento.entregue => StatusServico.concluido,
            _ => a.status == StatusAgendamento.concluido ? StatusServico.concluido : StatusServico.pendente,
          };
    return Agendamento(
      id: a.id,
      servico: servicoPrincipal,
      servicos: servicosDoAgendamento.isEmpty ? [servicoPrincipal] : servicosDoAgendamento,
      veiculo: veiculo,
      dataHora: DateTime(a.data.year, a.data.month, a.data.day,
        int.parse(a.horario.split(':')[0]), int.parse(a.horario.split(':')[1])),
      status: status,
      pago: a.statusPagamento == StatusPagamento.pago,
    );
  }

  static Future<List<String>> horariosLivres(DateTime data) => _horarioApi.livres(data);

  static Future<void> criarAgendamento({required Veiculo veiculo, required List<Servico> servicosSelecionados,
    required DateTime dataHora}) async {
    await _agendamentoApi.criar(
      idVeiculo: veiculo.id,
      data: dataHora,
      horario: '${dataHora.hour.toString().padLeft(2, '0')}:${dataHora.minute.toString().padLeft(2, '0')}',
      idServicos: servicosSelecionados.map((s) => s.id).toList(),
    );
    await carregarDadosCliente();
  }

  static Future<void> cancelarAgendamento(Agendamento agendamento) async {
    await _agendamentoApi.cancelar(agendamento.id);
    await carregarDadosCliente();
  }

  static Future<void> pagarAgendamento(Agendamento agendamento, FormaPagamento forma) async {
    await _agendamentoApi.pagar(agendamento.id, forma: forma);
    await carregarDadosCliente();
  }

  static Future<void> adicionarVeiculo(Veiculo veiculo) async {
    await _veiculoApi.cadastrar(placa: veiculo.placa, marca: veiculo.marca,
      modelo: veiculo.modelo, cor: veiculo.cor);
    await carregarDadosCliente();
  }

  static Future<void> atualizarVeiculo(Veiculo veiculo) async {
    await _veiculoApi.atualizar(veiculo.id, placa: veiculo.placa, marca: veiculo.marca,
      modelo: veiculo.modelo, cor: veiculo.cor);
    await carregarDadosCliente();
  }

  static Future<void> removerVeiculo(Veiculo veiculo) async {
    await _veiculoApi.excluir(veiculo.id);
    await carregarDadosCliente();
  }

  static bool placaExiste(String placa, {String? ignorarId}) {
    final alvo = placa.replaceAll('-', '').trim().toUpperCase();
    return veiculos.value.any((v) => v.id != ignorarId &&
      v.placa.replaceAll('-', '').trim().toUpperCase() == alvo);
  }

  static bool veiculoEmUso(Veiculo veiculo) => agendamentos.value.any((a) =>
    a.veiculo.id == veiculo.id && a.status != StatusServico.concluido && a.status != StatusServico.cancelado);

  static Agendamento? proximoAgendamento() {
    final lista = agendamentos.value.where((a) => a.status != StatusServico.concluido && a.status != StatusServico.cancelado).toList();
    return lista.isEmpty ? null : lista.first;
  }

  static Agendamento? proximoAPagar() {
    final lista = agendamentos.value.where((a) => !a.pago && a.status != StatusServico.cancelado).toList();
    return lista.isEmpty ? null : lista.first;
  }

  static void limpar() {
    veiculos.value = const [];
    agendamentos.value = const [];
    APIClient.limparSessao();
  }
}
