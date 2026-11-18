# Documentação da API mobile atualizada (Fase 3)

Registrado em 15/11/2026 12:32.

## O que mudou
- `openapi.yml` (v1.2): nova tag *API mobile* com as 8 rotas de `/api/v1/*` (login, serviços, veículos GET/POST/DELETE, agendamentos GET/POST/cancelar, horários, usuários GET/PATCH), respostas de erro `{"erro"}`, schemas `Api*` e nota geral (sessão, sem logout, sem cadastro pela API). Removida a frase "não há API JSON". Servidor corrigido para `SplashFast.war` / contexto `SplashFast` (antes `SplashFast-1.0`). YAML validado com `yaml.safe_load`.
- `plano-requisicoes-mobile-api.md`: aviso de atualização e tabela de contratos reescrita (sem `idcliente`, login por e-mail, sem `/auth/cadastro`, cancelar e horários implementados).
- `api-json-requisicao-resposta-erros.md`: aviso de atualização e seção de pendências refeita.
- `login-api-mobile.md`: corpo `{cpf, senha}`, resposta sem `token`, `LoginRequest` removido.
- `classes-api-mobile.md`: cancelar já existe no servidor; falta o método no app.
- `analise-app-mobile.md` §3.5: aviso de que é desenho inicial e lista das diferenças; `/horarios` com o formato real.
- Javadoc: `AtualizarPerfilRequest` (`/usuarios`, não `/me`), `NovoVeiculoRequest` (`id` é o cliente; `cor` opcional), `Json` (cabeçalho novo; `Response_enviar` não diz mais "200"), `ApiServlet` (só `ClienteApiServlet` a usa).

## Por quê
Fase 3 de `plano-pendencias-api-mobile.md`: o time mobile consome `openapi.yml` e os registros; vários descreviam JWT, `idcliente` e rotas que não existem mais.

## Pendências que ficam
- `ApiServlet.idClienteAutenticado` não é chamado por ninguém (código morto; os servlets usam `ApiAuthFilter.idAutenticado`). Decidir se remove.
- `Json.Response_ok`/`Response_enviar` mantêm nomes fora da convenção Java (renomear mexe em todos os servlets).
- `cliente_api.dart` (app) ainda lança `Exception` genérica no PATCH e usa endpoint passado por parâmetro; comentário de `veiculo_api.dart` sobre o id está defasado. Alterações do time mobile.
- Relatos antigos em `visao-geral-v2.md` e `analise-geral-v1.md` não foram reescritos (são fotos datadas).

## Verificação
`mvn compile` limpo; YAML carregado sem erro.
