# Integração Servlets + Views JSP — Recuperação

Commits: `3481984` (2026-10-18), `1f43b58` (2026-11-01)

## Estrutura de Roteamento

### Servlets em `src/main/java/com/splash/web/servlet/`

Todos mapeados via `@WebServlet(...)` — nenhum em `web.xml`.

| Servlet | Mapeamento | GET (forward/redirect) | POST (forward/redirect) | Autenticação |
|---------|-----------|--------|--------|-------|
| `IndexServlet` | `""` (raiz) | `/WEB-INF/views/index.jsp` | — | Pública |
| `CadastroClienteServlet` | `/cadastro` | `cadastro.jsp` (public) | 400/409/500 ou redir `/login?cadastro=sucesso` | Pública |
| `ClienteServlet` | `/cliente` | `/WEB-INF/views/cliente.jsp` | `acao=editar\|remover\|...` | Cliente |
| `ServicoServlet` | `/servicos` | `/WEB-INF/views/painel-servicos.jsp` | `acao=editar\|remover\|salvar` | Admin |
| `VeiculoServlet` | `/veiculos` | Redir `/cliente` | `acao=adicionar\|remover` | Cliente |
| `AgendamentoServlet` | `/agendamentos` | Redir `/cliente` | `acao=agendar\|cancelar` | Cliente |
| `PainelServlet` | `/painel`, `/painel/*` | `/WEB-INF/views/painel.jsp` (+ sub-painéis) | — | Admin/Colaborador |
| `AdminServlet` | `/admin/*` | ❌ `/admin.jsp` (não existe) | `secao=colaboradores\|...` | Admin |
| `LoginServlet` | `/login` | `/WEB-INF/views/login.jsp` | POST autentica | Pública |
| `ColaboradorLoginServlet` | `/colaborador/login` | `/WEB-INF/views/colaborador-login.jsp` | POST autentica | Pública |
| `DeletarCadastroServlet` | `/deletarCadastro` | `/WEB-INF/views/deletarCadastro.jsp` | POST deleta cliente | Cliente |
| `PortalServlet` | `/portal` | `/WEB-INF/views/portal.jsp` | — | Cliente autenticado |
| `LogoutServlet` | `/logout` | — | — | — → redirect `/` |

### Fluxos Principais

**1. Cliente anônimo → Cadastro → Login**

```
GET  /
  ↓ IndexServlet
  → forward /WEB-INF/views/index.jsp
     [Link: "Criar conta" → /cadastro]

GET  /cadastro
  ↓ CadastroClienteServlet
  → forward cadastro.jsp (arquivo público, não em WEB-INF)
     [Formulário: nome, cpf, telefone, email, senha]

POST /cadastro
  ↓ CadastroClienteServlet
  ├─ Validação falha → 400, mostra formulário com erro
  ├─ Email/CPF duplicado → 409
  └─ Sucesso → redirect /login?cadastro=sucesso
     [Servlet `LoginServlet` mostra mensagem de sucesso]

POST /login
  ↓ LoginServlet
  ├─ Autentica DAOCliente.autenticar(email, senha) → ClienteView
  ├─ Coloca clienteId em session
  └─ redirect /portal (PortalServlet)
```

**2. Admin → Painel → Editar/Remover**

```
GET  /painel
  ↓ PainelServlet
  → forward /WEB-INF/views/painel.jsp
     [Sidebar: Clientes, Serviços, Carros, Agendamentos, ...]

GET  /painel/clientes (ou ?secao=clientes)
  ↓ PainelServlet
  → forward /WEB-INF/views/painel-clientes.jsp
     [JSTL loop: c:forEach items="${clientes}"]
     [Botões: Editar (GET ?editar=id), Remover (POST acao=remover)]

GET  /cliente?editar=5
  ↓ ClienteServlet
  → forward /WEB-INF/views/cliente.jsp
     [Formulário pré-preenchido]

POST /cliente (acao=editar)
  ↓ ClienteServlet
  ├─ DAOCliente.updateUsuarios(id, nome, email, telefone)
  └─ redirect /painel/clientes (ou forward com sucesso)

POST /cliente (acao=remover)
  ↓ ClienteServlet
  ├─ DeletarCadastroServlet [ou lógica em ClienteServlet]
  └─ redirect /painel/clientes
```

