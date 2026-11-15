# Remoção de código sem uso da API

Registrado em 15/11/2026 12:28.

## O que foi removido
- `api/Handler.java`: servlet vazio, sem `@WebServlet` nem referências.
- DTOs sem uso em `api/dto`: `ErroResponse`, `LoginRequest`, `LoginResponse`, `ServicoResponse`, `NovoAgendamentoRequest`. Os servlets montam o JSON direto com `org.json`; o formato de erro vive em `Json.erro`.
- `Json.parametroInt`: o `idcliente` saiu da query string (cliente vem da sessão).

Antes de apagar, `grep` em `src`, `app-mobile/lib`, `pom.xml` e `WEB-INF` confirmou zero referências. `mvn compile` e `mvn test` passam.

## O que ficou
`api/dto` só tem `ClienteResumo`, `AtualizarPerfilRequest` e `NovoVeiculoRequest` (usados por `ClienteApiServlet`, `VeiculoApiServlet`).

## Por quê / ligação
Fase 2 de `plano-pendencias-api-mobile.md`: deixar a API só com o que é usado antes de atualizar a documentação (Fase 3) e escrever testes (Fase 4). Os registros antigos que citam esses DTOs (`api-json-requisicao-resposta-erros.md`, `login-api-mobile.md`) serão corrigidos na Fase 3.

## Observação
O `Handler.java` foi removido do índice com `git rm --cached`; as demais remoções aparecem só como alteração na árvore de trabalho. Nada foi commitado.
