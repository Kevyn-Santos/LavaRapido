# Correção das rotas `.html` que sobraram após a conversão para JSP

Data: 2026-10-21

Status: **executado**. Complementa o commit `24de23c` ("Converte páginas HTML para JSP"), que renomeou as
páginas `.html` para `.jsp` mas deixou alguns links apontando para os arquivos antigos.

---

## 1. O que foi feito e por quê

O commit `24de23c` renomeou `cadastro.html`, `painel*.html`, `acesso-colaborador.html` e `baixar-app.html` para
`.jsp`. Como os arquivos `.html` deixaram de existir, todo link que ainda os citava resultava em 404. Esta
alteração troca cada um desses links pela JSP correspondente, seguindo a mesma convenção (caminho relativo ao
arquivo) que o próprio `24de23c` já usava nas outras páginas do painel. Nenhuma servlet foi alterada.

| Arquivo:linha | Destino anterior | Destino novo |
|---|---|---|
| `src/main/webapp/cadastro.jsp:17` | `index.html` | `index.jsp` |
| `src/main/webapp/cadastro.jsp:20` | `index.html` | `index.jsp` |
| `src/main/webapp/cadastro.jsp:29` (`action` do form) | `../../baixar-app.html` | `WEB-INF/views/baixar-app.jsp` |
| `src/main/webapp/cadastro.jsp:58` | `index.html` | `index.jsp` |
| `src/main/webapp/index.jsp:116` | `cadastro.html` | `cadastro.jsp` |
| `src/main/webapp/index.jsp:162` | `WEB-INF/Views/acesso-colaborador.html` | `WEB-INF/views/acesso-colaborador.jsp` (também corrige `Views` → `views`; o Linux diferencia maiúsculas) |
| `src/main/webapp/WEB-INF/views/painel-clientes.jsp:34-41` | `painel.html`, `painel-clientes.html`, `painel-carros.html`, `painel-agendamentos.html`, `painel-atendimentos.html`, `painel-pagamentos.html`, `painel-colaboradores.html`, `painel-servicos.html` | o mesmo nome com `.jsp` |
| `src/main/webapp/WEB-INF/views/painel-atendimentos.jsp:14` | `../../index.html` | `../../index.jsp` |
| `src/main/webapp/WEB-INF/views/painel-atendimentos.jsp:15` | `../../index.html` | `../../index.jsp` |
| `src/main/webapp/WEB-INF/views/painel-atendimentos.jsp:27` | `painel.html` | `painel.jsp` |
| `src/main/webapp/Assets/Js/painel.js:437` | `painel-agendamentos.html` | `painel-agendamentos.jsp` |
| `src/main/webapp/Assets/Js/painel.js:541` | `painel-agendamentos.html` | `painel-agendamentos.jsp` |

As duas linhas de `painel.js` não estão numa JSP, mas o script gera esses links dentro das páginas do painel
(`painel-atendimentos.jsp` e `painel-pagamentos.jsp`), então entram na mesma correção.

Depois da alteração, `grep -rn '\.html' src/main/webapp` não retorna nada.

---

## 2. Relação com o resto do projeto: o que esta correção **não** resolve

Trocar `.html` por `.jsp` elimina a referência a arquivos inexistentes, mas as páginas novas continuam
inacessíveis pelo navegador, por causa da arquitetura descrita no `CLAUDE.md`:

1. **JSP dentro de `WEB-INF/` não é servida diretamente.** O Tomcat responde 404 para qualquer URL que comece com
   `/WEB-INF/`. Por isso `index.jsp → WEB-INF/views/acesso-colaborador.jsp`, `cadastro.jsp → WEB-INF/views/baixar-app.jsp`
   e todos os links entre as páginas `painel*.jsp` só vão funcionar quando houver uma servlet para cada tela,
   que faça o forward para `/WEB-INF/views/x.jsp`, e os links apontarem para a rota dessa servlet.
2. **Nenhuma servlet faz forward para** `acesso-colaborador.jsp`, `baixar-app.jsp`, `painel.jsp` ou `painel-*.jsp`.
   As telas funcionais equivalentes hoje são `/colaborador/login` (`colaborador-login.jsp`) e `/admin/*` (`admin.jsp`).
3. **O formulário de `cadastro.jsp` não fala com `CadastroClienteServlet`.** A servlet (`/cadastro`, POST) espera
   `nome`, `cpf`, `telefone`, `email` e `senha` (mínimo 8 caracteres). O formulário envia `name`, `phone`,
   `email`, `pass` (mínimo 6), não tem CPF e não mostra `${erro}`. O destino funcional do `action` seria
   `cadastro`, mas só depois de alinhar os campos (já apontado em `analise-geral-v1.md`, item 4).
4. **Links relativos inconsistentes nas páginas do painel** (fora do escopo, não são `.html`): algumas usam
   `index.jsp` e outras `../../index.jsp` para voltar ao início (`painel-clientes.jsp:14,18`,
   `painel-carros.jsp:14-15`, `painel-agendamentos.jsp:19`, `acesso-colaborador.jsp:42`, `baixar-app.jsp:17,20,34`).
   Quando as telas forem servidas por servlets, o padrão do projeto é `${pageContext.request.contextPath}/...`,
   como em `login.jsp` e `admin.jsp`.

Os forwards das servlets existentes foram conferidos e estão corretos: todos apontam para JSPs que existem em
`/WEB-INF/views/` (ou `/cadastro.jsp`, que é pública), e os redirects apontam para rotas mapeadas.
