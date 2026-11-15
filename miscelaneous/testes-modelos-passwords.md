# Testes unitários dos modelos e do Passwords (Fase 4, parte 4)

Registrado em 15/11/2026 13:11.

## O que foi feito
Suíte de **216 para 278 testes** (277 passam; **2 falham de propósito**, ver abaixo). Sem banco nem Tomcat.

- `model/ValidacaoTest`: `obrigatorio`, texto obrigatório/opcional, e-mail, CPF, telefone, placa (formatos válidos e inválidos), valor monetário (arredondamento HALF_UP).
- `model/PessoasETest`: `EntidadeBase` (id uma só vez e positivo), `Cliente` (normalização, setters, `carregar`, veículos), `Veiculo`, `Colaborador`, `Servico`.
- `model/AgendamentoFluxoTest`: `Agendamento` (total, itens, reagendar, estados finais, `estaNoPassado`), `ItemAgendamento`, `Atendimento` (ciclo AGUARDANDO→EM_LAVAGEM→FINALIZADO→ENTREGUE conclui o agendamento, colaboradores, pagamento), `Pagamento`, e as transições dos três enums de status.
- `security/PasswordsTest`: formato e salt do BCrypt, `matches` certo/errado/nulo.

## Falhas intencionais (bug encontrado, NÃO corrigido, aguardando decisão)
**`Passwords.matches` lança `IllegalArgumentException` quando o hash guardado não é um BCrypt aceito pelo jBCrypt 0.4** (`PasswordsTest.hashMalformado`: "Invalid salt version"; `PasswordsTest.prefixo2y`: "Invalid salt revision"). Impacto real, confirmado no `database/seed.sql`:
- Os clientes e vários colaboradores do seed têm hashes de teste (`HASH_TESTE_CLIENTE_01`, `HASH_TESTE_COLABORADOR_01`...). Tentar logar com eles (site `/login`, `/colaborador/login` ou `POST /api/v1/auth/login`) cai em `Passwords.matches`, que lança a exceção; nenhum login-servlet captura `IllegalArgumentException`, então o resultado é erro 500 em vez de "E-mail ou senha inválidos" (401).
- O administrador do seed (`kelsey@teste.com`) usa prefixo `$2y$`, gerado por outra ferramenta; o jBCrypt 0.4 só entende `$2a$`, então esse login também estoura.
Opções para decidir: (a) `matches` capturar `IllegalArgumentException` e devolver `false`; (b) regerar o seed com hashes `$2a$` reais; (c) as duas. O `CLAUDE.md` já cita o seed com hashes falsos como bloqueio do MVP.

## Observações (sem teste falhando)
- `Validacao.valorMonetario` arredonda em silêncio (`10.125` vira `10.13`), enquanto `ServicoServlet` e `AdminServlet` recusam mais de 2 casas decimais: o mesmo preço é tratado de formas diferentes conforme a porta de entrada. Também não há limite superior (a coluna é DECIMAL(10,2)).
- `Cliente` guarda o id em dois lugares: `getId()` (de `EntidadeBase`) e `getId_cliente()`. `setId_cliente` não atualiza o primeiro, então um cliente com `setId_cliente(5)` ainda tem `getId() == null` e `isPersistido() == false`. `Cliente.carregar` preenche os dois.
- O BCrypt (jBCrypt) considera só os primeiros 72 bytes da senha; `/cadastro` e o painel de clientes exigem mínimo de 8 caracteres mas não máximo (o painel de colaboradores limita a 72).
- `Validacao.cpf` não confere dígitos verificadores (já registrado em `testes-servlets-site-painel.md`).

## Ainda sem teste
`DatabaseConnection`, JSPs, ramo com token de `SetupAdminServlet` e integração com Tomcat + MySQL. Testes seguem fora do git (decisão do grupo).

## Ligação com o projeto
Fase 4 de `plano-pendencias-api-mobile.md`; continua `testes-api-mobile.md`, `testes-daos.md` e `testes-servlets-site-painel.md`.

## Atualização (15/11/2026 13:20)
O bug de `Passwords.matches` e as observações de valor monetário e id duplicado do `Cliente` foram corrigidos (`correcoes-modelos-passwords.md`). Nenhum teste falha: suíte 279 verde.
