import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:flash_splash/core/api/agendamento_api.dart';
import 'package:flash_splash/core/api/api_client.dart';
import 'package:flash_splash/core/api/model/status_enums.dart';

void main() {
  test('listar traz todos os serviços do agendamento com nome e valor praticado', () async {
    final api = AgendamentoApi(
      apiClient: APIClient(
        client: MockClient((_) async => http.Response.bytes(
              utf8.encode(jsonEncode([
                {
                  'id_agendamento': 10,
                  'id_veiculo': 2,
                  'data_agendamento': '2030-12-01',
                  'hora_agendamento': '10:00',
                  'id_servico': [1, 3],
                  'servicos': [
                    {'id_servico': 1, 'nome': 'Lavagem simples', 'valor': 30.0},
                    {'id_servico': 3, 'nome': 'Cera', 'valor': 60.0},
                  ],
                  'total_servico': 90.0,
                  'status': 'AGENDADO',
                  'status_atendimento': null,
                  'status_pagamento': 'PENDENTE',
                  'forma_pagamento': null,
                }
              ])),
              200,
            )),
      ),
    );

    final a = (await api.listar()).single;

    expect(a.servicos.map((s) => s.nome), ['Lavagem simples', 'Cera']);
    expect(a.servicos.fold<double>(0, (soma, s) => soma + s.valor), a.total);
    expect(a.idServicos, ['1', '3']);
    expect(a.status, StatusAgendamento.agendado);
    expect(a.statusAtendimento, isNull);
    expect(a.statusPagamento, StatusPagamento.pendente);
  });
}
