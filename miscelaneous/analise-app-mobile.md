# Análise do app mobile (`app-mobile/`) e plano da API Java para o mobile

> Primeira versão: 15/10/2026. **Revisada em 22/10/2026** a partir do código atual (`main` em `a1003c9`, com o pacote `com.splash.web.api` ainda não versionado).
> Restrição de projeto: **sem Spring nem outro framework.** A API é feita com Java puro: o JDK, a API Jakarta Servlet que o Tomcat já fornece e poucas bibliotecas pequenas.

### Registro desta revisão

| O que mudou | Por quê |
| --- | --- |
| Parte 1 atualizada para a nova versão do app (commit `8f1f6d3`: acompanhamento, status, pagamento por agendamento, edição de veículo) | O app mudou e vários problemas da versão anterior foram resolvidos |
| Parte 2 reescrita: o backend agora compila, usa os DAOs por tabela e tem `Dockerfile` real | O texto anterior citava `LavaRapidoRepository` e `ClienteRepository`, que não existem mais |
| Parte 3 refeita sem Spring, com a escolha entre Servlet e `com.sun.net.httpserver` e a lista de módulos e bibliotecas | Pedido explícito: "tudo será feito com Java puro". O `api/Handler.java` recém-criado importa `HttpServer` |
| Endpoints ligados aos métodos reais dos DAOs, com as lacunas de cada um | Para saber exatamente o que falta no `db/` antes de escrever a API |

Ligação com o resto do projeto: este documento é o plano do item "TODO APP 2: criar uma API para conectar o banco" de `miscelaneous/TODO.md`, usa a camada descrita em `separacao-daos.md` e `dtos-criadas.md` e, quando as rotas existirem, elas devem entrar no `miscelaneous/openapi.yml` (hoje só tem as rotas JSP).

---

## Parte 1: o app mobile hoje

### 1.1 Visão geral

| Item | Valor |
| --- | --- |
| Pacote | `flash_splash` (`pubspec.yaml`) |
| Tecnologia | Flutter / Dart (SDK `^3.13.2`), Material 3 |
| Dependências | **Só o Flutter SDK.** Nenhum pacote de rede ou armazenamento |
| Tamanho | Cerca de 2.850 linhas de Dart em `lib/` |
| Persistência | **Nenhuma.** Tudo fica em memória (`core/data/repositorio.dart`) |
| Comunicação externa | **Nenhuma.** Nenhuma chamada HTTP |

### 1.2 Arquitetura

```
lib/
  main.dart, app.dart        MaterialApp + ThemeController (claro/escuro)
  core/
    data/repositorio.dart    "banco" em memória: ValueNotifier estáticos de servicos, veiculos, agendamentos
    models/                  Servico, Veiculo, Agendamento (+ enum StatusServico)
    session/sessao.dart      Sessao.cpf (string estática)
    theme/, utils/           paleta do site, Cpf (validação/máscara), formatadores
  features/
    auth/                    TelaInicial, LoginCliente
    home/                    ContaCliente (abas), InicioCliente, ServicoCard
    agendamentos/            Agendamentos, NovoAgendamento
    acompanhamento/          AcompanharServicos, StatusChip            (novo)
    perfil/                  PerfilCliente, MeusVeiculos (com edição), Notificacoes
    pagamento/               Pagamento (agora ligado a um agendamento)
    configuracoes/           Configuracoes
```

O próprio `Repositorio` diz o que fazer: *"Quando houver backend, é aqui que a troca acontece"*, e `definirServicos(...)` já existe para receber a lista da API. Toda tela lê os dados por `ValueListenableBuilder` sobre esses `ValueNotifier`, então trocar a origem dos dados mexe pouco nas telas.

### 1.3 O que mudou desde a primeira análise

| Antes (15/10) | Agora |
| --- | --- |
| Pagar um serviço sem agendamento (E4) | O pagamento sai de um agendamento (`Repositorio.proximoAPagar`, `marcarComoPago`) |
| Placa duplicada aceita (E7) | `Repositorio.placaExiste` bloqueia, já normalizando o hífen |
| Agendamento sem status | `StatusServico` (pendente, em andamento, concluído) e tela **Acompanhar** com `StatusChip` |
| Veículo só podia ser criado | Editar e excluir; não exclui veículo com serviço não concluído |
| Serviços fixos com ícone e id textual | 4 serviços de exemplo ("Serviço 1..4"), à espera da API |

### 1.4 Problemas que continuam (e o que a API resolve)

