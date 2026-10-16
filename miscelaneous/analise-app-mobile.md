# Análise do app mobile (`app-mobile/`) e plano de integração com o backend Java

> Escrito em 15/10/2026, a partir do código atual do repositório (incluindo as alterações ainda não commitadas do backend).

---

## Parte 1: o projeto mobile

### 1.1 Visão geral

| Item | Valor |
| --- | --- |
| Nome do pacote | `flash_splash` (`pubspec.yaml`) |
| Tecnologia | Flutter / Dart (SDK `^3.13.2`), Material 3 |
| Dependências | **Só o Flutter SDK.** Não usa `http`, `provider`, `shared_preferences` nem nenhum outro pacote |
| Plataformas geradas | android, ios, web, linux, macos, windows (padrão do `flutter create`) |
| Tamanho | Cerca de 2.000 linhas de Dart em `lib/` |
| Persistência | **Nenhuma.** Tudo fica em memória e se perde quando o app fecha |
| Comunicação externa | **Nenhuma.** O app não faz nenhuma chamada de rede |

É um **protótipo navegável da área do cliente** de um lava-rápido: login, escolha de serviço, cadastro de veículos, agendamento e uma tela de pagamento simulada. Funciona como maquete funcional do produto, sem backend.

### 1.2 Arquitetura

```
lib/
  main.dart            -> runApp(FlashSplashApp)
  app.dart             -> MaterialApp; escuta o ThemeController (claro/escuro)
  core/
    constants/         app_assets.dart: caminho da ilustração
    data/              repositorio.dart: "banco" em memória (ValueNotifier estático)
    models/            Servico, Veiculo, Agendamento (classes imutáveis simples)
    session/           Sessao.cpf: CPF do usuário logado (string estática)
    theme/             paleta do site + ThemeData claro/escuro + ThemeController
    utils/             cpf.dart (validação e máscara), formatadores.dart (data/hora)
  features/
    auth/              TelaInicial (vitrine) e LoginCliente
    home/              ContaCliente (abas), InicioCliente, ServicoCard
    agendamentos/      Agendamentos (lista), NovoAgendamento (formulário)
    perfil/            PerfilCliente, MeusVeiculos, Notificacoes
    pagamento/         Pagamento
    configuracoes/     Configuracoes
```

**Gerência de estado:** `ValueNotifier` estático + `ValueListenableBuilder`. O `Repositorio` expõe `veiculos` e `agendamentos` como `ValueNotifier<List<...>>`; as telas reconstroem quando a lista é trocada. O tema usa o mesmo padrão (`ThemeController.themeMode`). É simples e adequado para protótipo, mas é estado global: fica difícil de testar e de trocar por dados remotos.

### 1.3 Fluxo de navegação

```
TelaInicial (vitrine com ilustração)
  ├─ "Entrar" / "Agendar lavagem" / "Ver serviços" ──> LoginCliente
  │
LoginCliente (CPF + senha)
  └─ sucesso ──> ContaCliente (pushReplacement)
                   ├─ Aba Início ──────> InicioCliente
                   │                      └─ escolhe serviço ─> Pagamento(servico)
                   ├─ Aba Agenda ──────> Agendamentos
                   │                      └─ "Novo agendamento" ─> NovoAgendamento
                   └─ Aba Perfil ──────> PerfilCliente
                                          ├─ Meus agendamentos ─> Agendamentos
                                          ├─ Meus veículos ─────> MeusVeiculos (+ diálogo Novo veículo)
                                          ├─ Formas de pagamento ─> Pagamento()
                                          ├─ Notificações ──────> Notificacoes
                                          ├─ Configurações ─────> Configuracoes
                                          └─ Sair ──> TelaInicial (limpa a pilha)
```

### 1.4 Telas e funções principais

