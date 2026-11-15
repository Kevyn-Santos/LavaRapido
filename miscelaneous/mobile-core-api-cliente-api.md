# app-mobile/lib/core/api: `ClienteApi` (GET /usuarios devolve objeto, não lista)

Registrado em 2026-11-15.

## Problema
`GET /api/v1/usuarios` devolve um único `{id, nome, cpf, telefone, email}`, mas `Clienteapi.getCliente` decodificava uma `List` (daria `TypeError` ao abrir o perfil; só não aparecia porque `perfil_cliente.dart` nunca usava o Future). A classe também lançava `Exception` genérica, não usava `comTratamentoDeRede`, recebia o endpoint por parâmetro e duplicava o tratamento de rede no `login`.

## O que foi feito (`cliente_api.dart`, pendência 3 resolvida)
- Classe renomeada para `ClienteApi`.
- `buscar()` → `GET /usuarios` fixo, devolve **um** `ClienteModel` (substitui `getCliente(endpoint)`).
- `atualizar({nome?, telefone?, email?})` → `PATCH /usuarios`, só os campos informados, devolve o `ClienteModel` (substitui `atualizarCliente(endpoint, ClienteModel)`). Erros: 404, 422.
- `login` e os demais usam `comTratamentoDeRede` + `ApiException.deResposta` e `utf8.decode(bodyBytes)`.
- `ClienteModel.toJson` removido (sem uso; mandava `id`/`cpf`, que a API ignora).
- `login_cliente.dart`: só o nome da classe. `perfil_cliente.dart`: usa `buscar()` e mostra o nome real do cliente (fallback "Cliente Fast Splash" enquanto carrega ou em erro); some o aviso `unused_field`.
- Testes novos `app-mobile/test/cliente_api_test.dart` (`MockClient`, 6 casos, incluindo a regressão do objeto). `dart analyze lib test`: sem problemas; testes passam.

## Ligação com o projeto
Fecha a pendência 3 de `mobile-core-api-ajustes-e-pendencias.md`. Contrato: `miscelaneous/openapi.yml` (`/usuarios`), sem mudança no servidor.

## Continua pendente
HTTPS/ambiente (`api_config.dart`) e ligar as demais telas ao `core/api/` (inclui `Agendamento` com um serviço vs. `id_servico[]`).
