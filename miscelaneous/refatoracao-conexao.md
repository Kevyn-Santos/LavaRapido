# Refatoração da conexão com o banco

Data: 2026-10-14

Objetivo: todo acesso ao banco passa a usar `DatabaseConnection.getConnection()`, que escolhe entre banco
local e de produção pela variável `ENV_DEV` do `.env` (valores `LOCAL` ou `PROD`; padrão `LOCAL`).

Variáveis lidas do `.env` na raiz do projeto, com prefixo do ambiente:

| Ambiente | URL            | Usuário      | Senha        |
|----------|----------------|--------------|--------------|
| LOCAL    | `LOCAL_DB_URL` | `LOCAL_USER` | `LOCAL_PASS` |
| PROD     | `PROD_DB_URL`  | `PROD_USER`  | `PROD_PASS`  |

## Alterações

| Arquivo modificado | Linha modificada | Imports modificados | Código da conexão antiga | Código da conexão nova |
|---|---|---|---|---|
| `src/main/java/com/splash/web/db/LavaRapidoRepository.java` | 3–4 (removidas) | Removido `import com.example.Database;` (pacote não existe mais; `DatabaseConnection` está no mesmo pacote e não precisa de import) | `import com.example.Database;` | — |
| `src/main/java/com/splash/web/db/LavaRapidoRepository.java` | 94, 107, 123, 141, 157, 170, 181, 198, 214, 236, 317, 337, 369, 384, 408, 433, 511, 531, 546, 555 (numeração após remover as linhas 3–4; antes eram 96, 109, 125, 143, 159, 172, 183, 200, 216, 238, 319, 339, 371, 386, 410, 435, 513, 533, 548, 557) | Nenhum | `try (Connection connection = Database.getConnection()` | `try (Connection connection = DatabaseConnection.getConnection()` |
| `src/main/java/com/splash/web/db/DatabaseConnection.java` | 3 (removida) | Removido `import java.lang.reflect.InvocationTargetException;` (não é mais usado) | `import java.lang.reflect.InvocationTargetException;` | — |
| `src/main/java/com/splash/web/db/DatabaseConnection.java` | 24 | Nenhum | `Ambiente.valueOf(dotenv.get("ENV_DEV", "LOCAL"));` | `Ambiente.valueOf(dotenv.get("ENV_DEV", "LOCAL").trim().toUpperCase());` (aceita `local`, `Prod` etc. sem lançar `IllegalArgumentException`) |
| `src/main/java/com/splash/web/db/DatabaseConnection.java` | 50–55 | Nenhum | `Class.forName("com.mysql.cj.jdbc.Driver").getDeclaredConstructor().newInstance();` com `catch` que lançava `RuntimeException` | `Class.forName("com.mysql.cj.jdbc.Driver");` com `catch (ClassNotFoundException e)` lançando `SQLException` |
| `src/main/java/com/splash/web/db/DatabaseConnection.java` | 57–61 | Nenhum | `ChaveObrigatoria(prefix + "DB_URL_PROD")`, `ChaveObrigatoria(prefix + "USER_PROD")`, `ChaveObrigatoria(prefix + "PASS_PROD")`, dentro de `try/catch` que trocava `SQLException` por `RuntimeException` | `ChaveObrigatoria(prefix + "DB_URL")`, `ChaveObrigatoria(prefix + "USER")`, `ChaveObrigatoria(prefix + "PASS")`, sem `try/catch` (a `SQLException` é propagada) |
| `src/main/java/com/splash/web/db/Database.java` | Arquivo removido | — | `DriverManager.getConnection(url, user, password)` com `DB_URL`/`DB_USER`/`DB_PASSWORD` lidos de `System.getenv` | Substituído por `DatabaseConnection.getConnection()` |

`DAOCliente.java` já usava `DatabaseConnection.getConnection()` em todas as chamadas e não foi alterado.

## Motivo das correções em `DatabaseConnection`

- **Chaves erradas:** `prefix + "DB_URL_PROD"` gerava `LOCAL_DB_URL_PROD` e `PROD_DB_URL_PROD`. Nenhuma das duas existe
  no `.env`, então toda conexão lançava `IllegalStateException`.
- **`RuntimeException` no lugar de `SQLException`:** o servlet `Cadastro` trata
  `SQLIntegrityConstraintViolationException` para responder 409. Com a exceção embrulhada, esse tratamento nunca
  era alcançado.
- **`Class.forName` mantido:** no Tomcat, o `DriverManager` é carregado pelo classloader comum e não descobre
  sozinho o driver que fica em `WEB-INF/lib`. O registro explícito evita `No suitable driver found`.

## Verificação

- Os pacotes `db` e `model` compilam sem erros (`javac` com o classpath do Maven).
- `mvn compile` ainda falha, mas só nos servlets antigos (`AdminServlet`, `AgendamentoServlet`,
  `CadastroClienteServlet`, `ColaboradorLoginServlet`, `LoginServlet`, `SetupAdminServlet`, `VeiculoServlet`).
  Os erros vêm dos imports `com.example.*` e da visibilidade package-private de `LavaRapidoRepository` e `WebSupport`,
  e não da conexão. Eles serão resolvidos na separação das DAOs.
- `DAOClienteTest` mocka `DatabaseConnection.getConnection()`, que continua existindo com a mesma assinatura.
  O teste não foi executado porque o build do Maven não passa da compilação dos servlets.
