# `index.jsp` passa a listar os serviços vindos do banco

Data: 2026-11-07

## Problema

A seção `#servicos` de `index.jsp` tinha 4 `<article class="svc-card">` com nome, descrição, preço e
duração escritos à mão no HTML. A tabela `servico` já existe no banco e `DAOServico.listar()` já retorna
`List<ServicoView>` (id, nome, descricao, preco) ordenado por `id_servico`, mas nada na página pública
usava esse dado — o conteúdo estático podia ficar divergente do que estava realmente cadastrado.

`index.jsp` é servido hoje como `welcome-file` estático, sem passar por nenhuma servlet: `web.xml` só
declara `<welcome-file>index.jsp</welcome-file>`, e não há `@WebServlet` mapeado em `/` ou `/index` em
`src/main/java/com/splash/web/servlet/`. Todo o resto do projeto nunca usa scriptlet/`jsp:useBean` para dado
dinâmico — o padrão é servlet → `request.setAttribute` → forward → `<c:forEach>` na JSP (ex.: `VeiculoServlet`
→ `painel-carros.jsp`).

## Solução

- **Novo `src/main/java/com/splash/web/servlet/IndexServlet.java`**, `@WebServlet("")`. O padrão `""`
  (string vazia) do Servlet spec mapeia *só* a requisição exata da raiz do contexto (`/SplashFast/`); não é
  o mesmo que `@WebServlet("/")`, que viraria o "default servlet" e passaria a interceptar toda requisição
  não mapeada, incluindo `Assets/*`, `cadastro.jsp` e `health.jsp` — isso seguiria quebrando o serving direto
  desses arquivos públicos.
  - `doGet`: `request.setAttribute("servicos", new DAOServico().listar())`, depois
    `request.getRequestDispatcher("/index.jsp").forward(request, response)`.
  - `SQLException` cai em `WebSupport.erroBanco(request, response, exception)`, igual a todo outro servlet
    que lista algo do banco.
- **`src/main/webapp/index.jsp`**: os 4 `<article>` fixos foram trocados por
  `<c:forEach var="servico" items="${servicos}" varStatus="st">` gerando um `<article>` por linha de
  `servico`. Campos lidos via EL: `${servico.nome}`, `${servico.descricao}`, `${servico.preco}` — nomes de
  getter do `ServicoView` não mudaram.
  - Preço formatado com `<fmt:formatNumber type="currency" currencySymbol="R$ ">` (taglib `jakarta.tags.fmt`
    adicionado no topo da página, com `<fmt:setLocale value="pt_BR" />`), já que `preco` chega como
    `BigDecimal` puro.
  - Classe de animação `delay-1`..`delay-4` agora usa `delay-${(st.index % 4) + 1}` (via `varStatus`) para
    não travar no número fixo de 4 cards que existia antes.
  - A tabela `servico` não tem coluna de duração; a linha que antes dizia "cerca de X min" foi trocada por
    um texto fixo igual em todo card ("Consulte o tempo no agendamento"), já que esse dado não é persistido
    em nenhuma tabela hoje.
  - Ícone SVG e o link `<a class="go" href="#cadastro">` continuam fixos dentro do loop — não vêm do banco.

Nada mudou em `DAOServico` nem em `ServicoView`; a listagem já existia e só passou a ser consumida pela
página pública.

## Limitação conhecida

Duração do serviço não existe no schema (`database/schema.sql`), então o card nunca vai mostrar um tempo
real enquanto essa coluna não for adicionada — ficou com texto genérico de propósito.

## Bug encontrado e corrigido: cards somem ao navegar via `index.jsp`

Data: 2026-11-07

Vários JSPs (`painel-clientes.jsp`, `painel-carros.jsp`, `painel-servicos.jsp`, `painel-agendamentos.jsp`,
`painel-atendimentos.jsp`, `painel-colaboradores.jsp`, `painel-pagamentos.jsp`, `colaborador-login.jsp`,
`baixar-app.jsp`, `cadastro.jsp`) têm links `href="${pageContext.request.contextPath}/index.jsp"` apontando
direto para o arquivo JSP, não para a raiz do contexto. Como `IndexServlet` estava mapeado só em `""`
(raiz exata), esses links contornavam o servlet: o container servia `index.jsp` estaticamente, sem passar
por `doGet`, então `request.setAttribute("servicos", ...)` nunca rodava e o
`<c:forEach var="servico" items="${servicos}">` não tinha nada para iterar — os cards de serviço somem
sem nenhum erro visível.

Os `sendRedirect` existentes (`PortalServlet`, `LogoutServlet`) já iam para `contextPath + "/"`, batendo
com o mapeamento `""` — por isso não reproduziam o problema; só a navegação direta via `index.jsp` dentro
das próprias JSPs reproduzia.

**Primeira tentativa de correção (causou regressão):** `IndexServlet` passou a mapear dois padrões —
`@WebServlet({"", "/index.jsp"})` — mantendo o forward para `/index.jsp` (arquivo físico em
`src/main/webapp/index.jsp` na época). Isso introduziu um **`StackOverflowError` por loop infinito**:
como `/index.jsp` virou um path mapeado para o próprio `IndexServlet`, o `forward("/index.jsp")` dentro
do `doGet` não caía mais no JSP compilado — ele invocava `IndexServlet.doGet` de novo, que forwardava
de novo, indefinidamente. Reproduzia tanto acessando `/` quanto `/index.jsp` diretamente, já que os
dois mapeamentos levam ao mesmo `doGet`.

### Três opções avaliadas para resolver o loop

