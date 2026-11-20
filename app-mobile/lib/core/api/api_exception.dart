import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

/// Erro de uma chamada à API, com a mensagem pronta para mostrar ao usuário.
class ApiException implements Exception {
  final String mensagem;
  final int? statusCode;

  ApiException(this.mensagem, {this.statusCode});

  /// Monta o erro a partir da resposta do servidor, que sempre manda `{"erro": "mensagem"}`.
  factory ApiException.deResposta(http.Response resposta) {
    String? erro;
    try {
      final corpo = jsonDecode(utf8.decode(resposta.bodyBytes));
      if (corpo is Map<String, dynamic>) erro = corpo['erro'] as String?;
    } catch (_) {}
    return ApiException(
      erro ?? 'Falha na requisição (${resposta.statusCode}).',
      statusCode: resposta.statusCode,
    );
  }

  @override
  String toString() => mensagem;
}

/// Executa [chamada] e converte falha de rede/timeout em [ApiException] com mensagem amigável.
/// Uma [ApiException] lançada dentro da chamada passa direto.
///
/// Só erros de rede viram "não foi possível conectar". Resposta mal formada ([FormatException],
/// [TypeError]) ou argumento inválido têm mensagem própria e o erro real vai para o log, para não
/// se passar por falta de conexão.
Future<T> comTratamentoDeRede<T>(Future<T> Function() chamada) async {
  try {
    return await chamada();
  } on ApiException {
    rethrow;
  } on TimeoutException {
    throw ApiException('O servidor demorou para responder. Tente novamente.');
  } on SocketException {
    throw ApiException('Não foi possível conectar ao servidor.');
  } on http.ClientException {
    throw ApiException('Não foi possível conectar ao servidor.');
  } on HandshakeException {
    throw ApiException('Não foi possível conectar ao servidor.');
  } on FormatException catch (e, pilha) {
    debugPrint('Resposta/argumento inválido: $e\n$pilha');
    throw ApiException('Resposta inesperada do servidor.');
  } on TypeError catch (e, pilha) {
    debugPrint('Resposta com formato inesperado: $e\n$pilha');
    throw ApiException('Resposta inesperada do servidor.');
  } catch (e, pilha) {
    // Qualquer outro erro continua chegando às telas como ApiException (elas só tratam esse tipo).
    debugPrint('Erro inesperado na chamada à API: $e\n$pilha');
    throw ApiException('Ocorreu um erro inesperado. Tente novamente.');
  }
}