**3. Colaborador → Painel → Atendimentos**

```
GET  /colaborador/login
  ↓ ColaboradorLoginServlet
  → forward /WEB-INF/views/colaborador-login.jsp

POST /colaborador/login
  ↓ ColaboradorLoginServlet
  ├─ DAOColaborador.autenticar(email, senha) → ColaboradorView
  ├─ Coloca colaboradorId + nivelAcesso em session
  └─ redirect /painel (PainelServlet)
     [Painel admin se nivelAcesso >= ADMINISTRADOR, senão painel colaborador]

GET  /painel/atendimentos
  ↓ PainelServlet
  → forward /WEB-INF/views/painel-atendimentos.jsp
     [Dropdown: Status (AGUARDANDO → EM_LAVAGEM → FINALIZADO → ENTREGUE)]

POST /admin?secao=atendimentos&acao=atualizar&id=10&status=EM_LAVAGEM
  ↓ AdminServlet
  ├─ DAOAtendimento.atualizar(id, status, idsColaboradores)
  └─ Redir ou forward com sucesso
```

## Views JSP

### Localização e Acesso

```
src/main/webapp/
├── index.jsp                    ← Pública (raiz do webapp)
├── cadastro.jsp                 ← Pública (GET /cadastro)
├── health.jsp                   ← Pública (healthcheck)
├── Assets/                      ← Público
│   ├── CSS/
│   │   ├── style.css           ← Geral (index, cadastro, login)
│   │   ├── painel.css          ← Painel admin
│   │   └── ...
│   ├── Js/
│   │   ├── painel.js           ← Comportamento painel (2026-11-06 fix)
│   │   ├── reveal.js           ← Scroll reveal
│   │   └── ...
│   └── Img/
└── WEB-INF/
    └── views/                  ← Protegidas (só via forward)
        ├── erro.jsp            ← Erro genérico do `WebSupport.erroBanco`
        ├── login.jsp           ← Form login cliente (não versioned, criada durante setup)
        ├── painel.jsp          ← Painel admin (container)
        ├── painel-clientes.jsp ← Lista clientes (2026-11-08 fix: editar/remover ativos)
        ├── painel-servicos.jsp ← Lista serviços
        ├── painel-carros.jsp   ← Lista veículos (vazio — sem dados do servidor)
        ├── painel-agendamentos.jsp ← Lista agendamentos (vazio)
        ├── painel-atendimentos.jsp ← Lista atendimentos (vazio)
        ├── painel-colaboradores.jsp ← Lista colaboradores (vazio)
        ├── painel-pagamentos.jsp ← Lista pagamentos (vazio)
        ├── portal.jsp          ← Portal cliente
        ├── cliente.jsp         ← Edição de cliente
        ├── cadastro.jsp (antigo, não usado)
        ├── colaborador-login.jsp
        ├── deletarCadastro.jsp
        └── baixar-app.jsp
```

### Painel Dois Layouts (2026-11-08 state)

**painel-clientes.jsp** contém DOIS layouts lado a lado:

1. **Layout legado** — `<table>` HTML nativo com Editar/Remover funcionais (GET/POST)
2. **Layout novo** — `.tbl` / `.trow` / `.acts` (classes CSS modernas)

Editar/Remover copiados para layout novo em 2026-11-08, mantendo compatibilidade com ambos durante transição.

**Outros painéis** — Layout novo apenas, containers vazios (`#cars-table-container`, `#bookings-table-container` etc.) sem JSTL loop.

### JSTL + EL em Views

Exemplo (`painel-clientes.jsp`):

```jsp
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:forEach var="cliente" items="${clientes}">
  <tr>
    <td>${cliente.id_cliente}</td>
    <td>${cliente.nome}</td>
    <td>
      <a href="?editar=${cliente.id_cliente}">Editar</a>
      <form method="post" style="display:inline">
        <input type="hidden" name="acao" value="remover">
        <input type="hidden" name="idCliente" value="${cliente.id_cliente}">
        <button type="submit" onclick="return confirm('Remover?')">Remover</button>
      </form>
    </td>
  </tr>
</c:forEach>
```

