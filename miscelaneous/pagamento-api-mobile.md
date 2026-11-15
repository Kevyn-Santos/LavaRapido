# Pagamento pelo app: POST /api/v1/agendamentos/{id}/pagar

Registrado em 2026-11-15 14:52.

## O que mudou
- Nova rota `POST /api/v1/agendamentos/{id}/pagar {forma}` (`AgendamentoApiServlet`). `forma` ∈ `PIX`, `CREDITO`, `DEBITO` (`DINHEIRO` só o atendente registra no painel). Resposta 200 `{mensagem, status_pagamento: "PAGO", forma_pagamento}`.
- Novo `DAOPagamento.idDoAgendamentoDoCliente(idCliente, idAgendamento)`: devolve o id do pagamento só se o agendamento for de um veículo do cliente. Necessário porque `DAOPagamento.atualizar(idPagamento, ...)` não conhece o dono.
- Erros: 404 agendamento inexistente/de outro cliente, 409 pagamento já processado ou agendamento cancelado, 422 forma inválida, 400 caminho/corpo inválido.

## Por que e como liga ao resto
- A linha de `pagamento` (PENDENTE) já nasce em `DAOAgendamento.criar`; a rota só a atualiza.
- Atendente (painel, `AdminServlet` → `DAOPagamento.atualizar`) e cliente (app) gravam na mesma linha; `GET /agendamentos` lê dela, então um reflete no outro sem sincronização extra. `atualizar` só altera `PENDENTE`, então se os dois pagarem quase juntos o segundo recebe 409 (o app deve apenas recarregar a lista).
- Libera a regra "lavagem só começa com pagamento confirmado" (`DAOAtendimento.atualizar`).
- Testes: 5 em `AgendamentoApiServletTest` (`Pagar`), 1 em `DAOPagamentoTest`; `openapi.yml` atualizado.
