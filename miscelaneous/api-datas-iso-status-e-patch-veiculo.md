# API mobile: datas ISO, status no agendamento e PATCH de veículo

Registrado em 2026-11-15 14:34.

## O que mudou
1. **Datas em ISO `yyyy-MM-dd`** em toda a API: `data_agendamento` do `GET /agendamentos`, `dataAgendamento` do `POST /agendamentos` e o parâmetro `data` do `GET /horarios`. Antes o `GET` saía `yyyy/MM/dd` e o `POST`/`horarios` entravam `dd/MM/yyyy`. Data fora do formato → 400 `Data inválida. Use yyyy-MM-dd`.
2. **`GET /agendamentos` ganhou `status`** (`AGENDADO`/`CANCELADO`/`CONCLUIDO`) **e `status_atendimento`** (`AGUARDANDO`/`EM_LAVAGEM`/`FINALIZADO`/`ENTREGUE`, `null` sem atendimento). `AgendamentoView` recebeu o componente `statusAtendimento` (último) e `DAOAgendamento.listarPorCliente` passou a fazer `LEFT JOIN atendimento` (1:1, `id_agendamento` é UNIQUE).
3. **`PATCH /veiculos/{id}`** `{placa?, marca?, modelo?, cor?}`: atualização parcial usando o `DAOVeiculo.atualizar` que já existia (o servlet mescla com os dados atuais). 404 se o veículo não for do cliente, 422 placa inválida, 409 placa repetida. `cor` vazia/`null` apaga a cor. `VeiculoApiServlet` passou a estender `ApiServlet` (que roteia PATCH).

## Por quê
O app precisa do estado da lavagem para a tela "Acompanhar" e de editar veículo (`meus_veiculos.dart`); e o formato assimétrico de datas era pendência da Fase 1 de `plano-pendencias-api-mobile.md`.

## Ligação com o projeto
- Site/painel não usam esses formatos (JSPs usam `AgendamentoView.getData()` direto), então nada mudou neles.
- O Flutter ainda precisa trocar `dd/MM/yyyy` por `yyyy-MM-dd` em `agendamento_api.dart` e ler os campos novos em `AgendamentoModel.dart` (não feito aqui).
- `openapi.yml` atualizado; testes ajustados e novos (299 passando).

## Próximo
Pagamento pelo mobile: rota que chame `DAOPagamento.atualizar` para o agendamento do cliente (a definir).
