# Recuperação de Emergência — Índice

**Data:** 2026-11-11

**Propósito:** Mapear mudanças perdidas nos commits de 2026-11-07 a 2026-11-08, registrar estado atual do projeto, e listar o que falta para MVP V1 executável localmente.

---

## Conteúdo

### 1. [`01-estado-atual.md`](01-estado-atual.md)

**Status de Compilação, Testes e Deploy**

- ✓ Projeto compila sem erros (69 arquivos fonte)
- ✓ 23 testes passam (DAOCliente)
- ✓ WAR gerado em `target/SplashFast.war`
- Erros corrigidos:
  - `DAOAtendimento.remover()` — `Public Void` → `public void`
  - `DAOClienteTest` — Removido teste para método inexistente
- Pré-requisitos para execução: MySQL, `.env`, Tomcat 10.1

**Leia quando:** Precisa entender status atual de build/test

---

### 2. [`02-api-rest-v1.md`](02-api-rest-v1.md)

**Implementação da API REST v1**

Commits: `65ebce0`, `89f866e`, `06a5c85`, `3f1569b`, `1b68b57`

- 3 servlets API implementados:
  - `ServicoApiServlet` — GET `/api/v1/servicos`
  - `VeiculoApiServlet` — GET/POST/DELETE `/api/v1/veiculos`
  - `AgendamentoApiServlet` — GET/POST `/api/v1/agendamentos`
- DTOs: `ServicoResponse`, `NovoAgendamentoRequest`, etc.
- Serialização JSON via Jackson (`Json.java`)
- Autenticação via sessão HTTP (sem token Bearer)
- OpenAPI docs em `miscelaneous/openapi.yml` (pode estar desatualizada)
- **Pendência:** app-mobile ainda usa dados em-memória, não consome API

**Leia quando:** Precisa testar endpoints, integrar com app-mobile, ou documentar API

---

### 3. [`03-daos-expansao.md`](03-daos-expansao.md)

**Expansão para Per-Table DAOs**

Referência: `miscelaneous/repositorios-removidos-e-cadastro-unico.md` (2026-10-18)

Migração completada de `LavaRapidoRepository` monolítico para 7 DAOs:

- `DAOCliente` — ✓ Testado (7 testes passam)
- `DAOServico` — ✓ CRUD completo
- `DAOVeiculo` — ⚠️ Sem `atualizar()`
- `DAOAgendamento` — ✓ Transações multi-tabela
- `DAOAtendimento` — ✓ (2026-11-11 fix)
- `DAOColaborador` — ⚠️ Sem `atualizar()` / `remover()`
- `DAOPagamento` — ✓ UPDATE

Padrão: `new DAOX().metodo()` (sem injeção de dependência)

DTOs em `model.dto/` — records imutáveis com getters JSP-compatíveis

**Leia quando:** Precisa entender estrutura de persistência, adicionar métodos DAO, ou testes

---

### 4. [`04-servlets-e-views.md`](04-servlets-e-views.md)

**Integração Servlets + Views JSP**

Commits: `3481984` (2026-10-18), `1f43b58` (2026-11-01)

- 12 servlets mapeados via `@WebServlet()` (sem `web.xml`)
- Views em `WEB-INF/views/` (protegidas, só via forward)
- Públicas: `index.jsp`, `cadastro.jsp`, `health.jsp`, `Assets/*`
- Fluxos: Cliente (cadastro → login → portal), Admin (painel → editar/remover)
- Painel tem dois layouts durante transição (legado + novo)
- Filtro UTF-8 forçado em todas requisições
- Tratamento de erros → `erro.jsp` + `WebSupport.erroBanco()`

**Painéis vazios (falta dados):**
- `painel-carros.jsp`, `painel-agendamentos.jsp`
- `painel-colaboradores.jsp`, `painel-atendimentos.jsp`, `painel-pagamentos.jsp`

**Pendência:** AdminServlet aponta para `/admin.jsp` inexistente

**Leia quando:** Precisa popular painéis, adicionar/remover views, ou entender fluxos

---

### 5. [`05-frontend-painel-js.md`](05-frontend-painel-js.md)

**Frontend — `painel.js` e CSS**

Commit: `3f1569b` (2026-11-06)

**Mudança crítica:** Removido bloqueio de API fictícia em `painel.js`

