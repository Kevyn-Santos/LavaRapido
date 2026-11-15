# `GET /api/v1/agendamentos`: lista de serviços com nome e valor

Registrado em 2026-11-15.

## O que mudou
- A resposta de cada agendamento ganhou `servicos: [{id_servico, nome, valor}]`. `id_servico[]` e `total_servico` continuam iguais (compatível).
- `valor` = `agendamento_servico.valor_praticado` (preço na época do agendamento, não o do catálogo); a soma é o `total_servico`.
- `AgendamentoView` (DTO) ganhou o componente `servicos` (`List<ServicoView>`; `preco` guarda o valor praticado, `descricao` vem null).
- `DAOAgendamento.listarPorCliente`: a mesma query traz `servicos_detalhe` (`GROUP_CONCAT` de `id:valor:nome`, uma linha por serviço); o nome vai por último porque pode conter `:`. Sem query extra.
- `AgendamentoApiServlet` monta o array; `openapi.yml` (`ApiAgendamento.servicos`) atualizado.
- Dart: `AgendamentoModel.servicos` (`ServicoDoAgendamento`), teste `app-mobile/test/agendamento_api_test.dart`.

## Por quê
O app é de consulta: o cliente precisa ver todos os serviços de cada agendamento. Cruzar `id_servico[]` com o catálogo mostraria o preço de hoje e a soma poderia não bater com o total cobrado.

## Verificação
`mvn test`: 304 testes, 0 falhas (DAO e servlet com mocks, com casos novos para a lista e para nome contendo `:`). `dart analyze lib test` e `flutter test`: ok.
**Não verificado contra MySQL real:** o SQL novo só foi coberto por mock; rodar `FluxoApiIntegracaoTest`/`IntegracaoDaosTest` ou um `GET /agendamentos` local. Limite conhecido: `GROUP_CONCAT` trunca em `group_concat_max_len` (1024 por padrão), suficiente para dezenas de serviços; nomes de serviço com quebra de linha quebrariam o parse (não validados hoje).

## Ligação com o projeto
Segue `miscelaneous/app_mobile/integracao-flutter-direcionamento-2026-11-15.md` (seção 5). Falta o time Flutter adaptar o `Agendamento` da UI (hoje 1 `Servico`) e a seleção múltipla no novo agendamento.