| # | Problema | Onde | Resolvido pela API? |
| --- | --- | --- | --- |
| E1 | `sdk: ^3.13.2` exige um patch de Dart mais novo que o instalado em algumas máquinas; `flutter pub get` falha | `pubspec.yaml:8` | Não. Trocar para `^3.13.0` |
| E2 | Logout limpa só o CPF; veículos e agendamentos do usuário anterior ficam na memória | `perfil_cliente.dart:110`, `sessao.dart` | Sim, se o logout limpar token **e** repositórios |
| E3 | Login aceita qualquer CPF válido com a senha fixa `1234` | `login_cliente.dart:22,55` | Sim (`POST /auth/login`) |
| E5 | Pagamento é simulado: um diálogo e `marcarComoPago` local | `pagamento.dart:35-66` | Parcial: ver 3.6, fase 2 |
| E6 | Horário livre (qualquer hora, inclusive 03:00), sem checar conflito | `novo_agendamento.dart:51-62` | Sim, com `GET /horarios` |
| E8 | "Próximo agendamento" é o primeiro não concluído da lista, mesmo que a data já tenha passado | `repositorio.dart:119` | Sim, filtrando pela data que vem da API |
| L1 | Agendamento com **um** serviço; o backend modela N (`agendamento_servico`) | `models/agendamento.dart` | Exige mudar a tela para seleção múltipla |
| L2 | `Veiculo` **sem `marca`**, que é `NOT NULL` no banco | `models/veiculo.dart` | Exige campo novo no formulário |
| L3 | Cancelar **remove** o item; no banco o status vira `CANCELADO` e o histórico fica | `repositorio.dart:94` | Sim, mostrando o status |
| L4 | O botão de demonstração da tela Acompanhar deixa o **cliente** mudar o status do serviço | `acompanhar_servicos.dart:134` | Remover: só o colaborador muda (`/admin`) |
| L5 | `id` de `Servico`, `Veiculo` e `Agendamento` é `String`; no banco é `INT` | `core/models/` | Trocar para `int` |
| L6 | Sem tela de cadastro no app | — | Não precisa: o cadastro é no site (`/cadastro` → `/baixar-app`). Ver 2.3 |
| L7 | Permissão `INTERNET` só nos manifests `debug/` e `profile/` | `android/app/src/` | Adicionar no `main/` antes do build *release* |

---

## Parte 2: o backend Java hoje

### 2.1 Estado geral

- **Compila** (`mvn -o compile` sem erros, Java 25). Os problemas de visibilidade e de rota duplicada citados na versão anterior foram resolvidos.
- **A camada de dados é só de DAOs** (`DAOCliente`, `DAOVeiculo`, `DAOServico`, `DAOAgendamento`, `DAOAtendimento`, `DAOPagamento`, `DAOColaborador`), com instâncias públicas e DTOs `record` em `model.dto`.
- **Há um `Dockerfile` real:** build com Maven + Temurin 25, runtime `tomcat:10.1-jre25`, WAR publicado como `ROOT.war`, porta lida de `$PORT` (Render).
- **`com.splash.web.api.Handler`** foi criado vazio, importando `com.sun.net.httpserver.HttpServer`. A seção 3.1 discute essa escolha.

### 2.2 A área do cliente no site foi retirada

Os últimos commits removeram de `WEB-INF/views` as telas do cliente. Hoje estes servlets fazem `forward` para JSPs que **não existem** e respondem erro:

| Servlet | Rota | JSP que falta |
| --- | --- | --- |
| `LoginServlet` | `/login` | `/WEB-INF/views/login.jsp` |
| `PortalServlet` | `/portal` | `/WEB-INF/views/portal.jsp` |
| `VeiculoServlet` | `/veiculos` | `/WEB-INF/views/veiculos.jsp` |
| `AgendamentoServlet` | `/agendamentos` | `/WEB-INF/views/agendamentos.jsp` |
| `SetupAdminServlet` | `/setup/admin` | `/WEB-INF/views/setup-admin.jsp` (o arquivo está na raiz do `webapp/`) |

Isso combina com o fluxo novo: o site faz **cadastro** (`/cadastro` → `/baixar-app`) e o **painel do colaborador** (`/admin/*`); a **área do cliente passa a ser o app**. Então a API não é um extra: ela substitui esses quatro primeiros servlets. Quando a API cobrir as mesmas operações, eles podem ser removidos (e o `openapi.yml` atualizado). `SetupAdminServlet` é do colaborador e precisa só do caminho corrigido.

### 2.3 O que o app precisa x o que os DAOs já fazem

| Necessidade do app | Método existente | Lacuna |
| --- | --- | --- |
| Login | `DAOCliente.autenticar(email, senha)` → `ClienteView` | O app entra por **CPF**. Falta `autenticarPorCpf` (ou o app passa a usar e-mail) |
| Perfil | `DAOCliente.getusuario(id)` → `Cliente` | Devolve o model; a API deve montar a resposta sem expor campos internos |
| Editar perfil | `DAOCliente.updateUsuarios(id, nome, telefone, email)` | — |
| Cadastro | `new Cliente(...)` + `Passwords.hash` + `DAOCliente.insertUsuario` | Já existe no site; no app é opcional |
| Serviços | `DAOServico.listar()` → `List<ServicoView>` | — |
| Veículos | `DAOVeiculo.listarPorCliente`, `inserir`, `remover` | **Sem update** (o app edita veículo). `inserir` não remove o hífen: usar `Validacao.placa` antes |
| Agendar | `DAOAgendamento.criar(idCliente, idVeiculo, data, horario, idsServicos)` | — (transação completa: serviços, atendimento e pagamento `PENDENTE`) |
| Meus agendamentos | `DAOAgendamento.listarPorCliente` → `AgendamentoView` | Não traz os **nomes dos serviços** nem o **status do atendimento** que a tela Acompanhar usa |
| Cancelar | `DAOAgendamento.cancelar(idCliente, id)` → `boolean` | — |
| Horários livres | — | Falta `horariosOcupados(data)` e a regra de capacidade (o `UNIQUE` do banco é por veículo, não por box) |
| Pagar | `DAOPagamento.atualizar(idPagamento, status, forma)` | É operação do colaborador. Para o cliente escolher a forma, falta um método restrito ao dono (fase 2) |