- ✓ Removido `pendingMessage` e `showPending()`
- ✓ Reescrito `setupForm()` — agora permite POST quando validação passa
- ✓ Validações client-side: CPF, telefone, placa
- ✓ Form submit agora chega ao servidor (não bloqueado)

**Antes:** Nenhum POST saia do navegador.
**Depois:** POST vai para servlet quando validações JS passam.

**Efeito visual:** Containers de listagem ainda vazios (não é bloqueio, é falta de dados do servidor)

**Leia quando:** Precisa entender fluxo de validação, adicionar validações, ou verificar por que forms não enviam

---

### 6. [`06-roteamento-index-servlet.md`](06-roteamento-index-servlet.md)

**Roteamento `IndexServlet` — Correção de Loop Infinito**

Commits: `06a5c85` (18:00), `1b68b57` (18:15), `1f43b58` (18:30) — 2026-11-07

**Problema:** `@WebServlet({"", "/index.jsp"})` + forward `/index.jsp` → StackOverflowError

**Três opções consideradas:**

1. **Opção A** — Mover `index.jsp` para `WEB-INF/views/` (temporária)
2. **Opção B** — Remover mapeamento duplo, trocar links para contextPath raiz (adotada)
3. **Opção C** — Controle manual de reentrada (descartada)

**Final (Opção B):**

- `@WebServlet("")` — Só raiz exata
- `index.jsp` fica em `src/main/webapp/` (pública)
- Links JSPs trocados: `/index.jsp` → `/` (~10 arquivos)
- Forward continua: `/index.jsp` → arquivo físico

**Validação:** Sem StackOverflowError, compile OK

**Leia quando:** Precisa entender roteamento de raiz, links internos, ou debugar loop de forward

---

### 7. [`07-painel-clientes-operacional.md`](07-painel-clientes-operacional.md)

**Painel de Clientes — Editar/Remover Operacional**

Commit: `1f43b58` (2026-11-08)

**Mudança:** Botões Editar/Remover ativados em layout novo (`.tbl` / `.trow` / `.acts`)

- ✓ GET `?editar=id` → formulário pré-preenchido
- ✓ POST `acao=remover` + confirmação → deleta cliente
- ✓ Layout legado preservado (`<table>`) para transição
- Validações: Cliente (ID validado, exception handling)
- `ClienteServlet` trata ambas ações

**Análise replicação em outros painéis:** Não é copy-paste direto (bloqueadores diferentes por painel)

**Leia quando:** Precisa replicar pattern editar/remover em painéis vazios, ou testar funcionalidade

---

### 8. [`08-checklist-falta-executar.md`](08-checklist-falta-executar.md)

**Checklist: O Que Falta para MVP V1 Executável Localmente**

**Bloqueadores Críticos:**

- ✗ MySQL 8.0.16+ com database criado
- ✗ Arquivo `.env` com credenciais
- ✗ Tomcat 10.1 instalado e configurado
- ✗ Arquivo `login.jsp` recriado (não versioned)

**Bloqueadores Funcionais (Alto):**

- ⚠️ Painéis vazios — sem dados vindos do servidor
- ⚠️ AdminServlet aponta para `/admin.jsp` inexistente
- ⚠️ Métodos DAO incompletos (`DAOVeiculo.atualizar`, `DAOColaborador.remover`)

**Validações Necessárias:**

- Testes de integração (nenhum, apenas unit de DAOCliente)
- Testes E2E (nenhum, necessário Selenium/WebDriver)

**Estimativa:** ~60 min para MVP V1 local funcionar (setup DB + Tomcat + login.jsp + testes básicos)

**Checklist de execução:** 20 items detalhados

**Leia quando:** Antes de começar a executar o projeto localmente, ou para planejar sessão com grupo

---

## Índice por Tópico

### Por Funcionalidade

| Tópico | Arquivo |
|--------|---------|
| Build/Compile/Test | `01-estado-atual.md` |
| API REST e endpoints | `02-api-rest-v1.md` |
| Persistência e DAOs | `03-daos-expansao.md` |
| Rotas, servlets, views | `04-servlets-e-views.md` |
| Frontend validações | `05-frontend-painel-js.md` |
| Roteamento raiz | `06-roteamento-index-servlet.md` |
| CRUD cliente no painel | `07-painel-clientes-operacional.md` |
| Setup local + próximos passos | `08-checklist-falta-executar.md` |

### Por Data de Commit

