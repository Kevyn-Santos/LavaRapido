import 'dart:async';
import 'dart:convert';

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
Future<T> comTratamentoDeRede<T>(Future<T> Function() chamada) async {
  try {
    return await chamada();
  } on ApiException {
    rethrow;
  } on TimeoutException {
    throw ApiException('O servidor demorou para responder. Tente novamente.');
  } catch (_) {
    throw ApiException('Não foi possível conectar ao servidor.');
  }
}
