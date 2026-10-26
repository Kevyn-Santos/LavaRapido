# Esqueleto da API `/api/v1/*` (servlets)

> Registrado em 26/10/2026, às 12:28 (UTC).

## Contexto

Este registro documenta a criação do **esboço** da API REST que vai conectar o app
mobile (`app-mobile/`) ao backend Java, conforme o plano descrito em
`miscelaneous/analise-app-mobile.md` (Parte 3). É só estrutura: nenhuma rota foi
implementada de fato.

## Onde ficou o esqueleto

O pedido original foi "criar o esqueleto em `src/api`". Como este é um projeto Maven/WAR
que roda no Tomcat, código Java só compila dentro de `src/main/java/<pacote>` — por isso o
esqueleto foi criado em **`src/main/java/com/splash/web/api`**, um novo pacote dentro do
mesmo projeto/WAR já existente (`com.splash.web.*`). Isso segue exatamente a recomendação da
análise (seção 3.1): reaproveitar o mesmo Tomcat e a mesma camada `db` que o site JSP já usa,
em vez de subir um segundo servidor. As rotas usam **Servlets** (`@WebServlet`/`@WebFilter`),
não `HttpServer`, para que o Tomcat seja reaproveitado — exatamente como solicitado.

## Mudanças feitas

### Branch
- Criada a branch `API_MOBILE` a partir de `ccr-92d86657-cukeg9`.

### Estrutura de arquivos criada

```
src/main/java/com/splash/web/api/
├── ApiServlet.java              # base abstrata: suporte a PATCH + idClienteAutenticado(request)
├── ApiAuthFilter.java           # @WebFilter("/api/v1/*") — valida o JWT (ainda não implementado)
├── Json.java                    # helper de serialização JSON (ok/erro/ler) — ainda não implementado
├── jwt/
│   └── JwtService.java          # gerar/validar token JWT — ainda não implementado
├── dto/                         # DTOs de request/response da API (distintos dos DTOs de JSP em model/dto)
│   ├── LoginRequest.java
│   ├── LoginResponse.java
│   ├── ClienteResumo.java
│   ├── CadastroRequest.java
│   ├── AtualizarPerfilRequest.java
│   ├── NovoVeiculoRequest.java
│   ├── NovoAgendamentoRequest.java
│   └── ErroResponse.java
└── v1/                          # servlets de rota (modelo api/v1/*)
    ├── AuthApiServlet.java        -> POST /api/v1/auth/login, /api/v1/auth/cadastro
    ├── MeApiServlet.java          -> GET e PATCH /api/v1/me
    ├── ServicoApiServlet.java     -> GET /api/v1/servicos
    ├── VeiculoApiServlet.java     -> GET/POST /api/v1/veiculos, DELETE /api/v1/veiculos/{id}
    ├── AgendamentoApiServlet.java -> GET/POST /api/v1/agendamentos, POST /api/v1/agendamentos/{id}/cancelar
    └── HorarioApiServlet.java     -> GET /api/v1/horarios?data=...
```

### Rotas definidas (modelo `api/v1/*`)

| Método | Rota | Servlet |
| --- | --- | --- |
| POST | `/api/v1/auth/login` | `AuthApiServlet` |
| POST | `/api/v1/auth/cadastro` | `AuthApiServlet` |
| GET | `/api/v1/me` | `MeApiServlet` |
| PATCH | `/api/v1/me` | `MeApiServlet` |
| GET | `/api/v1/servicos` | `ServicoApiServlet` |
| GET | `/api/v1/veiculos` | `VeiculoApiServlet` |
| POST | `/api/v1/veiculos` | `VeiculoApiServlet` |
| DELETE | `/api/v1/veiculos/{id}` | `VeiculoApiServlet` |
| GET | `/api/v1/agendamentos` | `AgendamentoApiServlet` |
| POST | `/api/v1/agendamentos` | `AgendamentoApiServlet` |
| POST | `/api/v1/agendamentos/{id}/cancelar` | `AgendamentoApiServlet` |
| GET | `/api/v1/horarios` | `HorarioApiServlet` |

Todas as rotas acima, exceto `/api/v1/auth/*`, passam pelo `ApiAuthFilter`
(`@WebFilter("/api/v1/*")`), que por ora apenas repassa a cadeia de filtros sem validar nada
(placeholder — ver "O que falta fazer").

### O que **não** foi feito (intencionalmente)

- Nenhum método tem lógica de negócio: todo `doGet`/`doPost`/`doPatch`/`doDelete` responde
  `501 Not Implemented` (ou é um corpo vazio comentado com `// TODO`), como marcador visual de
  "ainda não implementado".
- `Json`, `JwtService` e `ApiAuthFilter` são só a casca da classe (assinaturas + comentários
  `TODO`), sem usar nenhuma biblioteca nova.
- **Nenhuma dependência foi adicionada ao `pom.xml`** (Jackson, java-jwt). Isso é proposital:
  o pedido foi só o esboço; adicionar as libs é parte da implementação (pré-requisito listado
  na seção 3.3 da análise).
- Nenhuma alteração em `web.xml`, `DatabaseConnection`, DAOs existentes ou classes de modelo.

### Validação feita

- `javac --release 21` dos arquivos novos (com o `jakarta.servlet-api-6.1.0.jar` do repositório
  Maven local no classpath): compila sem erros.
- **Não foi possível rodar `mvn compile` no projeto completo neste ambiente**: o `pom.xml`
  exige `maven.compiler.source/target = 25`, e o JDK disponível aqui é o 21. Essa limitação é
  do ambiente e já existia antes desta mudança (não foi introduzida por ela).

## O que falta fazer

1. **Pré-requisitos do backend** (seção 2.3/3.2 da análise), antes de implementar qualquer rota:
   - Corrigir a compilação do backend (visibilidade de `ClienteRepository`/`LavaRapidoRepository`).
   - Resolver a rota `/cadastro` duplicada (`Cadastro.java` vs `CadastroClienteServlet.java`).
   - Escolher uma única camada de dados (migrar de `LavaRapidoRepository` para os DAOs).
   - Adicionar `autenticarClientePorCpf(cpf, senha)` (login do app é por CPF, não e-mail).
2. **Dependências no `pom.xml`:** `jackson-databind`, `jackson-datatype-jsr310`, `java-jwt` (com.auth0).
3. **Implementar `Json`** com um `ObjectMapper` único (JavaTimeModule, sem `WRITE_DATES_AS_TIMESTAMPS`).
4. **Implementar `JwtService`** (assinatura HMAC, segredo em `JWT_SECRET` via dotenv-java) e
   **`ApiAuthFilter`** (extrair/validar o Bearer token, liberar `/auth/*` e `GET /servicos`,
   setar `idCliente` no request, responder 401 quando inválido).
5. **Implementar cada servlet de `v1/`** ligando aos DAOs existentes (`DAOCliente`, `DAOServico`,
   `DAOVeiculo`, `DAOAgendamento`), com o mapeamento de erros da seção 3.6 da análise
   (`IllegalArgumentException` → 400, token ausente/invalido → 401, recurso de outro cliente → 404,
   `SQLIntegrityConstraintViolationException` → 409, `IllegalStateException` → 422, `SQLException` → 500).
6. **`GET /api/v1/horarios`**: implementar o cálculo de horários livres (corrige o erro E6 do app:
   hoje não há validação de horário de funcionamento nem de conflito).
7. Testar as rotas implementadas com `curl`/Postman e documentar em `miscelaneous/openapi.yml`.
8. Só depois disso: mudanças no app Flutter (seção 3.7) e infraestrutura/Docker (seção 3.8).
