# DTOs criadas em `model.dto`

Data: 2026-10-18

Status: **executado**. É o passo 1 dos próximos passos de `daos-separadas.md` (seção 4) e a seção 4.8 de
`separacao-daos.md`.

---

## 1. O que mudou

| Arquivo | Mudança |
|---|---|
| `model/dto/ClienteView.java` | Novo. Era o record `LavaRapidoRepository.Cliente`. |
| `model/dto/VeiculoView.java` | Novo. Era o record `LavaRapidoRepository.Veiculo`. |
| `model/dto/ServicoView.java` | Novo. Era o record `LavaRapidoRepository.Servico`. |
| `model/dto/AgendamentoView.java` | Novo. Era o record `LavaRapidoRepository.Agendamento`. |
| `model/dto/ColaboradorView.java` | Novo. Era o record `LavaRapidoRepository.Colaborador`. |
| `model/dto/AtendimentoView.java` | Novo. Era o record `LavaRapidoRepository.Atendimento`. |
| `model/dto/PagamentoView.java` | Novo. Era o record `LavaRapidoRepository.Pagamento`. |
| `db/DAOVeiculo`, `DAOServico`, `DAOColaborador`, `DAOAgendamento`, `DAOAtendimento`, `DAOPagamento` | O import `com.splash.web.db.LavaRapidoRepository.X` virou `com.splash.web.model.dto.XView`, e os tipos de retorno/listas foram trocados. O comentário "Record temporário" foi removido. SQL e lógica não mudaram. |
| `db/DAOCliente.java` | `autenticar` devolve `ClienteView` em vez de `LavaRapidoRepository.Cliente`. Como o nome é diferente de `model.Cliente`, não precisa mais do nome completo. |
| `db/ClienteRepository.java` | `autenticar` devolve `ClienteView`. |
| `db/LavaRapidoRepository.java` | Perdeu os 7 records. Ficaram só `cadastrarCliente` e `autenticarCliente` (este devolve `ClienteView`). |

Os campos, a ordem do construtor e os getters de cada DTO são **idênticos** aos do record antigo.

## 2. Por quê

- Os records estavam dentro de `LavaRapidoRepository` só de forma temporária. Enquanto estivessem lá, a classe
  não podia ser apagada e toda DAO dependia do repositório antigo.
- DTO é um objeto só de leitura: carrega o resultado de uma consulta (muitas vezes com JOIN, `SUM` ou
  `GROUP_CONCAT`) até a tela. Ele fica em `model.dto` para não se misturar com os modelos de domínio de `model`,
  que têm validação e regras (ver `dto-vs-modelos.md`).
- O sufixo `View` deixa claro, no código, que o objeto é uma "visão" para a tela e não a entidade.

### Por que os getters `getX()` continuam

O Tomcat 10.1 usa Jakarta EL 5.0, que só lê propriedades no padrão JavaBean (`getNome()`). Os acessores de
record (`nome()`) só são lidos pela EL 6.0 (Tomcat 11). Sem os getters, `${servico.nome}` nas JSPs pararia de
funcionar.

## 3. Como se liga ao resto do projeto

```
Servlet ──► new DAOX().listar...() ──► List<XView> ──► request.setAttribute ──► JSP (${x.campo})
```

- **JSPs:** não mudam. Os nomes das propriedades (`${servico.id}`, `${pagamento.forma}`) são os mesmos.
- **Servlets antigos:** continuam sem compilar (já não compilavam). Quando forem migrados para as DAOs, devem
  importar `com.splash.web.model.dto.XView` no lugar de `LavaRapidoRepository.X`. Exemplo:

```java
import com.splash.web.model.dto.ColaboradorView;

ColaboradorView colaborador = new DAOColaborador().autenticar(email, senha);
```

- **Regras para a separação não degradar** (de `dto-vs-modelos.md`): DTO nunca é parâmetro de um método que grava;
  regra de negócio nunca vai num DTO. O único uso interno de DTO numa escrita é `DAOAgendamento.criar`, que monta
  `ServicoView(id, null, null, preco)` só como par id/preço dentro da transação (já era assim com o record).

## 4. Decisão em aberto

`dto-vs-modelos.md` recomenda manter só 3 DTOs (`AgendamentoView`, `AtendimentoView`, `PagamentoView`) e
trocar `ClienteView`, `ServicoView`, `VeiculoView` e `ColaboradorView` pelos modelos de `model`, depois de criar
um `carregar(...)` neles. Esta etapa seguiu o plano original de 7 DTOs (`separacao-daos.md` 4.8), que é uma
troca direta e não muda o comportamento. A troca dos 4 DTOs simples por modelos continua possível depois.

## 5. Verificação

`mvn compile`: os pacotes `db` e `model` compilam sem erro. Os erros restantes são só dos servlets antigos
(`AdminServlet`, `AgendamentoServlet`, `CadastroClienteServlet`, `ColaboradorLoginServlet`, `LoginServlet`,
`VeiculoServlet`), que ainda usam `LavaRapidoRepository`.
