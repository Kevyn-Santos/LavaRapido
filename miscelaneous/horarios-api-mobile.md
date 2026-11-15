# Horários livres e validação de horário no agendamento

Registrado em 15/11/2026 12:02.

## O que mudou
- Nova `model/GradeHorarios`: grade de **06:00 a 17:30, de 30 em 30 min** (24 horários; 18:00 é o fechamento). `todos()`, `valido()`, `interpretar(String)` (aceita `HH:mm` e `HH:mm:ss`).
- `DAOAgendamento`:
  - novos `horariosOcupados(data)` (ignora `CANCELADO`) e `horariosLivres(data)` (data passada → vazio; hoje → só o que ainda não passou);
  - `criar` agora valida, antes de gravar: horário na grade, data/horário não passados e horário livre (`SELECT ... FOR UPDATE` na transação, serializando reservas simultâneas). Violação → `IllegalArgumentException` ("Horário fora da grade...", "Não é possível agendar em data ou horário que já passou.", "Horário indisponível."). O horário é gravado normalizado (`Time`).
- `HorarioApiServlet` (antes 501): `GET /api/v1/horarios?data=dd/MM/yyyy` → 200 `["06:00","06:30",...]`; 400 `{"erro"}` sem `data` ou com formato inválido; 500 erro de banco. Exige sessão.
- `AgendamentoApiServlet`: Javadoc do POST atualizado (422 para horário fora da grade/passado/indisponível, sem mudança de código).

## Por quê
Resolve o erro E1 (horário sem validação) de `analise-app-mobile.md` e a pendência de `api-json-requisicao-resposta-erros.md`. O app precisa listar horários livres e a API é a autoridade sobre a regra.

## Achado: o schema não garante "um por horário"
`UNIQUE (id_veiculo, data, horario)` não impede dois veículos no mesmo horário e ainda bloqueia reagendar o mesmo veículo em horário de agendamento `CANCELADO`. Por isso a regra está em código, ignorando cancelados. Risco aceito: deadlock raro entre duas reservas simultâneas do mesmo horário (uma delas vira 500).

## Decisões do grupo
Grade 06:00–18:00 (último horário 17:30), 30 min, um agendamento por horário (qualquer veículo/cliente); validação na DAO (vale para API, site do cliente e painel); data da API em `dd/MM/yyyy` (o plano antigo previa `yyyy-MM-dd`).

## Ligação com o projeto
`AgendamentoServlet` (site) e `AdminAgendamentoServlet` herdam as regras, pois chamam a mesma `criar`; ambos já tratam `IllegalArgumentException`. Fase 1 de `plano-pendencias-api-mobile.md` concluída.

## Verificação
`mvn compile` e `mvn test` passam. Rotas não exercitadas contra Tomcat/MySQL.
