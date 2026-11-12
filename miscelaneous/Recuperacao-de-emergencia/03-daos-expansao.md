# Expansão das DAOs — Recuperação

Referência: `miscelaneous/repositorios-removidos-e-cadastro-unico.md` (2026-10-18)

## Resumo da Migração

Transição completada de repositórios monolíticos (`LavaRapidoRepository`, `ClienteRepository`) para **per-table DAOs** em `src/main/java/com/splash/web/db/`.

Cada DAO:
- Um método por operação CRUD
- Apenas SQL + ResultSet mapping
- Instanciação inline: `new DAOServico().listar()`
- Nenhuma injeção de dependência (Tomcat 10.1 sem framework)

## DAOs Implementadas e Funcionais

### DAOCliente

**Métodos:**

| Método | Assinatura | Status |
|--------|-----------|--------|
| `listar()` | `List<ClienteView>` | ✓ Testado |
| `inserirUsuario(Cliente)` | `void` throws SQLException | ✓ Testado |
| `getUsuario(int)` | `ClienteView` | ✓ Testado |
| `updateUsuarios(int, String, String, String)` | `void` throws SQLException | ✓ Testado |
| `autenticar(String, String)` | `ClienteView` | ✓ Testado |
| `deleteusuario(int)` | ✗ Removido | Propósito: remoção não é permitida para clientes |

**Validações:**

- `Cliente` constructor valida nome, CPF, email, telefone via `Validacao`
- Senha já deve vir hashada (via `Passwords.hash()` no servlet)
- CPF duplicado → `SQLIntegrityConstraintViolationException` (409 no servlet)
- Email duplicado → `SQLIntegrityConstraintViolationException` (409 no servlet)

**DTO de retorno:** `ClienteView` (record imutável, properties para JSP EL)

### DAOServico

**Métodos:**

| Método | Retorna | Status |
|--------|---------|--------|
| `listar()` | `List<ServicoView>` | ✓ |
| `inserirServico(Servico)` | `void` | ✓ |
| `atualizarServico(int, String, String, double, int)` | `void` | ✓ |
| `removerServico(int)` | `void` | ✓ |

**Uso:** Painel admin (criar/editar/listar/remover serviços)

### DAOVeiculo

**Métodos:**

| Método | Retorna | Status |
|--------|---------|--------|
| `listar(int cliente_id)` | `List<VeiculoView>` | ✓ |
| `inserirVeiculo(Veiculo)` | `void` | ✓ |
| `removerVeiculo(int)` | `void` | ✓ |

**Limitação:** Sem `atualizar` — edição de veículo não implementada

**Uso:** Cliente próprio (listar/adicionar/remover carros)

**DTO:** `VeiculoView`

### DAOAgendamento

**Métodos:**

| Método | Assinatura | Status |
|--------|-----------|--------|
| `listar(int cliente_id)` | `List<AgendamentoView>` | ✓ |
| `criar(int, int, int[], String, String)` | `void` throws SQLException | ✓ |
| `cancelar(int agendamento_id)` | `void` throws SQLException | ✓ |

**Transações:** `criar` trata inserção de agendamento + itens (N:N com `ItemAgendamento`)

**Uso:** Cliente cria agendamento (POST `/api/v1/agendamentos`), cancela via painel

**DTO:** `AgendamentoView`

### DAOColaborador

**Métodos:**

| Método | Assinatura | Status |
|--------|-----------|--------|
| `listar()` | `List<ColaboradorView>` | ✓ |
| `inserir(Colaborador)` | `void` | ✓ |
| `autenticar(String, String)` | `ColaboradorView` | ✓ |

**Limitação:** Sem `remover` e sem `atualizar` — admin não consegue editar colaboradores após criação

**Uso:** Setup inicial (`SetupAdminServlet`), login de colaborador

**DTO:** `ColaboradorView`

### DAOAtendimento

**Métodos:**

| Método | Assinatura | Status |
|--------|-----------|--------|
| `listar()` | `List<AtendimentoView>` | ✓ |
| `atualizar(int, String, List<Integer>)` | `void` throws SQLException | ✓ (2026-11-11 fix) |
| `remover(int)` | `void` throws SQLException | ✓ (2026-11-11 fix) |

**Lógica de atualização:** Transação ACID com lock pessimista, validação de transição de status, atualiza timestamps (`data_inicio`, `data_fim`)

**Uso:** Painel admin muda status de atendimento (AGUARDANDO → EM_LAVAGEM → FINALIZADO → ENTREGUE)

**DTO:** `AtendimentoView`

### DAOPagamento

**Métodos:**

| Método | Assinatura | Status |
|--------|-----------|--------|
| `listar()` | `List<PagamentoView>` | ✓ |
| `atualizar(int, String, String)` | `void` | ✓ |

**Uso:** Painel admin muda status e forma de pagamento

**DTO:** `PagamentoView`

## DTOs Criadas