| Tela | Arquivo | O que faz |
| --- | --- | --- |
| **Tela inicial** | `features/auth/tela_inicial.dart` | Vitrine com o layout do site: gradiente petróleo, ilustração `hero_lavagem.png`, chamada "Lavagem rápida, agendada em...", botões *Agendar lavagem* e *Ver serviços*, seção com cartões de serviço. Todos os botões levam ao login. |
| **Login do cliente** | `features/auth/login_cliente.dart` | Formulário com CPF (máscara `000.000.000-00` e validação dos dígitos verificadores) e senha (com mostrar/ocultar). Compara a senha com a constante `'1234'`. Se passar, grava o CPF em `Sessao.cpf` e abre `ContaCliente`. "Esqueci minha senha" só mostra um SnackBar. |
| **Conta do cliente** | `features/home/conta_cliente.dart` | `NavigationBar` com 3 abas (Início, Agenda, Perfil). Usa `IndexedStack`, então cada aba mantém o próprio estado. |
| **Início** | `features/home/inicio_cliente.dart` | Saudação, cartão "Próximo agendamento" (o primeiro agendamento futuro), lista de serviços selecionáveis e botão *Ir para pagamento*. |
| **Meus agendamentos** | `features/agendamentos/agendamentos.dart` | Lista os agendamentos (serviço, data/hora, veículo), cancela com diálogo de confirmação e tem o botão *Novo agendamento*. |
| **Novo agendamento** | `features/agendamentos/novo_agendamento.dart` | Formulário em 3 passos: 1) serviço, 2) veículo (`ChoiceChip`), 3) data (hoje até +90 dias) e horário. Bloqueia horários no passado. Salva no `Repositorio`, ordenado por data. |
| **Meu perfil** | `features/perfil/perfil_cliente.dart` | Avatar, nome fixo "Cliente Fast Splash", CPF da sessão formatado, atalhos para as outras telas e *Sair da conta*. |
| **Meus veículos** | `features/perfil/meus_veiculos.dart` | Lista os veículos (já começa com um "Nissan Skyline ABC-1234" de exemplo). O diálogo *Novo veículo* pede modelo, placa (regex antiga ou Mercosul) e cor. |
| **Pagamento** | `features/pagamento/pagamento.dart` | Com `servico`: resumo e valor. Sem `servico`: vira "Formas de pagamento". Escolha entre Pix, crédito e débito. Confirmar só abre um diálogo dizendo que é uma demonstração. |
| **Notificações** | `features/perfil/notificacoes.dart` | Dois cartões estáticos. |
| **Configurações** | `features/configuracoes/configuracoes.dart` | Switch de notificações (só visual), switch de modo escuro (funciona), *Alterar senha* (SnackBar), *Ajuda* e *Sobre*. |

**Utilitários que valem destacar**

- `Cpf.valido` implementa corretamente o algoritmo dos dígitos verificadores e rejeita sequências repetidas. A flag `exigirDigitosVerificadores` desliga a checagem para testes.
- `CpfInputFormatter` aplica a máscara enquanto o usuário digita.
- `AppTheme` centraliza a paleta do site (petróleo, ciano, coral) e já define cores de status (pendente, em andamento, concluído) que ainda não são usadas.

### 1.5 Erros e limitações encontrados

Verificação executada: `flutter analyze` / `flutter test` (não chegaram a rodar, ver item E1) e leitura de todo o código em `lib/`.

#### Erros (quebram algo ou se comportam de forma incorreta)

