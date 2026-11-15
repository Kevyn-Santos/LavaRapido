# Testes unitários das DAOs restantes (Fase 4, parte 2)

Registrado em 15/11/2026 12:42.

## O que mudou
Suíte de **78 para 119 testes**, todos passando, sem banco real (`DatabaseConnection` mockado). Nova base `db/DaoTestBase` (conexão falsa e `statementPara(trecho, rs)`, que liga um trecho de SQL a um statement próprio, útil nas transações com várias consultas).

- `DAOServicoTest`: `listar`, `buscar`, `salvar` (INSERT x UPDATE, normalização), `remover`.
- `DAOPagamentoTest`: `listar`, validações de `atualizar`, PAGO/CANCELADO, pagamento já processado.
- `DAOColaboradorTest`: `listar`, `autenticar` (BCrypt real), `criarAdministradorInicial` (lock, já existe admin, lock não obtido, liberação do lock), `atualizar` (validações e UPDATE dinâmico), `remover` (último administrador protegido, rollback).
- `DAOAtendimentoTest`: `listar`, transições de status (válida, pular etapa, voltar, agendamento cancelado, inexistente, só trocar colaboradores com ids repetidos), conclusão do agendamento ao finalizar, `remover`.
- `DAOVeiculoConsultasTest`: `listarPorCliente`, `atualizar`, `remover`.
- `DAOAgendamentoListagemTest`: `listarPorCliente` (GROUP_CONCAT em `List<Integer>`, serviços nulos) e `listarTodos`.
- `DAOClienteComplementoTest`: `autenticar`, `autenticarPorEmail`, `getUsuariosComVeiculos`, `salvar`, `remover`.

## Bugs achados pelos testes e corrigidos
1. `DAOPagamento.atualizar(id, "PAGO", null)` lançava `NullPointerException` (`Set.of(...).contains(null)`) em vez de `IllegalArgumentException`; a forma nula agora é checada antes.
2. `DAOVeiculo.atualizar` lançava `NullPointerException` com `cor` nula (`cor.isBlank()`); agora nula grava NULL, coerente com `inserir`.

## Decisão: testes não versionados
`/src/test/` continua no `.gitignore` por decisão do grupo (2026-11-15). Os testes existem só na máquina de quem os escreveu; este registro é o único rastro versionado deles.

## Ainda sem teste
Servlets do site e do painel (`servlet/`), `WebSupport`, `EncodingFilter`, modelos (`Cliente`, `Veiculo`, `Validacao`, enums), `Passwords` isolado, `DatabaseConnection` e testes de integração com Tomcat + MySQL.

## Ligação com o projeto
Fase 4 de `plano-pendencias-api-mobile.md`; continua `testes-api-mobile.md`.
