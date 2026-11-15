# Checklist: O Que Falta para MVP V1 Executável Localmente

Data: 2026-11-11

## Resumo

Projeto compila, testa, empacota. WAR gerado. **Falta:** DB + credenciais + servidor Tomcat + testes integrados + algumas funcionalidades de UI (painéis vazios).

## Bloqueadores para Primeira Execução Local

### ✗ Crítico: Banco de Dados

**Pré-requisito:** MySQL ≥ 8.0.16 rodando

**Ação necessária:**

1. Criar database em MySQL local:
   ```bash
   mysql -u root -p < database/schema.sql
   mysql -u root -p < database/seed.sql
   ```

2. Criar arquivo `.env` na raiz do projeto:
   ```
   ENV_DEV=LOCAL
   LOCAL_DB_URL=jdbc:mysql://localhost:3306/splashfast
   LOCAL_USER=seu_usuario_mysql
   LOCAL_PASS=sua_senha_mysql
   INITIAL_ADMIN_TOKEN=um_token_aleatorio_longo
   ```

3. Colocar `.env` em local acessível:
   - Opção A: Raiz do projeto (quando rodado via IDE)
   - Opção B: `/var/lib/tomcat10/` (quando Tomcat é sistema)
   - Verificar: `src/main/resources/.env` para testes, `.env` para runtime

**Impact se não feito:** Toda servlet que toca DB vai dar `SQLException` (sem connection).

### ✗ Crítico: Tomcat 10.1+

**Pré-requisito:** Tomcat 10.1 instalado

**Ação necessária:**

1. Instalar Tomcat 10.1:
   ```bash
   # Debian/Ubuntu
   sudo apt install tomcat10 tomcat10-admin
   
   # Ou baixar manual de archive.apache.org/dist/tomcat/tomcat-10/
   ```

2. Verificar instalação:
   ```bash
   $CATALINA_BASE/bin/catalina.sh version
   # Deve mostrar v10.1.x
   ```

3. Deploy WAR:
   ```bash
   cp target/SplashFast.war $CATALINA_BASE/webapps/
   # Ou rename para ROOT.war para servir em /
   ```

4. Iniciar Tomcat:
   ```bash
   sudo systemctl start tomcat10
   # ou
   $CATALINA_BASE/bin/startup.sh
   ```

5. Verificar:
   ```bash
   curl http://localhost:8080/SplashFast
   # Esperado: HTML da index.jsp com lista de serviços
   ```

**Impact se não feito:** WAR não executa, nenhuma servlet responde.

### ✗ Crítico: Arquivo `login.jsp`

**Pré-requisito:** Recriação de view protegida

**Situação:** Arquivo está em `.gitignore`, não versionado.

**Ação necessária:**

1. Copiar template de `cadastro.jsp` ou criar novo:
   ```jsp
   <%@ page contentType="text/html; charset=UTF-8" %>
   <%@ taglib prefix="c" uri="jakarta.tags.core" %>
   
   <!DOCTYPE html>
   <html lang="pt-BR">
   <head>
       <meta charset="UTF-8">
       <title>Login — SplashFast</title>
       <link rel="stylesheet" href="${pageContext.request.contextPath}/Assets/CSS/style.css">
   </head>
   <body>
       <div class="form-container">
           <h1>Login</h1>
           
           <% if ("sucesso".equals(request.getParameter("cadastro"))) { %>
               <p class="success">Cadastro realizado! Faça login com suas credenciais.</p>
           <% } %>
           
           <c:if test="${not empty param.erro}">
               <p class="error">${param.erro}</p>
           </c:if>
           
           <form method="post" action="${pageContext.request.contextPath}/login">
               <div class="form-group">
                   <label for="email">Email:</label>
                   <input type="email" id="email" name="email" required>
               </div>
               <div class="form-group">
                   <label for="senha">Senha:</label>
                   <input type="password" id="senha" name="senha" required>
               </div>
               <button type="submit" class="btn">Entrar</button>
           </form>
           
           <p>
               Não tem conta? <a href="${pageContext.request.contextPath}/cadastro">Cadastre-se aqui</a>
           </p>
           <p>
               <a href="${pageContext.request.contextPath}/">Voltar</a>
           </p>
       </div>
   </body>
   </html>
   ```

2. Salvar em: `src/main/webapp/WEB-INF/views/login.jsp`

3. Rebuild WAR:
   ```bash
   mvn clean package -DskipTests
   ```

**Impact se não feito:** Redirecionamento `/login` falha com 404, cliente não consegue autenticar após cadastro.

---

## Bloqueadores Funcionais (Sem Executar Código)

### ⚠️ Alto: Painéis vazios

**Painéis afetados:**

- `painel-carros.jsp` — Container `#cars-table-container` vazio
- `painel-agendamentos.jsp` — Container `#bookings-table-container` vazio
- `painel-colaboradores.jsp` — Container `#collab-table-container` vazio
- `painel-atendimentos.jsp` — Container `#queues-container` vazio
- `painel-pagamentos.jsp` — Container `#payments-container` vazio