Localização: `src/main/java/com/splash/web/model/dto/`

Todas records (imutáveis, serializable, properties públicas para JSP EL):

- `ClienteView` — Para listagens de cliente
- `ServicoView` — Para GET `/api/v1/servicos`
- `VeiculoView` — Para listagens de veículo
- `AgendamentoView` — Para listagens de agendamento + GET `/api/v1/agendamentos`
- `ColaboradorView` — Para autenticação de colaborador
- `AtendimentoView` — Para listagens de atendimento
- `PagamentoView` — Para listagens de pagamento

### Acesso em JSPs

```jsp
${cliente.id_cliente}    ← record accessor via JavaBean getter
${servico.preco}
${agendamento.status}
```

Tomcat 10.1 suporta record accessors como getters implícitos.

## Segregação Arquitetural

**Antes:** Tudo em `LavaRapidoRepository`
**Depois:**

```
db/
├── DatabaseConnection.java  ← Apenas getConnection(), nada de SQL
├── DAOCliente.java          ← cliente (INSERT/SELECT/UPDATE)
├── DAOServico.java          ← serviço (CRUD)
├── DAOVeiculo.java          ← veículo (sem UPDATE)
├── DAOAgendamento.java      ← agendamento + itemAgendamento (CREATE/READ/CANCEL)
├── DAOAtendimento.java      ← atendimento (READ/UPDATE/DELETE)
├── DAOPagamento.java        ← pagamento (READ/UPDATE)
├── DAOColaborador.java      ← colaborador (CREATE/READ/AUTH)
└── Passwords.java           ← BCrypt (segurança)
```

## Transações Multitabela

**DAOAgendamento.criar():**

```
BEGIN TRANSACTION
  1. INSERT agendamento
  2. Retrieve agendamento.id
  3. INSERT itemAgendamento × len(idServicos)
  4. INSERT colaborador_agendamento × len(idColaboradores) [se houver]
COMMIT
```

Isolamento REPEATABLE_READ (default MySQL).

**DAOAtendimento.atualizar():**

```
BEGIN TRANSACTION
  1. SELECT FOR UPDATE atendimento (lock pessimista)
  2. Validar transição de status
  3. UPDATE atendimento (status, timestamps)
  4. DELETE colaborador_atendimento
  5. INSERT colaborador_atendimento (lista nova)
  6. UPDATE agendamento.status se atendimento finalizado
COMMIT or ROLLBACK
```

## Mapeamento Servlet → DAO

| Servlet | DAO Principal | Secundárias | Métodos Usados |
|---------|---------------|-------------|----------------|
| `CadastroClienteServlet` | `DAOCliente` | `Passwords` | `insertUsuario` |
| `ClienteServlet` | `DAOCliente` | — | `listar`, `autenticar`, `updateUsuarios` |
| `ServicoServlet` | `DAOServico` | — | `listar`, `inserir`, `atualizar`, `remover` |
| `VeiculoServlet` | `DAOVeiculo` | — | `listar`, `inserir`, `remover` |
| `AgendamentoServlet` | `DAOAgendamento` | `DAOServico` | `criar`, `listar`, `cancelar` |
| `AdminServlet` | `DAOColaborador`, `DAOServico`, `DAOAtendimento`, `DAOPagamento` | — | `listar`, `inserir`, `atualizar`, `remover` |
| `PainelServlet` | `DAOCliente`, `DAOAgendamento`, `DAOAtendimento` | — | Prepara dados para painel |

## Histórico de Mudanças

| Data | Commit | Descrição |
|------|--------|-----------|
| 2026-10-18 | `4662f3e` | Remove `LavaRapidoRepository` e `ClienteRepository` |
| 2026-10-18 | `3481984` | Servlets importam DAOs, forwards apontam para `/WEB-INF/views/` |
| 2026-10-18 | `bec8212` | Cadastro único em `/cadastro`, `Cadastro.java` apagada |
| 2026-11-11 | — | Fix: `DAOAtendimento.remover()` — corrigido `Public Void` para `public void` |

## Pendências Conhecidas

1. **DAOVeiculo.atualizar()** — Não implementado. Edição de veículo precisa ser adicionada.
2. **DAOColaborador.atualizar() / remover()** — Não implementados. Admin não consegue editar colaboradores.
3. **Testes** — Apenas DAOCliente tem testes unit. DAOs restantes carecem cobertura.
4. **Docs OpenAPI** — Pode estar desatualizada em relação ao código atual.

## Próximos Passos

1. Implementar `DAOVeiculo.atualizar(id, placa, modelo, ano)`
2. Implementar `DAOColaborador.atualizar(id, ...)` e `remover(id)`
3. Escrever testes para DAOs restantes (Mockito + JUnit 5)
4. Atualizar openapi.yml com endpoints finais
5. Testar fluxo completo: cliente cria agendamento → painel atendimento → colaborador marca como finalizado
