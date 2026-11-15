import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flash_splash/core/api/api_client.dart' as api_client;
import 'package:flash_splash/core/api/api_exception.dart';
import 'package:flash_splash/core/api/model/ClienteModel.dart';

class Clienteapi{

  final api_client.APIClient apiClient;

  Clienteapi({required this.apiClient});


  /// POST /auth/login {email, senha}. O servidor abre a HttpSession e devolve
  /// `{cliente:{...}}`; o cookie da sessão é guardado pelo [APIClient].
  /// Lança [ApiException] com a mensagem do servidor em caso de falha.
  Future<ClienteModel> login(String email, String senha) async {
    final http.Response response;
    try {
      response = await apiClient.post('/auth/login', body: {'email': email, 'senha': senha});
    } on TimeoutException {
      throw ApiException('O servidor demorou para responder. Tente novamente.');
    } catch (_) {
      throw ApiException('Não foi possível conectar ao servidor.');
    }

    Map<String, dynamic>? corpo;
    try {
      corpo = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {}

    if (response.statusCode == 200 && corpo?['cliente'] is Map<String, dynamic>) {
      return ClienteModel.fromJson(corpo!['cliente'] as Map<String, dynamic>);
    }
    throw ApiException(
      (corpo?['erro'] as String?) ?? 'Falha ao fazer login (${response.statusCode}).',
      statusCode: response.statusCode,
    );
  }

  Future<ClienteModel> atualizarCliente(String endpoint, ClienteModel cliente) async {
    final response = await apiClient.patch(endpoint, body: cliente.toJson());

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return ClienteModel.fromJson(data);
    } else {
      throw Exception('Falha ao atualizar o cliente: ${response.statusCode}');
    }
  }


  Future<List<ClienteModel>> getCliente(String endpoint) async {
    final response = await apiClient.get(endpoint);

    if(response.statusCode ==200){
          final List<dynamic> data = jsonDecode(response.body);
          return data.map((json) => ClienteModel.fromJson(json)).toList();
    }
    throw Exception('Falha ao carregar os clientes: ${response.statusCode}');
  }

}