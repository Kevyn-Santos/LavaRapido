# Correção do redirect de `CadastroClienteServlet` (2026-11-13)

## O que mudou
`CadastroClienteServlet` (`/cadastro`): removida a decisão baseada em `getServletPath() + getPathInfo()`.
- `doGet` sempre encaminha para `/cadastro.jsp`.
- `doPost` sempre redireciona para `/baixar-app` após gravar (Post/Redirect/Get).

## Por quê
A servlet é mapeada em `/cadastro` (mapeamento exato), então `path` valia sempre `"/cadastro"`. O ramo
`"/cadastro.jsp"` (→ `/baixar-app`) era inalcançável e o ramo `"/cadastro"` mandava para `/painel/clientes`,
rota protegida que devolvia o cliente ao login. O `doGet` também nunca exibia o formulário.

## Ligação com o projeto
O único formulário que posta em `/cadastro` é o público (`cadastro.jsp`); o painel usa `ClienteServlet`.
Por isso não há mais bifurcação. `BaixarAppServlet` já documentava esse redirect.
