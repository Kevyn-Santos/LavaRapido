# Frontend — `painel.js` e CSS — Recuperação

Commit: `3f1569b` (2026-11-06), reafirmado em `1f43b58` (2026-11-01)

## Mudança Principal: Libertar Fluxo de Dados

### Problema (pré-2026-11-06)

`src/main/webapp/Assets/Js/painel.js` bloqueava **completamente** o envio de formulários com JavaScript, fingindo que havia integração com API REST que não existia.

Três travamentos:

1. **`pendingMessage`** — Constante string exibida ao abrir formulário (GET) e ao submeter (POST)
   ```javascript
   const pendingMessage = "Integração com a API REST pendente. Nenhum dado foi enviado ou salvo.";
   ```

2. **`showPending(container)`** — Função que preenchía cada container de listagem com:
   ```
   "Os dados deste módulo serão carregados pela API REST."
   ```
   Chamada em `init()` antes de qualquer renderização.

3. **`setupForm()` submit handler** — Bloqueava incondicionalmente:
   ```javascript
   form.addEventListener('submit', (e) => {
     e.preventDefault();  // ← SEMPRE impedia POST
     // ... validações ...
     showFormMessage(form, pendingMessage);  // ← Mostrava msg de "pendente"
   });
   ```

**Resultado:** Nenhuma requisição POST chegava ao servidor. Formulários nunca chamavam servlets.

### Solução (2026-11-06)

Reescrito `painel.js` para:

1. **Remover `pendingMessage` e `showPending`**
   - Deletada a constante
   - Deletada a função
   - Deletada a chamada em `init()`

2. **Reescrever `setupForm()` submit handler**

   **Antes:**
   ```javascript
   form.addEventListener('submit', (e) => {
     e.preventDefault();  // SEMPRE impedia
     // validações...
     showFormMessage(form, pendingMessage);
   });
   ```

   **Depois:**
   ```javascript
   form.addEventListener('submit', (e) => {
     // Validações primeiro
     if (!isValidCPF(cpfValue)) {
       e.preventDefault();
       showFormMessage(form, "CPF inválido");
       return;
     }
     if (!isValidPhone(phoneValue)) {
       e.preventDefault();
       showFormMessage(form, "Telefone inválido");
       return;
     }
     // ... outras validações ...
     if (!form.reportValidity()) {
       e.preventDefault();
       return;
     }
     // Se chegou aqui, NÃO chama preventDefault() em lugar nenhum
     // Deixa o navegador submeter o formulário normalmente
   });
   ```

   **Efeito:** POST vai para `form.action` (servlet correta) apenas quando validação passa.

## Mudanças em Assets

### `painel.js`

| Seção | Mudança | Motivo |
|-------|---------|--------|
| top (constantes) | Removida `pendingMessage` | Não há API pendente |
| `showPending(container)` | Função deletada | Listagens virão do servidor via JSTL |
| `init()` | Removida chamada `modules.forEach(m => showPending(...))` | Containers vazios agora é apenas estado visual, não bloqueador |
| `setupForm(module)` submit handler | Reescrito: validações com `preventDefault` local, sem else fatal | Permite POST ao servidor quando validação passa |

### `style.css`

**Nenhuma mudança em 2026-11-06** — CSS do painel (`.form-group`, `.btn`, `.tbl`, `.trow`) permanece o mesmo.

Arquivo `src/main/webapp/Assets/CSS/style.css` já tinha classes prontas para o layout novo.

### `painel.css`

**Adicionado em commits anteriores**, contém estilos específicos do painel (sidebar, tabs, dark mode se aplicável).

Status: ✓ Funcional, sem mudanças em 2026-11-06

## Estrutura HTML do Painel

Exemplo de `painel-clientes.jsp`:

