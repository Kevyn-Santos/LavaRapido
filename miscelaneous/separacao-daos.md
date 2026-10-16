# Separação das DAOs

Data: 2026-10-14

Status: **planejamento**. Nenhum código foi alterado ainda. Este documento diz para onde vai cada parte de
`LavaRapidoRepository`, `ClienteRepository`, `WebSupport` e `Passwords`, quais imports mudam e qual fica o fluxo.

Restrição desta etapa: os redirecionamentos para JSPs e entre servlets **não mudam**. Também não mudam os nomes
das propriedades lidas pelas JSPs (`${servico.id}`, `${pagamento.forma}`, `${atendimento.statusAgendamento}` etc.).

---

## 1. Situação atual

```
servlet (velhos) ──► LavaRapidoRepository (static, package-private) ──► DatabaseConnection
       │                    │  records internos: Cliente, Veiculo, Servico, Agendamento,
       │                    │                    Colaborador, Atendimento, Pagamento
       │                    └─► Passwords (BCrypt)
       ├──► ClienteRepository ──► LavaRapidoRepository   (só repassa a chamada)
       └──► WebSupport (está em db, mas é código HTTP)

servlet (novos) ──► DAOCliente (instância, public) ──► DatabaseConnection
                         └─► model.Cliente
```

Problemas:

- `LavaRapidoRepository` acessa 8 tabelas em um único arquivo.
- Os métodos são package-private (`static void ...`). Os servlets estão em outro pacote e não enxergam nada.
- Os records internos têm os mesmos nomes das classes de `model` (`Cliente`, `Veiculo`...). Um servlet que
  importa os dois tem conflito de nomes.
- `WebSupport` importa `jakarta.servlet`. Código HTTP não pertence à camada de banco.
- `ClienteRepository` não tem lógica própria.

---

## 2. Regras da separação

1. **Uma DAO por tabela principal.** Cada DAO tem só SQL e o mapeamento de `ResultSet` para objeto.
2. **Métodos de instância e `public`**, no mesmo padrão do `DAOCliente`. O servlet cria a DAO como variável local:
   `DAOVeiculo dao = new DAOVeiculo();`. Isso também deixa a DAO mockável nos testes.
3. **Uma transação fica inteira em uma DAO.** Se uma operação grava em várias tabelas dentro de um
   `commit`/`rollback`, ela usa uma única `Connection` e fica na DAO da tabela principal da operação.
   Exemplo: `criarAgendamento` grava em `agendamento`, `agendamento_servico`, `atendimento` e `pagamento`,
   e fica inteira em `DAOAgendamento`.
4. **Os records viram DTOs de consulta**, em `com.splash.web.model.dto`, com sufixo `View`. Os campos e getters
   ficam iguais, então as JSPs continuam funcionando sem alteração.
5. **Validação de formato fica em `model.Validacao`.** Validação de entrada HTTP fica em `WebSupport`.
   Regra de transição de status fica nos enums de `model.enums`.

### Por que DTOs e não as classes de `model` agora

As classes de `model` são entidades com regra de negócio. `Agendamento` exige um `Veiculo`, que exige um
`Cliente`. Já as listagens do admin são linhas de relatório com JOIN: nome do cliente, placa, nomes dos
colaboradores concatenados. Montar a árvore de entidades para cada linha é custoso e mudaria as propriedades
usadas nas JSPs. Nesta etapa os records continuam como estão, só mudam de lugar. A troca por entidades fica para
quando o `model` tiver um `carregar(...)` em cada classe, como `Cliente.carregar` já tem.

---

## 3. Estrutura nova

```
com/splash/web/
├── db/
│   ├── DatabaseConnection.java   (sem mudança)
│   ├── DAOCliente.java           (recebe cadastrarCliente e autenticarCliente)
│   ├── DAOVeiculo.java           (renomeado de DAOVeículo.java, sem acento)
│   ├── DAOServico.java
│   ├── DAOColaborador.java
│   ├── DAOAgendamento.java       (novo)
│   ├── DAOAtendimento.java       (novo)
│   └── DAOPagamento.java         (novo)
├── model/
│   ├── ... (entidades atuais, sem mudança)
│   └── dto/                      (novo pacote)
│       ├── ClienteView.java
│       ├── VeiculoView.java
│       ├── ServicoView.java
│       ├── AgendamentoView.java
│       ├── ColaboradorView.java
│       ├── AtendimentoView.java
│       └── PagamentoView.java
├── security/
│   └── Passwords.java            (movido de db, vira public)
└── servlet/
    └── WebSupport.java           (movido de db)
```