Pela regra do `CLAUDE.md`, os métodos que faltam **não** foram criados agora; eles entram quando cada rota for implementada, na seção certa do DAO (`Listagem`, `Update`...).

### 2.4 Equivalência de domínio Java ↔ Dart

| Conceito | Java / banco | Dart hoje | Ação no app |
| --- | --- | --- | --- |
| Serviço | `ServicoView(int id, nome, descricao, BigDecimal preco)` | `Servico(String id, nome, descricao, double preco, icone)` | `id` → `int`; `preco` vem como número JSON |
| Veículo | `VeiculoView(int id, placa, marca, modelo, cor)`; placa sem hífen | `Veiculo(String id, modelo, placa, cor)` | Adicionar `marca`; mostrar a placa com máscara |
| Agendamento | `AgendamentoView(id, placa, veiculo, data, horario, status, total, statusPagamento, formaPagamento)` | `Agendamento(id, servico, veiculo, dataHora, status, pago)` | `servicos: List`, `total`, `status` |
| Status do agendamento | `AGENDADO`, `CANCELADO`, `CONCLUIDO` | — | Enum Dart novo |
| Status do atendimento | `AGUARDANDO`, `EM_LAVAGEM`, `FINALIZADO`, `ENTREGUE` | `StatusServico`: pendente, emAndamento, concluido | `AGUARDANDO`→pendente, `EM_LAVAGEM`→emAndamento, `FINALIZADO`/`ENTREGUE`→concluido (ou ganhar o 4º estado) |
| Pagamento | `StatusPagamento` `PENDENTE`/`PAGO`/`CANCELADO`; `FormaPagamento` `DINHEIRO`/`PIX`/`CREDITO`/`DEBITO` | `bool pago`; forma como texto | `pago` = `statusPagamento == "PAGO"` |
| Horário | `TIME` → `String` `"09:00:00"` | `DateTime dataHora` | Juntar `data` + `horario` no `fromJson` |

---

## Parte 3: a API para o mobile, em Java puro

### 3.1 Servlet ou `com.sun.net.httpserver`?

Os dois são "Java puro" (nenhum é framework). A diferença é **onde a API roda**:

| Critério | **A. Servlets no mesmo WAR** (`jakarta.servlet`) | **B. `HttpServer` do JDK** (módulo `jdk.httpserver`) |
| --- | --- | --- |
| Onde roda | No Tomcat que já existe, mesma porta, mesmo deploy | Processo próprio, com `main` e porta própria |
| Render | Funciona sem mudança: a API fica em `https://<app>.onrender.com/api/v1` | O Render expõe **uma** porta por serviço, a do Tomcat. Exige um segundo serviço (outro Dockerfile, outro custo/limite) ou trocar o Tomcat pelo `HttpServer` |
| Rotas | `@WebServlet("/api/v1/veiculos/*")` + `getPathInfo()` | `server.createContext("/api/v1/veiculos", handler)` + `exchange.getRequestURI()` |
| Filtros (auth, CORS) | `@WebFilter` / `HttpFilter` | `com.sun.net.httpserver.Filter` adicionado em cada `HttpContext` |
| Corpo e cabeçalhos | `request.getInputStream()`, `getHeader`, `response.setStatus` | `exchange.getRequestBody()`, `getRequestHeaders()`, `sendResponseHeaders(status, tamanho)` |
| Threads | Pool do Tomcat | Você define: `server.setExecutor(Executors.newVirtualThreadPerTaskExecutor())` |
| Empacotamento | Nada muda (`mvn package` → WAR) | Precisa de um JAR executável com dependências (plugin `maven-shade` ou `maven-assembly`) além do WAR |
| Reuso | DAOs, `Passwords`, `Validacao`, `EncodingFilter`, testes com Mockito | DAOs e `Validacao` sim; filtro de encoding e testes de servlet não |

**Recomendação: A (Servlets no mesmo WAR).** Já é a tecnologia do projeto e da disciplina, não aumenta o deploy e os DAOs são chamados do mesmo jeito que nos servlets JSP. O `Handler.java` atual pode ser apagado (ou ficar só se a equipe escolher B).

Se a equipe preferir B mesmo assim, o esqueleto é:

