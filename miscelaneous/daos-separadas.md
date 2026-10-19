# DAOs separadas

Data: 2026-10-17

Status: **executado (parcial)**. Os métodos de `LavaRapidoRepository` foram separados nas DAOs, conforme
`separacao-daos.md`. Os servlets ainda **não** foram alterados, por isso os servlets antigos não compilam.
Os pacotes `db` e `model` compilam sem erros.

---

## 1. O que mudou

| Arquivo | Mudança |
|---|---|
| `db/DAOVeiculo.java` | Era um stub vazio. Recebeu as operações da tabela `veiculo`. |
| `db/DAOServico.java` | Arquivo novo. Recebeu as operações da tabela `servico`. |
| `db/DAOColaborador.java` | Era um stub vazio. Recebeu as operações da tabela `colaborador` (com a mudança 6.3). |
| `db/DAOAgendamento.java` | Era um stub vazio. Recebeu as operações da tabela `agendamento` e as transações que partem dela. |
| `db/DAOAtendimento.java` | Era um stub vazio. Recebeu as operações da tabela `atendimento` (com a mudança 6.4). |
| `db/DAOPagamento.java` | Era um stub vazio. Recebeu as operações da tabela `pagamento`. |
| `db/DAOCliente.java` | Recebeu `autenticar`. Os métodos que já existiam não mudaram. |
| `db/LavaRapidoRepository.java` | Perdeu os métodos movidos. Ficaram os records, `cadastrarCliente` e `autenticarCliente`. |

Não foram alterados: `ClienteRepository`, `Passwords`, `DatabaseConnection`, os servlets e as JSPs.
As DTOs (`model.dto`) ainda não existem.

### 1.1 Organização interna das DAOs

Cada DAO segue o padrão de `DAOCliente`: os métodos ficam agrupados em seções que indicam a parte do CRUD.

```java
/*--------------------------------------
Listagem de veículos
--------------------------------------*/
```

As seções são **Listagem**, **Inserção**, **Update** e **Remoção**. Quando uma operação ainda não existe, a seção
fica no arquivo apenas com um comentário. Exemplo: `// Nenhuma operação de update de veículo ainda`. Nenhuma
operação nova foi criada nesta etapa.

### 1.2 Records temporários

> **Atualização (2026-10-18):** os records viraram as DTOs de `model.dto` (`*View`). Ver `dtos-criadas.md`.

Como as DTOs ainda não existem, as DAOs devolvem os records que continuam dentro de `LavaRapidoRepository`
(`Cliente`, `Veiculo`, `Servico`, `Agendamento`, `Colaborador`, `Atendimento`, `Pagamento`). Cada DAO importa o
record que usa:

```java
import com.splash.web.db.LavaRapidoRepository.Veiculo;
```

Em `DAOCliente` o record é escrito com o nome completo (`LavaRapidoRepository.Cliente`), porque o nome `Cliente`
já é usado por `com.splash.web.model.Cliente`.

Quando as DTOs forem criadas, basta trocar esse import por `com.splash.web.model.dto.VeiculoView` (e o tipo de
retorno). Os getters dos records são os mesmos das futuras DTOs, então as JSPs não mudam.

### 1.3 O que ficou em `LavaRapidoRepository`

- Os 7 records (até a criação das DTOs).
- `cadastrarCliente`: sem alteração. Será unido a `DAOCliente.insertUsuario` na mudança 6.1.
- `autenticarCliente`: agora só chama `new DAOCliente().autenticar(email, senha)`.

Esses dois métodos ficaram porque `ClienteRepository` depende deles. O arquivo será apagado depois que os servlets
usarem as DAOs (passo 11 de `separacao-daos.md`).

### 1.4 Mudanças de lógica aplicadas

- **6.3 (`DAOColaborador.criarAdministradorInicial`)**: a verificação de administrador agora roda na mesma conexão
  que segura o `GET_LOCK`. Para isso existe um `private boolean existeAdministrador(Connection)`, usado pelo
  `public boolean existeAdministrador()`.
- **6.4 (`DAOAtendimento.atualizar`)**: `transicaoPermitida` foi apagado. A regra agora usa
  `StatusAtendimento.podeIrPara`, e manter o mesmo status continua permitido (o admin usa isso para trocar só os
  colaboradores). Um status inválido lança `IllegalArgumentException` em `StatusAtendimento.valueOf`, com a
  mensagem padrão do Java.

