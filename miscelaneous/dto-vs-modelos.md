# DTOs (records de consulta) x modelos de domínio

Data: 2026-10-15

Este documento explica por que o plano de `separacao-daos.md` propôs DTOs (`model.dto.*View`) em vez de usar só
as classes de `model`. Também compara os dois tipos de classe, mostra onde há duplicação de verdade e onde não
há, e lista os prós e contras de cada abordagem.

---

## 1. O que existe hoje

### Modelos (`com.splash.web.model`)

`EntidadeBase`, `Pessoa`, `Cliente`, `Colaborador`, `Veiculo`, `Servico`, `Agendamento`, `ItemAgendamento`,
`Atendimento`, `Pagamento`, mais os enums de `model.enums`.

Eles guardam **regras de negócio**:

- Validam os dados nos setters e construtores, via `Validacao` (CPF, e-mail, placa, tamanho de texto).
- Controlam o ciclo de vida: `Agendamento.cancelar()`, `Atendimento.iniciarLavagem()`, `Pagamento.confirmar()`.
  As transições permitidas ficam nos enums (`StatusAtendimento.podeIrPara`).
- Protegem relações: um `Veiculo` só nasce por `Cliente.cadastrarVeiculo(...)`, e o construtor de `Veiculo` é
  package-private.
- Formam uma árvore de objetos: `Atendimento` → `Agendamento` → `Veiculo` → `Cliente`.

### Records (`LavaRapidoRepository.Cliente`, `.Veiculo` etc.)

São 7 `record` declarados dentro de `LavaRapidoRepository`. Eles só **carregam dados**: não validam, não
têm regra e não mudam de estado. Cada um corresponde ao resultado de uma consulta SQL, muitas vezes com JOIN.

### Quem usa cada um

| Tipo | Usado fora do próprio pacote por |
|---|---|
| `model.Cliente` | `DAOCliente`, `Cadastro`, `DAOClienteTest` |
| `model.Validacao` | `EditarCadastro` |
| Outros 8 modelos | **Ninguém**. Nenhuma DAO ou servlet usa `Veiculo`, `Servico`, `Agendamento`, `Atendimento`, `Pagamento` ou `Colaborador`. |
| Records do repositório | `LoginServlet`, `ColaboradorLoginServlet`, `ClienteRepository`, e indiretamente `AdminServlet`, `AgendamentoServlet`, `VeiculoServlet` e as JSPs `admin.jsp`, `agendamentos.jsp` e `veiculos.jsp` (via EL) |

Ou seja: hoje a aplicação que funciona roda quase toda sobre os records. Os modelos estão prontos, mas só
`Cliente` está ligado ao banco.

---

## 2. Semelhanças e diferenças

| Aspecto | Modelo (`model.*`) | DTO / record de consulta |
|---|---|---|
| Objetivo | Representar uma coisa do negócio e suas regras | Transportar o resultado de uma consulta até a tela |
| Origem dos campos | Uma tabela (às vezes com relações) | Uma consulta, que pode juntar várias tabelas |
| Validação | Sim, em setters e construtores | Não |
| Comportamento | Sim (`cancelar`, `confirmar`, `calcularTotal`) | Não |
| Mutável | Sim, por métodos controlados | Não (`record` é imutável) |
| Tipos | Enums, `LocalTime`, objetos relacionados | `String`, `int`, `BigDecimal`, `LocalDate` simples |
| Relações | Referência a objeto (`agendamento.getVeiculo().getCliente()`) | Campo já resolvido (`cliente`, `placa` como texto) |
| Custo para montar a partir do banco | Alto: precisa reconstruir a árvore e não pode revalidar dados antigos (ver `Cliente.carregar`) | Baixo: uma linha do `ResultSet` vira um record |
| Uso em escrita (INSERT/UPDATE) | Sim, é o lugar certo | Não deve ser usado |

**Semelhança principal:** os dois têm campos com o mesmo nome e significado (`nome`, `placa`, `preco`,
`status`). É isso que dá a sensação de duplicação.

**Diferença principal:** o modelo responde "o que pode acontecer com esta coisa". O DTO responde "o que esta tela
precisa mostrar".

---

## 3. Comparação campo a campo

### 3.1 Pares com duplicação real

O record é um subconjunto do modelo e vem de uma única tabela. Nestes casos a duplicação existe de fato.

