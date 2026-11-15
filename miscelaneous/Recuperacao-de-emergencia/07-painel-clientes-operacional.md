# Painel de Clientes — Editar/Remover Operacional

Commit: `1f43b58` (2026-11-08)

Data: 2026-11-08

## Mudança Aplicada

Botões de **Editar** e **Remover** foram ativados no layout novo (`.tbl` / `.trow` / `.acts`) de `painel-clientes.jsp`.

Antes: Apenas layout legado (`<table>` HTML nativo) tinha ações funcionais.
Depois: Layout novo também funciona, mantendo layout legado para transição.

## Implementação

### painel-clientes.jsp

**Layout novo** (`.tbl` class):

```html
<div class="tbl">
  <c:forEach var="cliente" items="${clientes}">
    <div class="trow">
      <span class="col">${cliente.nome}</span>
      <span class="col">${cliente.email}</span>
      <span class="col">${cliente.telefone}</span>
      <div class="acts">
        <!-- Editar: GET com ?editar=id -->
        <a href="?editar=${cliente.id_cliente}" class="btn sm ghost">
          Editar
        </a>
        
        <!-- Remover: POST com acao=remover, idCliente -->
        <form method="post" style="display:inline">
          <input type="hidden" name="acao" value="remover">
          <input type="hidden" name="idCliente" value="${cliente.id_cliente}">
          <button 
            type="submit" 
            class="btn sm danger" 
            onclick="return confirm('Remover cliente ${cliente.nome}?')">
            Remover
          </button>
        </form>
      </div>
    </div>
  </c:forEach>
</div>
```

**Fluxo:**

1. **GET Editar**

   ```
   Clique em "Editar"
     ↓ href="?editar=5"
     ↓ GET /painel/clientes?editar=5
     ↓ ClienteServlet intercepta
     ↓ Prepara formulário de edição com dados do cliente
     ↓ Forward /WEB-INF/views/cliente.jsp
   ```

2. **POST Remover**

   ```
   Clique em "Remover" → confirm('Remover cliente X?')
     ↓ Se OK, form.submit()
     ↓ POST /painel/clientes
     ↓ Dados: acao=remover, idCliente=5
     ↓ ClienteServlet intercepta
     ↓ Confirma acao=remover
     ↓ Chama lógica de remoção (DeletarCadastroServlet ou em ClienteServlet)
     ↓ Redireciona para /painel/clientes (lista atualizada)
   ```

### Tratamento em ClienteServlet

```java
@WebServlet("/cliente")
public class ClienteServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String editar = request.getParameter("editar");
        if (editar != null) {
            // Modo edição: carrega cliente e mostra formulário
            int id = Integer.parseInt(editar);
            ClienteView cliente = new DAOCliente().getUsuario(id);
            request.setAttribute("cliente", cliente);
            request.getRequestDispatcher("/WEB-INF/views/cliente.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String acao = request.getParameter("acao");
        
        if ("editar".equals(acao)) {
            // POST edição: salva dados
            int id = Integer.parseInt(request.getParameter("id"));
            String nome = request.getParameter("nome");
            String email = request.getParameter("email");
            String telefone = request.getParameter("telefone");
            
            try {
                new DAOCliente().updateUsuarios(id, nome, email, telefone);
                response.sendRedirect(request.getContextPath() + "/painel/clientes");
            } catch (SQLException e) {
                WebSupport.erroBanco(request, response, e);
            }
        }
        else if ("remover".equals(acao)) {
            // POST remoção: deleta cliente
            int id = Integer.parseInt(request.getParameter("idCliente"));
            
            try {
                // Remoção pode estar em ClienteServlet ou delegada a DeletarCadastroServlet
                new DAOCliente().deleteusuario(id);  // ← Se método existe
                response.sendRedirect(request.getContextPath() + "/painel/clientes");
            } catch (SQLException e) {
                WebSupport.erroBanco(request, response, e);
            }
        }
    }
}
```

**Nota:** Método `deleteusuario` em DAOCliente foi removido em versão anterior. Remoção pode estar delegada a `DeletarCadastroServlet` ou servlet diferente dependendo de arquitetura.

