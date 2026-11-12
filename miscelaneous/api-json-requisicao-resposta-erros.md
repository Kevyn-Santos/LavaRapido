# API v1: JSON de requisição, resposta e erro padronizados

Escrito em 2026-11-12 (registro da correção feita em 2026-11-11, após o veredito sobre os servlets de `api/v1`).

## Por quê
Os servlets de `/api/v1/*` montavam JSON com `String.formatted` (sem `{}`, sem aspas, sem `[]`), escreviam uma resposta por item dentro do `for`, liam o corpo de GET/DELETE (que muitos clientes não enviam), deixavam `JSONException` sem tratamento (500) e respondiam erros com `"Erro": msg` (também inválido). O app Flutter (`app-mobile/`) vai consumir essas rotas, então toda resposta precisa ser JSON válido e todo erro precisa ter o mesmo formato. Autenticação (`ApiAuthFilter`/`JwtService`/login) ficou **fora** desta etapa e será feita depois; os servlets ainda recebem `idcliente` do chamador (marcado com TODO).

## Padrão adotado
- **Resposta de sucesso:** sempre montada com `org.json` (`JSONObject`/`JSONArray`) e enviada **uma vez**. Listas vazias → `[]`. Campos que podem ser nulos usam `Json.ouNulo` (porque `JSONObject.put(chave, null)` remove a chave). `BigDecimal` vira número com ponto decimal.
- **Erro:** `{"erro": "mensagem"}` com `Content-Type: application/json; charset=UTF-8`.
- **Status:** 400 requisição inválida (JSON/campo/parâmetro/data), 404 recurso inexistente, 409 violação de unicidade (placa), 422 regra de negócio da DAO, 500 erro de banco (mensagem genérica; o detalhe vai para o log do servidor via `getServletContext().log`, nunca para o cliente). Sucesso de criação: 201.
- **Requisição:** GET e DELETE não leem corpo; o `idcliente` vem da query string e o recurso no path. POST/PATCH leem o corpo com `Json.lerCorpo`.

## Mudanças por arquivo

### `api/Json.java`
- `erro(response, status, mensagem)`: agora gera `{"erro": "..."}` via `JSONObject` (antes `"Erro": mensagem`, inválido e sem escapar aspas).
- Novo `lerCorpo(request)`: lê o corpo como `JSONObject`; corpo vazio ou inválido lança `JSONException` (os servlets respondem 400).
- Novo `parametroInt(request, nome)`: lê inteiro da query string; ausente/inválido lança `IllegalArgumentException` com mensagem pronta para o 400.
- Novo `ouNulo(valor)`: `null` → `JSONObject.NULL`.
- `Response_ok`/`Response_enviar` e o stub `ler(request, Class)` ficaram como estavam.

### `v1/AgendamentoApiServlet.java`
- **GET** `?idcliente=`: usa `Json.parametroInt` (400 se faltar); `SQLException` → 500 + log (já devolvia array único, ver `agendamento-listar-por-cliente-ids-servicos.md`). Removido o `erroJson` privado em favor de `Json.erro`.
- **POST criar**: corpo lido com `Json.lerCorpo` (chaves mantidas: `idcliente`, `idveiculo`, `horarioAgendamento`, `dataAgendamento` em `dd/MM/yyyy`, `idservico[]`). Passou a responder **201** `{"mensagem": "Agendamento criado com sucesso"}` (antes não respondia nada). `JSONException`/`DateTimeParseException` → 400; `IllegalArgumentException` da DAO → 422 só com `getMessage()` (antes vazava `getCause`/`getStackTrace`); `SQLException` → 500 genérico (antes 422 e `throw new RuntimeException`, que gerava 500 depois de a resposta já ter sido escrita).
- **cancelar**: continua 501 (não implementado).
- Removidos imports sem uso (`Collectors`).

### `v1/ServicoApiServlet.java`
- Resposta: array único `[{id_servico, nome, descricao, preco}]`. O `%.2f` dependia do locale (pt_BR geraria `10,50`, quebrando o JSON); agora o preço é número JSON. Erro de banco → 500 com `{"erro"}` (antes 204 sem corpo, que escondia o erro). `ServicoResponse` deixou de ser usado como DTO intermediário.

### `v1/VeiculoApiServlet.java`
- **GET** `?idcliente=`: antes lia o corpo do GET. Agora array único `[{id_veiculo, placa, marca, modelo, cor}]` (chaves antes `Placa/Marca/modelo/Cor`, sem id). `NovoVeiculoRequest` não é mais usado como saída. `SQLException` → 500 (antes 204 + `throw`).
- **POST**: `Json.lerCorpo`; resposta **201** `{id_cliente, placa, marca, modelo, cor}` (antes 200 com texto inválido). `JSONException` → 400; `IllegalArgumentException` (cliente inexistente/inativo) → 422; `SQLIntegrityConstraintViolationException` (placa duplicada) → **409** (antes 500); demais `SQLException` → 500 (antes `throw new RuntimeException`).
- **DELETE**: agora `DELETE /api/v1/veiculos/{idVeiculo}?idcliente=` (antes lia as duas ids do corpo do DELETE). Sucesso 200 `{"mensagem": ...}` (antes texto puro); não encontrado → **404** (antes 422); id inválido → 400; `SQLException` → 500 (antes `catch (SQLException _) {}` vazio, que engolia o erro e devolvia resposta vazia).

### `v1/ClienteApiServlet.java`
- **GET** `?idcliente=`: antes listava **todos** os clientes (`getUsuarios`, expondo CPF/e-mail/telefone) e escrevia uma resposta por cliente, com strings sem aspas. Agora devolve um único objeto `{id, nome, cpf, telefone, email}` do cliente pedido (conforme o contrato), 404 se não existir.
- **PATCH**: `Json.lerCorpo`; `JSONException` → 400; cliente inexistente → 404 (antes 500 por `IllegalArgumentException` solta); valores rejeitados pelos setters/`Validacao` → 422 (antes 500); resposta com o mesmo objeto do GET (antes JSON inválido). A montagem do objeto foi extraída para `resumoJson`.

## Como se liga ao projeto
- Contratos dos endpoints: Javadoc de cada servlet (atualizado) e `analise-app-mobile.md`, seção 3.5. O app Flutter ainda usa dados em memória, então nenhum cliente foi quebrado; quando for integrado deve enviar `idcliente` na query (GET/DELETE) ou no corpo (POST/PATCH) até a autenticação existir.
- Mudanças de contrato visíveis ao chamador: GET de veículos/usuários/agendamentos exige `?idcliente=`; DELETE de veículo usa o path; chaves de veículo em minúsculas; `usuarios` devolve 1 objeto.

## Pendências
- Autenticação (`ApiAuthFilter`, `JwtService`, `AuthApiServlet`): trocar `idcliente` por `idClienteAutenticado(request)` (os servlets de agendamento e veículo ainda precisam herdar de `ApiServlet`). Hoje qualquer um lê/altera dados de qualquer cliente.
- `AgendamentoApiServlet.cancelar` e `HorarioApiServlet` não implementados.
- Validar `horarioAgendamento` (hoje vai direto para a DAO).
- Sem testes automatizados dos servlets; `mvn compile` e `mvn test` passam, mas as rotas não foram exercitadas contra o Tomcat.
