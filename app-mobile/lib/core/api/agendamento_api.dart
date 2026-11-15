import 'dart:convert';

import 'package:flash_splash/core/api/api_client.dart';
import 'package:flash_splash/core/api/api_exception.dart';
import 'package:flash_splash/core/api/model/AgendamentoModel.dart';

/// Agendamentos do cliente logado (o servidor usa a sessão para saber quem é).
class AgendamentoApi {
  final APIClient apiClient;

  AgendamentoApi({required this.apiClient});

  /// `GET /agendamentos`.
  Future<List<AgendamentoModel>> listar() => comTratamentoDeRede(() async {
        final resposta = await apiClient.get('/agendamentos');
        if (resposta.statusCode != 200) throw ApiException.deResposta(resposta);
        final lista = jsonDecode(utf8.decode(resposta.bodyBytes)) as List<dynamic>;
        return [for (final item in lista) AgendamentoModel.fromJson(item as Map<String, dynamic>)];
      });

  /// `POST /agendamentos` (201). O servidor espera a data como `yyyy-MM-dd` e os ids como números.
  /// Erros: 400 corpo inválido, 422 regra de negócio (veículo inativo, serviço inexistente...).
  Future<void> criar({
    required String idVeiculo,
    required DateTime data,
    required String horario,
    required List<String> idServicos,
  }) =>
      comTratamentoDeRede(() async {
        final dia = data.day.toString().padLeft(2, '0');
        final mes = data.month.toString().padLeft(2, '0');
        final ano = data.year.toString().padLeft(4, '0');
        final resposta = await apiClient.post('/agendamentos', body: {
          'idveiculo': int.parse(idVeiculo),
          'dataAgendamento': '$ano-$mes-$dia',
          'horarioAgendamento': horario,
          'idservico': [for (final id in idServicos) int.parse(id)],
        });
        if (resposta.statusCode != 201) throw ApiException.deResposta(resposta);
      });

  /// `POST /agendamentos/{id}/cancelar` (200). 404 se não existir, for de outro cliente ou
  /// não estiver mais `AGENDADO`.
  Future<void> cancelar(String idAgendamento) => comTratamentoDeRede(() async {
        final resposta = await apiClient.post('/agendamentos/$idAgendamento/cancelar', body: {});
        if (resposta.statusCode != 200) throw ApiException.deResposta(resposta);
      });

  /// `POST /agendamentos/{id}/pagar` (200). [forma] é `PIX`, `CREDITO` ou `DEBITO`.
  /// 409 = o pagamento já foi processado (ex.: o atendente marcou como pago no site, ou o
  /// agendamento foi cancelado): recarregue a lista com [listar].
  Future<void> pagar(String idAgendamento, {required String forma}) =>
      comTratamentoDeRede(() async {
        final resposta = await apiClient.post('/agendamentos/$idAgendamento/pagar', body: {'forma': forma});
        if (resposta.statusCode != 200) throw ApiException.deResposta(resposta);
      });
}