Arquivos apagados no final: `db/LavaRapidoRepository.java`, `db/ClienteRepository.java`, `db/WebSupport.java`,
`db/Passwords.java`, `db/DAOVeículo.java`.

---

## 4. Para onde vai cada método

Tabela principal = tabela que o método altera ou consulta como origem.

### 4.1 `DAOCliente` (tabela `cliente`)

| Origem | Método atual | Método novo em `DAOCliente` | Observação |
|---|---|---|---|
| `LavaRapidoRepository:91` | `static void cadastrarCliente(nome, cpf, telefone, email, senha)` | **Unir com** `public void insertUsuario(Cliente cliente)` | Os dois fazem o mesmo `INSERT`. Ver mudança de lógica 6.1. |
| `LavaRapidoRepository:105` | `static Cliente autenticarCliente(email, senha)` | `public ClienteView autenticar(String email, String senha)` | Usa `Passwords.matches`. |
| `ClienteRepository:10` | `cadastrar(...)` | — | Apagar. Chamadores usam `DAOCliente.insertUsuario`. |
| `ClienteRepository:15` | `autenticar(...)` | — | Apagar. Chamadores usam `DAOCliente.autenticar`. |

Os métodos que já existem em `DAOCliente` (`getUsuarios`, `getusuario`, `getUsuariosVeiculo`, `getUsuarioveiculo`,
`updateUsuarios`, `deleteusuario`, `deleteusuariosTotal`) ficam onde estão. `getUsuariosVeiculo` faz JOIN com
`veiculo`, mas devolve `Cliente` como raiz, então continua em `DAOCliente`.

### 4.2 `DAOVeiculo` (tabela `veiculo`)

| Origem | Método atual | Método novo em `DAOVeiculo` |
|---|---|---|
| `LavaRapidoRepository:137` | `static List<Veiculo> listarVeiculos(int idCliente)` | `public List<VeiculoView> listarPorCliente(int idCliente)` |
| `LavaRapidoRepository:154` | `static void adicionarVeiculo(idCliente, placa, marca, modelo, cor)` | `public void inserir(int idCliente, String placa, String marca, String modelo, String cor)` |
| `LavaRapidoRepository:168` | `static boolean removerVeiculo(idCliente, idVeiculo)` | `public boolean remover(int idCliente, int idVeiculo)` |

### 4.3 `DAOAgendamento` (tabela `servico`)

| Origem | Método atual | Método novo em `DAOAgendamento` |
|---|---|---|
| `LavaRapidoRepository:178` | `static List<Servico> listarServicos()` | `public List<ServicoView> listar()` |
| `LavaRapidoRepository:192` | `static void salvarServico(Integer idServico, nome, descricao, preco)` | `public void salvar(Integer idServico, String nome, String descricao, BigDecimal preco)` |
| `LavaRapidoRepository:212` | `static boolean removerServico(int idServico)` | `public boolean remover(int idServico)` |

`salvar` pode continuar fazendo INSERT ou UPDATE conforme `idServico` ser nulo. Quando o negócio crescer,
separe em `inserir` e `atualizar`.

### 4.4 `DAOColaborador` (tabela `colaborador`)

| Origem | Método atual | Método novo em `DAOColaborador` | Observação |
|---|---|---|---|
| `LavaRapidoRepository:120` | `static Colaborador autenticarColaborador(email, senha)` | `public ColaboradorView autenticar(String email, String senha)` | |
| `LavaRapidoRepository:365` | `static void cadastrarColaborador(nome, cargo, nivelAcesso, email, senha)` | `public void inserir(String nome, String cargo, String nivelAcesso, String email, String senha)` | |
| `LavaRapidoRepository:380` | `static List<Colaborador> listarColaboradores()` | `public List<ColaboradorView> listar()` | |
| `LavaRapidoRepository:544` | `static boolean existeAdministrador()` | `public boolean existeAdministrador()` + `private boolean existeAdministrador(Connection)` | Ver 6.3. |
| `LavaRapidoRepository:553` | `static void criarAdministradorInicial(nome, cargo, email, senha)` | `public void criarAdministradorInicial(...)` | Ver 6.3. |