**Causa:** `PainelServlet` não popula `request.setAttribute()` para esses dados, ou servlets não existem.

**Ação necessária:**

1. `PainelServlet` — Adicionar lógica de carregamento:
   ```java
   // Para carros
   if ("carros".equals(secao)) {
       List<VeiculoView> carros = new DAOVeiculo().listar(clienteId);
       request.setAttribute("carros", carros);
   }
   // Idem para agendamentos, atendimentos, etc.
   ```

2. JSP — Adicionar JSTL loop:
   ```jsp
   <div id="cars-table-container" class="tbl">
     <c:forEach var="carro" items="${carros}">
       <div class="trow">
         <span>${carro.placa}</span>
         ...
       </div>
     </c:forEach>
   </div>
   ```

3. Criar rotas admin-facing:
   - `VeiculoServlet` atualmente requer `clienteId` em sessão
   - Admin precisa de rota separada ou `WebSupport` ajustado
   - Ou: Criar `AdminVeiculoServlet`, `AdminAgendamentoServlet` etc.

**Impact se não feito:** Painéis admin mostram containers vazios (não é erro, mas visualmente vago). Funcionalidade admin não operacional.

### ⚠️ Alto: `AdminServlet` → view morta

**Situação:** `AdminServlet` faz forward para `/admin.jsp` que não existe em `WEB-INF/views/`.

**Ação necessária:**

Opção A (rápida): Adicionar `/admin.jsp` em `WEB-INF/views/admin.jsp` com conteúdo básico ou redirect:
```java
// Ou em AdminServlet, em vez de forward para admin.jsp:
response.sendRedirect(request.getContextPath() + "/painel");
```

Opção B (correta): Estruturar AdminServlet como sub-painéis dentro `painel.jsp`:
```jsp
<div id="admin-section">
  <c:choose>
    <c:when test="${secao eq 'colaboradores'}">
      <!-- Formulário + listagem colaboradores -->
    </c:when>
    <c:when test="${secao eq 'atendimentos'}">
      <!-- Formulário + listagem atendimentos -->
    </c:when>
  </c:choose>
</div>
```

**Impact se não feito:** Rotas `/admin?secao=...` retornam 404.

### ⚠️ Médio: Métodos DAO incompletos

**Métodos faltando:**

| DAO | Método | Impacto |
|-----|--------|--------|
| `DAOVeiculo` | `atualizar(id, ...)` | Admin não consegue editar veículos |
| `DAOColaborador` | `atualizar(id, ...)`, `remover(id)` | Admin não consegue editar/remover colaboradores |
| `DAOPagamento` | `remover(id)` (se necessário) | Remoção de pagamentos não possível |

**Ação necessária:**

Implementar os métodos:

```java
// DAOVeiculo
public void atualizar(int idVeiculo, String placa, String modelo, int ano) throws SQLException {
    String sql = "UPDATE veiculo SET placa = ?, modelo = ?, ano = ? WHERE id_veiculo = ?";
    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setString(1, placa);
        stmt.setString(2, modelo);
        stmt.setInt(3, ano);
        stmt.setInt(4, idVeiculo);
        if (stmt.executeUpdate() != 1) {
            throw new IllegalArgumentException("Veículo não encontrado.");
        }
    }
}
```

**Impact se não feito:** Funcionalidades de edição/remoção incompletas em painéis admin.

---

## Validações Necessárias (Testes)

### ✗ Sem cobertura: Testes de integração

**Estado atual:**

- ✓ DAOCliente — 23 testes unit (Mockito)
- ✗ Demais DAOs — Sem testes
- ✗ Servlets — Sem testes de integração
- ✗ Fluxos end-to-end — Sem testes

**Ação necessária (post-MVP):**

1. Testes unit para DAOs restantes (DAOServico, DAOAgendamento, etc.)
2. Testes de integração para servlets (com BD de teste em Docker)
3. Testes E2E (Selenium/WebDriver) para fluxos (cadastro → login → agendamento)

**Impact se não feito:** Código não testado, risco de regressões silenciosas.

### ✓ Presente: Compilação e package

```bash
mvn clean compile  # ✓ OK
mvn test           # ✓ OK (23 testes DAOCliente)
mvn package        # ✓ OK (WAR gerado)
```

---

## Configuração Ambiente

### Variáveis de Ambiente Requeridas