```html
<div id="clients-table-container" class="tbl">
  <!-- Layout novo com classes .trow, .acts -->
  <c:forEach var="cliente" items="${clientes}">
    <div class="trow">
      <span>${cliente.nome}</span>
      <span>${cliente.email}</span>
      <div class="acts">
        <a href="?editar=${cliente.id_cliente}" class="btn sm ghost">Editar</a>
        <form method="post" style="display:inline">
          <input type="hidden" name="acao" value="remover">
          <input type="hidden" name="idCliente" value="${cliente.id_cliente}">
          <button type="submit" class="btn sm danger" onclick="return confirm('Remover?')">Remover</button>
        </form>
      </div>
    </div>
  </c:forEach>
</div>

<!-- Layout legado (durante transição) -->
<table>
  <c:forEach var="cliente" items="${clientes}">
    <tr>...</tr>
  </c:forEach>
</table>
```

Form dentro `.trow`:

- `method="post"` → POST vai para servlet
- Hidden inputs: `acao` (que ação executar), `idCliente` (ID da entidade)
- Handler `painel.js` só impede envio se validações falham
- Se validação OK, form submete naturalmente

## Fluxo Atual (pós-2026-11-06)

```
Usuário clica em campo do formulário
  ↓ painel.js não interfere
  ↓ Preenchimento normal

Usuário clica "Salvar"
  ↓ Form submit event dispara
  ↓ painel.js validações:
     • CPF válido? Se não, preventDefault + msg
     • Telefone válido? Se não, preventDefault + msg
     • HTML5 reportValidity()? Se não, preventDefault
  ↓ Se tudo OK, preventDefault() nunca foi chamado
  ↓ Navegador submete POST naturalmente
  ↓ POST vai para servlet (action do form)
  ↓ Servlet processa, salva no DB
  ↓ Servlet redireciona ou recarrega
```

## Validações Implementadas em `painel.js`

**Funções auxiliares:**

- `isValidCPF(cpf)` — Valida formato e dígitos verificadores
- `isValidPhone(phone)` — Valida formato (11 dígitos, opcionalmente com parênteses)
- `isValidPlate(plate)` — Valida placa de veículo (ABC-1234 ou ABCD1234)

**Gatilhos:**

- Campo CPF: dispara validação on-blur
- Campo telefone: dispara validação on-blur
- Campo placa: dispara validação on-blur
- Form submit: validação final antes de POST

## Estado Atual (2026-11-11)

| Aspecto | Status | Notas |
|---------|--------|-------|
| Bloqueio API removido | ✓ | painel.js não bloqueia mais fluxo |
| Validações client-side | ✓ | CPF, telefone, placa funcionando |
| POST ao servidor | ✓ | Formulários chegam às servlets |
| Listagens containers | ⚠️ | Vazios — JSTL loop não implementado em alguns painéis |
| Estilo CSS | ✓ | Layout novo com classes modernas aplicável |

## Limitações Conhecidas

1. **Containers vazios** — `#cars-table-container`, `#bookings-table-container`, etc. não têm `<c:forEach>`
   - Motivo: Servlets não populam `request.setAttribute()` para essas seções
   - Impacto: Visual de "sem dados", mas não bloqueia envio

2. **Validações apenas client-side** — Servidor também valida
   - Ordem: JS primeiro (avisa usuário rápido), depois servidor (segurança)
   - Duplicação necessária (cliente pode ter JS desabilitado)

3. **Msgs de erro inline** — Usam `showFormMessage(form, msg)`
   - Mostra embaixo do form em estilo warning
   - Estilo definido em `painel.css` (classe `.form-message.error`)

## Relacionamento com Mudanças de Roteamento (2026-11-07)

Mudanças em `IndexServlet` e links JSP (contextPath) não afetam `painel.js` diretamente.

**Mas:** Links "voltar ao painel" em JSPs agora apontam para `/` (contextPath raiz) em vez de `/index.jsp`.

- Impacto em `painel.js`: Nenhum — JS não controla navegação de links, só de formulários

## Próximos Passos

1. **Popular containers:** Adicionar `<c:forEach>` em painel-carros.jsp, painel-agendamentos.jsp etc.
2. **Testar fluxo:** Cliente cria agendamento → POST chega ao servlet → salva no DB
3. **Melhorar msgs de erro:** Atualmente genéricas (ex: "CPF inválido"), poderia ser mais detalhadas
4. **Considerar API REST v2 futuro:** Se app-mobile migrar de dados em-memória, painel.js pode ser reutilizado com ajax() em vez de form submit
