# Visão geral v2 — estado do projeto (2026-11-11)

Sucessora de `analise-geral-v1.md` (2026-10-16). Análise somente leitura, feita por 4 subagentes (backend, views/frontend, banco/testes/build, app mobile) sobre a branch `main` (commit `d8a9b34`, árvore limpa). Nada foi compilado nem executado nesta análise; os pontos abaixo vêm de leitura de código e podem conter imprecisões marcadas como "a confirmar".

**Por que existe:** registrar o estado real após a migração para DAOs por tabela, o painel administrativo, a exclusão lógica e o esqueleto da API v1, e listar o que ainda bloqueia o MVP.
**Como se liga ao projeto:** serve de mapa de pendências; substitui a v1 como referência e complementa `repositorios-removidos-e-cadastro-unico.md`, `teste-ponta-a-ponta-tomcat-local.md` e `openapi.yml`.

---

## 1. Resumo executivo

- Projeto compila (69 fontes) e gera `target/SplashFast.war`. Servlets + JSP + JDBC puro, Tomcat 10.1, Java 25.
- Camada de DAOs por tabela e DTOs `*View` concluída; `LavaRapidoRepository` e `ClienteRepository` não existem mais.
- Painel de colaboradores (clientes, carros, agendamentos, atendimentos, pagamentos, serviços, colaboradores) lê do banco; sem dados mockados nos painéis.
- Exclusão lógica (`ativo`, `excluido_em`) em cliente, veículo, serviço e colaborador.
- API REST `/api/v1` existe só como esqueleto: JWT e filtro de autenticação são stubs.
- App Flutter funciona isolado, em memória, sem rede.

### Bloqueios principais (ordem sugerida)

1. `/agendamentos` do cliente provavelmente quebra (`DAOAgendamento.listarPorCliente` lê coluna inexistente).
2. `/login` e `/portal` fazem forward para JSPs que não existem; sessão expirada de cliente cai em tela inexistente.
3. `/setup/admin` quebra (JSP no lugar errado) e o seed bloqueia o setup mesmo assim.
4. Seed com hashes falsos: ninguém do seed consegue logar.
5. Cadastro público (`/cadastro`) redireciona para tela que exige login de colaborador e não mostra erros.
6. `/api/v1/*` sem autenticação (filtro e JWT stubs) e com possível IDOR.
7. XSS armazenado na página pública (`index.jsp:108-109`).
8. Sem proteção CSRF; sem filtro central de autorização.

---

## 2. Backend (`src/main/java/com/splash/web/`)

### 2.1 Estrutura
- `model/`: `EntidadeBase`, `Pessoa`, `Cliente`, `Colaborador`, `Veiculo`, `Agendamento`, `ItemAgendamento`, `Atendimento`, `Pagamento`, `Servico`, `Validacao`; `model/dto/` com 7 records `*View`; `model/enums/` com 5 enums.
- `db/`: `DatabaseConnection` (dotenv + `DriverManager`, sem pool) e 7 DAOs.
- `security/`: só `Passwords` (BCrypt custo 12).
- `servlet/`: 15 classes (inclui `WebSupport`, `EncodingFilter`).
- `api/`: `ApiAuthFilter`, `ApiServlet`, `Json`, `jwt/JwtService`, `dto/*`, `v1/*` (6 servlets).
- `web.xml` só tem `display-name` e `welcome-file`: sem `error-page`, `session-config`, `security-constraint`.

### 2.2 Rotas e acesso
Hierarquia em `WebSupport`: ADMINISTRADOR(3) > ATENDENTE(2) > OPERACIONAL(1). Sem sessão de colaborador: redirect para `/colaborador/login`; nível insuficiente: 403; cliente sem sessão: redirect para `/login`.