| # | Problema | Onde | Impacto |
| --- | --- | --- | --- |
| E1 | A restrição `sdk: ^3.13.2` é mais nova que o Dart instalado nesta máquina (3.13.1). `flutter pub get`, `analyze` e `test` falham com *version solving failed*. | `pubspec.yaml:7` | O projeto não compila em quem tem o SDK um patch abaixo. Use `^3.13.0` ou atualize o Flutter. |
| E2 | **Logout não limpa os dados.** `Sessao.limpar()` zera só o CPF; `Repositorio.veiculos` e `agendamentos` continuam na memória. | `perfil_cliente.dart:110`, `sessao.dart:8` | Se outra pessoa entrar com outro CPF no mesmo aparelho, ela vê os veículos e agendamentos do usuário anterior. |
| E3 | O login aceita **qualquer CPF válido** com a senha fixa `1234`. | `login_cliente.dart:17,50` | Não existe autenticação. O CPF não é verificado em lugar nenhum. |
| E4 | "Ir para pagamento" (aba Início) paga um serviço **sem agendamento**, e o pagamento não é registrado em lugar nenhum. | `inicio_cliente.dart:127-141`, `pagamento.dart:32` | O fluxo não faz sentido para o negócio: no backend, o pagamento pertence a um agendamento (`pagamento.id_agendamento NOT NULL`). |
| E5 | "Salvar forma de pagamento" não salva nada; só abre um diálogo. | `pagamento.dart:32-57` | É uma função falsa para o usuário. |
| E6 | O horário do agendamento aceita **qualquer hora** (03:00, por exemplo), sem horário de funcionamento e sem checar conflito. | `novo_agendamento.dart:42-53` | No banco existe `UNIQUE (id_veiculo, data, horario)`. O app permite duplicatas que o backend vai rejeitar. |
| E7 | É possível cadastrar dois veículos com a mesma placa. | `meus_veiculos.dart:115`, `repositorio.dart:37` | No banco, `veiculo.placa` é `UNIQUE`. |
| E8 | O cartão "Próximo agendamento" só é recalculado quando a lista muda, não quando o tempo passa. | `inicio_cliente.dart:56-62` | Um agendamento que já passou continua aparecendo como "próximo" até alguma mudança na lista. |

#### Limitações (funcionalidade ausente ou incompleta)

1. **Sem persistência e sem backend:** tudo some ao fechar o app (`repositorio.dart:7`).
2. **Sem cadastro de cliente.** Só existe login; não há tela para criar conta.
3. **O agendamento aceita só um serviço**, enquanto o backend modela N serviços por agendamento (`agendamento_servico`).
4. **Agendamento sem status:** cancelar *remove* o item da lista. No backend, cancelar muda o status para `CANCELADO` e o histórico continua existindo. As cores de status do `AppTheme` não são usadas.
5. **Não dá para editar nem excluir veículos**, nem reagendar.
6. **O veículo não tem `marca`**, mas no banco a coluna é `NOT NULL`. A placa é salva com hífen (`ABC-1234`), enquanto o backend normaliza para `ABC1234`.
7. **O serviço usa `id` String (`'completa'`) e guarda `IconData` no model.** O banco usa `id_servico INT` e não tem ícone. Os serviços estão fixos no código.
8. **Perfil genérico:** "Olá, cliente!" e "Cliente Fast Splash". Nome, e-mail e telefone não existem no app.
9. **Telas de enfeite:** notificações estáticas, switch de notificações sem efeito, "Alterar senha" e "Esqueci minha senha" sem implementação.
10. **O tema escolhido não é salvo**; volta para escuro a cada abertura.
11. **O nome do produto muda de tela para tela:** "Fast Splash" (`app.dart:17`, login, início, perfil), "Flash Splash" (Sobre, Ajuda, notificações) e `flash_splash` no launcher do Android. O `applicationId` ainda é `com.example.flash_splash`.
12. **Telas duplicadas:** "Meus agendamentos" aparece na aba Agenda e também no Perfil.
13. **Sem área do colaborador/admin**; o app cobre só o cliente.
14. **Testes:** só existe um smoke test (`test/widget_test.dart`) que confere se o widget raiz existe.
15. **`LEIA-ME.md`** descreve a aplicação de um zip "por cima do projeto" no Windows; não serve como documentação de setup. O `README.md` é o padrão do `flutter create`.
16. **Android:** a permissão `INTERNET` está declarada só nos manifests `debug/` e `profile/`. Um build *release* não vai conseguir acessar a API (ver Parte 3).

---

## Parte 2: como o app conversa com o projeto Java

### 2.1 Situação atual: não conversa

**Hoje o app mobile e o backend Java não têm nenhum ponto de integração.** São dois protótipos paralelos do mesmo domínio:

| | Backend Java (`src/`) | App mobile (`app-mobile/`) |
| --- | --- | --- |
| Interface | JSP renderizado no servidor (Tomcat) | Telas nativas Flutter |
| Dados | MySQL (`database/schema.sql`) via JDBC | Listas em memória |
| Autenticação | E-mail + senha com BCrypt, `HttpSession` | CPF + senha fixa `1234` |
| Formato de troca | Formulário HTML (`application/x-www-form-urlencoded`) → `forward` para JSP | Nenhum |
| Público | Cliente **e** colaborador/admin | Só cliente |

Os servlets atuais devolvem **HTML** (`forward` para `.jsp`) ou `redirect`, e mantêm o estado em `HttpSession` (cookie `JSESSIONID`). Um app Flutter não tem como usar isso de forma razoável: ele precisa de endpoints que recebam e devolvam **JSON**.

### 2.2 Onde os dois projetos já combinam

Os dois descrevem o mesmo domínio, e vários pedaços batem:

| Conceito | Java (model / tabela) | Dart (model) | Compatível? |
| --- | --- | --- | --- |
| Cliente | `Cliente` / `cliente(id_cliente, nome, cpf, telefone, email, senha_hash)` | só `Sessao.cpf` | Parcial: o app só tem o CPF |
| Validação de CPF | `Validacao.cpf`: só confere os 11 dígitos | `Cpf.valido`: confere os dígitos verificadores | O app é **mais rigoroso** que o backend |
| Veículo | `Veiculo(placa, marca, modelo, cor)`; placa normalizada sem hífen | `Veiculo(modelo, placa, cor)` | Falta `marca`; a placa tem formato diferente |
| Regex da placa | `^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$` (depois de remover o hífen) | `^[A-Za-z]{3}-?[0-9][A-Za-z0-9][0-9]{2}$` | **Equivalentes** |
| Serviço | `Servico(id INT, nome, descricao, preco BigDecimal)` | `Servico(id String, nome, descricao, preco double, icone)` | Tipo do id e ícone diferem |
| Agendamento | `Agendamento(veiculo, data, horario, status, itens[])` | `Agendamento(servico, veiculo, dataHora)` | App: 1 serviço e sem status. Java: N serviços e com status |
| Pagamento | `Pagamento(valor, forma: DINHEIRO/PIX/CREDITO/DEBITO, status)` | String "Pix" / "Cartão de crédito" / "Cartão de débito" | Mapeável (o app não tem DINHEIRO) |
| Status | `StatusAgendamento`, `StatusAtendimento`, `StatusPagamento` | cores prontas em `AppTheme`, sem enum | Falta o lado Dart |
| Identidade visual | JSPs com a paleta do site | `AppTheme`: "mesma paleta do site do grupo" | Sim |

O backend já tem **toda a lógica que o app precisa**, em `LavaRapidoRepository`:

| Necessidade do app | Método Java existente |
| --- | --- |
| Login | `autenticarCliente(email, senha)` |
| Cadastro | `cadastrarCliente(nome, cpf, telefone, email, senha)` |
| Listar serviços | `listarServicos()` |
| Veículos | `listarVeiculos(idCliente)`, `adicionarVeiculo(...)`, `removerVeiculo(...)` |
| Agendar | `criarAgendamento(idCliente, idVeiculo, data, horario, idsServicos)`: transação que já cria `agendamento_servico`, `atendimento` e `pagamento` PENDENTE |
| Meus agendamentos | `listarAgendamentosCliente(idCliente)`: já traz total, status e pagamento |
| Cancelar | `cancelarAgendamento(idCliente, idAgendamento)` |

Ou seja, **a integração consiste basicamente em expor esses métodos em JSON** e trocar o `Repositorio` em memória do app por chamadas HTTP.

### 2.3 Problemas do backend que bloqueiam a integração

Encontrados com `mvn -o compile` no estado atual da árvore de trabalho (refatoração em andamento, ainda não commitada):