**Opção A — Mover o JSP para `WEB-INF/views/` (a aplicada)**
Manter `@WebServlet({"", "/index.jsp"})`; mover o arquivo de
`src/main/webapp/index.jsp` para `src/main/webapp/WEB-INF/views/index.jsp` e trocar o forward de
`IndexServlet.doGet` para `/WEB-INF/views/index.jsp`. Elimina a colisão porque o path do forward deixa
de ter qualquer mapeamento de servlet — passa a seguir o mesmo padrão de todas as outras views do
projeto (`painel*.jsp` etc., só alcançáveis via forward). Nenhum dos ~10 links
`href=".../index.jsp"` espalhados pelas JSPs precisou mudar, pois `/index.jsp` continua existindo como
URL pública (agora puramente virtual, sem arquivo físico naquele caminho). Os links relativos dentro do
próprio `index.jsp` (ex.: `href="Assets/CSS/style.css"`, sem `contextPath`) não são afetados: por ser
`forward` e não `redirect`, a URL na barra do navegador não muda, então a resolução relativa também não
muda com a localização física do arquivo. **Foi a opção efetivamente aplicada.**

**Opção B — Reverter o mapeamento duplo e trocar os links**
Voltar `@WebServlet("")` (só a raiz exata), mantendo o arquivo físico em `src/main/webapp/index.jsp`
sem mover nada, e em vez disso trocar os ~10
`href="${pageContext.request.contextPath}/index.jsp"` nas JSPs (`painel-clientes.jsp`,
`painel-carros.jsp`, `painel-servicos.jsp`, `painel-agendamentos.jsp`, `painel-atendimentos.jsp`,
`painel-colaboradores.jsp`, `painel-pagamentos.jsp`, `colaborador-login.jsp`, `baixar-app.jsp`,
`cadastro.jsp`) para `href="${pageContext.request.contextPath}/"`. Resolve o bug original sem risco de
loop e sem mover arquivos, mas exige tocar em vários JSPs em vez de um único servlet — não foi a opção
escolhida.

**Opção C — Manter mapeamento duplo e arquivo no lugar, evitar o loop sem mover nada**
Manter `@WebServlet({"", "/index.jsp"})` e `index.jsp` em `src/main/webapp/`, mas trocar o mecanismo de
despacho na segunda entrada para não reentrar no mapeamento do servlet — por exemplo, uma guarda manual
via atributo de request ("já passei pelo `IndexServlet` nesta requisição") combinada com
`sendRedirect` em vez de `forward` quando a guarda já está marcada. Não há, na API padrão de Servlet,
uma forma de pedir a um `RequestDispatcher` que ignore mapeamentos de servlet e force a resolução do
JSP compilado enquanto o path estiver mapeado — então essa opção depende de um controle de fluxo ad hoc,
mais frágil e menos idiomático que A ou B (e muda semântica: um redirect troca a URL visível e perde o
atributo `servicos` do request, exigindo reconstruir o dado via sessão ou query string). Descartada por
esse motivo.

### Regressão residual após aplicar a opção A: 404 em `cadastro.jsp`

Data: 2026-11-07

Depois de mover `index.jsp` para `WEB-INF/views/` e ajustar o forward (opção A), o link "Voltar ao
início" de `cadastro.jsp` continuava dando 404. Causa: `cadastro.jsp` tinha dois links que nunca
seguiram o padrão `href="${pageContext.request.contextPath}/index.jsp"` usado por todas as outras
JSPs — `href="index.html"` (arquivo que não existe no projeto) e
`href="WEB-INF/views/index.jsp"` (caminho relativo sem `contextPath`, e `WEB-INF/*` nunca é acessível
por requisição direta no Servlet spec). Corrigido trocando ambos para
`href="${pageContext.request.contextPath}/index.jsp"`, igual ao resto do projeto.

## Mudança de plano: Opção B adotada como solução final

Data: 2026-11-07

Depois de aplicar a opção A (e corrigir o 404 residual em `cadastro.jsp`), o usuário decidiu trocar
para a **opção B** descrita acima. A opção A foi revertida:

- `src/main/webapp/WEB-INF/views/index.jsp` voltou para `src/main/webapp/index.jsp` (arquivo físico na
  raiz pública, como era originalmente).
- `IndexServlet` voltou a `@WebServlet("")` (só a raiz exata do contexto) e o forward voltou a ser
  `request.getRequestDispatcher("/index.jsp")`.
- Todos os ~10 links `href="${pageContext.request.contextPath}/index.jsp"` nas JSPs (`painel-clientes.jsp`,
  `painel-carros.jsp`, `painel-servicos.jsp`, `painel-agendamentos.jsp`, `painel-atendimentos.jsp`,
  `painel-colaboradores.jsp`, `painel-pagamentos.jsp`, `painel.jsp`, `colaborador-login.jsp`,
  `baixar-app.jsp`, `cadastro.jsp`) foram trocados para `href="${pageContext.request.contextPath}/"`,
  apontando para a raiz do contexto em vez do arquivo JSP direto — assim toda navegação "voltar ao
  início" passa por `IndexServlet`, que carrega `servicos` do banco antes do forward.

Esta é a configuração final: `IndexServlet` mapeado só em `""`, `index.jsp` de volta à raiz pública de
`src/main/webapp/`, sem risco de loop (só um mapeamento de servlet existe, e o forward vai para um path
sem mapeamento de servlet) e sem o 404 do `cadastro.jsp` (que agora usa o mesmo padrão de contextPath
raiz que todas as outras JSPs).
