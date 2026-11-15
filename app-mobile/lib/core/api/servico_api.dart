import 'dart:convert';

import 'package:flash_splash/core/api/api_client.dart';
import 'package:flash_splash/core/api/api_exception.dart';
import 'package:flash_splash/core/api/model/ServicoModel.dart';

/// Catálogo de serviços (`GET /servicos`, rota pública: funciona até sem login).
class ServicoApi {
  final APIClient apiClient;

  ServicoApi({required this.apiClient});

  Future<List<ServicoModel>> listar() => comTratamentoDeRede(() async {
        final resposta = await apiClient.get('/servicos');
        if (resposta.statusCode != 200) throw ApiException.deResposta(resposta);
        final lista = jsonDecode(utf8.decode(resposta.bodyBytes)) as List<dynamic>;
        return [for (final item in lista) ServicoModel.fromJson(item as Map<String, dynamic>)];
      });
}
