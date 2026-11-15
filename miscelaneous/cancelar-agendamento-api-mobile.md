# Cancelar agendamento na API mobile

Registrado em 2026-11-15 11:41.

## O que mudou
`AgendamentoApiServlet.cancelar` (antes 501) agora implementa `POST /api/v1/agendamentos/{id}/cancelar`.

- Cliente: vem da sessão (`ApiAuthFilter.idAutenticado`). Agendamento: lido do path (`/{id}/cancelar`).
- Chama `DAOAgendamento.cancelar(idCliente, idAgendamento)`, que já existia: transação que marca o agendamento `CANCELADO` (só se for do cliente e estiver `AGENDADO`) e o pagamento `PENDENTE` como `CANCELADO`.
- Sem corpo na requisição.

### Contrato
| Situação | Status | Corpo |
| --- | --- | --- |
| Cancelado | 200 | `{"mensagem": "Agendamento N cancelado com sucesso"}` |
| Path inválido (id não numérico, partes a mais) | 400 | `{"erro": ...}` |
| Sem sessão | 401 | `{"erro": "Faça login para continuar"}` (filtro) |
| Inexistente, de outro cliente ou fora de `AGENDADO` | 404 | `{"erro": "Agendamento não encontrado ou não pode ser cancelado"}` |
| Erro de banco | 500 | `{"erro": ...}` genérico; detalhe no log |

Um único 404 para os três casos evita revelar se o id existe para outro cliente. O Javadoc dizia 204; passou a 200 com mensagem, igual ao `DELETE /veiculos/{id}`, sem precisar de helper para resposta vazia.

## Por que
Era a última pendência de escrita da API para o time mobile. `agendamento_api.dart` ainda tem o comentário "servidor responde 501"; o time mobile implementa o método `cancelar` no app (nada do app foi alterado aqui).

## Como se liga ao projeto
Segue `autenticacao-sessao-api-mobile.md` (cliente da sessão) e `api-json-requisicao-resposta-erros.md` (formato de erro). Não há teste novo: ver decisão 4 abaixo.

## Decisões do grupo (2026-11-15)
1. Logout continua sem rota: encerrar a sessão (timeout) força novo login.
2. Cadastro só na web (`/cadastro`); não existe cadastro na API.
3. App roda em emulador Flutter: CORS não será tratado.
4. Testes unitários ficam defasados por ora; não são requisito do projeto.
5. Ordem de trabalho em `plano-pendencias-api-mobile.md`.

## Verificação feita
`mvn compile` limpo. Rota não exercitada contra Tomcat/MySQL nesta etapa (roteiro de curl no plano).