### 4.5 `DAOAgendamento` (tabela `agendamento`) — novo

| Origem | Método atual | Método novo em `DAOAgendamento` | Tabelas tocadas |
|---|---|---|---|
| `LavaRapidoRepository:221` | `static void criarAgendamento(idCliente, idVeiculo, data, horario, idsServicos)` | `public void criar(...)` (mesmos parâmetros) | `veiculo` (leitura), `servico` (leitura), `agendamento`, `agendamento_servico`, `atendimento`, `pagamento` |
| `LavaRapidoRepository:308` | `static List<Agendamento> listarAgendamentosCliente(int idCliente)` | `public List<AgendamentoView> listarPorCliente(int idCliente)` | leitura com JOIN |
| `LavaRapidoRepository:333` | `static boolean cancelarAgendamento(idCliente, idAgendamento)` | `public boolean cancelar(int idCliente, int idAgendamento)` | `agendamento`, `pagamento` |

`criar` e `cancelar` são transações. Por isso ficam inteiras aqui, mesmo gravando em outras tabelas (regra 3).

### 4.6 `DAOAtendimento` (tabela `atendimento`) — novo

| Origem | Método atual | Método novo em `DAOAtendimento` | Observação |
|---|---|---|---|
| `LavaRapidoRepository:396` | `static List<Atendimento> listarAtendimentos()` | `public List<AtendimentoView> listar()` | |
| `LavaRapidoRepository:423` | `static void atualizarAtendimento(idAtendimento, status, idsColaboradores)` | `public void atualizar(int idAtendimento, String status, List<Integer> idsColaboradores)` | Transação: `atendimento`, `agendamento`, `colaborador_atendimento`. |
| `LavaRapidoRepository:493` | `private static boolean transicaoPermitida(atual, proximo)` | — | Apagar. Usar `StatusAtendimento.podeIrPara`. Ver 6.4. |

### 4.7 `DAOPagamento` (tabela `pagamento`) — novo

| Origem | Método atual | Método novo em `DAOPagamento` |
|---|---|---|
| `LavaRapidoRepository:503` | `static List<Pagamento> listarPagamentos()` | `public List<PagamentoView> listar()` |
| `LavaRapidoRepository:526` | `static void atualizarPagamento(idPagamento, status, forma)` | `public void atualizar(int idPagamento, String status, String forma)` |

### 4.8 Records para `model.dto`

Cada record vira um arquivo `public record` em `com.splash.web.model.dto`. Os campos e getters ficam iguais.

| Record atual (`LavaRapidoRepository`) | Arquivo novo | Usado por |
|---|---|---|
| `Cliente` (linha 18) | `ClienteView.java` | `DAOCliente.autenticar`, `LoginServlet` |
| `Veiculo` (linha 24) | `VeiculoView.java` | `DAOVeiculo`, `VeiculoServlet`, `AgendamentoServlet` |
| `Servico` (linha 32) | `ServicoView.java` | `DAOAgendamento`, `DAOAgendamento.criar` (uso interno), `AdminServlet`, `AgendamentoServlet` |
| `Agendamento` (linha 39) | `AgendamentoView.java` | `DAOAgendamento`, `AgendamentoServlet` |
| `Colaborador` (linha 52) | `ColaboradorView.java` | `DAOColaborador`, `ColaboradorLoginServlet`, `AdminServlet` |
| `Atendimento` (linha 60) | `AtendimentoView.java` | `DAOAtendimento`, `AdminServlet` |
| `Pagamento` (linha 75) | `PagamentoView.java` | `DAOPagamento`, `AdminServlet` |

### 4.9 `WebSupport`

`WebSupport` vai para `com.splash.web.servlet`, o mesmo pacote dos servlets. Assim ele pode continuar
package-private e os servlets usam sem import.

| Método | Destino | Observação |
|---|---|---|
| `clienteId(request, response)` | `servlet.WebSupport` | Sem mudança. |
| `colaboradorId(request, response, nivelMinimo)` | `servlet.WebSupport` | Ver 6.5. |
| `erroBanco(request, response, exception)` | `servlet.WebSupport` | O forward para `/erro.jsp` está quebrado (a JSP está em `WEB-INF/views`), mas fica como está nesta etapa. |
| `campo(request, nome)` | `servlet.WebSupport` | Sem mudança. |
| `inteiro(valor)` | `servlet.WebSupport` | Sem mudança. |
| `preenchidos(valores...)` | `servlet.WebSupport` | Sem mudança. |
| `nivel(valor)` (private) | Apagar | Ver 6.5. |

