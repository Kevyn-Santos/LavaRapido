# Correção: mensagens de data/hora em português e status da remoção de veículo

Registrado em 15/11/2026 13:03.

## O que mudou
1. **Data/hora mal formatada (site, painel e API).** `AgendamentoServlet`, `AdminAgendamentoServlet` e `AgendamentoApiServlet` tratavam `DateTimeParseException` junto de outras exceções e repassavam `getMessage()`, sempre em inglês (`Text '...' could not be parsed...`); a mensagem em português do site era código morto. Agora `DateTimeParseException` tem `catch` próprio com texto fixo: "Informe uma data e um horário válidos." (site/painel) e "Data inválida. Use dd/MM/yyyy" (API). `IllegalArgumentException` (regra da DAO) continua repassando a própria mensagem. `JSONException` na API não mudou.
2. **Remoção de veículo no site.** `VeiculoServlet`, ação `remover`: quando falha (id inválido, veículo inexistente, de outro cliente ou já desativado) responde **404** (antes 200) com a mensagem "Veículo não encontrado." (antes dizia "ou vinculado a um agendamento", mas `DAOVeiculo.remover` é exclusão lógica e não depende de agendamento). A página continua sendo reexibida com a lista.

## Por quê
Vieram da análise dos testes dos servlets (`testes-servlets-site-painel.md`): o usuário via texto técnico em inglês e a falha da remoção era indistinguível de um sucesso para qualquer cliente HTTP, teste ou monitor.

## Testes
3 testes novos (suíte 213): mensagem em português no site, no painel e na API, e a remoção do site agora verifica 404 + mensagem. Os dois bugs dos testes **não** foram tratados nesta etapa (decisão do usuário).

## Estado dos bugs pendentes
- Placa sem validação de formato no site e na API (`placaInvalida`): continua falhando de propósito.
- Status `ENTREGUE` no painel: `AdminServlet.STATUS_ATENDIMENTO` já inclui `ENTREGUE` (alterado fora desta sessão, 12:59); o teste `atendimentoEntregue` passa.
