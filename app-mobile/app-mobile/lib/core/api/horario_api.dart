import 'dart:convert';

import 'package:flash_splash/core/api/api_client.dart';
import 'package:flash_splash/core/api/api_exception.dart';

/// Horários livres para agendar (`GET /horarios`). Exige sessão.
class HorarioApi {
  final APIClient apiClient;

  HorarioApi({required this.apiClient});

  /// `GET /horarios?data=yyyy-MM-dd` -> `["06:00", "06:30", ...]` (`HH:mm`, grade de 06:00 a
  /// 17:30 de 30 em 30 min). Data passada devolve lista vazia; hoje, só o que ainda não passou.
  Future<List<String>> livres(DateTime data) => comTratamentoDeRede(() async {
        final dia = data.day.toString().padLeft(2, '0');
        final mes = data.month.toString().padLeft(2, '0');
        final ano = data.year.toString().padLeft(4, '0');
        final resposta = await apiClient.get('/horarios?data=$ano-$mes-$dia');
        if (resposta.statusCode != 200) throw ApiException.deResposta(resposta);
        final lista = jsonDecode(utf8.decode(resposta.bodyBytes)) as List<dynamic>;
        return [for (final horario in lista) horario as String];
      });
}