Nenhum método de `WebSupport` vai para uma DAO. Todos dependem de `HttpServletRequest` ou validam entrada HTTP.

### 4.10 `Passwords`

Vai para `com.splash.web.security.Passwords`, com classe e métodos `public`. É usado por `DAOCliente`,
`DAOColaborador` e pelo servlet de cadastro (ver 6.1). Hash de senha não é responsabilidade da camada de banco.

---

## 5. Imports novos

### 5.1 DAOs

Todas as DAOs estão no pacote `com.splash.web.db`, o mesmo de `DatabaseConnection`. Por isso não importam a conexão.

| Arquivo | Imports do projeto | Imports `java.*` |
|---|---|---|
| `DAOCliente` | `com.splash.web.model.Cliente`, `com.splash.web.model.dto.ClienteView`, `com.splash.web.security.Passwords` | sem mudança |
| `DAOVeiculo` | `com.splash.web.model.dto.VeiculoView` | `java.sql.Connection`, `PreparedStatement`, `ResultSet`, `SQLException`, `java.util.ArrayList`, `List` |
| `DAOAgendamento` | `com.splash.web.model.dto.ServicoView` | os de `DAOVeiculo` + `java.math.BigDecimal` |
| `DAOColaborador` | `com.splash.web.model.dto.ColaboradorView`, `com.splash.web.security.Passwords` | os de `DAOVeiculo` |
| `DAOAgendamento` | `com.splash.web.model.dto.AgendamentoView` | os de `DAOVeiculo` + `java.math.BigDecimal`, `java.sql.Date`, `java.sql.Statement`, `java.time.LocalDate`, `java.util.LinkedHashMap`, `java.util.LinkedHashSet`, `java.util.Map`, `java.util.Set` |
| `DAOAtendimento` | `com.splash.web.model.dto.AtendimentoView`, `com.splash.web.model.enums.StatusAtendimento` | os de `DAOVeiculo` + `java.util.LinkedHashSet` |
| `DAOPagamento` | `com.splash.web.model.dto.PagamentoView` | os de `DAOVeiculo` + `java.sql.Date` |

### 5.2 Servlets

Em todos os servlets abaixo, **remova** `import com.example.WebSupport;`, `import com.example.ClienteRepository;`
e `import com.splash.web.db.LavaRapidoRepository;`. `WebSupport` passa a estar no mesmo pacote e não precisa de import.

| Servlet | Imports novos | Chamadas que mudam |
|---|---|---|
| `AdminServlet` | `com.splash.web.db.DAOAgendamento`, `DAOColaborador`, `DAOAtendimento`, `DAOPagamento` | `LavaRapidoRepository.listarServicos()` → `new DAOServico().listar()`; `listarColaboradores()` → `new DAOColaborador().listar()`; `listarAtendimentos()` → `new DAOAtendimento().listar()`; `listarPagamentos()` → `new DAOPagamento().listar()`; `removerServico` → `DAOServico.remover`; `salvarServico` → `DAOServico.salvar`; `cadastrarColaborador` → `DAOColaborador.inserir`; `atualizarAtendimento` → `DAOAtendimento.atualizar`; `atualizarPagamento` → `DAOPagamento.atualizar` |
| `AgendamentoServlet` | `com.splash.web.db.DAOAgendamento`, `DAOVeiculo`, `DAOAgendamento` | `listarVeiculos` → `DAOVeiculo.listarPorCliente`; `listarServicos` → `DAOServico.listar`; `listarAgendamentosCliente` → `DAOAgendamento.listarPorCliente`; `criarAgendamento` → `DAOAgendamento.criar`; `cancelarAgendamento` → `DAOAgendamento.cancelar` |
| `VeiculoServlet` | `com.splash.web.db.DAOVeiculo` | `listarVeiculos` → `listarPorCliente`; `adicionarVeiculo` → `inserir`; `removerVeiculo` → `remover` |
| `LoginServlet` | `com.splash.web.db.DAOCliente`, `com.splash.web.model.dto.ClienteView` | `ClienteRepository.autenticar` → `new DAOCliente().autenticar`; tipo `LavaRapidoRepository.Cliente` → `ClienteView` |
| `ColaboradorLoginServlet` | `com.splash.web.db.DAOColaborador`, `com.splash.web.model.dto.ColaboradorView` | `autenticarColaborador` → `DAOColaborador.autenticar`; tipo `LavaRapidoRepository.Colaborador` → `ColaboradorView` |
| `SetupAdminServlet` | `com.splash.web.db.DAOColaborador` | `existeAdministrador` e `criarAdministradorInicial` → mesmos nomes em `DAOColaborador` |
| `CadastroClienteServlet` | `com.splash.web.db.DAOCliente`, `com.splash.web.model.Cliente`, `com.splash.web.security.Passwords` | `ClienteRepository.cadastrar(...)` → monta `Cliente` e chama `DAOCliente.insertUsuario`. Ver 6.1 e 6.2. |
| `Cadastro` | `com.splash.web.security.Passwords` | `cliente.setSenhaHash(senha)` → `cliente.setSenhaHash(Passwords.hash(senha))`. Ver 6.1. |

