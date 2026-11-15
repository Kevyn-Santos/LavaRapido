# Plano: requisições do app Flutter para a API `/api/v1/*`

Escrito em 2026-11-13. Documento de planejamento: **nenhum código Dart ou Java foi alterado** nesta etapa.

> **Atualizado em 2026-11-15.** O contrato vigente da API está em `openapi.yml` (tag *API mobile*). Desde este plano: a autenticação passou a `HttpSession` (`autenticacao-sessao-api-mobile.md`), então o `idcliente` **não** vai mais na query nem no corpo; `/auth/login` recebe `{email, senha}` e devolve `{cliente}` (sem token); **não existe** `/auth/cadastro` (cadastro só na web); cancelar e `GET /horarios` estão implementados (`cancelar-agendamento-api-mobile.md`, `horarios-api-mobile.md`); `POST /veiculos` aceita `cor` opcional e devolve `id_veiculo` (`ajuste-veiculos-api-mobile.md`). A tabela abaixo foi corrigida; as demais seções ficam como histórico do planejamento.

## Por quê
O app (`app-mobile/`, pacote `flash_splash`) guarda tudo em memória (`lib/core/data/repositorio.dart`) e o `pubspec.yaml` não tem pacote de rede. A API já devolve JSON padronizado (ver `api-json-requisicao-resposta-erros.md`). Falta decidir onde ficam as chamadas HTTP, como instalar a dependência e como testar. Meta imediata: as requisições funcionarem "cruas", sem validação nem filtro no app.

Liga-se a: `analise-app-mobile.md` (plano geral e seção 3.5 dos endpoints), `api-json-requisicao-resposta-erros.md` (formato de resposta/erro) e `openapi.yml` (ainda sem as rotas `/api/v1`).

## 1. Onde ficam as requisições

Nova pasta `lib/core/api/`, um arquivo `.dart` por recurso (`core/` já abriga `data/`, `models/`, `session/`; a pasta nova segue o padrão):

```
lib/core/api/
  api_config.dart        URL base (const), timeout
  api_client.dart        get/post/patch/delete genéricos: monta URI, JSON, header, decodifica
  api_exception.dart     ApiException(status, mensagem), lida de {"erro": "..."}
  auth_api.dart          POST /auth/login, POST /auth/cadastro        (servlet ainda TODO)
  servico_api.dart       GET  /servicos                               (pública)
  veiculo_api.dart       GET /veiculos?idcliente=, POST /veiculos, DELETE /veiculos/{id}?idcliente=
  agendamento_api.dart   GET /agendamentos?idcliente=, POST /agendamentos
  cliente_api.dart       GET /usuarios?idcliente=, PATCH /usuarios
  horario_api.dart       GET /horarios?data=                          (servlet ainda TODO)
```

Regras:
- Só `api_client.dart` importa `package:http`. Os outros arquivos só chamam o `ApiClient`.
- Cada `*_api.dart` devolve `Map`/`List` crus por enquanto (`dynamic` do `jsonDecode`). Conversão para `Servico`/`Veiculo`/`Agendamento` (`fromJson`) fica para depois, quando o `Repositorio` for trocado.
- Nada de `package:flutter` dentro de `core/api/`. Isso permite rodar com `dart` puro (seção 3).
- Os arquivos não mexem em telas nem em `Repositorio` nesta etapa.

### Contratos reais (lidos do Javadoc dos servlets)

