import 'package:flash_splash/core/api/api_client.dart';
import 'package:flash_splash/core/data/repositorio.dart';

/// Dados da sessão do cliente logado (somente em memória).
class Sessao {
  Sessao._();

  /// CPF do cliente, apenas com dígitos.
  static String cpf = '';

  /// ID do cliente, conforme o banco de dados.
  static String id = '';  

  /// Verdadeiro quando o cliente já fez login.
  static bool get logado => id.isNotEmpty;

  static void limpar() {
    cpf = '';
    id = '';
    APIClient.limparSessao();
    Repositorio.limpar();
  }
}