1. **O backend não compila.** Os servlets foram para `com.splash.web.servlet`, mas `ClienteRepository` (classe `final class` sem `public`) e os métodos `static` de `LavaRapidoRepository` continuam *package-private* em `com.splash.web.db`. Resultado: dezenas de erros "is not public ... cannot be accessed from outside package" em `LoginServlet`, `CadastroClienteServlet`, `VeiculoServlet`, `AdminServlet`, entre outros. O mesmo vale para `Passwords`.
2. **Duas classes mapeiam a mesma rota `/cadastro`** (`Cadastro.java` e `CadastroClienteServlet.java`). O Tomcat se recusa a subir a aplicação com URL patterns duplicados.
3. **Duas camadas de acesso a dados concorrentes:** `DAOCliente` (novo) e `LavaRapidoRepository`/`ClienteRepository` (antigo). `DAOVeiculo`, `DAOAgendamento` e `DAOColaborador` são classes **vazias**.
4. **Login por e-mail no backend e por CPF no app.** É preciso escolher um (ou aceitar os dois).
5. **O `Dockerfile` da raiz é um placeholder** (`FROM ubuntu:latest` + `top -b`). Não empacota o WAR nem o Tomcat.
6. A pasta `servlet-app/` é uma cópia antiga do backend (`com.example`) que ainda está no repositório e pode confundir.

---

## Parte 3: implantação de uma API para unir o backend Java + MySQL ao app Dart

### 3.1 Arquitetura proposta

```
┌────────────────────┐   HTTPS + JSON    ┌────────────────────────────────────────┐   JDBC   ┌─────────┐
│  App Flutter       │ ────────────────> │  Tomcat (mesmo WAR SplashFast)         │ ───────> │  MySQL  │
│  ApiClient (http)  │ <──────────────── │   /api/v1/*   -> Servlets REST (JSON)  │          │ lava_   │
│  AuthRepository    │   Authorization:  │   /*.jsp, ... -> Servlets JSP (site)   │          │ rapido  │
│  ServicoRepository │   Bearer <token>  │        │                │              │          └─────────┘
│  ...               │                   │        └──── camada db (DAO/Repository)│
└────────────────────┘                   └────────────────────────────────────────┘
```

**Recomendação: colocar a API no próprio projeto Java** (mesmo WAR e mesmo Tomcat), em um pacote novo `com.splash.web.api`, reaproveitando a camada `db` que já existe. Assim não há um segundo servidor para manter, e o site JSP e o app usam o mesmo banco e as mesmas regras.

Para manter a stack da disciplina, a recomendação é **Servlets + Jackson** (sem Spring). Migrar para Spring Boot ou JAX-RS (Jersey) também resolveria, mas obriga a reescrever o que já funciona.

### 3.2 Pré-requisitos no backend (fazer antes)

1. **Fazer o projeto compilar:** tornar `public` a classe `ClienteRepository` e os métodos de `LavaRapidoRepository` usados fora do pacote (ou, melhor, terminar a migração para os DAOs `DAOCliente`, `DAOVeiculo` e `DAOAgendamento` e deixá-los públicos).
2. **Resolver o conflito de `/cadastro`:** apagar ou renomear um dos dois servlets.
3. **Escolher uma única camada de dados.** A sugestão é mover a lógica de `LavaRapidoRepository` para os DAOs vazios e depois remover o repositório antigo.
4. **Login por CPF:** adicionar `autenticarClientePorCpf(cpf, senha)` (`SELECT ... WHERE cpf = ?`; a coluna já é `UNIQUE`) ou aceitar um campo `login` que pode ser e-mail ou CPF.

### 3.3 Dependências (pom.xml)

```xml
<!-- Serialização JSON -->
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-databind</artifactId>
    <version>2.18.2</version>
</dependency>
<dependency>  <!-- suporte a LocalDate/LocalTime -->
    <groupId>com.fasterxml.jackson.datatype</groupId>
    <artifactId>jackson-datatype-jsr310</artifactId>
    <version>2.18.2</version>
</dependency>
<!-- Token JWT para o app (stateless) -->
<dependency>
    <groupId>com.auth0</groupId>
    <artifactId>java-jwt</artifactId>
    <version>4.4.0</version>
</dependency>
```

