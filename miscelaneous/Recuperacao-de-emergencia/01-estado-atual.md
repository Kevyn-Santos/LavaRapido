# Estado Atual do Projeto — Compilação, Testes e Deploy

Data: 2026-11-11

## Resumo Executivo

Projeto em **estado compilável**. Testes passam (23 casos). WAR (target/SplashFast.war) gerado com sucesso. Dois erros de sintaxe já corrigidos durante diagnóstico.

## Mudanças Aplicadas Nesta Sessão

### Erros Corrigidos

1. **DAOAtendimento.java:135** — `Public Void remover(...)` → `public void remover(...)`
   - Erro de capitalização em modificador de acesso
   - Bloqueava compilação

2. **DAOClienteTest.java:418-448** — Removida classe aninhada `DeleteUsuario`
   - Tentava chamar `dao.deleteusuario(int)` que foi removido em versão anterior
   - Método não implementado em `DAOCliente` conforme documentação
   - Testes abertos: `insertUsuario`, `getUsuarios`, `getusuario`, `updateUsuarios` — todos passam

## Status de Compilação

```
mvn clean compile
→ BUILD SUCCESS (1.736 s)
✓ 69 arquivos fonte compilados
✓ Sem warnings além dos deprecation de Java 25
```

## Status de Testes

```
mvn test
→ BUILD SUCCESS (4.038 s)
✓ 23 testes rodam
✓ 0 falhas, 0 erros
Detalhes:
  - getUsuarios() — 7 testes
  - insertUsuario(cliente) — 3 testes
  - updateUsuarios(id, nome, telefone, email) — 8 testes
  - getusuario(id) — 5 testes
```

## Status de Package

```
mvn package -DskipTests
→ BUILD SUCCESS (1.560 s)
✓ WAR criado em: target/SplashFast.war
✓ Webapp assembled com 69 classes + JSPs + Assets
```

## Pré-requisitos para Execução Local

### Obrigatórios (Não Presentes)

1. **MySQL ≥ 8.0.16** rodando
   - Database schema: `database/schema.sql` precisa ser executado
   - Seed: `database/seed.sql` precisa ser executado

2. **Arquivo `.env` na raiz do projeto** com variáveis (ou `System.getenv()`)
   ```
   ENV_DEV=LOCAL
   LOCAL_DB_URL=jdbc:mysql://localhost:3306/splashfast
   LOCAL_USER=<usuario>
   LOCAL_PASS=<senha>
   INITIAL_ADMIN_TOKEN=<token_seguro>
   ```
   Detalhes completos em `miscelaneous/variaveis-de-ambiente.md`

3. **Tomcat 10.1+** para deploy local
   - Copiar `target/SplashFast.war` para `$CATALINA_BASE/webapps/`
   - Context path será `/SplashFast` (ou `/` se renomeado para `ROOT.war`)

### Presentes e Funcionais

- ✓ Java 25 compilador
- ✓ Maven 3.6+ (buildado localmente)
- ✓ Todas as dependências declaradas em `pom.xml` (baixadas)
- ✓ Estrutura de código-fonte compilável
- ✓ Suite de testes unit (sem dependências de DB real, usa Mockito)

## Próximos Passos Críticos

1. Configurar MySQL local com `schema.sql` + `seed.sql`
2. Criar `.env` com credenciais corretas
3. Instalar Tomcat 10.1 se não estiver presente
4. Deploy: copiar WAR para `webapps/`
5. Iniciar Tomcat e testar acesso em `http://localhost:8080/SplashFast`

---

## Notas Técnicas

- **Encoding**: Projeto força UTF-8 via `EncodingFilter` — confirmado no pom.xml com `project.build.sourceEncoding`
- **Classpath**: Tomcat lê `.env` de `-Ddotenv.dir` ou diretório de trabalho da JVM (tipicamente `/var/lib/tomcat10` em Debian/Ubuntu)
- **Driver JDBC**: Registrado explicitamente com `Class.forName("com.mysql.cj.jdbc.Driver")` em `DatabaseConnection`
- **Exceções**: SQLExceptions propagadas sem wrap proposital — servlets mapeiam `SQLIntegrityConstraintViolationException` para 409