| Arquivo | Requisição | Sucesso | Erros |
| --- | --- | --- | --- |
| servico | `GET /servicos` (pública) | 200 `[{id_servico, nome, descricao, preco}]` | 500 |
| veiculo | `GET /veiculos` | 200 `[{id_veiculo, placa, marca, modelo, cor}]` | 401, 500 |
| veiculo | `POST /veiculos` `{placa, marca, modelo, cor?}` | 201 `{id_veiculo, placa, marca, modelo, cor}` | 400, 401, 409 (placa), 422, 500 |
| veiculo | `DELETE /veiculos/{id}` | 200 `{mensagem}` | 400, 401, 404, 500 |
| agendamento | `GET /agendamentos` | 200 `[{id_agendamento, id_veiculo, data_agendamento, hora_agendamento, id_servico[], total_servico, status_pagamento, forma_pagamento}]` | 401, 500 |
| agendamento | `POST /agendamentos` `{idveiculo, dataAgendamento "dd/MM/yyyy", horarioAgendamento "HH:mm", idservico[]}` | 201 `{mensagem}` | 400, 401, 422 (grade, passado, indisponível, regra da DAO), 500 |
| agendamento | `POST /agendamentos/{id}/cancelar` | 200 `{mensagem}` | 400, 401, 404, 500 |
| cliente | `GET /usuarios` | 200 `{id, nome, cpf, telefone, email}` | 401, 404 |
| cliente | `PATCH /usuarios` `{nome?, telefone?, email?}` | 200 mesmo objeto | 400, 401, 404, 422 |
| auth | `POST /auth/login` `{email, senha}` | 200 `{cliente}` + cookie `JSESSIONID` | 400, 401, 500 |
| horario | `GET /horarios?data=dd/MM/yyyy` | 200 `["06:00", ..., "17:30"]` | 400, 401, 500 |

Erro: sempre `{"erro": "mensagem"}`.

Pontos de atenção do contrato (não corrigidos agora):
- `GET /agendamentos` devolve `data_agendamento` como `yyyy/MM/dd`, mas o `POST` recebe `dd/MM/yyyy`. O app precisa tratar os dois formatos.
- Ids no app são `String` (`Veiculo.id`, `Agendamento.id`); na API são `int`. `Agendamento` do app tem 1 serviço; a API aceita `idservico[]`.
- (Resolvido) O cliente agora vem da sessão; nenhuma rota recebe `idcliente`.

## 2. Dependências (`pubspec.yaml`)

Dentro de `app-mobile/`:

```shell
flutter pub add http      # adiciona "http: ^1.x" em dependencies e já baixa
flutter pub get           # só se editar o pubspec.yaml à mão
flutter pub outdated      # opcional: ver versões
```

Edição manual equivalente:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0     # usar a versão que `flutter pub add` escolher
```

Use `flutter pub ...`, não `dart pub ...`, neste projeto: o pacote depende do SDK do Flutter e o `dart pub get` recusa esse caso.

Android (emulador/aparelho):
- `android/app/src/main/AndroidManifest.xml` precisa de `<uses-permission android:name="android.permission.INTERNET"/>` (o manifest de debug já tem; o de `main` é que vale em release).
- API em `http://` (sem TLS) no Android 9+ é bloqueada por padrão. Em desenvolvimento, adicionar `android:usesCleartextTraffic="true"` na tag `<application>`. Remover em produção (Render usa HTTPS).

## 3. Como executar e testar

### URL base conforme o ambiente
| Onde o app roda | URL base |
| --- | --- |
| Linux desktop (`flutter run -d linux`) | `http://localhost:8080/SplashFast/api/v1` |
| Emulador Android | `http://10.0.2.2:8080/SplashFast/api/v1` |
| Celular físico | `http://<IP-da-máquina-na-rede>:8080/SplashFast/api/v1` |
| Docker/Render (`ROOT.war`) | `https://<host>/api/v1` (sem `/SplashFast`) |

Porta 8080 e contexto `/SplashFast` valem para Tomcat local com `SplashFast.war`. Para trocar sem editar código: `String.fromEnvironment('API_URL', defaultValue: '...')` em `api_config.dart` e `flutter run --dart-define=API_URL=http://10.0.2.2:8080/SplashFast/api/v1`.

Flutter **web** (`-d chrome`) não funciona hoje: o backend não tem filtro de CORS. Evitar até existir.

### Pré-requisito: backend de pé
1. MySQL com `database/schema.sql` + `database/seed.sql`, `.env` configurado.
2. `mvn package` e copiar `target/SplashFast.war` para `webapps/` do Tomcat 10.1.
3. Conferir no terminal antes de abrir o app:
   ```shell
   curl http://localhost:8080/SplashFast/api/v1/servicos
   curl "http://localhost:8080/SplashFast/api/v1/veiculos?idcliente=1"
   ```

