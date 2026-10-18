# Resumo: testes da DAOCliente e documentação OpenAPI

Data: 2026-10-12

## 1. Testes unitários da `DAOCliente`

**Arquivo:** `src/test/java/com/splash/web/db/DAOClienteTest.java` (não versionado: `.gitignore` → `/src/test/`)

**Como rodar:** `mvn test`

### Abordagem
- JUnit 6 (Jupiter) + Mockito 5.
- Nenhum banco real é usado. `DatabaseConnection.getConnection()` é mockado com `mockStatic` e devolve
  `Connection` / `PreparedStatement` / `ResultSet` falsos. Assim os testes são de fato unitários:
  eles verificam o SQL gerado, os parâmetros e sua ordem, o mapeamento do ResultSet, as validações,
  a propagação de exceções e o fechamento dos recursos (try-with-resources).
- Os testes estão agrupados por método com `@Nested` e têm `@DisplayName` em português.

### Cobertura (24 testes)
| Método | O que é verificado |
|---|---|
| `getUsuarios()` | mapeia várias linhas; lista vazia; SQL correto; fecha recursos; propaga `SQLException` |
| `getusuario(id)` | SQL com `WHERE`; vincula o id **antes** de `executeQuery`; chama `rs.next()` antes de ler; mapeamento |
| `insertUsuario(cliente)` | SQL e parâmetros 1..5 na ordem; `executeUpdate`; fecha recursos; `SQLException` encapsula a causa original |
| `updateUsuarios(...)` | id nulo → IAE sem abrir conexão; todos os campos nulos ou em branco → IAE; SQL dinâmico com todos os campos, só email, nome+telefone; parâmetros na ordem; 0 linhas afetadas → IAE; fecha recursos |
| `deleteusuario(id)` | SQL, `setInt` antes de `executeUpdate`, fecha recursos, propaga `SQLException` |
| `deleteusuariosTotal(id)` | idem |

### Resultado: 22 passam, 2 falham (bug real na DAO)
Os 2 testes que falham são de `getusuario(int id)` e apontam um defeito em `DAOCliente.java:65-78`:
- **`vinculaIdAntesDeExecutar`**: o `?` nunca recebe valor (`stmt.setInt(1, id)` não é chamado). Além disso,
  `executeQuery()` roda na abertura do try-with-resources, antes de qualquer `set`.
- **`avancaCursorAntesDeLer`**: `rs.next()` nunca é chamado, então ler as colunas lança `SQLException` em um banco real.

Correção sugerida (não aplicada, porque o pedido era só criar testes):
```java
try (Connection conn = DatabaseConnection.getConnection();
     PreparedStatement stmt = conn.prepareStatement(sql)) {
    stmt.setInt(1, id);
    try (ResultSet rs = stmt.executeQuery()) {
        if (!rs.next()) return null; // ou lançar exceção
        Cliente client = new Cliente();
        ... // mapeamento atual
        return client;
    }
}
```

### Outro bug achado durante os testes (modelo)
- `Pessoa.java:12`: `int id = super.getId();` faz unboxing de `null` e lança **NullPointerException**.
  Por isso o construtor completo `new Cliente(nome, cpf, telefone, email, senha)` **sempre falha**.
  O teste de `insertUsuario` monta o `Cliente` via setters para isolar a DAO desse problema.
  Basta remover essa linha.

### Alterações em arquivos versionados
- `pom.xml`: dependências de teste `junit-jupiter 6.0.3` e `mockito-junit-jupiter 5.23.0` (escopo `test`),
  além do `maven-surefire-plugin 3.5.4` com `-XX:+EnableDynamicAgentLoading` (agente do Mockito no Java 25).
- `.gitignore`: entrada `/src/test/`.

## 2. Documentação das rotas (OpenAPI 3.0.3)

**Arquivo:** `miscelaneous/openapi.yml` (não versionado: `miscelaneous/*`). Foi gerado por um subagente em paralelo.
O YAML é sintaticamente válido. Não houve validação contra o schema OpenAPI.

Server: `http://{host}:{port}/{contextPath}`, com padrão `localhost:8080/SplashFast-1.0`.

| Método | Path | Resumo |
|---|---|---|
| GET | `/`, `/index.jsp` | formulário de cadastro |
| POST | `/cadastro` | cadastra o cliente e faz forward para `/mostrarCadastros` |
| POST | `/mostrarCadastros` | lista clientes em `cadastroT.jsp` (só POST) |
| GET | `/listarCadastros` | lista clientes em `EditarCadastro.jsp` |
| POST | `/editarCadastro` | atualiza nome/telefone/email |
| GET | `/listarCadastrosExclusao` | lista clientes em `DeletarCadastro.jsp` |
| POST | `/deletarCadastro` | exclui o cliente (`IdUser`, `CheckAll`) |

### Inconsistências apontadas pelo subagente (não verificadas uma a uma)
1. `Cadastro.java`: falta `return` após o forward nos `catch`, o que causa um forward duplo (`IllegalStateException`).
2. `Cadastro.java`: `Cliente` e a DAO são campos de instância do servlet, o que não é thread-safe.
3. `insertUsuario` encapsula a exceção em `new SQLException(e)`, então o `catch (SQLIntegrityConstraintViolationException)` nunca dispara e um duplicado vira 500. **(resolvido: a DAO propaga a exceção original)**
4. A senha é gravada em texto puro em `senha_hash`.
5. `setCPF` não valida. O placeholder do CPF não cabe no `maxlength=11`.
6. As JSPs usam `${users.name}`, mas o getter é `getNome()`, o que provavelmente causa `PropertyNotFoundException`.
7. `cadastroT.jsp` usa `${users.id}`, mas a DAO preenche só `id_cliente`. **(resolvido: `Cliente.carregar` preenche `setId`)**
8. O checkbox `CheckAll` envia `"on"`, mas o servlet compara com `"true"`. `deleteusuariosTotal` é idêntico a `deleteusuario`.
9. `DeletarCadastro` não define charset e não verifica as linhas afetadas.
10. Depois de `POST /editarCadastro`, a JSP é renderizada sem `currentUsers` e o select fica vazio.
11. O update não valida telefone/email. `text/plain` é definido antes do forward para a JSP.
12. ~~Path com acento~~ (resolvido: agora `/listarCadastrosExclusao`). Nomes de classes ainda inconsistentes (`Listarcadastros`).
13. `getUsuarios` chama `setTelefone`, que valida, então um telefone inválido no banco derruba a listagem inteira. **(resolvido: ver `carregamento-sem-validacao.md`)**
