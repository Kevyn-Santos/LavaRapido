import 'dart:convert';

import 'package:http/http.dart' as http;
import 'api_config.dart' as config;

class APIClient {
  final http.Client client;

  /// Cookie da HttpSession do servidor (`JSESSIONID=...`). É estático porque
  /// várias telas criam seu próprio `APIClient` e todas precisam da mesma sessão.
  static String? _cookieSessao;

  /// Chamado quando o servidor responde 401 numa rota protegida (sessão expirada ou inexistente).
  /// Definido em `main.dart`: limpa a [Sessao] e volta para a tela inicial.
  static void Function()? aoSessaoExpirar;

  APIClient({http.Client? client}) : client = client ?? http.Client();

  /// Esquece a sessão do servidor (usar no logout).
  static void limparSessao() => _cookieSessao = null;

  /// Monta a URL. O [endpoint] pode trazer query string (`/horarios?data=2030-12-01`): ela é separada
  /// antes, para preservar a query string ao montar a URL a partir da base configurável.
  Uri _uri(String endpoint) {
    final destino = Uri.parse(endpoint);
    final base = Uri.parse(config.APIConfig.BASE_URL);
    return base.replace(
      path: '${base.path.replaceFirst(RegExp(r'/$'), '')}${destino.path}',
      queryParameters: destino.hasQuery ? destino.queryParameters : null,
    );
  }

  Map<String, String> get _headers => {
        ...config.APIConfig.HEADERS,
        if (_cookieSessao != null) 'Cookie': _cookieSessao!,
      };

  /// Guarda o JSESSIONID enviado pelo servidor (header Set-Cookie) e trata o 401: fora de
  /// `/auth/*` (onde 401 é só "senha errada"), significa que a sessão do servidor expirou.
  http.Response _processar(String endpoint, http.Response response) {
    final setCookie = response.headers['set-cookie'];
    if (setCookie != null) {
      final achou = RegExp(r'JSESSIONID=[^;,\s]+').firstMatch(setCookie);
      if (achou != null) _cookieSessao = achou.group(0);
    }
    if (response.statusCode == 401 && !endpoint.startsWith('/auth/')) {
      limparSessao();
      aoSessaoExpirar?.call();
    }
    return response;
  }

  /// GET sem id: o servidor sabe quem é o cliente pela sessão (cookie).
  Future<http.Response> get(String endpoint) async {
    final resposta = await client.get(_uri(endpoint), headers: _headers).timeout(config.APIConfig.TIMEOUT);
    return _processar(endpoint, resposta);
  }

  Future<http.Response> post(String endpoint, {required Map<String, dynamic> body}) async {
    final resposta = await client
        .post(_uri(endpoint), headers: _headers, body: jsonEncode(body))
        .timeout(config.APIConfig.TIMEOUT);
    return _processar(endpoint, resposta);
  }

  Future<http.Response> patch(String endpoint, {required Map<String, dynamic> body}) async {
    final resposta = await client
        .patch(_uri(endpoint), headers: _headers, body: jsonEncode(body))
        .timeout(config.APIConfig.TIMEOUT);
    return _processar(endpoint, resposta);
  }

  /// DELETE sem corpo: o recurso vem no caminho (ex.: `/veiculos/3`) e o cliente, da sessão.
  Future<http.Response> delete(String endpoint) async {
    final resposta = await client.delete(_uri(endpoint), headers: _headers).timeout(config.APIConfig.TIMEOUT);
    return _processar(endpoint, resposta);
  }
}
