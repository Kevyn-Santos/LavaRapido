# Ajustes do painel: pagamento antes da lavagem, erro de agendamento na tela e horários reais (2026-11-15)

Implementa os pontos 2, 3 e 4 de `plano-ajustes-usabilidade-v1.md` (o ponto 1, setup do 1º administrador, ficou para depois).

## 2. Lavagem só com pagamento confirmado
- `DAOAtendimento.atualizar`: o `SELECT ... FOR UPDATE` agora faz `LEFT JOIN pagamento`; a transição `AGUARDANDO → EM_LAVAGEM` lança `IllegalArgumentException` se o pagamento não for `PAGO`. Mesma transação da mudança de status, sem corrida com a tela de pagamentos. `AGUARDANDO → AGUARDANDO` (trocar só colaboradores) continua permitido.
- `DAOAtendimento.listar` e `AtendimentoView` ganharam `statusPagamento` (`MAX(p.status_pagamento)`, `PENDENTE` se não houver linha).
- `painel-atendimentos.jsp`: sem pagamento `PAGO` a única opção é "Aguardando pagamento (lavagem bloqueada)"; o erro do DAO aparece pelo caminho já existente de `AdminServlet.doPost`.
- **Reversão de PAGO:** decisão "bloquear depois do início". `DAOPagamento.atualizar` já só altera pagamentos `PENDENTE` (`WHERE status_pagamento = 'PENDENTE'`), então `PAGO` nunca volta nem é cancelado, nem antes do início. Nada novo no código; só documentado no Javadoc do método.
- O operacional não registra pagamento (exige `ATENDENTE`): a mensagem manda pedir ao atendente.

## 3. Erro de agendamento na própria tela
- `AdminAgendamentoServlet`: os `sendError` (400/409) viraram `voltarComErro`: guarda `erroAgendamento` e o rascunho (`rascunhoAgendamento`: cliente, veículo, data, horário, serviços) na sessão e redireciona para `/painel/agendamentos`.
- `PainelServlet` (seção `agendamentos`) move os dois atributos da sessão para a requisição (`erro`, `rascunho`) e os remove, então a mensagem aparece uma vez.
- `painel-agendamentos.jsp`: `#form-error` mostra `${erro}`; o formulário reabre preenchido. Antes de enviar, `min` = hoje e mensagem "Escolha hoje ou uma data futura." ao escolher data passada.

## 4. Horários reais
- Novo `AdminHorarioServlet` (`GET /admin/horarios?data=yyyy-MM-dd`, nível `OPERACIONAL`, `Cache-Control: no-store`) devolve `DAOAgendamento.horariosLivres(data)` em `HH:mm`. Mesma regra da API mobile (`/api/v1/horarios`), mas com sessão do colaborador. Erros em JSON `{"erro": ...}` (400 data inválida, 500 banco).
- `#bk-slot` perdeu as 9 opções fixas: começa em "Escolha a data primeiro" e o JS recarrega ao mudar a data ("Sem horários livres nesta data" quando vazio). Respostas atrasadas de uma data anterior são descartadas.
- A corrida entre dois operadores continua coberta por `DAOAgendamento.criar` (transação); o erro cai no fluxo do item 3.

## Testes
`DAOAtendimentoTest` (pagamento PENDENTE/CANCELADO/ausente recusa e faz rollback; manter status sem pagamento passa), `PainelEAdminServletTest` (erros viram flash + redirect; `PainelServlet` move e limpa o flash), novo `AdminHorarioServletTest`. `mvn test` sem falhas.

## Verificação manual pendente
Rodar no Tomcat: data passada, horário já ocupado, data de hoje (horários que já passaram somem), iniciar lavagem com pagamento pendente e depois de pago. O JS do formulário não tem teste automatizado.

## Ligação com o projeto
Usa a grade e a regra de disponibilidade de `GradeHorarios`/`DAOAgendamento` (`horarios-api-mobile.md`) e o ciclo do atendimento com a tabela `pagamento` criada junto do agendamento.
