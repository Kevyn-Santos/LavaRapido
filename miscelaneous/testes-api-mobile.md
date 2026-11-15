# Testes unitários da API mobile e das regras de horário (Fase 4, parte 1)

Registrado em 15/11/2026 12:37.

## O que mudou
- Removido `ApiServlet.idClienteAutenticado` (sem chamadas; os servlets usam `ApiAuthFilter.idAutenticado`). Javadoc de `ApiServlet` ajustado.
- Suíte de **31 para 78 testes**, todos passando (`mvn test`), sem banco real nem Tomcat:
  - `model/GradeHorariosTest`: 24 horários, validação da grade, `interpretar` (HH:mm, HH:mm:ss, inválidos).
  - `api/JsonTest`: `erro` (escape de aspas), `Response_ok`, `lerCorpo`, `ouNulo`.
  - `api/v1/*ServletTest` (`Horario`, `Agendamento`, `Veiculo`, `Servico`, `Auth`, `Cliente`): status e corpo de cada rota (200/201/400/401/404/409/422/500), cliente da sessão repassado à DAO, detalhe de erro de banco não vaza. DAOs substituídas com `mockConstruction`; base comum `ApiTestSupport`.
  - `db/DAOAgendamentoTest`: `criar` (fora da grade, data passada, serviços inválidos, horário ocupado com rollback e sem INSERT), `horariosLivres` (tira ocupados, data passada, ignora cancelados), `cancelar` (commit, nada a cancelar, rollback).
  - `db/DAOVeiculoTest`: `inserir` devolve o id gerado, normaliza, cor opcional, cliente inválido.
- Já existiam: `ApiAuthFilterTest` e `DAOClienteTest`.

## Atenção: `src/test/` está no .gitignore
`.gitignore` linha 50 ignora `/src/test/`; os testes novos **não aparecem** no `git status` e não serão commitados sem `git add -f` (ou sem remover a regra). Decisão do grupo pendente (é o item "tests ignored by git" dos bloqueios do MVP em `repositorios-removidos-e-cadastro-unico.md`).

## Fora desta etapa (Fase 4 continua)
Sem teste ainda: DAOs `Servico`, `Colaborador`, `Atendimento`, `Pagamento`, `DAOAgendamento.listarPorCliente`/`listarTodos`, `DAOVeiculo` (demais métodos), servlets do site/painel, `WebSupport`, modelos/`Validacao`, `Passwords`. Os de integração (Tomcat + MySQL) também não existem; as rotas ainda não foram exercitadas contra o banco real.

## Ligação com o projeto
Fase 4 de `plano-pendencias-api-mobile.md`. Cobre o que foi criado/alterado nas Fases 1–2 (`cancelar-agendamento-api-mobile.md`, `horarios-api-mobile.md`, `ajuste-veiculos-api-mobile.md`).
