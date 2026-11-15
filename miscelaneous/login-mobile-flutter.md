# Login do app Flutter (e-mail + senha, sessão HttpSession)

Registrado em 2026-11-14.

## O que mudou (`app-mobile/lib`)
- `features/auth/login_cliente.dart`: campo CPF trocado por E-mail; senha demo `1234` removida; `_entrar` agora é assíncrono, chama `Clienteapi.login`, mostra loading e exibe a mensagem de erro do servidor em SnackBar. Em sucesso grava `Sessao.id` (e `Sessao.cpf`) e navega como antes.
- `core/api/cliente_api.dart`: `login(email, senha)` faz `POST /auth/login`, lê `{cliente:{...}}` (ignora `token`) e lança `ApiException` (mensagem do campo `erro`).
- `core/api/api_client.dart`: guarda o cookie `JSESSIONID` (estático, compartilhado entre instâncias) a partir do `Set-Cookie` e o reenvia em toda requisição; usa o `http.Client` da instância. `APIClient.limparSessao()` no logout.
- `core/api/api_config.dart`: `BASE_URI` = só host:porta; novo `BASE_PATH` = `/SplashFast/api/v1` (o formato anterior não funcionava com `Uri.http`).
- `core/api/api_exception.dart` (novo), `model/ClienteModel.dart` (id aceita número, campo `cpf`), `session/sessao.dart` (`logado` = `id` preenchido; `limpar()` também descarta o cookie).

## Por que
Decisão: autenticar por HttpSession em vez de JWT. O app só precisa reenviar o cookie; nada de token. O backend foi concluído em `autenticacao-sessao-api-mobile.md`.

## O que o backend precisava fazer (concluído em 2026-11-14)
- `AuthApiServlet.login`: `request.getSession(true).setAttribute("clienteId", id)` após autenticar.
- `ApiAuthFilter`: liberar `/api/v1/auth/*` e `GET /servicos`; nas demais responder 401 sem sessão.
- Remover o `token` do JSON (o mobile ignora).

## Ligação com o projeto
Complementa `login-api-mobile.md` (contrato do endpoint). Pendência fora do escopo: `perfil_cliente.dart` chama `/cliente`, mas a rota existente é `/usuarios`.
