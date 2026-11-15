# Plano de pendências da API para o time mobile

Registrado em 2026-11-15 11:41. Documento de planejamento, derivado da análise da estrutura da API (`/api/v1/*`) cruzada com `miscelaneous/` e o hub externo.

## Ordem de trabalho (definida pelo grupo)
1. **Pendências técnicas imediatas** para o mobile poder implementar no Flutter.
2. **Remover o que não é usado.**
3. **Atualizar documentação e comentários.**
4. **Testes unitários** de cada parte.

### Fase 1: pendências técnicas
- [x] `POST /agendamentos/{id}/cancelar` (ver `cancelar-agendamento-api-mobile.md`).
- [x] `GET /horarios?data=` e validação do `POST /agendamentos` (ver `horarios-api-mobile.md`). Pontos que eram abertos:
  - grade de horários (abertura, fechamento, intervalo) e capacidade por horário: decisão de negócio;
  - a DAO não tem consulta de horários ocupados: criar em `DAOAgendamento`;
  - validar `horarioAgendamento` (`HH:mm`), data não passada e horário livre também no `POST` (a API é a autoridade);
  - formatos assimétricos de data (`GET` devolve `yyyy/MM/dd`, `POST` recebe `dd/MM/yyyy`): decidir se unifica.
- [x] `POST /veiculos`: `cor` opcional e `id_veiculo` no 201 (ver `ajuste-veiculos-api-mobile.md`).

### Fase 2: remoções (concluída, ver `remocao-codigo-sem-uso-api.md`)
- `api/Handler.java` (servlet vazio, sem mapeamento).
- DTOs sem uso: `ErroResponse`, `LoginRequest`, `LoginResponse`, `ServicoResponse`, `NovoAgendamentoRequest`.
- `Json.parametroInt` (o `idcliente` saiu da query).
- Confirmar uso antes de apagar (grep) e rodar `mvn compile`.

### Fase 3: documentação e comentários (concluída, ver `documentacao-api-mobile-atualizada.md`)
- `openapi.yml` não tem nenhuma rota `/api/v1` e diz "não há API JSON".
- `plano-requisicoes-mobile-api.md`: ainda descreve `idcliente` na query/corpo, login por `cpf`, `/auth/cadastro` e JWT.
- `api-json-requisicao-resposta-erros.md`: pendências de autenticação já resolvidas.
- `login-mobile-flutter.md`: confirmar se `cliente_api.dart` aponta para `/usuarios`.
- Javadoc: `AtualizarPerfilRequest` cita `/api/v1/me`; `NovoVeiculoRequest.id` é o id do cliente; `Json.Response_enviar` diz "200".

### Fase 4: testes (concluída: API, horários, DAOs, servlets do site/painel, modelos, Passwords, DatabaseConnection e integração com MySQL real; suíte de 305, ver `testes-*.md` e `testes-integracao-e-database-connection.md`)
Hoje só `ApiAuthFilterTest` e `DAOClienteTest`. Cobrir servlets de `v1/` e as demais DAOs.

## Fora de escopo (decisões do grupo)
Logout, cadastro pela API, CORS. Ver `cancelar-agendamento-api-mobile.md`.
