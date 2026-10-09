/// Dados da sessão do cliente logado (somente em memória).
class Sessao {
  Sessao._();

  /// CPF do cliente, apenas com dígitos.
  static String cpf = '';

  static void limpar() {
    cpf = '';
  }
}
