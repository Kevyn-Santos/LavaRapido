# Testes unitários dos servlets do site e do painel (Fase 4, parte 3)

Registrado em 15/11/2026 12:48.

## O que foi feito
Suíte de **119 para 210 testes** (`mvn test`: 208 passam, **2 falham de propósito** — ver abaixo). Sem Tomcat nem banco: request/response/sessão falsos e DAOs trocadas por `mockConstruction`. Pacote `com.splash.web.servlet` de teste:

- `WebTestSupport` (base: parâmetros por mapa, sessão de cliente/colaborador, verificações de forward/redirect).
- `WebSupportTest`: sessão de cliente e colaborador, hierarquia ADMINISTRADOR > ATENDENTE > OPERACIONAL, 403, `erroBanco`, helpers.
- `PaginasSimplesTest`: `EncodingFilter`, `Health`, `IndexServlet`, `BaixarAppServlet`, `PortalServlet`, `LogoutServlet`.
- `LoginServletsTest`: login de cliente e de colaborador (400/401/ok com sessão nova/500).
- `CadastroESetupTest`: `/cadastro` (hash da senha, senha curta, CPF de tamanho errado, duplicado 409) e `/setup/admin` sem `INITIAL_ADMIN_TOKEN` (503). Os caminhos com token **não** são testáveis: o servlet usa `System.getenv`, que o Mockito não substitui.
- `ClienteEServicoServletTest`: painel de clientes e de serviços (nível, listar, editar, salvar, remover, 400/409).
- `VeiculoEAgendamentoServletTest`: área do cliente (cliente sempre o da sessão; agendar/cancelar; erros).
- `PainelEAdminServletTest`: `/painel/*` (nível por seção, parametrizado), `/admin/*` (atendimentos, pagamentos, serviços, colaboradores, remover a própria conta), `/admin/veiculos`, `/admin/agendamentos`.

## Falhas intencionais (bugs encontrados, NÃO corrigidos, aguardando decisão)
1. **`VeiculoEAgendamentoServletTest.placaInvalida`**: o cadastro de veículo do site (`VeiculoServlet`, `/veiculos`) só confere tamanho (≤ 10) e maiúsculas; aceita placa como `!!!!`. O painel admin (`AdminVeiculoServlet`) valida com `Validacao.placa`. A API (`VeiculoApiServlet`) também não valida. Falta validar no site e na API (ou dentro de `DAOVeiculo.inserir`).
2. **`PainelEAdminServletTest.atendimentoEntregue`**: `AdminServlet.STATUS_ATENDIMENTO` aceita só `AGUARDANDO`, `EM_LAVAGEM` e `FINALIZADO`; o ciclo (`StatusAtendimento`, `DAOAtendimento`) termina em `ENTREGUE`, que nunca pode ser gravado pelo painel. Se a omissão for proposital, remover o teste.

## Outras observações (sem teste falhando)
- `Validacao.cpf` confere só os 11 dígitos, não os dígitos verificadores (`11111111111` é aceito).
- `AgendamentoServlet` e `AdminAgendamentoServlet` devolvem ao usuário a mensagem de `DateTimeParseException` em inglês (`Text '...' could not be parsed...`) quando a data ou o hora vêm mal formatados.
- `VeiculoServlet` ao falhar a remoção reexibe a lista com status 200 (sem 4xx).
- Como há 2 testes vermelhos, **`mvn package` falha localmente** (o surefire roda antes do WAR). `mvn package -DskipTests` contorna. O Dockerfile/Render não são afetados porque `src/test/` não está no git.

## Ainda sem teste
Modelos (`Cliente`, `Veiculo`, `Validacao`, enums, `Pessoa`), `Passwords` isolado, `DatabaseConnection` e integração com Tomcat + MySQL; os JSPs; o ramo com token de `SetupAdminServlet`.

## Ligação com o projeto
Fase 4 de `plano-pendencias-api-mobile.md`; continua `testes-api-mobile.md` e `testes-daos.md`. Testes seguem fora do git (decisão do grupo).

## Atualização (15/11/2026 13:03)
- Bug 2 (`ENTREGUE`) resolvido: `AdminServlet` passou a aceitar o status e o teste `atendimentoEntregue` passa. Resta 1 falha intencional (`placaInvalida`).
- As observações de data/hora em inglês e de remoção de veículo com status 200 foram corrigidas (`correcao-mensagens-data-e-remocao-veiculo.md`).

## Atualização (15/11/2026 13:06)
Bug 1 (placa sem validação) resolvido em `DAOVeiculo.inserir` (`validacao-placa-dao-veiculo.md`). Nenhum teste falha mais: suíte 216 verde.