| Record | Campos do record | Modelo equivalente | O que falta no modelo para substituir o record |
|---|---|---|---|
| `Cliente` | `id`, `nome`, `email` | `Cliente` (tem tudo isso + `cpf`, `telefone`, `senhaHash`, `veiculos`) | Nada. `Cliente.carregar(...)` já existe. |
| `Servico` | `id`, `nome`, `descricao`, `preco` | `Servico` (mesmos campos) | Um `Servico.carregar(id, nome, descricao, preco)` sem revalidação. |
| `Veiculo` | `id`, `placa`, `marca`, `modelo`, `cor` | `Veiculo` (mesmos campos + `cliente`) | Um jeito de carregar do banco. O construtor é package-private e exige o `Cliente` dono, e `cadastrarVeiculo` revalida a placa. |
| `Colaborador` | `id`, `nome`, `cargo`, `nivelAcesso` (String), `email` | `Colaborador` (mesmos campos, `nivelAcesso` como enum `NivelAcesso`) | Um `Colaborador.carregar(...)`. Ver o cuidado abaixo. |

Cuidado com `Colaborador`: `ColaboradorLoginServlet` grava `nivelAcesso` na sessão, e
`WebSupport.colaboradorId` confere `nivel instanceof String`. Com o modelo, `getNivelAcesso()` devolve o enum.
Grave `colaborador.getNivelAcesso().name()` na sessão, ou a checagem de permissão passa a recusar todo mundo.

Nos servlets a troca exige mudar chamadas. `LoginServlet:50-51` e `ColaboradorLoginServlet:48-50` usam os
acessores de record (`cliente.id()`, `colaborador.nome()`). Os modelos usam getters (`getId()`, `getNome()`).

Para as JSPs, a troca é transparente: `${servico.id}`, `${veiculo.placa}` e `${colaborador.nivelAcesso}`
funcionam igual. O `getId()` vem de `EntidadeBase`, e a EL imprime o nome do enum.

### 3.2 Pares sem duplicação real

O record é uma linha de relatório montada com JOIN e agregação. O modelo não tem esses campos, ou tem em outro
formato.

| Record | Campos do record | Modelo mais próximo | Diferenças |
|---|---|---|---|
| `Agendamento` | `id`, `placa`, `veiculo` (texto "marca modelo"), `data`, `horario` (String), `status` (String), `total`, `statusPagamento`, `formaPagamento` | `Agendamento` | O modelo guarda o objeto `Veiculo`, não o texto. `horario` é `LocalTime` e `status` é enum. O total é calculado por `calcularTotal()` somando os itens, e no record vem pronto de `SUM()`. O modelo não tem dados de pagamento, que ficam em `Atendimento.getPagamento()`. |
| `Atendimento` | `id`, `idAgendamento`, `cliente` (nome), `placa`, `data`, `horario`, `status`, `statusAgendamento`, `colaboradores` (nomes juntados), `idsColaboradores` (ids juntados) | `Atendimento` | No modelo, `cliente`, `placa`, `data` e `horario` estão 2 ou 3 níveis abaixo (`getAgendamento().getVeiculo().getCliente().getNome()`). `colaboradores` é uma `List<Colaborador>`, não um texto de `GROUP_CONCAT`. |
| `Pagamento` | `id`, `idAgendamento`, `cliente`, `placa`, `data`, `horario`, `valor`, `forma`, `status` | `Pagamento` | O modelo não sabe a qual agendamento pertence (não tem referência de volta). Também não tem `cliente`, `placa`, `data` nem `horario`. Ele tem `dataPagamento` e as regras `confirmar`/`cancelar`. |

Para trocar estes 3 records por modelos seria preciso:

1. Reconstruir a árvore inteira para cada linha. Isso exige carregar `Cliente`, `Veiculo`, `Agendamento`,
   itens, `Atendimento`, colaboradores e `Pagamento`, com mais consultas ou um JOIN grande e um mapeamento complexo.
2. Mudar as JSPs: `${atendimento.cliente}` vira `${atendimento.agendamento.veiculo.cliente.nome}`, e
   `${pagamento.forma}` vira `${pagamento.formaPagamento}`. Isso está fora da etapa atual.
3. Criar construtores de carga que não revalidem dados antigos, em 5 classes.

---

## 4. Opções

### Opção A — só modelos

Apagar os records. As DAOs devolvem sempre classes de `model`.

Prós:
- Um único tipo para cada conceito. Não há dúvida sobre qual classe usar.
- Toda regra fica perto dos dados. Um servlet que lista atendimentos já recebe um objeto que sabe se pode
  `iniciarLavagem()`.