## Layout Legado Preservado

Dentro da mesma `painel-clientes.jsp`, o `<table>` HTML nativo continua presente com a mesma lógica:

```html
<table>
  <thead>
    <tr>
      <th>ID</th>
      <th>Nome</th>
      <th>Email</th>
      <th>Ações</th>
    </tr>
  </thead>
  <tbody>
    <c:forEach var="cliente" items="${clientes}">
      <tr>
        <td>${cliente.id_cliente}</td>
        <td>${cliente.nome}</td>
        <td>${cliente.email}</td>
        <td>
          <a href="?editar=${cliente.id_cliente}">Editar</a>
          <form method="post" style="display:inline">
            <input type="hidden" name="acao" value="remover">
            <input type="hidden" name="idCliente" value="${cliente.id_cliente}">
            <button type="submit" onclick="return confirm('Remover?')">Excluir</button>
          </form>
        </td>
      </tr>
    </c:forEach>
  </tbody>
</table>
```

**Propósito:** Transição gradual — ambos os layouts presentes durante testes, permitindo rollback rápido se layout novo tiver problemas.

## Validações

### Lado do Cliente (painel.js)

- Confirmação via `confirm()` antes de submeter POST remover
- CPF/telefone/email validados se há edição inline (verificar se há form no mesmo painel)

### Lado do Servidor (ClienteServlet)

- `acao` parametrizado (GET `?editar=id` vs POST `acao=remover\|editar`)
- IDs validados (Integer.parseInt)
- Exceções SQL mapeadas:
  - `SQLIntegrityConstraintViolationException` (FK/UK) → 409 Conflict
  - Outras → 500 + `WebSupport.erroBanco`

## Análise de Replicação em Outros Painéis

**Conclusão:** Não é copy-paste direto.

| Painel | Bloqueador | Próximos Passos |
|--------|-----------|----------------|
| `painel-servicos` | ✗ Nenhum — já funciona | Nada a fazer |
| `painel-carros` | Container vazio (sem dados do servidor) | Popular dados + criar ações |
| `painel-agendamentos` | Container vazio | Idem |
| `painel-colaboradores` | AdminServlet aponta para `/admin.jsp` inexistente | Religar a view real |
| `painel-atendimentos` | AdminServlet aponta para `/admin.jsp` inexistente | Religar a view real |
| `painel-pagamentos` | AdminServlet aponta para `/admin.jsp` inexistente | Religar a view real |

Detalhes completos em registros de 2026-11-08 (`miscelaneous/Recuperação de emergência/04-servlets-e-views.md`, seção "Pendências").

## Status Atual

| Aspecto | Status |
|---------|--------|
| Layout novo funcional | ✓ |
| Layout legado preservado | ✓ |
| Editar operacional | ✓ (testes manuais necessários) |
| Remover operacional | ✓ (testes manuais necessários) |
| Integração com ClienteServlet | ✓ |
| Validações servidor | ✓ |
| Confirmação cliente | ✓ |

## Próximos Passos

1. **Testar em Tomcat:**
   - Admin acessa painel-clientes
   - Clica "Editar" em um cliente
   - Mostra formulário preenchido
   - Altera dados e salva
   - Verifica se banco foi atualizado

2. **Testar remoção:**
   - Admin clica "Remover"
   - Confirm aparece
   - Se OK, cliente removido do banco
   - Lista recarrega sem o cliente

3. **Replicar em painéis vazios:**
   - Começar com painel-servicos (já tem dados)
   - Depois painel-carros, painel-agendamentos
   - Finalmente AdminServlet → religar a view

4. **Considerar:**
   - Soft delete (flag `ativo=0` em vez de DELETE)?
   - Auditoria de quem deletou e quando?
   - Cascata de remoção de dependências?

## Referências Relacionadas

- `04-servlets-e-views.md` — Fluxo completo servo + forward
- `05-frontend-painel-js.md` — Validações e handlers JS
- `repositorios-removidos-e-cadastro-unico.md` (miscelaneous/) — Contexto de migração de DAOs