---

## 2. O que cada DAO faz

Todas as DAOs ficam em `com.splash.web.db`, têm métodos `public` de instância e abrem a conexão com
`DatabaseConnection.getConnection()`. Todas propagam `SQLException`.

### 2.1 `DAOCliente` — tabela `cliente`

| Método | Retorno | O que faz |
|---|---|---|
| `getUsuarios()` | `List<model.Cliente>` | Lista todos os clientes. |
| `getusuario(int id)` | `model.Cliente` | Busca um cliente. Lança `IllegalArgumentException` se o id não existir. |
| `getUsuariosVeiculo()` | `List<model.Cliente>` | Lista os clientes que têm veículo, com os veículos carregados. |
| `getUsuarioveiculo(int id)` | `model.Cliente` | Busca um cliente com os veículos dele. |
| `autenticar(String email, String senha)` | `LavaRapidoRepository.Cliente` | Confere e-mail e senha (BCrypt). Retorna `null` se não conferir. **Novo.** |
| `insertUsuario(model.Cliente cliente)` | `void` | Insere o cliente. Grava `getSenhaHash()` como está, então o hash precisa ser gerado antes. |
| `updateUsuarios(Integer id, String nome, String telefone, String email)` | `void` | Atualiza só os campos preenchidos. |
| `deleteusuario(int id)` / `deleteusuariosTotal(int id)` | `void` | Remove o cliente (os dois fazem o mesmo `DELETE`). |

### 2.2 `DAOVeiculo` — tabela `veiculo`

| Método | Retorno | O que faz | Origem |
|---|---|---|---|
| `listarPorCliente(int idCliente)` | `List<Veiculo>` | Lista os veículos do cliente, ordenados pela placa. | `listarVeiculos` |
| `inserir(int idCliente, String placa, String marca, String modelo, String cor)` | `void` | Insere o veículo. Placa em maiúsculas; cor vazia vira `NULL`. | `adicionarVeiculo` |
| `remover(int idCliente, int idVeiculo)` | `boolean` | Remove o veículo só se ele pertencer ao cliente. `false` se nada foi removido. | `removerVeiculo` |

Update: ainda não existe.

### 2.3 `DAOServico` — tabela `servico`

| Método | Retorno | O que faz | Origem |
|---|---|---|---|
| `listar()` | `List<Servico>` | Lista todos os serviços, ordenados pelo nome. | `listarServicos` |
| `salvar(Integer idServico, String nome, String descricao, BigDecimal preco)` | `void` | `idServico == null` faz INSERT; caso contrário faz UPDATE. Lança `SQLException` se o UPDATE não encontrar o serviço. | `salvarServico` |
| `remover(int idServico)` | `boolean` | Remove o serviço. `false` se ele não existir. | `removerServico` |

### 2.4 `DAOColaborador` — tabela `colaborador`

| Método | Retorno | O que faz | Origem |
|---|---|---|---|
| `listar()` | `List<Colaborador>` | Lista os colaboradores, ordenados pelo nome. | `listarColaboradores` |
| `autenticar(String email, String senha)` | `Colaborador` | Confere e-mail e senha. Retorna `null` se não conferir. | `autenticarColaborador` |
| `existeAdministrador()` | `boolean` | Indica se já existe um colaborador `ADMINISTRADOR`. | `existeAdministrador` |
| `inserir(String nome, String cargo, String nivelAcesso, String email, String senha)` | `void` | Insere o colaborador. Recebe a senha pura e gera o hash. | `cadastrarColaborador` |
| `criarAdministradorInicial(String nome, String cargo, String email, String senha)` | `void` | Cria o primeiro administrador com um lock no MySQL. Lança `IllegalStateException` se já existir um. | `criarAdministradorInicial` |

Update e remoção: ainda não existem.

### 2.5 `DAOAgendamento` — tabela `agendamento`

| Método | Retorno | O que faz | Origem |
|---|---|---|---|
| `listarPorCliente(int idCliente)` | `List<Agendamento>` | Lista os agendamentos do cliente com veículo, total e situação do pagamento. | `listarAgendamentosCliente` |
| `criar(int idCliente, int idVeiculo, LocalDate data, String horario, List<Integer> idsServicos)` | `void` | Transação: confere o veículo, lê os preços, grava `agendamento`, `agendamento_servico`, `atendimento` e `pagamento`. | `criarAgendamento` |
| `cancelar(int idCliente, int idAgendamento)` | `boolean` | Transação: cancela o agendamento (só se `AGENDADO`) e o pagamento pendente. `false` se não foi possível cancelar. | `cancelarAgendamento` |