### 3.4 Autenticação

O app não deve depender de `JSESSIONID`. A proposta é usar um **JWT**:

1. `POST /api/v1/auth/login` com `{ "cpf": "52998224725", "senha": "..." }`.
2. O backend confere com `Passwords.matches` (BCrypt, que já existe) e devolve `{ "token": "eyJ...", "cliente": { "id": 1, "nome": "...", ... } }`.
3. O token é assinado com HMAC (segredo em variável de ambiente `JWT_SECRET`, lido pelo `dotenv` que o projeto já usa), carrega `sub = id_cliente` e expira em algumas horas.
4. Um **`ApiAuthFilter`** (`@WebFilter("/api/v1/*")`) valida o header `Authorization: Bearer <token>` em todas as rotas, exceto `/auth/*` e `GET /servicos`, e coloca o `idCliente` em `request.setAttribute("idCliente", ...)`.
5. **O `idCliente` vem sempre do token, nunca do corpo da requisição.** Os métodos existentes já recebem `idCliente` (`listarVeiculos(idCliente)`, `cancelarAgendamento(idCliente, id)`), então um cliente não consegue mexer em dados de outro.

No app, o token fica salvo com `flutter_secure_storage`, que substitui o `Sessao.cpf`.

### 3.5 Endpoints (v1, área do cliente)

| Método | Rota | Corpo / resposta | Usa (Java) | Substitui (Dart) |
| --- | --- | --- | --- | --- |
| POST | `/api/v1/auth/cadastro` | `{nome, cpf, telefone, email, senha}` → `201` | `cadastrarCliente` | *(tela nova)* |
| POST | `/api/v1/auth/login` | `{cpf, senha}` → `{token, cliente}` | `autenticarCliente*` | `LoginCliente._entrar` |
| GET | `/api/v1/me` | → `{id, nome, cpf, telefone, email}` | `DAOCliente.getusuario` | nome fixo do Perfil |
| PATCH | `/api/v1/me` | `{nome?, telefone?, email?}` | `DAOCliente.updateUsuarios` | *(novo)* |
| GET | `/api/v1/servicos` | → `[{id, nome, descricao, preco}]` | `listarServicos` | `Repositorio.servicos` |
| GET | `/api/v1/veiculos` | → `[{id, placa, marca, modelo, cor}]` | `listarVeiculos` | `Repositorio.veiculos` |
| POST | `/api/v1/veiculos` | `{placa, marca, modelo, cor}` → `201` | `adicionarVeiculo` | `adicionarVeiculo` |
| DELETE | `/api/v1/veiculos/{id}` | → `204` | `removerVeiculo` | *(novo)* |
| GET | `/api/v1/agendamentos` | → `[{id, placa, veiculo, data, horario, status, total, statusPagamento, formaPagamento}]` | `listarAgendamentosCliente` | `Repositorio.agendamentos` |
| POST | `/api/v1/agendamentos` | `{idVeiculo, data: "2026-10-20", horario: "09:00", idsServicos: [1,2]}` → `201` | `criarAgendamento` | `adicionarAgendamento` |
| POST | `/api/v1/agendamentos/{id}/cancelar` | → `204` | `cancelarAgendamento` | `cancelarAgendamento` |
| GET | `/api/v1/horarios?data=2026-10-20` | → `["08:00","08:30",...]` livres | *(novo método)* | corrige o E6 |

Uma fase 2, se houver tempo, pode incluir pagamento (`PUT /agendamentos/{id}/pagamento {forma}`) e rotas de colaborador (`/api/v1/colaborador/*` com `NivelAcesso`), reaproveitando `listarAtendimentos` e `atualizarAtendimento`.

### 3.6 Padrão de servlet REST