Os servlets novos (`ConsultarCadastro`, `EditarCadastro`, `DeletarCadastro`, `Listar*`, `MostrarCadastros`) não mudam.

---

## 6. Pequenas mudanças de lógica

### 6.1 Senha gravada sem hash (bug de segurança)

`Cadastro.java:31` faz `cliente.setSenhaHash(request.getParameter("senha"))`. A senha pura vai para a coluna
`senha_hash`. Consequências:

- A senha fica legível para quem tiver acesso ao banco.
- O login quebra: `Passwords.matches` chama `BCrypt.checkpw`, que lança `IllegalArgumentException` quando o
  valor gravado não é um hash BCrypt.

Correção: o servlet gera o hash antes de montar o `Cliente`.

```java
cliente.setSenhaHash(Passwords.hash(request.getParameter("senha")));
```

Com isso, `cadastrarCliente` do repositório deixa de ser necessário: `insertUsuario(Cliente)` grava o hash
recebido. A normalização que `cadastrarCliente` fazia (`trim`, e-mail em minúsculas) já é feita pelos setters
de `Cliente`, que passam por `Validacao`.

Clientes já cadastrados por `Cadastro` com senha pura precisam ser apagados ou ter a senha redefinida.

Dois cuidados ao unir os cadastros:

- `Cliente.setCPF` só atribui o valor, sem chamar `Validacao.cpf`. O construtor completo valida, mas o setter não.
  Hoje um CPF com máscara (`123.456.789-00`) entra no banco como foi digitado. Troque o corpo do setter por
  `this.cpf = Validacao.cpf(cpf);`.
- `CadastroClienteServlet` exige senha com ao menos 8 caracteres e `Cadastro` não exige nada. O tamanho mínimo
  precisa ser conferido **antes** do hash, porque o hash BCrypt sempre tem 60 caracteres.

### 6.2 Rota `/cadastro` duplicada

`Cadastro` e `CadastroClienteServlet` usam `@WebServlet("/cadastro")`, e o Tomcat recusa o deploy. Mudar a rota
é mexer em roteamento, que está fora desta etapa. Mesmo assim, as duas classes devem usar o mesmo
`DAOCliente.insertUsuario`, para que a escolha da rota depois seja só apagar uma delas.

### 6.3 `criarAdministradorInicial` usa duas conexões

Hoje o método pega um `GET_LOCK` na conexão A e chama `existeAdministrador()`, que abre uma conexão B. O lock do
MySQL vale por conexão, então a verificação deve rodar na mesma conexão que segura o lock.

```java
public boolean existeAdministrador() throws SQLException {
    try (Connection connection = DatabaseConnection.getConnection()) {
        return existeAdministrador(connection);
    }
}

private boolean existeAdministrador(Connection connection) throws SQLException {
    String sql = "SELECT 1 FROM colaborador WHERE nivel_acesso = 'ADMINISTRADOR' LIMIT 1";
    try (PreparedStatement statement = connection.prepareStatement(sql);
         ResultSet result = statement.executeQuery()) {
        return result.next();
    }
}
```

Dentro de `criarAdministradorInicial`, troque `existeAdministrador()` por `existeAdministrador(connection)`.

### 6.4 Transição de status do atendimento

