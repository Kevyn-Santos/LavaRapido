class APIConfig {
  /// Host:porta do Tomcat. No emulador Android troque por "10.0.2.2:8080";
  /// em celular físico use o IP da máquina na rede (ex.: "192.168.0.10:8080").
  static const String BASE_URI = "10.0.2.2:8080";

  /// Prefixo de todas as rotas da API (contexto do Tomcat + /api/v1).
  static const String BASE_PATH = "/SplashFast/api/v1";

  // timeout (30Seg)
  static const Duration TIMEOUT = Duration(seconds: 30);

  // Headers (map<String, string>)
  static const Map<String, String> HEADERS = {"Content-Type": "application/json"};
}