| Rota | Acesso |
|---|---|
| `/`, `/health`, `/baixar-app`, `/login`, `/colaborador/login`, `/cadastro` | públicas |
| `/setup/admin` | pública, exige `INITIAL_ADMIN_TOKEN` e nenhum admin existente |
| `/portal`, `/veiculos`, `/agendamentos` | cliente |
| `/clientes` | OPERACIONAL+ |
| `/servicos` | ADMINISTRADOR |
| `/admin/*` | inicio/atendimentos OPERACIONAL; pagamentos ATENDENTE; servicos/colaboradores ADMINISTRADOR |
| `/admin/veiculos` (POST) | OPERACIONAL+ |
| `/painel/*` (GET) | clientes/carros/agendamentos/atendimentos OPERACIONAL; pagamentos ATENDENTE; servicos/colaboradores ADMINISTRADOR |
| `/api/v1/*` | sem autenticação efetiva (ver 2.5) |

Controle de acesso é feito servlet a servlet. Servlet novo que esqueça a checagem fica aberto.

### 2.3 O que está pronto
- Login de cliente e colaborador com BCrypt; sessão regenerada no login.
- Todo SQL usa `PreparedStatement`; nenhuma SQL injection achada.
- Criação transacional de agendamento (veículo do cliente, preço lido do banco, serviço, atendimento, pagamento) e cancelamento transacional (`DAOAgendamento`).
- Máquina de estados do atendimento validada no DAO com `SELECT ... FOR UPDATE`.
- Bootstrap do primeiro admin com `MessageDigest.isEqual` e `GET_LOCK`.
- CRUD de serviços e clientes (painel); colaboradores só inserção; atendimentos e pagamentos só atualização de status.

### 2.4 Bugs e inconsistências
1. **`DAOAgendamento.listarPorCliente` (l.137)** lê `getInt("id_servico")`, mas o SELECT devolve só `servicos` (GROUP_CONCAT, l.121). Provável `SQLException`; quebra `/agendamentos` e o GET da API. `AgendamentoView` tem `id_cliente`/`id_servico` como `int` único, getters fora do padrão (`getidVeiculo`) e nenhum `getId()`.
2. **`CadastroClienteServlet` (l.32-38, 58-62)**: GET compara `path` com `/index.jsp`/`/painel/clientes`, mas o servlet path é sempre `/cadastro` → GET responde 200 em branco. No POST o redirect final vai para `/painel/clientes` (exige login de colaborador) em vez de `/baixar-app`; ramo `/cadastro.jsp` inalcançável.
3. `AdminServlet:91` redireciona para `/painel/colaboradores?sucesso=1` (rota GET-only); o resto usa `/admin/<secao>`.
4. `SetupAdminServlet:50-51`: NPE se a env some entre `configurado()` e o POST. Janela estreita.
5. Validação de preço diferente entre `ServicoServlet.parsePreco` (`setScale(2, UNNECESSARY)`) e `AdminServlet` (l.129-134).
6. `DAOServico.salvar` (l.75-76) lança `SQLException` simples se UPDATE não acha linha → 500 em vez de 404/400. `buscar` (l.42) não filtra `ativo`.
7. Leituras sem filtro `ativo`: `DAOCliente.getUsuarios` (l.45), `getusuario` (l.59), SELECT de l.114-116; `DAOCliente.salvar` (l.288) edita cliente excluído. UNIQUE de cpf/email/placa persiste após exclusão lógica (não dá para recadastrar).
8. `ClienteServlet:66-68` usa hash literal `"temporary"` só para passar na validação de `Cliente` (gambiarra; não chega ao banco).
9. `VeiculoServlet` valida só tamanho da placa (não chama `Validacao.placa`, ao contrário de `AdminVeiculoServlet:54`); em falha de `remover` devolve 200.
10. Agendamento sem validação de conflito de horário, horário comercial, nem horário passado no mesmo dia (`AgendamentoServlet:63`). API de horários pendente.
11. `DAOColaborador.atualizar`/`remover` sem chamador; sem proteção contra remover o último admin. `existeAdministrador` (l.79) conta admins inativos: se o único admin for desativado, setup fica em 410 e ninguém recupera acesso.
12. `Json.erro` (`api/Json.java:42-44`) gera JSON inválido (`"Erro": msg` sem chaves/aspas); `Json.ler` retorna `null`.
13. `DatabaseConnection`: `ENV_DEV` inválido derruba o carregamento da classe (`ExceptionInInitializerError`).
14. `AdminServlet` `default -> null` seguido de `getRequestDispatcher(view)`: seção inválida pode gerar NPE (a confirmar se há validação antes).
15. `StatusAtendimento.valueOf` no DAO lança `IllegalArgumentException` com mensagem em inglês; `getDate(...).toLocalDate()` sem checar nulo em `DAOAgendamento`.
16. `DAOAtendimento.remover` (l.136) faz DELETE físico, fora do padrão de exclusão lógica.