Bibliotecas taglib:

- `jakarta.tags.core` — `<c:forEach>`, `<c:if>`, `<c:out>`
- `jakarta.tags.fmt` — `<fmt:formatDate>`, `<fmt:formatNumber>`

Escopo da servlet → request:

```java
// Em ClienteServlet
List<ClienteView> clientes = dao.listar();
request.setAttribute("clientes", clientes);
request.getRequestDispatcher("/WEB-INF/views/painel-clientes.jsp").forward(request, response);
```

## Tratamento de Erros

### Fluxo de Erro

Qualquer servlet → exceção:

```java
// Em ClienteServlet
try {
    dao.deleteusuario(id);
} catch (SQLException e) {
    WebSupport.erroBanco(request, response, e);
    // → forward /WEB-INF/views/erro.jsp + detalhes do erro
    // → HTTP 500
}
```

**Exceções conhecidas** mapeadas em servlet:

| Exceção | Status HTTP | Resposta |
|---------|------------|----------|
| `SQLIntegrityConstraintViolationException` (FK/UK violada) | 409 Conflict | Msg: "CPF ou e-mail já cadastrado" |
| `IllegalArgumentException` (validação) | 400 Bad Request | Mostra formulário com erro |
| Outra `SQLException` | 500 Internal Server Error | `WebSupport.erroBanco(...)` |

### Validações

1. **Cliente**: Nome (não vazio, < 100), CPF (válido, unique), email (válido, unique), telefone (formato)
   - Feita em `model.Validacao` + construtor/setters de `Cliente`

2. **Veículo**: Placa (formato, unique), modelo, ano (inteiro válido)
   - Feita em servlet antes de chamar DAO

3. **Agendamento**: Data/horário (futuros), veículo do cliente, serviços existem
   - Feita em `DAOAgendamento.criar` antes de INSERT

## Filtros

### EncodingFilter

```java
@WebFilter("/*")
public class EncodingFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        chain.doFilter(request, response);
    }
}
```

Força UTF-8 em toda requisição/resposta — necessário porque projeto tem acentuação em português.

## Mudanças 2026-11-01 a 2026-11-08

| Data | Mudança | Arquivo | Status |
|------|---------|---------|--------|
| 2026-11-07 | Fix: IndexServlet loop infinito → mover index.jsp para WEB-INF/views | IndexServlet, index.jsp | ✓ |
| 2026-11-07 | Opção B adotada: revert A, usar contextPath para root | Todos JSPs (~10) | ✓ |
| 2026-11-08 | Editar/Remover funcional em painel-clientes.jsp (layout novo) | painel-clientes.jsp | ✓ |

## Pendências

1. **painel-carros.jsp, painel-agendamentos.jsp** — Containers vazios, sem dados do servidor
   - Pré-requisito: `VeiculoServlet` rota admin-facing, `AgendamentoServlet` ajustado para admin
   - Ou: Adicionar lógica em `PainelServlet` para popular dados

2. **painel-colaboradores.jsp, painel-atendimentos.jsp, painel-pagamentos.jsp** — Containers vazios
   - AdminServlet forward apontava para `/admin.jsp` que não existe
   - Precisa religar `AdminServlet` a views reais (ou dentro de painel.jsp como sub-painéis)

3. **login.jsp** — Arquivo não versioned (.gitignore), precisa ser recriado durante setup
   - Deve ter form email/senha + link para /cadastro

4. **Testes de integração** — Nenhum teste para fluxos servlet+DAO+DB
   - Considerar testes com `MockHttpServletRequest` ou Selenium

## Próximos Passos

1. Popular dados no painel-clientes (e replicar em painel-servicos — já funciona)
2. Desbloquear painel-carros/agendamentos (criar rota admin-facing em VeiculoServlet)
3. Religar AdminServlet a view real (admin.jsp ou sub-painel dentro painel.jsp)
4. Testar fluxo cliente login → criar agendamento → ver painel
5. Testar fluxo admin login → editar atendimento → salvar
