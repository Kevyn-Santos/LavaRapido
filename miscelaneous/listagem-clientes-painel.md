# Listagem de clientes em `/painel/clientes`

## O quê

`/painel/clientes` passou de uma tela sem nenhuma listagem (o `PainelServlet` só autenticava e
fazia `forward` pro JSP, sem dado nenhum) para uma listagem completa, renderizada no servidor via
JSTL, seguindo o padrão visual de "tabela em grid" já definido (mas não usado por nenhuma JSP) em
`painel.css`.

Arquivos alterados:

- **`DAOCliente.java`** — novo método `getUsuariosComVeiculos()` (bloco "Listagem de usuarios"),
  uma variante de `getUsuariosVeiculo()` (já existente) trocando `INNER JOIN` por `LEFT JOIN`
  veiculo. Mesmo padrão de acumulação em `Map<Integer, Cliente>` + `mapearCliente` +
  `cliente.cadastrarVeiculo(...)`, mas com checagem `rs.getString("placa") != null` antes de
  cadastrar o veículo (sem ela, colunas `v.*` nulas do `LEFT JOIN` quebrariam
  `Validacao.textoObrigatorio` dentro de `Veiculo`).
- **`PainelServlet.java`** — no `doGet`, quando `secao.equals("clientes")`, chama
  `new DAOCliente().getUsuariosComVeiculos()` e põe o resultado no atributo de request
  `clientes`, antes do `forward`. Erro de banco cai no `WebSupport.erroBanco(...)` já existente
  (forward pra `erro.jsp`).
- **`painel-clientes.jsp`** — `<div id="clients-table-container">` deixou de ser um placeholder
  vazio: agora tem um `<c:if test="${empty clientes}">` com mensagem "Nenhum cliente cadastrado."
  e, quando há clientes, uma tabela feita com `<div class="tbl">` + `<div class="thead trow crow">`
  (cabeçalho) + um `<div class="trow crow">` por cliente, via `<c:forEach items="${clientes}">`.
  Colunas: **Cliente** (nome em destaque + e-mail abaixo, `<p class="small">`), **Telefone**,
  **Carros** (`marca modelo` de cada `Veiculo` do cliente, separados por vírgula, ou "—" se a
  lista estiver vazia) e **Ações** (botões "Editar"/"Remover", classes `.btn.sm.ghost` e
  `.btn.sm.danger` já existentes — **sem handler/rota ainda, só visual**).
- **`painel.css`** — nova regra `.crow { grid-template-columns: 1.6fr 1fr 1.6fr auto; }` no bloco
  "5. TABELAS, CAMPOS E PESQUISA", definindo a largura das 4 colunas acima.

## Por quê

Pedido do usuário: "como listar em painel-clientes.jsp os clientes que estão no banco". A primeira
versão usou `<table>` HTML nativa, que ficou sem nenhum estilo (texto colado) porque `painel.css`
não define regra nenhuma pra `<table>/<tr>/<td>` — o CSS do painel usa um padrão de "tabela" feito
com **divs em grid** (`.tbl` + `.thead` + `.trow`), o mesmo esquema já usado por `.atc`
(atendimentos) em `painel.css`, só que nenhuma JSP chegava a usar esse padrão ainda (ele só
existia na folha de estilo, sem HTML correspondente).

O usuário então pediu que a tela ficasse exatamente como um mockup fornecido — colunas
Cliente/Telefone/Carros/Ações, nome+e-mail empilhados, botões Editar/Remover — e confirmou que:
(1) os botões devem ser só visuais por enquanto (não existe rota de edição/remoção de cliente
ainda, só `/cadastro` pro insert), e (2) a coluna Carros deve mostrar marca+modelo reais dos
veículos do cliente, não um texto fixo. Isso forçou a troca da consulta: a listagem simples
(`DAOCliente.getUsuarios()`, sem join) não trazia veículo nenhum, e o método com join existente
(`getUsuariosVeiculo()`) usa `INNER JOIN`, que esconderia qualquer cliente sem veículo cadastrado
— inaceitável pra uma listagem geral de clientes.

## Como se liga ao projeto

- Segue o padrão de DAO único por tabela principal (`DAOCliente`), com a consulta multi-tabela
  (cliente + veículo) ainda dentro do DAO de `cliente`, igual à regra do `CLAUDE.md` pra queries
  que juntam tabelas relacionadas.
- Reaproveita getters de bean já existentes (`Cliente.getNome/getEmail` via `Pessoa`,
  `getCpf/getTelefone/getId_cliente/getVeiculos`, `Veiculo.getMarca/getModelo`) sem renomear
  nenhum — importante porque outras JSPs/EL dependem desses nomes.
- Não mexeu em `painel.js`: os botões "Editar"/"Remover" e o campo de busca (`#input-search`)
  continuam inertes, junto com o mesmo gap que já existe em todos os outros painéis
  (`carros`, `agendamentos`, etc., ver análise no histórico desta sessão) — a listagem de
  clientes é a primeira a sair do estado de placeholder, mas CRUD completo (editar/excluir,
  busca reativa) fica pra uma tarefa futura.
- `mvn compile` validado limpo após as mudanças.