`criar` lança `IllegalArgumentException` quando a lista de serviços está vazia ou repetida, quando o veículo não é
do cliente ou quando um serviço não existe. Em qualquer erro a transação é desfeita (`rollback`).

Remoção: ainda não existe. `cancelar` fica na seção de update, porque só troca o status.

### 2.6 `DAOAtendimento` — tabela `atendimento`

| Método | Retorno | O que faz | Origem |
|---|---|---|---|
| `listar()` | `List<Atendimento>` | Lista os atendimentos com cliente, placa e colaboradores (nomes e ids concatenados). | `listarAtendimentos` |
| `atualizar(int idAtendimento, String status, List<Integer> idsColaboradores)` | `void` | Transação: confere a transição de status, atualiza o atendimento (datas de início e fim), conclui o agendamento quando `FINALIZADO`/`ENTREGUE` e regrava os colaboradores. | `atualizarAtendimento` |

`atualizar` lança `IllegalArgumentException` quando o atendimento não existe, quando o agendamento está cancelado
ou quando a transição não é permitida.

Inserção: o atendimento é criado por `DAOAgendamento.criar`. Remoção: ainda não existe.

### 2.7 `DAOPagamento` — tabela `pagamento`

| Método | Retorno | O que faz | Origem |
|---|---|---|---|
| `listar()` | `List<Pagamento>` | Lista os pagamentos com cliente, placa, data e horário do agendamento. | `listarPagamentos` |
| `atualizar(int idPagamento, String status, String forma)` | `void` | Atualiza o status. Quando `PAGO`, grava a forma e a data do pagamento. Lança `IllegalArgumentException` se o pagamento não existir ou estiver cancelado. | `atualizarPagamento` |

Inserção: o pagamento é criado por `DAOAgendamento.criar`. Remoção: ainda não existe (cancelar o agendamento
cancela o pagamento).

---

## 3. Como usar as DAOs nos servlets

### 3.1 Padrão

O servlet cria a DAO como variável local e chama o método de instância. Esse é o mesmo padrão de `EditarCadastro`
com `DAOCliente`.

```java
import com.splash.web.db.DAOVeiculo;

DAOVeiculo daoVeiculo = new DAOVeiculo();
request.setAttribute("veiculos", daoVeiculo.listarPorCliente(clienteId));
```

Para usar o tipo devolvido pela DAO no servlet (DTO de `model.dto`):

```java
import com.splash.web.model.dto.ColaboradorView;

ColaboradorView colaborador = new DAOColaborador().autenticar(email, senha);
```

### 3.2 Tratamento de erros

| Exceção | Significado | Resposta do servlet |
|---|---|---|
| `IllegalArgumentException` | Validação ou regra de negócio (mensagem pronta para o usuário). | 400, mostra `getMessage()`. |
| `IllegalStateException` | Só em `criarAdministradorInicial`: a configuração já foi feita. | 410 (`SC_GONE`), como `SetupAdminServlet` já faz. |
| `SQLException` com SQLState `23xxx` | Violação de chave única ou estrangeira (ex.: placa ou e-mail repetido). | 409. |
| Outra `SQLException` | Falha de banco. | `WebSupport.erroBanco(request, response, exception)` (500). |

Métodos que retornam `boolean` (`remover`, `cancelar`) não lançam exceção quando nada foi alterado. O servlet confere
o retorno, como `AgendamentoServlet` já faz com o cancelamento.

### 3.3 Troca de chamadas por servlet

Os redirecionamentos e os nomes dos atributos (`request.setAttribute(...)`) não mudam. Em cada servlet, remova
`import com.splash.web.db.LavaRapidoRepository;` (quando não houver mais uso do tipo do record) e importe as DAOs.