```java
public static void main(String[] args) throws IOException {
    int porta = Integer.parseInt(System.getenv().getOrDefault("API_PORT", "8081"));
    HttpServer server = HttpServer.create(new InetSocketAddress(porta), 0);
    HttpContext veiculos = server.createContext("/api/v1/veiculos", new VeiculoHandler());
    veiculos.getFilters().add(new AuthFilter());       // com.sun.net.httpserver.Filter
    server.setExecutor(Executors.newVirtualThreadPerTaskExecutor());
    server.start();
}
```

Nesse caso, o restante deste documento continua valendo; muda só a "casca" (`HttpExchange` no lugar de `HttpServletRequest/Response`).

### 3.2 Módulos e bibliotecas

**Do JDK 25 (nada a instalar)**

| Módulo / pacote | Uso na API |
| --- | --- |
| `java.base` → `java.time` | `LocalDate`, `LocalTime`, `Instant`, `Duration` (datas do agendamento, expiração do token) |
| `java.base` → `java.util.Base64` | Codificação *base64url* do token |
| `java.base` → `javax.crypto.Mac`, `SecretKeySpec` | Assinatura HMAC-SHA256 do token |
| `java.base` → `java.security.MessageDigest` | `MessageDigest.isEqual` para comparar assinaturas em tempo constante |
| `java.base` → `java.security.SecureRandom` | Gerar segredos ou tokens opacos, se a equipe preferir |
| `java.base` → `java.util.concurrent` | *Virtual threads* (só na opção B) |
| `java.sql` | JDBC, já usado pelos DAOs; `SQLIntegrityConstraintViolationException` → 409 |
| `java.net.http` | `HttpClient` para testes de ponta a ponta da API em Java (alternativa ao `curl`) |
| `jdk.httpserver` | `com.sun.net.httpserver.*`, **só na opção B** |

**Da API Jakarta Servlet 6.1 (o Tomcat 10.1 já fornece; `provided` no `pom.xml`)**

`HttpServlet` (`doGet`/`doPost`/`doPut`/`doDelete`), `@WebServlet`, `HttpFilter` + `@WebFilter`, `HttpServletRequest#getPathInfo`, `getInputStream`, `getHeader`, `setAttribute`, e `@WebListener` + `ServletContextListener` (para falhar no deploy se `JWT_SECRET` não existir).

**Já no `pom.xml`**

| Biblioteca | Uso na API |
| --- | --- |
| `mysql-connector-j` 9.7.0 | Driver JDBC (DAOs) |
| `jbcrypt` 0.4 (via `security.Passwords`) | Conferir a senha no login |
| `dotenv-java` 3.2.0 | Configuração do banco; o `JWT_SECRET` segue o padrão de `INITIAL_ADMIN_TOKEN` (`System.getenv`) |
| `junit-jupiter` 6.0.3 + `mockito-junit-jupiter` 5.23.0 | Testes dos servlets da API com `HttpServletRequest`/`Response` mockados, como em `DAOClienteTest` |

**A adicionar**

| Biblioteca | Versão (Maven Central, 22/10/2026) | Por quê | Alternativas |
| --- | --- | --- | --- |
| `com.fasterxml.jackson.core:jackson-databind` | 2.22.4 | Ler e escrever JSON. Serializa os `record` de `model.dto` direto e lê o corpo das requisições em `record`s. Escrever um *parser* JSON à mão não compensa | `gson` 2.14.0 (mais simples, precisa de adaptador para `LocalDate`); JSON-B com `org.eclipse:yasson` 3.0.5 (padrão Jakarta); Jackson 3 (`tools.jackson.core:jackson-databind` 3.2.4, já trata `java.time`, mas tem menos material de estudo) |
| `com.fasterxml.jackson.datatype:jackson-datatype-jsr310` | 2.22.4 | `LocalDate`/`LocalTime` como `"2026-10-20"` / `"09:00"` | — |

```xml
<!-- API JSON para o app mobile -->
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-databind</artifactId>
    <version>2.22.4</version>
</dependency>
<dependency>
    <groupId>com.fasterxml.jackson.datatype</groupId>
    <artifactId>jackson-datatype-jsr310</artifactId>
    <version>2.22.4</version>
</dependency>
```

**Opcionais**

| Biblioteca | Quando usar |
| --- | --- |
| `com.auth0:java-jwt` 4.6.2 | Se a equipe não quiser escrever o JWT à mão (3.4). Faz o mesmo com menos código próprio |
| `com.zaxxer:HikariCP` 7.1.0 | Pool de conexões. Hoje cada chamada de DAO abre uma conexão nova pelo `DriverManager`; com o app gerando mais requisições, um pool reduz a latência. Mudaria só o `DatabaseConnection` |

**Não usar:** Spring / Spring Boot, JAX-RS (Jersey, RESTEasy), Lombok. Nenhum é necessário para o tamanho desta API.

### 3.3 Estrutura do pacote `com.splash.web.api`

