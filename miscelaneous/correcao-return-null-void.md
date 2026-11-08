# Correção: `return null;` em métodos `void`

## O quê

Projeto não compilava: vários métodos `void` (em sua maioria `doGet`/`doPost` de
servlets, que são `void` por assinatura do Servlet API) continham `return null;`
em vez de `return;`. Trocado `return null;` → `return;` nos pontos de retorno
antecipado desses métodos, sem nenhuma outra alteração de lógica.

Arquivos corrigidos (18 ocorrências):

- `servlet/BaixarAppServlet.java` (linha 22)
- `servlet/VeiculoServlet.java` (linhas 21, 29)
- `servlet/LoginServlet.java` (linha 23)
- `servlet/Health.java` (linha 13)
- `servlet/AgendamentoServlet.java` (linhas 28, 37)
- `servlet/SetupAdminServlet.java` (linhas 23, 28, 34)
- `servlet/PortalServlet.java` (linhas 20, 25, 28)
- `api/Handler.java` (linha 24)
- `api/v1/AgendamentoApiServlet.java` (linha 26)
- `api/v1/VeiculoApiServlet.java` (linha 26)
- `api/v1/ServicoApiServlet.java` (linha 23)
- `api/v1/HorarioApiServlet.java` (linha 23)

## Por quê

`mvn compile` falhava com `incompatible types: unexpected return value` em
todos os pontos acima — um método declarado `void` não pode retornar um valor,
nem `null`. Provável resíduo de edição/refatoração anterior na expansão da API
v1 (ver `esqueleto-api-v1-2026-10-26.md`) que deixou o código em estado não
compilável.

## Como se liga ao projeto

Corrige apenas a assinatura de retorno; nenhuma regra de negócio, validação ou
fluxo foi alterado. `mvn compile` passa limpo após a correção. Escopo
estritamente estes 18 `return null;` — nenhum outro arquivo ou trecho tocado.