| Servlet | Chamada atual | Chamada nova |
|---|---|---|
| `VeiculoServlet` | `LavaRapidoRepository.listarVeiculos(id)` | `new DAOVeiculo().listarPorCliente(id)` |
| | `LavaRapidoRepository.adicionarVeiculo(...)` | `new DAOVeiculo().inserir(...)` |
| | `LavaRapidoRepository.removerVeiculo(idCliente, idVeiculo)` | `new DAOVeiculo().remover(idCliente, idVeiculo)` |
| `AgendamentoServlet` | `listarVeiculos(id)` | `new DAOVeiculo().listarPorCliente(id)` |
| | `listarServicos()` | `new DAOServico().listar()` |
| | `listarAgendamentosCliente(id)` | `new DAOAgendamento().listarPorCliente(id)` |
| | `criarAgendamento(...)` | `new DAOAgendamento().criar(...)` |
| | `cancelarAgendamento(idCliente, id)` | `new DAOAgendamento().cancelar(idCliente, id)` |
| `AdminServlet` | `listarServicos()` / `salvarServico(...)` / `removerServico(id)` | `DAOServico.listar()` / `salvar(...)` / `remover(id)` |
| | `listarColaboradores()` / `cadastrarColaborador(...)` | `DAOColaborador.listar()` / `inserir(...)` |
| | `listarAtendimentos()` / `atualizarAtendimento(...)` | `DAOAtendimento.listar()` / `atualizar(...)` |
| | `listarPagamentos()` / `atualizarPagamento(...)` | `DAOPagamento.listar()` / `atualizar(...)` |
| `ColaboradorLoginServlet` | `autenticarColaborador(email, senha)` | `new DAOColaborador().autenticar(email, senha)` |
| `SetupAdminServlet` | `existeAdministrador()` / `criarAdministradorInicial(...)` | mesmos nomes em `new DAOColaborador()` |
| `LoginServlet` | `ClienteRepository.autenticar(email, senha)` | `new DAOCliente().autenticar(email, senha)` |
| `CadastroClienteServlet` | `ClienteRepository.cadastrar(...)` | Fica para a mudança 6.1 (montar `Cliente` com `Passwords.hash` e chamar `insertUsuario`). |

Quando um servlet usa várias operações da mesma DAO (como `AdminServlet`), crie uma variável para cada DAO no
início do método e reutilize:

```java
DAOServico daoServico = new DAOServico();
DAOColaborador daoColaborador = new DAOColaborador();
request.setAttribute("servicos", daoServico.listar());
request.setAttribute("colaboradores", daoColaborador.listar());
```

### 3.4 Exemplo completo (`VeiculoServlet.doGet`)

```java
int clienteId = WebSupport.clienteId(request, response);
if (clienteId < 0) {
    return;
}
try {
    DAOVeiculo daoVeiculo = new DAOVeiculo();
    request.setAttribute("veiculos", daoVeiculo.listarPorCliente(clienteId));
    request.getRequestDispatcher("/veiculos.jsp").forward(request, response); // caminho sem mudança nesta etapa
} catch (SQLException exception) {
    WebSupport.erroBanco(request, response, exception);
}
```

### 3.5 Testes

As DAOs podem ser testadas como `DAOClienteTest`: `mockStatic(DatabaseConnection.class)` devolve uma `Connection`
falsa, então nenhum banco real é usado. Como os servlets criam a DAO com `new`, um teste de servlet pode trocar a
DAO usando `mockConstruction(DAOVeiculo.class)` do Mockito.

---

## 4. Próximos passos

Seguem a ordem de `separacao-daos.md`, seção 8:

1. ~~Criar as DTOs em `model.dto` e trocar os imports dos records nas DAOs.~~ Feito em 2026-10-18 (`dtos-criadas.md`).
2. ~~Mover `Passwords` para `security/`.~~ Feito em 2026-10-18.
3. ~~Aplicar a mudança 6.1 (unir `cadastrarCliente` com `insertUsuario`).~~ Feito em 2026-10-18.
4. ~~Trocar as chamadas dos servlets (seção 3.3 deste arquivo).~~ Feito em 2026-10-18.
5. ~~Apagar `LavaRapidoRepository` e `ClienteRepository`.~~ Feito em 2026-10-18.
6. Escrever os testes das novas DAOs.

> **Atualização (2026-10-18):** os passos 2 a 5 estão registrados em `repositorios-removidos-e-cadastro-unico.md`,
> junto com a correção dos forwards para `WEB-INF/views` e o cadastro único em `/cadastro`.