### 2.5 API REST `/api/v1`
- `ApiAuthFilter` só chama `chain.doFilter` (l.31-32); `JwtService.gerar` retorna `null`, `validar` retorna `-1`. Dependência `java-jwt` não está no `pom.xml`; `JWT_SECRET` não documentado.
- `AuthApiServlet` e `HorarioApiServlet`: 501. `ClienteApiServlet`, `VeiculoApiServlet`, `ServicoApiServlet`, `AgendamentoApiServlet`: parciais com TODO.
- `AgendamentoApiServlet.doGet` lê `idcliente` do corpo JSON sem checar dono → IDOR (hoje a única rota que expõe dados). Monta JSON por `String.formatted` sem escape. Linha 46: `new ArrayList<>(int)` passa capacidade, não converte nada.
- `api/Handler.java` sem `@WebServlet`: código morto.
- Conflito entre relatórios: um subagente diz que o `/auth/*` tem login e cadastro funcionando; outro e o código dos TODO indicam 501. Tratar como não implementado até confirmar.

### 2.6 Segurança
- **CSRF:** nenhum token em POSTs de estado.
- **Sessão/cookie:** `web.xml` sem `HttpOnly`/`Secure`/timeout; sem rate limit ou bloqueio nos logins.
- **Autorização:** sem filtro central.
- **Senha:** BCrypt 12 ok; qualquer OPERACIONAL pode redefinir senha de cliente pelo painel (`DAOCliente.salvar`); possível enumeração de e-mail por tempo (BCrypt só roda se o usuário existe).
- `AdminVeiculoServlet` repassa `exception.getMessage()` para `sendError`.
- `erroBanco` loga no servidor e mostra mensagem genérica: correto.

### 2.7 Código morto e duplicação
- Modelos de domínio sem uso fora de `model/`: `Agendamento`, `ItemAgendamento`, `Atendimento`, `Pagamento`, `Servico`, `Colaborador`, `NivelAcesso`; `StatusAgendamento`, `StatusPagamento`, `FormaPagamento`. DAOs usam `*View` e `Map`. Só `StatusAtendimento` é usado. Servlets repetem listas literais de status/formas.
- DAOs sem chamador: `DAOCliente.getUsuariosVeiculo`, `getUsuarioveiculo`, `updateUsuarios`, `deleteusuario`; `DAOColaborador.atualizar`/`remover`; `DAOAtendimento.remover`. SQL comentado e TODO em `DAOCliente:77-110`.
- Rotas duplicadas: `/servicos` vs `/admin/servicos`; `/painel/*` vs `/admin/*`; `/veiculos` vs `/admin/veiculos`; `/clientes` GET (`getUsuarios`) vs `/painel/clientes` (`getUsuariosComVeiculos`).
- Tratamento `SQLState startsWith("23")` repetido em 7 servlets sem helper em `WebSupport`.
- `request.setCharacterEncoding` redundante (`EncodingFilter` já cobre); `doGet` chamado de dentro de `doPost` para reexibir formulário.
- `PainelServlet:111-114` com comentário obsoleto ("serão integrados nas próximas etapas").
- Nomes inconsistentes: `getusuario`/`getUsuarios`, `Id`, `ChaveObrigatoria`, `Response_ok`, `id_cliente` em modelo Java.