- Reaproveita o trabalho já feito em `model`, que hoje está quase todo sem uso.

Contras:
- As listagens com JOIN (admin) ficam caras de montar e difíceis de manter.
- Exige `carregar(...)` em quase todas as classes, para não revalidar dados antigos.
- Muda as propriedades das JSPs `admin.jsp` e `agendamentos.jsp`.
- Telas que mostram dados de várias tabelas forçam o modelo a ter campos que não são regra de negócio. Por
  exemplo, pôr `nomeCliente` em `Pagamento` só para a tela polui o modelo.

### Opção B — só DTOs

Apagar ou ignorar os modelos. As DAOs devolvem records, e as regras ficam em SQL e nos servlets.

Prós:
- Menos código. Cada consulta tem o formato exato que a tela usa.
- É como o `LavaRapidoRepository` já funciona hoje.

Contras:
- As regras de negócio ficam espalhadas. Hoje a regra de transição do atendimento já aparece duas vezes:
  `transicaoPermitida` no repositório e `StatusAtendimento.podeIrPara` no enum, com comportamentos diferentes.
- Status como `String` aceita qualquer texto. Um erro de digitação (`"CANCELDO"`) só aparece em execução.
- Joga fora o `model`, que tem validação e ciclo de vida já escritos e testáveis sem banco.

### Opção C — os dois, com papéis separados

- **Escrita (INSERT, UPDATE, mudança de status):** sempre por modelos. A regra é aplicada antes do SQL.
- **Leitura de telas com JOIN ou agregação:** por DTOs, que nunca são usados para gravar.

Prós:
- Cada tipo faz o que faz melhor: o modelo garante as regras e o DTO serve à tela.
- As JSPs não mudam.
- É a abordagem comum em sistemas com telas de relatório. O nome técnico é "separar modelo de escrita e
  modelo de leitura".

Contras:
- Dois tipos com campos parecidos. Quem lê o código precisa entender a diferença, e este documento existe por isso.
- Se uma coluna nova surgir, ela pode precisar ir para os dois lugares.
- Sem disciplina, alguém começa a gravar a partir de um DTO e as regras do modelo são contornadas.

---

## 5. Recomendação

Usar a opção C, mas **só onde a duplicação não é real**:

| Conceito | Usar | Motivo |
|---|---|---|
| Cliente | Modelo `Cliente` | Já existe `carregar`. O record `Cliente` (id, nome, email) é apagado. |
| Serviço | Modelo `Servico` | Mesmos campos. Falta só um `carregar`. |
| Veículo | Modelo `Veiculo` | Mesmos campos. Falta um jeito de carregar sem revalidar. |
| Colaborador | Modelo `Colaborador` | Mesmos campos. Falta `carregar`, e a sessão deve receber `nivelAcesso.name()`. |
| Agendamento (lista do cliente) | `AgendamentoView` | Linha de relatório com `SUM` e dados de pagamento. |
| Atendimento (lista do admin) | `AtendimentoView` | Linha de relatório com `GROUP_CONCAT` e dados de 4 tabelas. |
| Pagamento (lista do admin) | `PagamentoView` | Linha de relatório com dados do cliente e do agendamento. |

Com isso sobram 3 DTOs em vez de 7, e todos com um motivo claro para existir. As **escritas** de agendamento,
atendimento e pagamento passam a consultar as regras do modelo e dos enums antes do SQL, em vez de repetir a regra
em texto (por exemplo, `'CANCELADO'` escrito à mão no SQL).

Regra para não deixar a separação degradar:

- DTO nunca é parâmetro de um método que grava no banco.
- Regra de negócio nunca é escrita em um DTO.
- Se um DTO passar a ter os mesmos campos de um modelo e vier de uma única tabela, ele deve ser trocado pelo modelo.

### Ordem sugerida

1. Criar `carregar(...)` em `Servico`, `Veiculo` e `Colaborador`, no mesmo padrão de `Cliente.carregar`.
2. Fazer `DAOServico`, `DAOVeiculo` e `DAOColaborador` devolverem os modelos. Apagar os records
   `Cliente`, `Servico`, `Veiculo` e `Colaborador`.
3. Mover os records `Agendamento`, `Atendimento` e `Pagamento` para `model/dto/` como `AgendamentoView`,
   `AtendimentoView` e `PagamentoView`.
4. Depois, ligar as escritas de agendamento, atendimento e pagamento às regras do modelo e dos enums.

Esta recomendação muda a seção 4.8 de `separacao-daos.md`, que propunha 7 DTOs.