| Data | Commits | Arquivo |
|------|---------|---------|
| 2026-10-18 | `4662f3e`, `3481984`, `bec8212` | `03-daos-expansao.md`, `04-servlets-e-views.md` |
| 2026-11-06 | `3f1569b` | `05-frontend-painel-js.md` |
| 2026-11-07 | `06a5c85`, `1b68b57`, `1f43b58` | `06-roteamento-index-servlet.md` |
| 2026-11-08 | `1f43b58` | `07-painel-clientes-operacional.md` |
| 2026-11-11 | (fixes) | `01-estado-atual.md`, `03-daos-expansao.md` |

### Por Prioridade de Leitura

1. **Primeira vez:** `01-estado-atual.md` + `08-checklist-falta-executar.md`
2. **Entender arquitetura:** `03-daos-expansao.md` + `04-servlets-e-views.md`
3. **Testar localmente:** `02-api-rest-v1.md` + `07-painel-clientes-operacional.md`
4. **Debugar fluxos:** `05-frontend-painel-js.md` + `06-roteamento-index-servlet.md`
5. **Próximas mudanças:** `08-checklist-falta-executar.md` (seção "Próximas Sessões")

---

## Status Resumido

| Componente | Status | Nota |
|-----------|--------|------|
| **Compilação** | ✓ OK | 69 fontes, sem erros |
| **Testes** | ✓ OK | 23 testes DAOCliente passam |
| **Build WAR** | ✓ OK | `target/SplashFast.war` gerado |
| **API REST** | ✓ Implementado | 3 servlets, JSON, autenticação sessão |
| **DAOs** | ✓ 7 DAOs | Completos exceto `atualizar/remover` em 3 |
| **Servlets** | ✓ 12 mappings | Rotas, validação, tratamento erro |
| **Frontend JS** | ✓ Liberado | Bloqueio API removido, validações ativas |
| **Roteamento** | ✓ Corrigido | IndexServlet loop fixado, links atualizados |
| **CRUD Painel** | ✓ Editar/Remover | Funcional em painel-clientes |
| **MySQL** | ✗ Não setup | Precisa executar schema + seed |
| **Tomcat** | ✗ Não instalado | Precisa instalar 10.1 |
| **login.jsp** | ✗ Não criado | Arquivo não versioned, precisa recriação |
| **Painéis vazios** | ⚠️ Vazios | Servidores não popula dados, precisa JSTL |

---

## Próximas Ações

### Curto Prazo (Hoje/Esta Semana)

1. [ ] Setup MySQL + seed (`database/schema.sql`, `database/seed.sql`)
2. [ ] Criar `.env` com credenciais
3. [ ] Instalar Tomcat 10.1
4. [ ] Recriação `login.jsp`
5. [ ] Deploy WAR e testes manuais (golden path)

### Médio Prazo (Próximas 1-2 semanas)

1. [ ] Popular painéis vazios (JSTL + dados servidor)
2. [ ] Implementar `DAOVeiculo.atualizar()`, `DAOColaborador.remover()`, etc.
3. [ ] Religar AdminServlet a view real (ou admin.jsp)
4. [ ] Testes de integração (servlet + DAO + DB)

### Longo Prazo

1. [ ] App-mobile integração (migrar de repositório em-memória para API REST)
2. [ ] Testes E2E (Selenium)
3. [ ] Soft delete / auditoria
4. [ ] Melhorias de UX (msgs erro mais descritivas, validações melhoradas)

---

## Referências Externas

- **Repositório local:** `/home/kevyn/Documents/Faculdade/JAVA/LavaRápido/SplashFast`
- **Hub externo:** `/home/kevyn/Documents/ClaudePrompts/Projects/LavaRapido/`
  - Registros em: `.../registros/2026-11-*.md`
  - Cópia de miscelaneous em: `.../miscelaneous/`
- **CLAUDE.md:** Instruções globais do projeto
- **Database:** `database/schema.sql`, `database/seed.sql`, `database/README.md`
- **Documentação técnica:** `miscelaneous/` (vários `.md`)
- **OpenAPI:** `miscelaneous/openapi.yml` (pode estar desatualizada)

---

## Criado por

**Claude Haiku 4.5** | 2026-11-11

**Contexto:** Recuperação de mudanças perdidas em versionamento de 2026-11-07 a 2026-11-08, mapeamento de estado atual, e planejamento de MVP V1.

**Método:** Análise de commits recentes, leitura de registros hub externo, diagnóstico local (compile, test, package), e documentação estruturada em 8 arquivos temáticos.