---

## 3. Views e frontend (`src/main/webapp/`)

### 3.1 Telas
- Públicas: `index.jsp` (via `IndexServlet`), `cadastro.jsp` (acessado direto, não pelo servlet), `baixar-app.jsp`, `colaborador-login.jsp`, `health.jsp` (disputa rota com servlet `Health`), `erro.jsp`.
- Painel (exige login): `painel.jsp` e `painel-{clientes,carros,agendamentos,atendimentos,pagamentos,colaboradores,servicos}.jsp`.
- Todos os painéis usam dados do banco; sem arrays fixos.

### 3.2 Quebrados e órfãos
- `WEB-INF/views/login.jsp` e `portal.jsp` **não existem** (`LoginServlet:22,35,43`, `PortalServlet:19`).
- `setup-admin.jsp` está em `webapp/`, mas `SetupAdminServlet` faz forward para `/WEB-INF/views/setup-admin.jsp` (l.30,59,71,83).
- `Assets/Js/painel-agendamento.js` não é referenciado por nenhum JSP (procura `#booking-form`; a tela usa `#form-booking`): código morto.
- `painel.jsp:168-169`: `href="painel-agendamentos.jsp"`/`painel-atendimentos.jsp` relativos para JSP em WEB-INF → 404; usar `${ctx}/painel/...`.
- `colaborador-login.jsp:66` (CSS relativo) e `:104` (`../../index.jsp` resolve fora do contexto).
- `index.jsp:30,39,195,196` e `cadastro.jsp:213,216,265` com assets/links relativos; `cadastro.jsp` mistura relativo e contextPath.
- `baixar-app.jsp:31-32`: botões das lojas com `href="#"`. `index.jsp:104`: botão "↗" aponta para `#cadastro`.

### 3.3 Fluxo de cadastro
- `cadastro.jsp:230` posta em `cadastro` (path `/cadastro`) → redirect para `/painel/clientes` em vez de `/baixar-app`; "Conta criada com sucesso!" nunca é alcançada.
- Servlet envia `erro` (l.75-79) que a página não exibe; inputs não repopulam (`value="${param.x}"` ausente). Erro de CPF/e-mail duplicado é silencioso.
- Textos sem acento em `cadastro.jsp` (l.216, 223-224, 253).

### 3.4 HTML/EL/JSTL
- `cadastro.jsp:262`: `</b utton>` malformado; `<-` sem escape em `cadastro.jsp:265` e `colaborador-login.jsp:104`.
- `cadastro.jsp` sem `<%@ page %>`/`contentType`/`pageEncoding`.
- `erro.jsp` e `setup-admin.jsp` usam URI antiga `http://java.sun.com/jsp/jstl/core`; demais usam `jakarta.tags.core`. Padronizar.
- Lógica de negócio na view: somatório em `painel-pagamentos.jsp:68-77`.
- Convenção de DTO: `cliente.id_cliente` (snake_case) em `painel-clientes.jsp:114` e `painel-carros.jsp:70,106,169`, vs `cliente.id`/`veiculo.id`.
- Menu de 8 links copiado em cada painel, sem `<jsp:include>`/tag file.
- `index.jsp`: preço mínimo fixo "R$ 40,00" (l.70), título "Quatro jeitos de lavar." fixo com lista dinâmica (l.99), endereço/telefone de exemplo (l.141,157,163,164), WhatsApp genérico.

### 3.5 XSS
- Maioria usa `<c:out>`. **Sem escape:** `index.jsp:108-109` (`${servico.nome}`, `${servico.descricao}`) — campos editáveis pelo admin → XSS armazenado na página pública. Correção mais urgente da camada de view.
- Sem `innerHTML`, `<%= %>` ou `escapeXml="false"`.

