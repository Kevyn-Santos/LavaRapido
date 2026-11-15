# Login da API mobile (`POST /api/v1/auth/login`)

Registrado em 2026-11-14 20:19.

## O que mudou
- `DAOCliente.autenticarPorEmail(email, senha)`: busca cliente ativo por e-mail (`LIMIT 1`) e confere a senha com `Passwords.matches` contra `senha_hash`. Devolve `Cliente` (com cpf e telefone) ou `null`.
- `AuthApiServlet.login()`: lê JSON `{email, senha}`, chama o DAO e responde `{cliente:{id,nome,cpf,telefone,email}}` (a versão inicial devolvia também `token`, removido; ver abaixo). Erros: 400 (corpo inválido/campos vazios), 401 (`E-mail ou senha inválidos`), 500 (banco).
- O corpo é `{email, senha}` (o campo `cpf` foi trocado por `email`). O DTO `LoginRequest` foi removido por não ser usado (`remocao-codigo-sem-uso-api.md`); o servlet lê o JSON direto.

## Por que
O app Flutter precisa autenticar o cliente. A senha não pode ser comparada no SQL: BCrypt usa salt aleatório, então o mobile não consegue gerar um hash igual ao do banco. O mobile envia a senha em texto puro (HTTPS em produção) e o servidor verifica o hash. `DAOCliente.autenticar` (login web, retorna `ClienteView`) ficou intacto.

## Ligação com o projeto
- Atualização 2026-11-14: o login agora abre `HttpSession` e o `token` saiu da resposta; `ApiAuthFilter` exige a sessão e os servlets deixaram de usar `?idcliente=` (ver `autenticacao-sessao-api-mobile.md`).
- Sem cadastro pelo mobile (regra de negócio): rota `/auth/cadastro` e `CadastroRequest` removidos. Cadastro só pela web (`/cadastro`).
- Seed tem hashes falsos: para testar, cadastrar cliente por `/cadastro`.