### Com Flutter
```shell
cd app-mobile
flutter pub get
flutter run -d linux                                    # desktop, mais rápido para testar
flutter run -d <id-emulador>                            # ver ids com: flutter devices
flutter run --dart-define=API_URL=http://10.0.2.2:8080/SplashFast/api/v1
flutter test                                            # testes que usam http/testing (MockClient), sem rede
```
Para ver a resposta sem montar tela: chamar `ServicoApi().listar()` e `debugPrint` no `main()` ou num botão temporário.

### Com Dart puro (sem abrir o app)
Os arquivos de `core/api/` só importam `dart:convert` e `package:http`, então rodam sem Flutter. Criar um script, por exemplo `tool/testar_api.dart`, que instancia o `ApiClient` e imprime as respostas:

```shell
cd app-mobile
flutter pub get
dart run tool/testar_api.dart
```
Observação (não verificado nesta máquina): como o pacote depende do SDK do Flutter, o `dart run` pode tentar um `pub get` próprio e falhar. Se falhar, rodar `flutter pub get` antes (gera `.dart_tool/package_config.json`) ou colocar o script e os arquivos de API num pacote Dart separado sem dependência do Flutter.

Alternativa sem Dart: Postman CLI / `curl` contra as mesmas rotas, para separar "servidor errado" de "cliente errado".

## 4. Validações e filtros: quem pede, quem executa (ainda não implementar)

Princípio: o **servidor é a autoridade**; o app valida só para dar resposta rápida. Toda regra do app precisa existir também na API, porque o app pode ser contornado.

| Regra | App pede/faz (UX) | API executa (autoridade) |
| --- | --- | --- |
| CPF, e-mail, telefone, nome | `Cpf` (`core/utils/cpf.dart`) e máscaras antes de enviar | `Validacao` via construtor/setters de `Cliente` → hoje 422 no `PATCH`; incluir no `/auth/cadastro` |
| Placa válida/única | normalizar hífen/maiúscula antes de enviar | `VeiculoApiServlet.POST`: validar formato; 409 já existe para duplicada |
| Veículo pertence ao cliente | enviar só ids de veículos que a API listou | `AgendamentoApiServlet.POST`: checar dono do `idveiculo` e existência dos `idservico[]` (hoje a DAO decide) |
| Data/horário | pedir `GET /horarios?data=` e mostrar só os livres | `HorarioApiServlet` (implementar) + revalidar no `POST /agendamentos`: data não passada, horário livre, `horarioAgendamento` no formato `HH:mm` (pendência já registrada) |
| Cancelar agendamento | botão só em status permitido | `AgendamentoApiServlet.cancelar` (501 hoje): regra de status e dono |
| Autenticação | `ApiClient` guarda e reenvia o cookie `JSESSIONID` (substituiu o Bearer; ver `autenticacao-sessao-api-mobile.md`) | `ApiAuthFilter`: 401 sem sessão; `idcliente` vem da sessão e deixou de vir do app |
| Mensagem de erro | `ApiClient` converte `status != 2xx` em `ApiException(status, erro)`; telas mostram `erro` em 400/422, "já cadastrada" em 409, "tente depois" em 500 | `Json.erro` já padroniza `{"erro"}` |
| CORS (só se houver Flutter web) | — | novo filtro `CorsFilter` em `/api/*` |
| Encoding | `Content-Type: application/json; charset=utf-8` | `EncodingFilter` (já existe) |

Ordem sugerida: (1) requisições cruas funcionando; (2) `AuthApiServlet` + `ApiAuthFilter` e token no `ApiClient`; (3) `HorarioApiServlet`; (4) validações do servidor listadas acima; (5) validações de UX no app.

## 5. Próximos passos práticos
1. `flutter pub add http`.
2. Criar `lib/core/api/` com os arquivos da seção 1 (`ApiClient` primeiro; depois `servico_api.dart`, o único endpoint público e sem dependência de dados).
3. Testar com `curl` e depois com `dart run tool/testar_api.dart`.
4. Só então ligar `Repositorio.definirServicos(...)` à API.