| Var | Valor Exemplo | Obrigatória | Leitura |
|-----|---------------|-------------|---------|
| `ENV_DEV` | `LOCAL` \| `PROD` | ✓ | `.env` ou `System.getenv` |
| `LOCAL_DB_URL` | `jdbc:mysql://localhost:3306/splashfast` | ✓ (se `ENV_DEV=LOCAL`) | `.env` |
| `LOCAL_USER` | `usuario_mysql` | ✓ (se `ENV_DEV=LOCAL`) | `.env` |
| `LOCAL_PASS` | `senha_mysql` | ✓ (se `ENV_DEV=LOCAL`) | `.env` |
| `INITIAL_ADMIN_TOKEN` | `<token_aleatorio_longo>` | ✓ | `System.getenv` (setup inicial) |
| `PROD_DB_URL` | — | ✓ (se `ENV_DEV=PROD`) | — |
| `PROD_USER` | — | ✓ (se `ENV_DEV=PROD`) | — |
| `PROD_PASS` | — | ✓ (se `ENV_DEV=PROD`) | — |

**Localização `.env`:**

- **Desenvolvimento (IDE):** Raiz do projeto
- **Tomcat sistema:** `/var/lib/tomcat10/.env` ou via `-Ddotenv.dir`
- **Docker:** Variáveis de ambiente do container

**Exemplo `.env`:**

```
ENV_DEV=LOCAL
LOCAL_DB_URL=jdbc:mysql://localhost:3306/splashfast
LOCAL_USER=root
LOCAL_PASS=senha123
INITIAL_ADMIN_TOKEN=zx7k9mQ2w5vL8pR3nT6bY9jU4iO1eH
```

---

## Checklist de Execução

### Preparação

- [ ] MySQL 8.0.16+ instalado e rodando
- [ ] Banco `splashfast` criado via `database/schema.sql`
- [ ] Seed executado via `database/seed.sql`
- [ ] Arquivo `.env` criado com credenciais corretas
- [ ] `.env` em local acessível (raiz do projeto ou $CATALINA_BASE)

### Build

- [ ] `mvn clean compile` — ✓ BUILD SUCCESS
- [ ] `mvn test` — ✓ 23 testes passed
- [ ] `mvn package -DskipTests` — ✓ WAR gerado em `target/SplashFast.war`

### Servidor

- [ ] Tomcat 10.1 instalado
- [ ] `$CATALINA_BASE` variável definida (ou `/var/lib/tomcat10`)
- [ ] WAR copiado para `$CATALINA_BASE/webapps/`
- [ ] Tomcat iniciado: `sudo systemctl start tomcat10`

### Aplicação

- [ ] Arquivo `login.jsp` criado em `src/main/webapp/WEB-INF/views/`
- [ ] WAR reempacotado: `mvn package -DskipTests`
- [ ] Tomcat recarregado ou reiniciado

### Testes Manuais (Golden Path)

- [ ] Acesso `http://localhost:8080/SplashFast` — mostra index com serviços
- [ ] Link "Criar conta" leva a `/cadastro`
- [ ] Cadastro com dados válidos → sucesso → redirect `/login?cadastro=sucesso`
- [ ] Login com credenciais cadastradas → sucesso → `/portal`
- [ ] Admin login via `/colaborador/login` com seed data
- [ ] Acesso `/painel` → mostra painel admin
- [ ] Listagem `/painel/clientes` — mostra clientes
- [ ] Editar cliente — formulário pré-preenchido
- [ ] Remover cliente — confirmação, depois removido da lista
- [ ] Logout → home

---

## Próximas Sessões / Responsabilidades

| Item | Responsável | Prioridade | Status |
|------|-------------|-----------|--------|
| Setup MySQL + seed | Grupo | **CRÍTICO** | ⏳ TO-DO |
| `.env` + credenciais | Grupo | **CRÍTICO** | ⏳ TO-DO |
| Deploy Tomcat | Grupo | **CRÍTICO** | ⏳ TO-DO |
| Recriação `login.jsp` | Grupo | **CRÍTICO** | ⏳ TO-DO |
| Popular painéis vazios | Grupo | Alto | ⏳ TO-DO |
| Testes integração | Grupo | Médio | ⏳ TO-DO |
| Soft delete / auditoria | Grupo | Baixo | ⏳ FUTURE |
| App-mobile integração | Grupo | Médio | ⏳ FUTURE |

---

## Estimativa de Tempo

| Tarefa | Tempo |
|--------|-------|
| Preparar DB + `.env` | 15 min |
| Instalar/configurar Tomcat | 20 min |
| Recriação `login.jsp` | 10 min |
| Deploy e testes manuais | 15 min |
| **Total MVP V1 local funcional** | **~60 min** |
| Popular painéis + testes | 2-3 horas |
| App-mobile integração | 4-6 horas |

---

## Referências

- `01-estado-atual.md` — Status de compilação/testes
- `02-api-rest-v1.md` — Endpoints disponíveis
- `03-daos-expansao.md` — Estrutura de DAOs
- `04-servlets-e-views.md` — Fluxos de servlet
- `05-frontend-painel-js.md` — Validações JS
- `06-roteamento-index-servlet.md` — Roteamento raiz
- `07-painel-clientes-operacional.md` — Editar/Remover funcional
- `miscelaneous/variaveis-de-ambiente.md` — Docs variáveis
- `CLAUDE.md` — Configuração e arquitetura geral
- `database/README.md` — Setup DB
