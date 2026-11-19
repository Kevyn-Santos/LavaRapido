/// Configuração do servidor da API.
///
/// Emulador Android (padrão): http://10.0.2.2:8080/FastSplash/api/v1
/// Celular físico: informe o IP do computador na mesma rede usando
/// --dart-define=API_BASE_URL=http://192.168.0.10:8080/FastSplash/api/v1
/// Servidor HTTPS: --dart-define=API_BASE_URL=https://seu-dominio/FastSplash/api/v1
class APIConfig {
  static const String BASE_URL = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/FastSplash/api/v1',
  );
  static const Duration TIMEOUT = Duration(seconds: 30);
  static const Map<String, String> HEADERS = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };
}
