# DAOAgendamento.listarPorCliente: ids dos serviços como lista

Escrito em 2026-11-11 23:37.

## O que mudou
- `DAOAgendamento.listarPorCliente`: o `GROUP_CONCAT` de `id_servico` (string `"1,3,5"`, ou `null` sem serviços) agora é lido com `getString` e convertido em `List<Integer>`. Antes era lido com `getInt("servicos")`, que falha com mais de um serviço. A query passou a usar `GROUP_CONCAT(DISTINCT ...)` para não repetir ids.
- `AgendamentoView`: o componente `id_servico` passou de `int` para `List<Integer>`, e `getIdServico()` devolve `List<Integer>`. Os nomes dos getters (usados pelas JSPs) não mudaram.

## Por quê
O `getInt` sobre o `GROUP_CONCAT` lançava `SQLException`, que o `AgendamentoApiServlet.doGet` tratava como "nenhum agendamento encontrado". Só os ids são necessários (não os nomes).

## Ligação com o projeto
Alimenta `GET /api/v1/agendamentos` (`AgendamentoApiServlet`, usado pelo app Flutter). `new ArrayList<>(item.getIdServico())` no servlet agora copia a lista de fato. Nenhum outro código usava o campo.

## Correções seguintes no `AgendamentoApiServlet.doGet` (2026-11-11 23:50)
- O id do cliente agora vem da query string: `GET /api/v1/agendamentos?idcliente=1`. Ausente ou inválido → 400 com `{"erro": "..."}`. Antes era lido do corpo do GET, que muitos clientes não enviam.
- A resposta é um único `JSONArray` (`[]` quando não há agendamentos), montado com `org.json`, em vez de um texto inválido escrito uma vez por item. Chaves: `id_agendamento`, `id_veiculo`, `data_agendamento` (`yyyy/MM/dd`), `hora_agendamento`, `id_servico` (array), `total_servico`, `status_pagamento`, `forma_pagamento` (null quando não há pagamento).
- `SQLException` → 500 com mensagem genérica (antes virava 204 sem corpo, escondendo a causa). `NovoAgendamentoRequest` deixou de ser usado como DTO de saída.
- `AgendamentoView`: o primeiro componente `id_cliente` (que na verdade recebia `id_agendamento`) foi renomeado para `id_agendamento`; `getIdCliente()` virou `getIdAgendamento()`. Nenhuma JSP usava o getter.
- Removidos imports sem uso do servlet.

## Pendências
- `Json.erro` gera `"Erro": mensagem`, que não é JSON válido (o `doPost`/`criar` ainda o usa).
- O `idcliente` vem do cliente sem autenticação; o ideal é obtê-lo da sessão/token (ver `ApiAuthFilter`).