### 3.6 JS e CSS
- Nenhum JS faz `fetch`/`XMLHttpRequest`/`/api/v1`; telas usam forms POST. `painel.js` (máscaras CPF/telefone/placa, troca lista/form), `bdPainel.js` (iniciais, saudação, data).
- `painel-clientes.jsp` e `painel-servicos.jsp` não incluem `painel.js`; `painel-clientes.jsp:182-215` chama `formatarCpf` (origem a confirmar → possível `ReferenceError`).
- Versão de cache inconsistente: `painel.js?v=2` em atendimentos/pagamentos/carros; sem `?v=` em agendamentos/colaboradores.
- Dois CSS (`style.css` 941 linhas, `painel.css` 1155) com `:root` duplicado; só o painel tem modo escuro.
- `<style>`/`<script>` inline grandes (`painel-agendamentos.jsp:10-130`), `.hide !important` repetido, muitos `style=""` inline.
- Marca inconsistente: `<img logo_fastsplash.png>` (index/cadastro) vs wordmark em texto (painéis, login, baixar-app). Fontes carregadas só em algumas páginas.
- `Assets/Video/lavagem-opala.mp4` (autoplay no hero) é pesado.
- `health.jsp`, `erro.jsp`, `setup-admin.jsp`: HTML cru, fora do padrão visual.

---

## 4. Banco, testes, build e configuração

### 4.1 Schema
- Três cópias: `database/schema.sql` (183 linhas, atual, com `ativo`/`excluido_em`), `src/main/resources/schema.sql` (defasado, `veiculo` com `ON DELETE RESTRICT`, ignorado pelo git). Divergência grande e ainda aberta.
- Schema cria banco `lava_rapido`; documentação 08-checklist cita `splashfast`.
- `README.md`: cita `jakarta.servlet-api` 6.1.0 e `SplashFast-1.0.war`; o `pom.xml` gera `SplashFast.war`.

### 4.2 Seed (`database/seed.sql`)
- Hashes falsos: `HASH_TESTE_CLIENTE_01..03` (l.29,36,43) e `HASH_TESTE_COLABORADOR_01..04` (l.214-235). `BCrypt.checkpw` lança `IllegalArgumentException`; login de qualquer usuário do seed dá erro (tratamento no servlet a confirmar).
- Seed cria 2 ADMINISTRADOR → `/setup/admin` bloqueado (410) e esses admins não logam. Pendência 7/8 da v1, ainda aberta.
- `database/README.md` não menciona hashes falsos nem o impasse do admin.

### 4.3 Testes
- Único arquivo: `src/test/java/com/splash/web/db/DAOClienteTest.java` (24 testes `@Nested`, Mockito `mockStatic`). `src/test/` está no `.gitignore` (l.48), versionado à força.
- Contagem divergente: commit `d8a9b34` diz 23 passando; `resumo-testes-dao-e-openapi.md` diz 24 (22 passam, 2 falham em `getusuario`). Doc desatualizado.
- Sem testes de: DAOServico, DAOAgendamento, DAOAtendimento, DAOColaborador, DAOPagamento, DAOVeiculo, servlets, API v1, `Passwords`, `DatabaseConnection`, filtros. Sem integração com banco nem E2E.
- Um subagente não encontrou testes em `src/test`; outro encontrou o arquivo acima. Prevalece o arquivo versionado.
- `Dockerfile:12` compila com `-DskipTests`: o deploy no Render nunca roda testes.