```java
package com.splash.web.api;

@WebServlet("/api/v1/veiculos/*")
public class VeiculoApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int idCliente = (int) req.getAttribute("idCliente");   // posto pelo ApiAuthFilter
        try {
            Json.ok(resp, LavaRapidoRepository.listarVeiculos(idCliente));
        } catch (SQLException e) {
            Json.erro(resp, 500, "Erro ao acessar o banco.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int idCliente = (int) req.getAttribute("idCliente");
        NovoVeiculoDto dto = Json.ler(req, NovoVeiculoDto.class);
        try {
            LavaRapidoRepository.adicionarVeiculo(idCliente, dto.placa(), dto.marca(), dto.modelo(), dto.cor());
            resp.setStatus(201);
        } catch (IllegalArgumentException e) {           // validação do model
            Json.erro(resp, 400, e.getMessage());
        } catch (SQLIntegrityConstraintViolationException e) {  // placa duplicada
            Json.erro(resp, 409, "Placa já cadastrada.");
        } catch (SQLException e) {
            Json.erro(resp, 500, "Erro ao acessar o banco.");
        }
    }
}
```

`Json` é um helper com um `ObjectMapper` único (com `JavaTimeModule` registrado e `WRITE_DATES_AS_TIMESTAMPS` desligado), que escreve `application/json; charset=UTF-8` e erros no formato padrão `{ "erro": "mensagem" }`. Os `record` que já existem em `LavaRapidoRepository` (`Veiculo`, `Servico`, `Agendamento`...) são serializados direto pelo Jackson.

**Mapeamento de erros (igual em toda a API):**

| Exceção Java | HTTP |
| --- | --- |
| `IllegalArgumentException` (validação em `Validacao`) | 400 |
| Token ausente ou inválido | 401 |
| Recurso de outro cliente | 404 (não revela que o recurso existe) |
| `SQLIntegrityConstraintViolationException` (CPF, e-mail ou placa duplicados; horário ocupado) | 409 |
| `IllegalStateException` (transição de status inválida) | 422 |
| `SQLException` genérica | 500 |

**CORS:** um filtro que responde `OPTIONS` e envia `Access-Control-Allow-Origin` só é necessário se o app também rodar como **Flutter Web**. Android e iOS nativos não usam CORS.

### 3.7 Mudanças no app Flutter

1. **`pubspec.yaml`:** adicionar `http`, `flutter_secure_storage` e `intl` (para a data ISO), e corrigir a restrição de SDK (E1).
2. **Configuração da URL base** por `--dart-define`:
   ```dart
   const apiBaseUrl = String.fromEnvironment('API_URL',
       defaultValue: 'http://10.0.2.2:8080/SplashFast/api/v1'); // 10.0.2.2 = localhost do PC visto do emulador Android
   ```
   No celular físico, use o IP do PC na rede local (`flutter run --dart-define=API_URL=http://192.168.0.10:8080/SplashFast/api/v1`).
3. **`core/api/api_client.dart`:** um wrapper de `http.Client` que adiciona `Authorization: Bearer`, faz `jsonDecode`, converte respostas que não são 2xx em uma `ApiException(status, mensagem)` e, no 401, apaga o token e volta para o login.
4. **Models com `fromJson`/`toJson`:**
   - `Servico`: `id` vira `int`, `preco` vem de string ou num, e o ícone sai do model (um mapa `id`/nome → `IconData` na camada de UI).
   - `Veiculo`: ganha `id` e `marca`.
   - `Agendamento`: ganha `id`, `status` (enum Dart espelhando `StatusAgendamento`), `servicos: List<Servico>`, `total`, `statusPagamento`.
