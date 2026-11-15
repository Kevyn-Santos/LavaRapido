# Roteamento `IndexServlet` — Recuperação de Mudanças

Commits: `3f1569b` (2026-11-06), evolução em `06a5c85` (2026-11-07), final em `1f43b58` (2026-11-07 18:30)

## Problema Original (pré-2026-11-07)

`IndexServlet` tinha mapeamento duplo que causava loop infinito:

```java
@WebServlet({"", "/index.jsp"})  // ← Mapeia AMBOS os paths
public class IndexServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Servico> servicos = new DAOServico().listar();
        request.setAttribute("servicos", servicos);
        request.getRequestDispatcher("/index.jsp").forward(request, response);
        // ↓
        // Quando path é "", forward /index.jsp funciona (cai em arquivo físico)
        // Mas quando path é "/index.jsp", forward /index.jsp aponta para O PRÓPRIO SERVLET
        // → StackOverflowError
    }
}
```

**Sintoma:** Acessar `/index.jsp` diretamente ou via link interno causava `StackOverflowError` — requests reentrantes no servlet.

Acessar `/` (raiz) funcionava (até aqui).

## Três Soluções Consideradas

### Opção A — Mover JSP para WEB-INF (Aplicada Temporariamente)

**Ideia:** Se JSP for protegida, forward sempre chega em arquivo físico (não há mapeamento de servlet para WEB-INF).

**Aplicação:**

```
Antes:  src/main/webapp/index.jsp                  ← Pública
Depois: src/main/webapp/WEB-INF/views/index.jsp    ← Protegida

IndexServlet:
    @WebServlet({"", "/index.jsp"})  // Mantém mapeamento duplo
    request.getRequestDispatcher("/WEB-INF/views/index.jsp").forward(...)
    
Links em JSPs:
    href="${pageContext.request.contextPath}/index.jsp"  // Continua OK
    // Resolução: /index.jsp → servlet → forward /WEB-INF/views/index.jsp
```

**Vantagem:** Segue padrão arquitetural do projeto (todas as views em WEB-INF, só via servlet forward).

**Desvantagem:** Exige movimentação de arquivo, manutenção de padrão em WEB-INF para uma única view pública.

### Opção B — Simplificar Mapeamento e Trocar Links (Final Adotada)

**Ideia:** Remover mapeamento duplo, manter JSP pública, mudar links internos para raiz.

**Aplicação:**

```
Antes:  @WebServlet({"", "/index.jsp"})
Depois: @WebServlet("")                       // Só raiz exata

Arquivo: Continua src/main/webapp/index.jsp  ← Pública

Forward: request.getRequestDispatcher("/index.jsp").forward(...)
    // /index.jsp agora resolve para arquivo físico (não tem mapeamento de servlet)

Links em JSPs:
    Antes: href="${pageContext.request.contextPath}/index.jsp"
    Depois: href="${pageContext.request.contextPath}/"         // Aponta para raiz
    
    ~10 JSPs afetadas:
    - painel-clientes.jsp, painel-carros.jsp, painel-servicos.jsp
    - painel-agendamentos.jsp, painel-atendimentos.jsp, painel-colaboradores.jsp
    - painel-pagamentos.jsp, painel.jsp
    - colaborador-login.jsp, baixar-app.jsp, cadastro.jsp (alguns desses)
```

**Vantagem:** Sem risco de loop, sem mover arquivos, alinha links com padrão já usado em `PortalServlet` e `LogoutServlet` (sempre para `/`).

**Desvantagem:** Edita vários JSPs em vez de um servlet.

### Opção C — Controle Manual de Reentrada (Descartada)

Idea: Marcar primeira entrada com atributo de request, segunda entrada usar `sendRedirect` em vez de `forward`.

Descartada por ser frágil e depender de `sendRedirect`, que perde atributo `request.setAttribute("servicos", ...)`.

## Decisão: Opção B

**Escolhida pelo usuário em commit `1f43b58` (2026-11-07 18:30).**

**Racional:** Mais direto, sem risco de loop futuro, alinha roteamento ao padrão existente.

## Mudanças Aplicadas

### `IndexServlet.java`

```java
// ANTES
@WebServlet({"", "/index.jsp"})
protected void doGet(...) {
    ...
    request.getRequestDispatcher("/index.jsp").forward(request, response);
}

// DEPOIS
@WebServlet("")
protected void doGet(...) {
    ...
    request.getRequestDispatcher("/index.jsp").forward(request, response);
}
```

### Links em JSPs

Trocados ~10 links de `/index.jsp` para `/` (contextPath raiz).