```
api/
  Json.java                 ObjectMapper único; ler(corpo), enviar(status, objeto), erro(status, mensagem)
  Tokens.java               emitir(idCliente) e validar(token): JWT HS256 com javax.crypto
  ApiAuthFilter.java        @WebFilter("/api/v1/*"): valida "Authorization: Bearer", põe idCliente no request
  ApiSupport.java           segmentos do getPathInfo(), conversão de exceções em HTTP (tabela 3.7)
  AuthApiServlet.java       /api/v1/auth/*          login (e cadastro, se o app tiver a tela)
  PerfilApiServlet.java     /api/v1/me
  ServicoApiServlet.java    /api/v1/servicos
  VeiculoApiServlet.java    /api/v1/veiculos/*
  AgendamentoApiServlet.java /api/v1/agendamentos/*
  HorarioApiServlet.java    /api/v1/horarios
  requisicao/               records de ENTRADA: LoginRequisicao, NovoVeiculo, NovoAgendamento...
```

Regras que seguem o `CLAUDE.md`:

- Os servlets da API **chamam os DAOs direto**, como os servlets JSP (`new DAOVeiculo().listarPorCliente(id)`).
- As **respostas** usam os DTOs de `model.dto` (`ServicoView`, `VeiculoView`, `AgendamentoView`...). O Jackson lê os `record` pelos componentes, e os getters `getX()` criados para o EL dão o mesmo nome de propriedade, então o JSON sai igual.
- As **entradas** (corpo JSON) são `record`s próprios em `api.requisicao`, **nunca** os DTOs de `model.dto`. O servlet converte a entrada em argumentos do DAO ou em model (`new Cliente(...)`, que valida via `Validacao`).
- Código, nomes e mensagens em português.

### 3.4 Autenticação sem sessão (JWT HS256 com o JDK)

O app não usa cookie `JSESSIONID`. Fluxo:

1. `POST /api/v1/auth/login` com `{"cpf": "52998224725", "senha": "..."}`.
2. O DAO confere com `Passwords.matches` e devolve `ClienteView`; a API responde `{"token": "...", "cliente": {"id": 1, "nome": "...", "email": "..."}}`.
3. O app manda `Authorization: Bearer <token>` em toda chamada. O `ApiAuthFilter` libera sem token só `/api/v1/auth/*`, `GET /api/v1/servicos` e `OPTIONS`.
4. **O `idCliente` vem sempre do token, nunca do corpo.** Os DAOs já recebem `idCliente` (`listarPorCliente`, `remover(idCliente, idVeiculo)`, `cancelar(idCliente, id)`), então um cliente não altera dados de outro.

Token feito só com o JDK (`Tokens.java`):

```java
final class Tokens {

    private static final Base64.Encoder B64 = Base64.getUrlEncoder().withoutPadding();
    private static final Base64.Decoder B64D = Base64.getUrlDecoder();
    private static final String CABECALHO = B64.encodeToString(
            "{\"alg\":\"HS256\",\"typ\":\"JWT\"}".getBytes(StandardCharsets.UTF_8));
    private static final Duration VALIDADE = Duration.ofHours(12);

    static String emitir(int idCliente) {
        long expira = Instant.now().plus(VALIDADE).getEpochSecond();
        String corpo = B64.encodeToString(("{\"sub\":" + idCliente + ",\"exp\":" + expira + "}")
                .getBytes(StandardCharsets.UTF_8));
        String conteudo = CABECALHO + "." + corpo;
        return conteudo + "." + B64.encodeToString(assinar(conteudo));
    }

    // Devolve o id do cliente, ou null se o token for inválido ou estiver expirado
    static Integer validar(String token) {
        try {
            String[] partes = token.split("\\.");
            if (partes.length != 3 || !partes[0].equals(CABECALHO)) {
                return null;
            }
            byte[] esperada = assinar(partes[0] + "." + partes[1]);
            if (!MessageDigest.isEqual(esperada, B64D.decode(partes[2]))) {   // tempo constante
                return null;
            }
            JsonNode claims = Json.MAPPER.readTree(B64D.decode(partes[1]));
            if (claims.path("exp").asLong() < Instant.now().getEpochSecond()) {
                return null;
            }
            return claims.path("sub").asInt();
        } catch (IllegalArgumentException | IOException exception) {
            return null;
        }
    }

    private static byte[] assinar(String conteudo) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(segredo(), "HmacSHA256"));
            return mac.doFinal(conteudo.getBytes(StandardCharsets.UTF_8));
        } catch (GeneralSecurityException exception) {
            throw new IllegalStateException("Falha ao assinar o token.", exception);
        }
    }

    private static byte[] segredo() {
        String valor = System.getenv("JWT_SECRET");
        if (valor == null || valor.length() < 32) {
            throw new IllegalStateException("Defina JWT_SECRET com ao menos 32 caracteres.");
        }
        return valor.getBytes(StandardCharsets.UTF_8);
    }
}
```