### 4.4 Build e deploy
- `Dockerfile` multi-stage (maven 3.9 + temurin 25 → tomcat 10.1 jre25), `ROOT.war`, porta de `$PORT` (padrão 10000), usuário `app`, heap 60% com SerialGC. Sem `HEALTHCHECK` apesar de existir `/health`.
- Sem `render.yaml`, CI ou docker-compose. `.dockerignore` exclui `.env`, `target/`, `.git/` e o próprio Dockerfile.
- `.gitignore` ignora `/src/test/`, `/.env`, `/CLAUDE.md`, `/src/main/resources/`. Views em `WEB-INF/views/` agora estão versionadas (corrigido desde a v1).
- `miscelaneous/build.sh` faz `purge-local-repository` e usa sudo/systemctl; ignorado pelo git. `miscelaneous/pomBack.xml` é backup solto.

### 4.5 Configuração
- `.env` (permissão 600, não versionado) tem `ENV_DEV`, `LOCAL_*`, `PROD_*` e também `PORT`, `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`; estas últimas **não são lidas por nenhum código**.
- Sem `.env.example`.
- `INITIAL_ADMIN_TOKEN` é lido por `System.getenv` (`SetupAdminServlet:49,80`): não funciona via `.env`.
- `JWT_SECRET` ausente de `variaveis-de-ambiente.md`.

### 4.6 Dependências (`pom.xml`)
- `jakarta.servlet-api` 6.1.0 (`provided`) vs Tomcat 10.1 que implementa 6.0 → alinhar para 6.0.0 (pendência da v1).
- `jbcrypt` 0.4 (antigo; BCrypt trunca senha em 72 bytes). `maven.compiler.source/target` em vez de `release`.
- Demais: mysql-connector-j 9.7.0, json 20260814, dotenv-java 3.2.0, junit-jupiter 6.0.3, mockito 5.23.0, jstl 3.0.x. Versões não consultadas no Maven Central.
- `java-jwt` ausente.

### 4.7 OpenAPI (`miscelaneous/openapi.yml`, v1.1, 790 linhas)
- Nenhuma rota `/api/v1` documentada; descrição diz "não há API JSON".
- Diz "Não há `web.xml`" — existe (só welcome-file).
- Server padrão `localhost:8080/SplashFast-1.0`; real é `/SplashFast` local e `/` no Docker.
- Faltam: `/clientes`, `/servicos` (HTML), `/painel/*`, `/admin/veiculos`, `/health`, `/api/*`.
- Docs antigos citam `/listarCadastros`, `/editarCadastro`, `/deletarCadastro`, `/mostrarCadastros`, que não existem mais.
- `08-checklist-falta-executar.md` afirma que `AdminServlet` aponta para `admin.jsp` inexistente: desatualizado, aponta para `painel-*.jsp`.

---

## 5. App mobile (`app-mobile/`, Flutter `flash_splash`)

- ~2.890 linhas em `lib/` e `test/`; Material 3; única dependência o SDK Flutter.
- Telas: auth (`tela_inicial`, `login_cliente`), home, agendamentos (lista, novo), acompanhamento, perfil (dados, veículos CRUD, notificações), pagamento, configurações; tema claro/escuro; CPF com máscara/validação.
- Dados em `core/data/repositorio.dart:12-134` com `ValueNotifier` estáticos (serviços, veículos, agendamentos); perdem-se ao fechar. Serviços fixos "Serviço 1..4"; veículo de exemplo pré-carregado. `definirServicos()` (l.26) é o ponto de entrada para dados da API.
- **Sem rede:** nenhum `http`/`dio`. Login aceita qualquer CPF válido com senha fixa `'1234'` (`login_cliente.dart:22`); sem token. Pagamento simulado (`pagamento.dart:50,64`).
- `AndroidManifest` principal sem permissão INTERNET (só debug/profile): build release não acessaria rede.
- Lacunas de modelo vs banco: agendamento com um serviço só (banco aceita N); `Veiculo` sem `marca` (NOT NULL no banco); cancelar remove item em vez de marcar `CANCELADO` (`repositorio.dart:94`); `id` como `String` (banco `INT`).
- Problemas: logout só limpa CPF, dados do usuário anterior ficam em memória (`perfil_cliente.dart:110`); botão de demonstração permite cliente mudar status do serviço (`acompanhar_servicos.dart:130`); horário livre sem checar conflito (`novo_agendamento.dart:51-62`); "próximo agendamento" ignora data (`repositorio.dart:119`, a confirmar); `pubspec.yaml:8` exige `sdk: ^3.13.2` (a confirmar se `pub get` falha).
- Testes: um smoke test (`test/widget_test.dart`). Estado global estático dificulta testar.
- Backend sem: login por CPF (`DAOCliente` só autentica por e-mail), atualização de veículo, horários livres.
- `analise-app-mobile.md` está desatualizado: diz que `com.splash.web.api` não está versionado, mas existe.

