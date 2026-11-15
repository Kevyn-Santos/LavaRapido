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

  /// `POST /agendamentos` (201). O servidor espera a data como `dd/MM/yyyy` e os ids como números.
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
        final resposta = await apiClient.post('/agendamentos', body: {
          'idveiculo': int.parse(idVeiculo),
          'dataAgendamento': '$dia/$mes/${data.year}',
          'horarioAgendamento': horario,
          'idservico': [for (final id in idServicos) int.parse(id)],
        });
        if (resposta.statusCode != 201) throw ApiException.deResposta(resposta);
      });

  // TODO(time mobile): o servidor já implementa `POST /agendamentos/{id}/cancelar` e
  // `GET /horarios?data=dd/MM/yyyy`; falta criar os métodos Dart correspondentes aqui.
  // Ver miscelaneous/plano-pendencias-api-mobile.md.
}