- `JWT_SECRET`: gerar com `openssl rand -base64 48`, configurar no Render e localmente, e registrar em `miscelaneous/variaveis-de-ambiente.md`. Trocar o segredo desloga todo mundo.
- Um `@WebListener` pode chamar `Tokens.emitir(0)` no `contextInitialized` para o deploy falhar logo se o segredo faltar, em vez de falhar no primeiro login.
- Alternativa equivalente: `com.auth0:java-jwt` (`JWT.create().withSubject(...).withExpiresAt(...).sign(Algorithm.HMAC256(segredo))`).
- Login por CPF: adicionar `DAOCliente.autenticarPorCpf(cpf, senha)` na seção de Listagem, igual a `autenticar` mas com `WHERE cpf = ?` (coluna já `UNIQUE`). Normalizar o CPF para só dígitos antes da consulta.

### 3.5 Endpoints (v1, área do cliente)

Base: `/api/v1`. Corpo e resposta em `application/json; charset=UTF-8`. Datas `yyyy-MM-dd`, horários `HH:mm`.

| Método | Rota | Corpo → resposta | DAO | Substitui no app |
| --- | --- | --- | --- | --- |
| POST | `/auth/login` | `{cpf, senha}` → `200 {token, cliente}` | `DAOCliente.autenticarPorCpf` *(novo)* | senha fixa em `LoginCliente` |
| POST | `/auth/cadastro` *(opcional)* | `{nome, cpf, telefone, email, senha}` → `201` | `new Cliente(...)` + `insertUsuario` | — (hoje o cadastro é no site) |
| GET | `/me` | → `{id, nome, cpf, telefone, email}` | `DAOCliente.getusuario` | nome fixo do Perfil |
| PATCH | `/me` | `{nome, telefone, email}` → `204` | `DAOCliente.updateUsuarios` | *(novo)* |
| GET | `/servicos` *(pública)* | → `[{id, nome, descricao, preco}]` | `DAOServico.listar` | `Repositorio.definirServicos` |
| GET | `/veiculos` | → `[{id, placa, marca, modelo, cor}]` | `DAOVeiculo.listarPorCliente` | `Repositorio.veiculos` |
| POST | `/veiculos` | `{placa, marca, modelo, cor}` → `201` | `Validacao.placa` + `DAOVeiculo.inserir` | `adicionarVeiculo` |
| PUT | `/veiculos/{id}` | `{placa, marca, modelo, cor}` → `204` | `DAOVeiculo` update *(novo)* | `atualizarVeiculo` |
| DELETE | `/veiculos/{id}` | → `204`; `409` se tiver agendamento | `DAOVeiculo.remover` | `removerVeiculo` |
| GET | `/agendamentos` | → `[{id, placa, veiculo, data, horario, status, total, statusPagamento, formaPagamento}]` | `DAOAgendamento.listarPorCliente` | `Repositorio.agendamentos` |
| POST | `/agendamentos` | `{idVeiculo, data, horario, idsServicos: [1,2]}` → `201` | `DAOAgendamento.criar` | `adicionarAgendamento` |
| POST | `/agendamentos/{id}/cancelar` | → `204`; `409` se não estiver `AGENDADO` | `DAOAgendamento.cancelar` | `cancelarAgendamento` |
| GET | `/horarios?data=2026-10-23` | → `["08:00","08:30",...]` | *(novo)* | corrige E6 |

Ajustes de DAO pedidos por esses endpoints:

1. **`AgendamentoView` + `listarPorCliente`:** incluir `servicos` (`GROUP_CONCAT(s.nome)`) e `statusAtendimento` (`LEFT JOIN atendimento`). Só **acrescenta** componentes e getters, então as JSPs do painel não mudam.
2. **`DAOVeiculo`:** update restrito ao dono (`WHERE id_cliente = ? AND id_veiculo = ?`).
3. **Exclusão de veículo:** o banco usa `ON DELETE RESTRICT` em `agendamento`, então um veículo com **qualquer** agendamento (mesmo concluído ou cancelado) não sai: a API responde 409. A regra do app ("só bloqueia se houver serviço não concluído") precisa seguir a do banco.
4. **Horários:** definir a regra (funcionamento, intervalo, quantos carros por horário). O `UNIQUE (id_veiculo, data, horario)` impede só o mesmo carro duas vezes no mesmo horário.

**Fase 2:** `PUT /agendamentos/{id}/pagamento {forma}` (cliente escolhe a forma; o colaborador confirma `PAGO` no painel) e rotas do colaborador (`/api/v1/colaborador/*`, com o nível de acesso no token), reaproveitando `DAOAtendimento` e `DAOPagamento`.

### 3.6 Padrão de código

`Json.java`:

```java
public final class Json {

    static final ObjectMapper MAPPER = JsonMapper.builder()
            .addModule(new JavaTimeModule())
            .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS)
            .disable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES)
            .build();

    private Json() {
    }

    static <T> T ler(HttpServletRequest request, Class<T> tipo) throws IOException {
        try {
            return MAPPER.readValue(request.getInputStream(), tipo);
        } catch (JsonProcessingException exception) {
            throw new IllegalArgumentException("JSON inválido.");
        }
    }

    static void enviar(HttpServletResponse response, int status, Object corpo) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        MAPPER.writeValue(response.getOutputStream(), corpo);
    }

    static void erro(HttpServletResponse response, int status, String mensagem) throws IOException {
        enviar(response, status, Map.of("erro", mensagem));
    }
}
```

`ApiAuthFilter.java`:

```java
@WebFilter("/api/v1/*")
public class ApiAuthFilter extends HttpFilter {

    @Override
    protected void doFilter(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        String rota = request.getRequestURI().substring(request.getContextPath().length());
        if (rotaPublica(request.getMethod(), rota)) {
            chain.doFilter(request, response);
            return;
        }
        String cabecalho = request.getHeader("Authorization");
        Integer idCliente = cabecalho != null && cabecalho.startsWith("Bearer ")
                ? Tokens.validar(cabecalho.substring(7)) : null;
        if (idCliente == null) {
            Json.erro(response, HttpServletResponse.SC_UNAUTHORIZED, "Sessão expirada. Entre novamente.");
            return;
        }
        request.setAttribute("idCliente", idCliente);
        chain.doFilter(request, response);
    }

    private static boolean rotaPublica(String metodo, String rota) {
        return "OPTIONS".equals(metodo) || rota.startsWith("/api/v1/auth/")
                || ("GET".equals(metodo) && rota.equals("/api/v1/servicos"));
    }
}
```

`AgendamentoApiServlet.java` (resumo):

```java
@WebServlet("/api/v1/agendamentos/*")
public class AgendamentoApiServlet extends HttpServlet {

    record NovoAgendamento(Integer idVeiculo, LocalDate data, LocalTime horario, List<Integer> idsServicos) {
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int idCliente = (int) request.getAttribute("idCliente");
        try {
            Json.enviar(response, 200, new DAOAgendamento().listarPorCliente(idCliente));
        } catch (SQLException exception) {
            ApiSupport.erroBanco(request, response, exception);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int idCliente = (int) request.getAttribute("idCliente");
        String[] partes = ApiSupport.segmentos(request);   // "" -> [], "/12/cancelar" -> ["12", "cancelar"]
        try {
            if (partes.length == 0) {
                NovoAgendamento corpo = Json.ler(request, NovoAgendamento.class);
                if (corpo.idVeiculo() == null || corpo.data() == null || corpo.horario() == null
                        || corpo.data().isBefore(LocalDate.now()) || corpo.idsServicos() == null) {
                    throw new IllegalArgumentException("Selecione um veículo, ao menos um serviço e uma data válida.");
                }
                new DAOAgendamento().criar(idCliente, corpo.idVeiculo(), corpo.data(),
                        corpo.horario().toString(), corpo.idsServicos());
                response.setStatus(HttpServletResponse.SC_CREATED);
            } else if (partes.length == 2 && "cancelar".equals(partes[1])) {
                Integer id = ApiSupport.inteiro(partes[0]);
                if (id == null || !new DAOAgendamento().cancelar(idCliente, id)) {
                    Json.erro(response, 409, "Agendamento não encontrado ou não pode mais ser cancelado.");
                    return;
                }
                response.setStatus(HttpServletResponse.SC_NO_CONTENT);
            } else {
                Json.erro(response, 404, "Rota não encontrada.");
            }
        } catch (IllegalArgumentException exception) {
            Json.erro(response, 400, exception.getMessage());
        } catch (SQLException exception) {
            ApiSupport.erroBanco(request, response, exception);   // SQLState 23xxx -> 409, resto -> 500
        }
    }
}
```

A validação de entrada repete a de `AgendamentoServlet`. Se os dois continuarem existindo, vale extrair essa checagem para um método comum; se o servlet JSP for removido (2.2), o problema some.

### 3.7 Mapeamento de erros (igual em toda a API)

Formato: `{"erro": "mensagem para o usuário"}`.

| Situação | HTTP |
| --- | --- |
| `IllegalArgumentException` (JSON inválido, `Validacao`, regra do DAO) | 400 |
| Token ausente, inválido ou expirado | 401 |
| Recurso de outro cliente ou id inexistente | 404 (não revela que o recurso existe) |
| `SQLException` com SQLState `23xxx` (CPF/e-mail/placa duplicados, veículo com agendamento, horário ocupado) | 409 |
| `cancelar` devolve `false` (já cancelado ou concluído) | 409 |
| `IllegalStateException` (transição de status inválida) | 422 |
| Outra `SQLException` | 500, com `getServletContext().log(...)` como em `WebSupport.erroBanco` |

**CORS:** só é necessário se o app rodar como **Flutter Web**. Android e iOS nativos não usam CORS. Se precisar, um `@WebFilter("/api/v1/*")` que responde `OPTIONS` e envia `Access-Control-Allow-Origin` / `-Headers: Authorization, Content-Type`.