`transicaoPermitida` duplica a regra de `StatusAtendimento.podeIrPara`, com uma diferença: a versão do
repositório aceita manter o mesmo status (`AGUARDANDO` → `AGUARDANDO`). O admin usa isso para trocar só os
colaboradores. Para manter esse comportamento:

```java
StatusAtendimento atual = StatusAtendimento.valueOf(result.getString("status"));
StatusAtendimento proximo = StatusAtendimento.valueOf(status);
if (atual != proximo && !atual.podeIrPara(proximo)) { ... }
```

`StatusAtendimento.valueOf` lança `IllegalArgumentException` para status inválido. O servlet já trata essa exceção.

### 6.5 Nível de acesso

`WebSupport.nivel` converte texto em número com um `switch`. Isso duplica o enum `NivelAcesso`. Opção sem mudar a
sessão (que guarda `nivelAcesso` como `String`): dar um peso ao enum.

```java
public enum NivelAcesso {
    OPERACIONAL(1), ATENDENTE(2), ADMINISTRADOR(3);
    private final int peso;
    NivelAcesso(int peso) { this.peso = peso; }
    public boolean atende(NivelAcesso minimo) { return peso >= minimo.peso; }
}
```

Em `colaboradorId`, `nivel(nivelAcesso) >= nivel(nivelMinimo)` vira
`NivelAcesso.valueOf(nivelAcesso).atende(NivelAcesso.valueOf(nivelMinimo))`.

Esta mudança é opcional. Se ficar para depois, mova `nivel` junto com `WebSupport` sem alteração.

### 6.6 `DAOCliente.deleteusuario` (opcional)

O `catch (RuntimeException e) { throw new RuntimeException(e); }` só embrulha a exceção de novo e não trata nada.
Pode ser removido. `deleteusuario` e `deleteusuariosTotal` executam o mesmo SQL, então um deles pode ser apagado.

---

## 7. Fluxo novo

```
Requisição HTTP
   │
   ▼
EncodingFilter (UTF-8)
   │
   ▼
Servlet (com.splash.web.servlet)
   ├── WebSupport.campo / inteiro / preenchidos   lê e confere a entrada
   ├── WebSupport.clienteId / colaboradorId       confere a sessão e o nível de acesso
   ├── model.Validacao (via setters de model)      confere o formato (CPF, e-mail, placa)
   ├── security.Passwords.hash                     só no cadastro de cliente
   │
   ▼
DAO (com.splash.web.db) ── uma por tabela principal
   ├── DatabaseConnection.getConnection()          LOCAL ou PROD, conforme ENV_DEV
   ├── SQL + transação (quando houver)
   ├── security.Passwords.matches                  só em autenticar
   └── devolve model.* (CRUD de cliente) ou model.dto.*View (listagens e login)
   │
   ▼
Servlet põe o resultado em request/session
   │
   ▼
forward/redirect para a JSP (sem mudança nesta etapa)
```

Em caso de erro:

- `IllegalArgumentException` vem de validação ou regra de negócio. O servlet responde 400 com a mensagem.
- `SQLException` com SQLState `23xxx` é violação de chave única ou estrangeira. O servlet responde 409.
- Outra `SQLException` é falha de banco. O servlet chama `WebSupport.erroBanco` e responde 500.

---

## 8. Ordem de execução

Cada passo deve terminar compilando os pacotes `db` e `model`.

1. Criar `model/dto/` com os 7 records.
2. Mover `Passwords` para `security/` e deixar `public`.
3. Renomear `DAOVeículo.java` para `DAOVeiculo.java`.
4. Preencher `DAOVeiculo`, `DAOAgendamento` e `DAOPagamento`. São leituras simples e servem de modelo para as outras DAOs.
5. Preencher `DAOColaborador`, com a mudança 6.3.
6. Criar `DAOAtendimento`, com a mudança 6.4.
7. Criar `DAOAgendamento`.
8. Adicionar `autenticar` ao `DAOCliente` e aplicar 6.1 em `Cadastro`.
9. Mover `WebSupport` para `servlet/`.
10. Atualizar imports e chamadas dos servlets (seção 5.2). Neste ponto `mvn compile` deve passar, exceto pela
    rota `/cadastro` duplicada, que só aparece no deploy.
11. Apagar `LavaRapidoRepository` e `ClienteRepository`.
12. Rodar `mvn test` e escrever testes das DAOs novas no padrão do `DAOClienteTest`.