---

## 6. O que mudou desde a v1 (2026-10-16)

**Resolvido:** compilação (repositórios legados removidos); views em `WEB-INF/views` versionadas e forwards corrigidos; DAOs por tabela + DTOs; exclusão lógica; painel de clientes/veículos refeito; `AdminVeiculoServlet`; cadastro unificado em `/cadastro`; NPE do construtor de `Pessoa` aparentemente corrigido; esqueleto da API v1 criado.

**Ainda aberto da v1:** seed com hashes falsos e admin duplicado; `login.jsp`/`portal.jsp` ausentes; dois `schema.sql` divergentes; servlet-api 6.1 vs Tomcat 10.1; README com nomes de WAR errados; `src/test/` ignorado pelo git; `INITIAL_ADMIN_TOKEN` fora do dotenv.

**Novo:** JWT/filtro da API são stubs; bugs de `listarPorCliente` e do redirect do cadastro; ausência de CSRF.

---

## 7. Plano de ação sugerido

**P0 (quebra o MVP)**
1. Corrigir `DAOAgendamento.listarPorCliente` e `AgendamentoView`.
2. Criar `login.jsp` e `portal.jsp` (ou remover `LoginServlet`/`PortalServlet`) e ajustar o redirect de sessão.
3. Mover `setup-admin.jsp` para `WEB-INF/views/`.
4. Seed com bcrypt real e no máximo um admin (ou nenhum, usando `/setup/admin`).
5. Corrigir GET e redirect de `CadastroClienteServlet`; exibir `erro` e repopular campos em `cadastro.jsp`.
6. Desativar ou proteger `/api/v1/*` enquanto o filtro JWT for stub (remover IDOR de `AgendamentoApiServlet`).

**P1 (segurança e consistência)**
7. Escapar `index.jsp:108-109`.
8. Token CSRF, flags de cookie de sessão, filtro central de autorização, rate limit nos logins.
9. Corrigir links relativos (`painel.jsp:168-169`, `colaborador-login.jsp:66,104`).
10. Filtrar `ativo` em `DAOCliente`/`DAOServico`; política para UNIQUE após exclusão lógica; proteger último admin.
11. Unificar rotas duplicadas (`/servicos`↔`/admin/servicos`, `/veiculos`↔`/admin/veiculos`, `/painel`↔`/admin`).
12. `web.xml`: `error-page`, `session-config`.

**P2 (qualidade e entrega)**
13. Implementar JWT (`java-jwt`, `JWT_SECRET`), `Json.erro` válido, endpoints v1; atualizar `openapi.yml`.
14. Testes das demais DAOs, `Passwords`, servlets; remover `-DskipTests` do Docker; versionar `src/test/` corretamente.
15. Unificar `schema.sql`; `servlet-api` 6.0.0; `.env.example`; corrigir README/nomes de WAR/banco; `HEALTHCHECK`.
16. Extrair menu e CSS/JS inline dos painéis; remover `painel-agendamento.js`; padronizar taglibs; decidir destino do model de domínio sem uso.
17. Mobile: ligar o app à API v1 (permissão INTERNET, camada de serviço, `marca`, N serviços, ids numéricos, limpar estado no logout, remover botão de demonstração).
