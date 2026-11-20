# Filtro de atendimentos: finalizados não apareciam

Registro de 20/11/2026 15:08.

## Modificação
`DAOAtendimento.listar()`: o `WHERE` passou de `at.status IN ('AGUARDANDO', 'EM_LAVAGEM')` para `IN ('AGUARDANDO', 'EM_LAVAGEM', 'FINALIZADO')`.

## Por quê
O filtro de `painel-atendimentos.jsp` (`#filtro-status-atendimento`) tem a opção "Finalizados", mas a query nunca trazia atendimentos `FINALIZADO`, então a opção sempre vinha vazia. Sem atendimentos ativos, `atendimentos` ficava vazio e o JSP mostrava só "Nenhum atendimento encontrado.", sem tabela nem filtro. O filtro JS em si (`filtrarAtendimentos()`, inline no JSP) estava correto; `painel-agendamento.js` não tem filtro.

## Ligação com o projeto
`listar()` alimenta `PainelServlet` (case `atendimentos`) e `AdminServlet`. O JSP já ignora `CANCELADO` e trata `ENTREGUE` como histórico; `ENTREGUE` continua fora da query e do select. `IntegracaoDaosTest` usa `listar().get(0)` logo após criar o agendamento (status `AGUARDANDO`, ordem por id decrescente), então não é afetado.
