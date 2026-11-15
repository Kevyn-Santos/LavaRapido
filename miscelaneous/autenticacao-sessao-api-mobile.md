# Autenticação da API mobile por HttpSession (sem JWT)

Registrado em 2026-11-14 21:27.

## O que mudou
**Backend (`src/main/java/com/splash/web/api`)**
- `ApiAuthFilter` (antes stub que deixava tudo passar) agora exige login em `/api/v1/*`. Públicas: `/api/v1/auth/*` e `GET /api/v1/servicos`. Nas demais lê `session.getAttribute("clienteId")`; sem sessão responde 401 `{"erro": "Faça login para continuar"}`. Com sessão, grava o id em `request.setAttribute("idCliente", ...)`; `ApiAuthFilter.idAutenticado(request)` devolve esse id aos servlets.
- `AuthApiServlet.login`: após conferir a senha, descarta a sessão anterior e faz `getSession(true).setAttribute("clienteId", id)` (mesmo padrão e mesma chave do `LoginServlet` do site). O Tomcat devolve o cookie `JSESSIONID`. O campo `token` saiu da resposta: `{cliente:{...}}`.
- `ClienteApiServlet`, `VeiculoApiServlet`, `AgendamentoApiServlet`: o cliente vem sempre da sessão. O `idcliente` deixou de existir na query (GET/DELETE) e no corpo (POST/PATCH); se o app mandar, é ignorado. Fecha o buraco em que bastava trocar o número da URL para ver ou alterar dados de outro cliente.
- Removidos: `api/jwt/JwtService` (stub) e o campo `token` de `LoginResponse`.
- Teste novo `ApiAuthFilterTest` (6 casos: rotas públicas, 401 sem sessão, sessão de colaborador, `POST /servicos` protegido, sessão válida repassa o id). Suíte: 31 testes passando.

**App (`app-mobile/lib`)**
- `APIClient.get(endpoint)` não recebe mais id nem envia `?idcliente=`; `Clienteapi.getCliente` e `perfil_cliente.dart` acompanharam.
- 401 fora de `/auth/*` = sessão expirou (o Tomcat expira com 30 min sem uso): `APIClient` descarta o cookie e chama `APIClient.aoSessaoExpirar`, ligado em `main.dart` a `voltarAoLogin()` (`app.dart`), que limpa `Sessao`, volta à `TelaInicial` e mostra "Sessão expirada. Entre novamente.". Em `/auth/*` o 401 é só senha errada e não dispara isso.

## Por que HttpSession e não JWT
- Há um único Tomcat, execução local e nenhum deploy: o ganho do JWT (servidor sem estado, vários servidores, clientes sem cookie) não se aplica.
- Custo: sessão = ~1 linha no login + filtro de ~15 linhas, sem dependência nem segredo novos; JWT exigiria `java-jwt`, `JWT_SECRET`, classe de assinatura/validação e tratamento de expiração.
- Explicação para a turma e o professor: "o servidor guarda quem logou na memória e o app apresenta um cookie; é o mesmo mecanismo do site". JWT exigiria explicar assinatura, claims, segredo e expiração.
- Logout real: no servidor basta invalidar a sessão; um JWT não pode ser revogado antes de expirar sem lista de bloqueio.

## Upgrade técnico futuro (não implementado)
Se a API for exposta a vários servidores ou a clientes sem cookie, trocar a sessão por JWT: `Authorization: Bearer`, assinatura HMAC com `JWT_SECRET` (`System.getenv`), claim `sub` = id do cliente. O ponto de troca é só o `ApiAuthFilter` (validar o token em vez da sessão) e o `AuthApiServlet.login` (emitir o token); os servlets não mudam, pois já leem `ApiAuthFilter.idAutenticado`. O desenho completo está em `analise-app-mobile.md` seção 3.4.

## Limitações conhecidas
- Não há `POST /auth/logout`: no app o logout só esquece o cookie; a sessão do servidor morre por timeout.
- Sem proteção CSRF (não se aplica a um app nativo que envia o cookie à mão; seria preciso se um navegador usasse a API).
- Se o app rodar no Chrome (Flutter web), o cookie exige CORS com credenciais; no emulador/desktop não há problema.
- Pendência fora do escopo (do registro anterior): `perfil_cliente.dart` chama `/cliente`, mas a rota existente é `/usuarios` e devolve um objeto, não lista.

## Ligação com o projeto
Fecha a pendência de `login-api-mobile.md` (token `null`) e a de `login-mobile-flutter.md` (backend). Substitui a seção 3.4 de `analise-app-mobile.md` e a linha "Autenticação" de `plano-requisicoes-mobile-api.md`. Reaproveita a chave `clienteId` de `WebSupport`, então a API e o site tratam cliente logado do mesmo jeito.
