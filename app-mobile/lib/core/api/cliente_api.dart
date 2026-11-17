import 'dart:convert';

import 'package:flash_splash/core/api/api_client.dart';
import 'package:flash_splash/core/api/api_exception.dart';
import 'package:flash_splash/core/api/model/cliente_model.dart';

/// Login e dados do cliente logado. O servidor identifica o cliente pela sessão (cookie):
/// nenhuma chamada envia o id do cliente.
class ClienteApi {
  final APIClient apiClient;

  ClienteApi({required this.apiClient});

  /// `POST /auth/login {cpf, senha}`. O servidor abre a HttpSession e devolve
  /// `{cliente:{...}}`; o cookie da sessão é guardado pelo [APIClient].
  /// Lança [ApiException] com a mensagem do servidor em caso de falha (401 = credenciais inválidas).
  Future<ClienteModel> login(String cpf, String senha) =>
      comTratamentoDeRede(() async {
        final resposta = await apiClient.post(
          '/auth/login',
          body: {'cpf': cpf, 'senha': senha},
        );
        if (resposta.statusCode != 200) {
          throw ApiException.deResposta(resposta);
        }
        final corpo = jsonDecode(utf8.decode(resposta.bodyBytes));
        if (corpo is Map<String, dynamic> &&
            corpo['cliente'] is Map<String, dynamic>) {
          return ClienteModel.fromJson(
            corpo['cliente'] as Map<String, dynamic>,
          );
        }
        throw ApiException(
          'Resposta inesperada do servidor.',
          statusCode: resposta.statusCode,
        );
      });

  /// `GET /usuarios` (200) -> UM objeto `{id, nome, cpf, telefone, email}` (não é lista).
  Future<ClienteModel> buscar() => comTratamentoDeRede(() async {
        final resposta = await apiClient.get('/usuarios');
        if (resposta.statusCode != 200) throw ApiException.deResposta(resposta);
        return ClienteModel.fromJson(jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>);
      });

  /// `PATCH /usuarios` (200) -> o [ClienteModel] atualizado. Só os campos informados mudam;
  /// o CPF não é editável. Erros: 404 cliente inexistente, 422 dado inválido.
  Future<ClienteModel> atualizar({String? nome, String? telefone, String? email}) =>
      comTratamentoDeRede(() async {
        final resposta = await apiClient.patch('/usuarios', body: {
          if (nome != null) 'nome': nome,
          if (telefone != null) 'telefone': telefone,
          if (email != null) 'email': email,
        });
        if (resposta.statusCode != 200) throw ApiException.deResposta(resposta);
        return ClienteModel.fromJson(jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>);
      });
}