### 3.8 Mudanças no app Flutter

1. **Pacotes:** `flutter pub add http flutter_secure_storage` (versões atuais do pub.dev). JSON usa `dart:convert` (já vem no SDK). Corrigir o SDK para `^3.13.0` (E1).
2. **URL base por `--dart-define`:**
   ```dart
   const apiBaseUrl = String.fromEnvironment('API_URL',
       defaultValue: 'http://10.0.2.2:8080/SplashFast/api/v1'); // 10.0.2.2 = localhost do PC visto pelo emulador
   ```
   Celular físico: IP do PC na rede (`--dart-define=API_URL=http://192.168.0.10:8080/SplashFast/api/v1`). Render: `https://<app>.onrender.com/api/v1` (WAR como `ROOT.war`, sem `/SplashFast`).
3. **`core/api/api_client.dart`:** envolve `http.Client`, adiciona `Authorization: Bearer`, decodifica JSON, transforma não-2xx em `ApiException(status, erro)` e, no 401, apaga o token e volta ao login. Timeout generoso (cerca de 60 s): o Render gratuito "dorme" e a primeira chamada demora.
4. **Models com `fromJson`:** `id` como `int` em todos; `Veiculo.marca`; `Agendamento` com `servicos`, `total`, `status`, `statusAtendimento` (→ `StatusServico`) e `pago` derivado de `statusPagamento`.
5. **`Repositorio`:** manter os `ValueNotifier` e trocar os métodos síncronos por `Future`s que chamam a API e depois atualizam a lista (`carregarServicos`, `carregarVeiculos`, `carregarAgendamentos`). As telas continuam com `ValueListenableBuilder` e ganham estado de carregando/erro.
6. **`Sessao`:** guardar o token no `flutter_secure_storage` em vez de `Sessao.cpf`; logout apaga o token **e** limpa os repositórios (E2).
7. **Telas:** `LoginCliente` chama a API e mostra a mensagem do servidor; `NovoAgendamento` com vários serviços e horários de `GET /horarios`; `Agendamentos` mostra o status em vez de remover; `MeusVeiculos` com campo **Marca**; `AcompanharServicos` sem o botão de mudar status (L4); `Pagamento` deixa de marcar como pago localmente.
8. **Android:** `<uses-permission android:name="android.permission.INTERNET"/>` em `android/app/src/main/AndroidManifest.xml`. Enquanto o teste local for em `http://`, `android:usesCleartextTraffic="true"` **só no manifest de debug**; produção (Render) já é HTTPS.

### 3.9 Implantação

| Ambiente | URL da API | Observações |
| --- | --- | --- |
| Tomcat local (`webapps/SplashFast.war`) | `http://localhost:8080/SplashFast/api/v1` | `.env` em `/var/lib/tomcat10` (ver `CLAUDE.md`); exportar `JWT_SECRET` no ambiente do Tomcat |
| Docker local (`docker build -t splashfast .`) | `http://localhost:10000/api/v1` | `docker run -p 10000:10000 -e ENV_DEV=PROD -e PROD_DB_URL=... -e JWT_SECRET=... splashfast` |
| Render | `https://<app>.onrender.com/api/v1` | Adicionar `JWT_SECRET` nas variáveis do serviço. Nenhuma mudança no `Dockerfile` (opção A) |

Na opção B (`HttpServer`), seria preciso um segundo serviço no Render com outro `Dockerfile` rodando `java -jar api.jar`.

### 3.10 Testes

- **Servlets da API:** JUnit + Mockito, mockando `HttpServletRequest`/`HttpServletResponse` (corpo via `getInputStream`, saída num `ByteArrayOutputStream`) e `mockStatic(DatabaseConnection.class)` como em `DAOClienteTest`.
- **`Tokens`:** emitir/validar, token adulterado, token expirado, segredo ausente.
- **Ponta a ponta:** `curl` ou `java.net.http.HttpClient` contra o Tomcat local com o `seed.sql` (ver `teste-ponta-a-ponta-tomcat-local.md`).

### 3.11 Ordem sugerida

1. Decidir A ou B (recomendado A) e apagar ou adaptar `api/Handler.java`.
2. Adicionar Jackson ao `pom.xml`; criar `Json`, `Tokens`, `ApiAuthFilter`, `ApiSupport`; configurar `JWT_SECRET`.
3. `DAOCliente.autenticarPorCpf` + `POST /auth/login` + `GET /servicos`; testar com `curl`. No app: `ApiClient`, login real e serviços da API.
4. Veículos (com marca e update) e `GET /me`.
5. Agendamentos: estender `AgendamentoView`, criar/listar/cancelar; depois `GET /horarios`.
6. Documentar as rotas `/api/v1/*` no `openapi.yml` e remover os servlets JSP do cliente que ficaram sem tela (2.2).
7. Permissão `INTERNET` no manifest principal e build *release* apontando para o Render.
8. Fase 2: pagamento pelo cliente e área do colaborador no app.
