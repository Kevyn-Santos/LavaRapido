import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:flash_splash/core/api/api_client.dart';
import 'package:flash_splash/core/api/api_exception.dart';
import 'package:flash_splash/core/api/cliente_api.dart';

http.Response _json(Object corpo, int status) => http.Response.bytes(
      utf8.encode(jsonEncode(corpo)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

ClienteApi _api(MockClientHandler handler) =>
    ClienteApi(apiClient: APIClient(client: MockClient(handler)));

const _cliente = {'id': 7, 'nome': 'João Açaí', 'cpf': '12345678901', 'telefone': '11999990000', 'email': 'j@x.com'};

void main() {
  test('buscar lê UM objeto (GET /usuarios não devolve lista)', () async {
    late http.Request pedido;
    final api = _api((r) async {
      pedido = r;
      return _json(_cliente, 200);
    });

    final cliente = await api.buscar();

    expect(pedido.method, 'GET');
    expect(pedido.url.path, endsWith('/api/v1/usuarios'));
    expect(cliente.id, '7');
    expect(cliente.nome, 'João Açaí');
  });

  test('atualizar envia só os campos informados e devolve o modelo', () async {
    late http.Request pedido;
    final api = _api((r) async {
      pedido = r;
      return _json({..._cliente, 'telefone': '11888880000'}, 200);
    });

    final cliente = await api.atualizar(telefone: '11888880000');

    expect(pedido.method, 'PATCH');
    expect(jsonDecode(pedido.body), {'telefone': '11888880000'});
    expect(cliente.telefone, '11888880000');
  });

  test('422 vira ApiException com a mensagem do servidor', () async {
    final api = _api((_) async => _json({'erro': 'E-mail inválido'}, 422));

    expect(
      api.atualizar(email: 'x'),
      throwsA(isA<ApiException>()
          .having((e) => e.mensagem, 'mensagem', 'E-mail inválido')
          .having((e) => e.statusCode, 'statusCode', 422)),
    );
  });

  test('login devolve o cliente em 200', () async {
    final api = _api((r) async {
      expect(jsonDecode(r.body), {'email': 'j@x.com', 'senha': 'abc'});
      return _json({'cliente': _cliente}, 200);
    });

    expect((await api.login('j@x.com', 'abc')).id, '7');
  });

  test('login com senha errada (401) lança a mensagem do servidor', () async {
    final api = _api((_) async => _json({'erro': 'E-mail ou senha inválidos'}, 401));

    expect(api.login('j@x.com', 'errada'),
        throwsA(isA<ApiException>().having((e) => e.mensagem, 'mensagem', 'E-mail ou senha inválidos')));
  });

  test('falha de rede vira mensagem amigável', () async {
    final api = _api((_) async => throw http.ClientException('sem rede'));

    expect(api.buscar(),
        throwsA(isA<ApiException>().having((e) => e.mensagem, 'mensagem', 'Não foi possível conectar ao servidor.')));
  });
}
