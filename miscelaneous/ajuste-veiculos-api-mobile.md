# Ajuste de `POST /api/v1/veiculos`: cor opcional e id na resposta

Registrado em 15/11/2026 12:05.

## O que mudou
- `DAOVeiculo.inserir` passou de `void` a `int`: devolve o `id_veiculo` gerado (`RETURN_GENERATED_KEYS`). Os chamadores web (`VeiculoServlet`, `AdminVeiculoServlet`) ignoram o retorno, sem mudança.
- `VeiculoApiServlet.doPost`:
  - `cor` é opcional (`optString`); ausente, nula ou vazia grava `NULL`, coerente com o `GET`, que já a trata como anulável, e com o schema (`cor VARCHAR(30)` sem `NOT NULL`);
  - o 201 devolve `{id_veiculo, placa, marca, modelo, cor}` com os valores normalizados (placa em maiúsculas, textos sem espaços nas pontas). O campo `id_cliente` saiu: o app já sabe quem é (sessão) e precisava do id do veículo.

## Por quê
Pendência listada na Fase 1 de `plano-pendencias-api-mobile.md`: sem o id o app tinha de chamar `GET /veiculos` de novo para poder excluir o veículo recém-criado; e exigir `cor` divergia do schema e do `GET`.

## Impacto no app (time mobile)
`veiculo_api.dart` ainda diz "a resposta não traz o id": agora traz `id_veiculo`, e `cor` pode ser omitida (hoje o app a manda sempre). Nada do app foi alterado aqui.

## Verificação
`mvn compile` limpo. Não exercitado contra Tomcat/MySQL.
