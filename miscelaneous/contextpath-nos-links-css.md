# contextPath nos links de CSS das JSPs

## O quê

Adicionado `${pageContext.request.contextPath}` nos `href` dos `<link rel="stylesheet">`
locais (pasta `Assets/CSS/`) em todas as JSPs. Links de fonte externa
(Google Fonts) não foram alterados — `contextPath` não se aplica a URL externa.

Arquivos alterados:

- `cadastro.jsp`, `index.jsp` → `Assets/CSS/style.css`
- `WEB-INF/views/baixar-app.jsp` → `Assets/CSS/style.css`
- `WEB-INF/views/painel.jsp`, `painel-colaboradores.jsp`, `painel-clientes.jsp`,
  `painel-carros.jsp`, `painel-pagamentos.jsp`, `painel-agendamentos.jsp`,
  `painel-servicos.jsp`, `painel-atendimentos.jsp` → `Assets/CSS/painel.css`

`WEB-INF/views/acesso-colaborador.jsp` já usava `${pageContext.request.contextPath}`
e não precisou de mudança.

## Por quê

Caminhos relativos (`Assets/CSS/...` ou `../../Assets/CSS/...`) dependem da URL
atual do navegador; quebram em qualquer contexto diferente do caminho exato
usado ao testar, e especialmente sob deploy como `ROOT.war` (Docker/Render,
sem prefixo de contexto) vs. deploy local como `/SplashFast`. `${pageContext.request.contextPath}`
resolve sempre para o contexto correto independente de onde a JSP é servida.

## Como se liga ao projeto

Só os `href` de CSS foram tocados; nenhum outro link (JS, imagem, âncora) ou
lógica de servlet foi alterado. Consistente com o padrão já usado em
`acesso-colaborador.jsp` e com o deploy dual (Tomcat local em `/SplashFast` vs.
Docker/Render como `ROOT.war`) descrito no `CLAUDE.md`.
