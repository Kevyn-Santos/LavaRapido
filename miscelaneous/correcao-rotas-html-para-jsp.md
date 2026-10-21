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

---

## 3. Segunda etapa: campo CPF no cadastro e links para o início

Atende parcialmente os itens 3 e 4 da seção 2. Nenhum outro ponto foi alterado.

### 3.1 Campo CPF em `cadastro.jsp`

Adicionado entre "Nome completo" e "Telemóvel", copiado da versão anterior do mesmo formulário (commit
`23d4d4b`, antes da conversão `24de23c`), sem o `value="<c:out value='${param.cpf}'/>"`, porque o `cadastro.jsp`
atual não declara a taglib JSTL:

```html
<div class="field">
  <label for="rc">CPF</label>
  <input id="rc" name="cpf" inputmode="numeric" maxlength="14" required placeholder="000.000.000-00">
</div>
```

O nome `cpf` é o que `CadastroClienteServlet` lê (`WebSupport.campo(request, "cpf")`), e o `maxlength` de 14 aceita o
CPF com máscara, que `Validacao` normaliza. Ficam pendentes, como antes: os outros campos (`name`, `phone`,
`pass`) ainda não têm os nomes que a servlet espera, o `action` ainda não aponta para `/cadastro`, e o texto
"São apenas quatro campos" agora está desatualizado (são cinco).

### 3.2 Links para `index.jsp` nas páginas de `WEB-INF/views/`

Os links relativos (`index.jsp` e `../../index.jsp`) não funcionam numa página servida por forward: o navegador
resolve o caminho a partir da URL da servlet, não da pasta do arquivo. Com o contexto `/SplashFast`, por exemplo,
`../../index.jsp` sai do contexto e `index.jsp` depende da profundidade da rota. Todos passam a usar o caminho
absoluto com o contexto, padrão já usado em `login.jsp`, `colaborador-login.jsp` e `erro.jsp`:

```html
href="${pageContext.request.contextPath}/index.jsp"
```

| Arquivo:linha | Antes |
|---|---|
| `acesso-colaborador.jsp:17,20` | `../../index.jsp` |
| `acesso-colaborador.jsp:42` | `index.jsp` |
| `baixar-app.jsp:17,20,34` | `index.jsp` |
| `painel.jsp:14,18` | `../../index.jsp` |
| `painel-agendamentos.jsp:19` | `index.jsp` |
| `painel-agendamentos.jsp:23` | `../../index.jsp` |
| `painel-atendimentos.jsp:14,15` | `../../index.jsp` |
| `painel-carros.jsp:14,15` | `index.jsp` |
| `painel-clientes.jsp:14,18` | `index.jsp` |
| `painel-colaboradores.jsp:15,16` | `../../index.jsp` |
| `painel-pagamentos.jsp:14,15` | `../../index.jsp` |
| `painel-servicos.jsp:15,16` | `../../index.jsp` |

Os links de `cadastro.jsp` (na raiz do webapp) ficaram relativos (`index.jsp`), porque já funcionam tanto em
`/cadastro` quanto em `/cadastro.jsp`. Os links "Sair" do painel continuam indo para o início, e não para `/sair`.

---

## 4. Terceira etapa: formulário de cadastro ligado a `CadastroClienteServlet`

Resolve o item 3 da seção 2 e as pendências de nomes de campo e `action` da seção 3.1.

| Arquivo | Mudança | Por quê |
|---|---|---|
| `servlet/CadastroClienteServlet.java` | Lê `name`, `cpf`, `phone`, `email` e `pass` em vez de `nome`, `cpf`, `telefone`, `email` e `senha`. | São os nomes do formulário de `cadastro.jsp`; a servlet passa a corresponder à JSP. |
| `servlet/CadastroClienteServlet.java` | Em sucesso faz forward para `/WEB-INF/views/baixar-app.jsp` (constante `SUCESSO`) em vez de redirect para `/login?cadastro=sucesso`. | A tela de sucesso do fluxo novo é a de baixar o app. Tem de ser forward porque o navegador não acessa `WEB-INF`; um `sendRedirect` para a JSP daria 404. |
| `cadastro.jsp` | `action` do form: `WEB-INF/views/baixar-app.jsp` → `${pageContext.request.contextPath}/cadastro`. | O POST agora chega à servlet, que valida, grava e decide a tela seguinte. |
| `openapi.yml` | `POST /cadastro` passa a responder 200 (forward para `baixar-app.jsp`), não 302, e `CadastroClienteForm` usa os novos nomes de campo. | Manter a documentação das rotas igual ao código. |

A validação, o hash e os erros 400/409 continuam como antes. Em caso de erro, a servlet faz forward para
`/cadastro.jsp` com o atributo `erro`.

### Pontos em aberto (não alterados)

- **Senha mínima:** a servlet exige 8 caracteres (`SENHA_MINIMA`), mas `cadastro.jsp` diz "mínimo 6" e usa
  `minlength="6"`. Uma senha de 6 ou 7 caracteres passa no navegador e volta com 400.
- **Mensagem de erro:** `cadastro.jsp` não mostra `${erro}` nem devolve os campos digitados. Em um erro 400 ou
  409 o formulário reaparece vazio e sem aviso.
- **Recarregar a página:** como o sucesso é um forward depois do POST, recarregar `baixar-app.jsp` reenvia o
  formulário, e o resultado é 409 (CPF ou e-mail já cadastrado). Para evitar isso (padrão
  Post/Redirect/Get), seria preciso uma rota GET que faça o forward para `baixar-app.jsp`.
- **CSS:** `baixar-app.jsp` carrega `../../Assets/CSS/style.css`. Servida a partir de `/SplashFast/cadastro`, esse
  caminho resolve para `/Assets/...`, fora do contexto: com deploy local (`/SplashFast`) a página fica sem estilo.
  No Docker (`ROOT.war`) funciona.
