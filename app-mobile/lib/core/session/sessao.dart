/// Dados da sessão do cliente logado (somente em memória).
class Sessao {
  Sessao._();

  /// CPF do cliente, apenas com dígitos.
  static String cpf = '';

  /// Verdadeiro quando o cliente já fez login.
  static bool get logado => cpf.isNotEmpty;

  static void limpar() {
    cpf = '';
  }
}