5. **Trocar o `Repositorio` estático por repositórios assíncronos** (`AuthRepository`, `ServicoRepository`, `VeiculoRepository`, `AgendamentoRepository`). Para continuar no padrão atual, cada repositório pode manter o `ValueNotifier` e ganhar um `Future<void> carregar()` que preenche a lista a partir da API. As telas quase não mudam; só precisam tratar carregando/erro (`FutureBuilder` ou um `bool carregando`).
6. **Telas:**
   - `LoginCliente`: chamar `AuthRepository.login`, mostrar a mensagem do servidor e remover `_senhaDemo`.
   - Criar a tela **Cadastro** (nome, CPF, telefone, e-mail, senha), reaproveitando `Cpf` e `CpfInputFormatter`.
   - `NovoAgendamento`: permitir vários serviços (`FilterChip`) e buscar os horários livres.
   - `Agendamentos`: mostrar o status com as cores do `AppTheme`; cancelar passa a chamar a API, e o item continua na lista como CANCELADO.
   - `MeusVeiculos`: campo **Marca** e exclusão.
   - `InicioCliente`: trocar *Ir para pagamento* por *Agendar este serviço*, que abre `NovoAgendamento` com o serviço já marcado (resolve o E4).
   - Logout: apagar o token **e** limpar todos os repositórios (resolve o E2).
7. **Android:**
   - Adicionar `<uses-permission android:name="android.permission.INTERNET"/>` em `android/app/src/main/AndroidManifest.xml` (hoje a permissão só existe em debug e profile).
   - Enquanto a API estiver em `http://` (sem TLS), usar `android:usesCleartextTraffic="true"` **só em debug**. Em produção, usar HTTPS.

### 3.8 Implantação (infraestrutura)

**Desenvolvimento local**

1. Rodar MySQL com `database/schema.sql` + `database/seed.sql`.
2. Preencher o `.env` (`ENV_DEV=LOCAL`, `LOCAL_DB_URL`, `LOCAL_USER`, `LOCAL_PASS`, `JWT_SECRET`).
3. `mvn package` → copiar `target/SplashFast.war` para o `webapps/` do Tomcat 11 (Jakarta Servlet 6.1).
4. `flutter run --dart-define=API_URL=...`.

**Docker (substitui o `Dockerfile` placeholder)**

```dockerfile
# Build
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -q dependency:go-offline
COPY src ./src
RUN mvn -q package -DskipTests

# Runtime
FROM tomcat:11.0-jdk21-temurin
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /app/target/SplashFast.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
```

```yaml
# docker-compose.yml
services:
  db:
    image: mysql:8.4
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASS}
      MYSQL_DATABASE: lava_rapido
    volumes:
      - ./database/schema.sql:/docker-entrypoint-initdb.d/01-schema.sql
      - ./database/seed.sql:/docker-entrypoint-initdb.d/02-seed.sql
      - dbdata:/var/lib/mysql
  api:
    build: .
    ports: ["8080:8080"]
    environment:
      ENV_DEV: PROD
      PROD_DB_URL: jdbc:mysql://db:3306/lava_rapido
      PROD_USER: root
      PROD_PASS: ${DB_ROOT_PASS}
      JWT_SECRET: ${JWT_SECRET}
    depends_on: [db]
volumes:
  dbdata:
```

Observação: o `DatabaseConnection` lê as variáveis com `dotenv-java`, configurado com `ignoreIfMissing()`. Por padrão, o `dotenv-java` também consulta as variáveis de ambiente do sistema, então as `environment:` do compose funcionam sem `.env` dentro do container.

Como o WAR é publicado como `ROOT.war`, a URL do app fica `https://<host>/api/v1`. Para produção, coloque um proxy reverso com TLS (Caddy/Nginx) na frente do Tomcat, ou use uma plataforma que já entrega HTTPS (Railway, Render, Fly.io).

### 3.9 Ordem sugerida de execução

1. Corrigir a compilação do backend e o conflito de `/cadastro` (seção 2.3).
2. Adicionar Jackson, o helper `Json`, `ApiAuthFilter` e JWT.
3. Implementar `auth/login`, `auth/cadastro` e `servicos`, e testar com `curl` ou Postman. Documentar no `miscelaneous/openapi.yml`, que hoje cobre só as rotas JSP.
4. No app: `ApiClient`, login real, tela de cadastro e serviços vindos da API.
5. Veículos (com marca) e depois agendamentos (multi-serviço, status, horários livres).
6. Dockerfile + docker-compose, e permissão de INTERNET no manifest principal.
7. Fase 2: pagamento e área do colaborador.