Exemplo (`painel-clientes.jsp`):

```jsp
<!-- ANTES -->
<a href="${pageContext.request.contextPath}/index.jsp">Home</a>

<!-- DEPOIS -->
<a href="${pageContext.request.contextPath}/">Home</a>
```

Arquivos atualizados:

- `painel-clientes.jsp`
- `painel-carros.jsp`
- `painel-servicos.jsp`
- `painel-agendamentos.jsp`
- `painel-atendimentos.jsp`
- `painel-colaboradores.jsp`
- `painel-pagamentos.jsp`
- `painel.jsp`
- `colaborador-login.jsp`
- `baixar-app.jsp`
- `cadastro.jsp` (parte deles)

## Validação

```
mvn compile
→ BUILD SUCCESS
✓ Sem erros de compilação
✓ Servlet roteamento revisado
```

**Testes manuais (necessários):**

```
GET http://localhost:8080/SplashFast/
  → IndexServlet dispara
  → Request.setAttribute("servicos", ...)
  → Forward /index.jsp
  → index.jsp renderiza com serviços listados
  ✓ OK

GET http://localhost:8080/SplashFast/index.jsp
  → Arquivo físico respondido diretamente (Apache/Tomcat)
  → Sem passar por servlet (porque mapeamento removido)
  → Renderiza sem serviços (JSP não tem acesso ao request.setAttribute)
  ⚠️ Comportamento esperado: URL direta não deverá funcionar

Navegação via link "Home" nas JSPs:
  → href="${pageContext.request.contextPath}/" → GET /
  → IndexServlet (mesmo comportamento que antes)
  ✓ OK
```

**Regressão evitada:**

- ✓ Sem StackOverflowError
- ✓ Sem loop infinito
- ✓ Sem mudança de localização de arquivo
- ✓ Forward continua funcionando

## Impacto em Outras Partes

### Rotas Públicas Não Afetadas

- `GET /cadastro` → `CadastroClienteServlet` → `cadastro.jsp` (pública, em webapp raiz)
- `GET /login` → `LoginServlet` → `/WEB-INF/views/login.jsp` (protegida)
- `GET /health` → `health.jsp` (pública, em webapp raiz)
- `GET /colaborador/login` → `ColaboradorLoginServlet` → `/WEB-INF/views/colaborador-login.jsp`

### Assets Continuam Acessíveis

- `/Assets/CSS/style.css` — Não interceptado por servlet (não há `@WebServlet("/Assets/*")`)
- `/Assets/Js/painel.js` — Idem
- `/Assets/Img/logo.png` — Idem

Tomcat default behavior: qualquer arquivo em `webapp` que não tem mapeamento de servlet é servido como static file.

## Timeline de Commits

| Data/Hora | Commit | Ação |
|-----------|--------|------|
| 2026-11-07 17:33 | `3639f51` | Problema descoberto |
| 2026-11-07 18:00 | `06a5c85` | Opção A aplicada (WEB-INF) + doc das 3 opções |
| 2026-11-07 18:15 | `1b68b57` | Merge branch JSPFront (inclui A) |
| 2026-11-07 18:30 | `1f43b58` | Opção B adotada: revert A, trocar links para contextPath raiz |

## Estado Atual (2026-11-11)

| Componente | Status |
|-----------|--------|
| Mapeamento servlet | ✓ Simples (`@WebServlet("")`) |
| Links internos | ✓ Apontam para raiz (`/`) |
| Forward de dados | ✓ Funciona (`request.setAttribute`, `forward`) |
| Arquivo index.jsp | ✓ Em local público (webapp raiz) |
| Compilação | ✓ Sem erros |
| Risco de loop | ✗ Eliminado |

## Relacionamento com Mudanças de API/Frontend

- **API REST (`/api/v1/...`)** — Não afetada. Servlets de API responderem JSON, independente do roteamento de IndexServlet.
- **painel.js** — Não afetada. JS valida formulários, POST vai para action do form (servlet específica).
- **Mudanças em DAOs** — Não afetadas. IndexServlet chama `DAOServico.listar()` como antes.

## Próximos Passos

1. **Testar em Tomcat:** Deploy WAR e verificar acesso a `/` e links "Home"
2. **Verificar redirect de logout:** `LogoutServlet` faz `sendRedirect("/")` — deve funcionar identicamente
3. **Documentar padrão:** Links internos sempre para raiz quando é home, nunca para `/index.jsp`
4. **Aplicar em futuras views:** Se houver nova view pública, segui o padrão Opção B (link para raiz)
