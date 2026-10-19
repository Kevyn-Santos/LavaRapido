# Remoção dos repositórios, migração dos servlets e cadastro único

Data: 2026-10-18

Status: **executado**. Fecha a migração descrita em `separacao-daos.md` (passos 8 a 11 da seção 8) e os
próximos passos de `daos-separadas.md` (seção 4, itens 2 a 5). Este arquivo compara o que foi feito com o que
foi proposto em `separacao-daos.md`, `dtos-criadas.md`/`daos-separadas.md` e `analise-geral-v1.md`, e lista o que
ainda falta para uma **MVP V1 local funcional**.

---

## 1. Commits

| Commit | Tópico | Resumo |
|---|---|---|
| `2f4e0c1` | (pré-requisito) | Trabalho que já estava pendente no working tree: DTOs em `model.dto`, `Passwords` em `security/`, `Cadastro` com hash, `SetupAdminServlet` com `DAOColaborador`. Commitado à parte para não se misturar com os tópicos abaixo. |
| `4662f3e` | 1 | Remove `LavaRapidoRepository` e `ClienteRepository`. Toda a manipulação de cliente fica em `DAOCliente`. |
| `3481984` | 2 | Servlets usam as DAOs. Forwards apontam para `/WEB-INF/views/`. |
| `bec8212` | 3 | `CadastroClienteServlet` vira o único cadastro, em `/cadastro`. A servlet `Cadastro` é apagada. |

---

## 2. O que mudou

### 2.1 Tópico 1: repositórios removidos (`4662f3e`)

| Arquivo | Mudança | Por quê |
|---|---|---|
| `db/LavaRapidoRepository.java` | Apagado. | Só restavam `cadastrarCliente` e `autenticarCliente`, e os dois já tinham equivalente em `DAOCliente`. |
| `db/ClienteRepository.java` | Apagado. | Só repassava as chamadas para `LavaRapidoRepository`. |
| `db/DAOCliente.java` | `insertUsuario(Cliente)` é o único INSERT de cliente (Javadoc explica o contrato). O comentário de transição saiu. `deleteusuario` perdeu o `catch (RuntimeException e) { throw new RuntimeException(e); }`. | Mudanças 6.1 e 6.6. A normalização que `cadastrarCliente` fazia (trim, e-mail em minúsculas) já é feita pelos setters de `Cliente`, via `Validacao`. O hash vem de `Passwords.hash`, chamado pelo servlet. |
| `security/Passwords.java` | `matches` passou a ser `public`. | Depois da mudança para `security/`, `DAOCliente` e `DAOColaborador` (pacote `db`) não conseguiam chamar `matches`, que estava package-private. Os pacotes `db` e `model` **não compilavam**, ao contrário do que dizia `dtos-criadas.md`. A seção 4.10 de `separacao-daos.md` já pedia classe e métodos `public`. |

Correspondência com o código antigo:

| Antes | Depois |
|---|---|
| `ClienteRepository.cadastrar(nome, cpf, telefone, email, senha)` | `new DAOCliente().insertUsuario(new Cliente(nome, cpf, telefone, email, Passwords.hash(senha)))` |
| `ClienteRepository.autenticar(email, senha)` | `new DAOCliente().autenticar(email, senha)` → `ClienteView` |

### 2.2 Tópico 2: imports e forwards (`3481984`)

Chamadas trocadas conforme a tabela 3.3 de `daos-separadas.md` e a seção 5.2 de `separacao-daos.md`:

| Servlet | DAOs/DTOs importados | Forward corrigido |
|---|---|---|
| `AdminServlet` | `DAOServico`, `DAOColaborador`, `DAOAtendimento`, `DAOPagamento` | `/admin.jsp` → `/WEB-INF/views/admin.jsp` |
| `AgendamentoServlet` | `DAOAgendamento`, `DAOServico`, `DAOVeiculo` | `/agendamentos.jsp` → `/WEB-INF/views/agendamentos.jsp` |
| `VeiculoServlet` | `DAOVeiculo` | `/veiculos.jsp` → `/WEB-INF/views/veiculos.jsp` |
| `ColaboradorLoginServlet` | `DAOColaborador`, `ColaboradorView` | `/colaborador-login.jsp` → `/WEB-INF/views/colaborador-login.jsp` |
| `LoginServlet` | `DAOCliente`, `ClienteView` | `/login.jsp` → `/WEB-INF/views/login.jsp` (JSP recriada, ver 2.4) |
| `SetupAdminServlet` | `DAOColaborador` (já usava) | `/setup-admin.jsp` → `/WEB-INF/views/setup-admin.jsp` |
| `PortalServlet` | — | `/portal.jsp` → `/WEB-INF/views/portal.jsp` |
| `WebSupport.erroBanco` | — | `/erro.jsp` → `/WEB-INF/views/erro.jsp` |
| `CadastroClienteServlet` | `DAOCliente`, `model.Cliente`, `Passwords` | `/cadastroT.jsp` → `/cadastro.jsp` (o formulário real, ver 2.3) |
| `DeletarCadastro` | — | Sem mudança. Deixou de chamar `deleteusuariosTotal`, que tinha sido comentado em `DAOCliente` (6.6). |

Quando um método usa a mesma DAO mais de uma vez, ela fica numa variável local (`daoServico`, `daoAgendamento`,
`daoVeiculo`), como sugere `daos-separadas.md` 3.3. Os nomes dos atributos de request e as propriedades lidas
pelas JSPs não mudaram.

`index.jsp`: o link "Acesso da equipe" apontava para `WEB-INF/Views/acesso.jsp`, que não existe e nem poderia ser
acessado pela URL. Agora aponta para `/colaborador/login`.

### 2.3 Tópico 3: cadastro único (`bec8212`)

| Arquivo | Mudança |
|---|---|
| `servlet/CadastroClienteServlet.java` | Mapeia `/cadastro` (era `/cadastroServlet`). GET mostra o formulário. POST confere a senha mínima de 8 caracteres **antes** do hash, monta `Cliente` pelo construtor (que valida nome, CPF, telefone e e-mail via `Validacao`), grava com `DAOCliente.insertUsuario` e redireciona para `/login?cadastro=sucesso`. |
| `servlet/Cadastro.java` | Apagado. |
| `webapp/cadastro.jsp` | `action` → `${contextPath}/cadastro`. Campos renomeados para os que a servlet lê (`nome`, `cpf`, `telefone`, `email`, `senha`), campo CPF adicionado, `minlength` 6 → 8, mensagem `erro`, valores digitados mantidos em caso de erro, CSS de `Assets/CSS/style.css`, link para `/login`. |
| `webapp/index.jsp` | "Criar conta" → `${contextPath}/cadastro` (passa pela servlet). |
| `miscelaneous/openapi.yml` | `/cadastroServlet` virou `/cadastro`; descrições e erros atualizados. |

Tratamento de erro do POST, seguindo `daos-separadas.md` 3.2:

| Situação | Resposta |
|---|---|
| Senha curta ou campo inválido (`IllegalArgumentException` de `Validacao`) | 400, formulário com a mensagem da validação. |
| CPF ou e-mail repetido (SQLState `23xxx`) | 409, "CPF ou e-mail já cadastrado." |
| Outra `SQLException` | `WebSupport.erroBanco` (500, `erro.jsp`). |

Por que esta servlet e não `Cadastro`: `Cadastro` respondia com `text/plain`, voltava para o `index.jsp` em caso de
erro e, em sucesso, fazia forward para `/mostrarCadastros`, que lista **todos** os clientes com CPF. A
`CadastroClienteServlet` já tinha o fluxo certo (redirect para o login, 409 para duplicado, `erroBanco`). Da
`Cadastro` foi aproveitada a validação pelo modelo, no lugar das checagens manuais de tamanho.

### 2.4 Fora do git

- `WEB-INF/views/login.jsp` foi recriada (formulário de e-mail/senha, mensagem de `?cadastro=sucesso`, `erro`,
  links para `/cadastro` e `/`). **Ela não está em nenhum commit**, porque o `.gitignore` ignora
  `/src/main/webapp/WEB-INF/views/` (ver 4, item 1).
- `src/test/.../DAOClienteTest.java` (também ignorado): o bloco `DeleteUsuariosTotal` foi apagado, porque o método
  não existe mais. Sem isso, `mvn test` não compila.

---

## 3. Comparação com as propostas

### 3.1 `separacao-daos.md`

| Proposta | Situação |
|---|---|
| 4.1: unir `cadastrarCliente` com `insertUsuario` | **Feito.** |
| 4.9: `erroBanco` com forward quebrado, "fica como está nesta etapa" | **Corrigido** (`/WEB-INF/views/erro.jsp`). |
| 4.10: `Passwords` com classe e métodos `public` | **Feito.** `matches` ainda era package-private e quebrava a compilação. |
| 5.2: imports novos dos servlets | **Feito** em todos. `Cadastro` foi apagado em vez de ajustado. |
| 6.1: senha sem hash | **Feito.** Só existe um caminho de cadastro, e ele sempre usa `Passwords.hash`. `Cliente.setCPF` já chamava `Validacao.cpf`. |
| 6.2: rota `/cadastro` duplicada | **Feito.** O plano dizia que as duas servlets mapeavam `/cadastro`. Na verdade `CadastroClienteServlet` estava em `/cadastroServlet`: não havia conflito no deploy, mas havia dois cadastros diferentes. Agora há uma servlet só, em `/cadastro`. |
| 6.3 e 6.4 | Já estavam feitos (`daos-separadas.md` 1.4). |
| 6.5: nível de acesso pelo enum `NivelAcesso` | **Pendente** (opcional). `WebSupport.nivel` continua com o `switch`. |
| 6.6: limpar `deleteusuario` | **Feito.** O `catch` inútil saiu e `deleteusuariosTotal` (comentado) não é mais chamado. |
| 8, passos 1 a 11 | **Feitos.** `WebSupport` (passo 9) já estava em `servlet/`. |
| 8, passo 12: testes das DAOs novas | **Pendente.** `mvn test` passa (25 testes, só `DAOClienteTest`). |

### 3.2 `dtos-criadas.md` e `daos-separadas.md`

| Ponto | Situação |
|---|---|
| "Servlets antigos continuam sem compilar" | **Resolvido.** Todos importam `model.dto.*View` e as DAOs. |
| "`db` e `model` compilam sem erro" | Não era verdade depois da mudança de `Passwords` (ver 2.1). **Resolvido.** |
| Próximos passos 2 a 5 (`Passwords`, 6.1, servlets, apagar repositórios) | **Feitos.** |
| Próximo passo 6 (testes das DAOs novas) | **Pendente.** |
| Decisão em aberto: trocar `ClienteView`, `ServicoView`, `VeiculoView` e `ColaboradorView` pelos modelos | **Continua em aberto.** Nada nesta etapa depende dela. |

### 3.3 `analise-geral-v1.md`

| # | Problema | Situação |
|---|---|---|
| 1 | 23 erros de compilação | **Resolvido** de outro jeito: em vez de tornar `public` os métodos dos repositórios, os repositórios foram apagados e os servlets usam as DAOs. `mvn compile`, `mvn test` e `mvn package` passam. |
| 2 | Forwards com caminho errado | **Resolvido** (tabela 2.2). |
| 3 | `login.jsp` apagado | **Resolvido localmente**: a JSP existe, mas não está versionada (item 6). |
| 4 | Formulário de cadastro errado | **Resolvido**: `cadastro.jsp` envia para `/cadastro` com os campos certos. |
| 5 | `index.jsp` não leva a nenhuma servlet; CSS do `cadastro.jsp` com 404 | **Resolvido**: "Criar conta" → `/cadastro`, "Acesso da equipe" → `/colaborador/login`, CSS de `Assets/CSS/`. |
| 6 | `.gitignore` esconde views e testes | **Pendente.** |
| 7 | Seed com hash inválido (login responde 500) | **Pendente.** |
| 8 | Seed cria um admin que não consegue logar e bloqueia `/setup/admin` | **Pendente.** |
| 9 | Variáveis de ambiente; `IllegalStateException` sem tratamento | **Pendente.** Confirmado no smoke test (seção 5). |
| menor | Rotas legadas gravam senha sem hash | **Resolvido**: a rota legada não existe mais. |
| menor | README cita `SplashFast-1.0.war` | **Pendente.** |
| menor | `jakarta.servlet-api` 6.1 (Tomcat 11) | **Pendente.** |
| menor | `database/schema.sql` e `src/main/resources/schema.sql` divergem | **Pendente.** |

---

## 4. O que falta para a MVP V1 local

> **Atualização (2026-10-18):** os itens 1 e 4 foram feitos, e o item 2 saiu do escopo (o seed não será usado
> por enquanto). As variáveis do item 3 estão em `variaveis-de-ambiente.md`. A lista atualizada está na seção 6
> de `teste-ponta-a-ponta-tomcat-local.md`.

Em ordem de prioridade. Os itens 1 a 4 impedem o uso real; os outros são melhorias.

1. **Versionar as views.** Tirar `/src/main/webapp/WEB-INF/views/` do `.gitignore` e commitar as JSPs, incluindo
   a `login.jsp` nova. Sem isso, um clone ou o build no Docker/Render gera um WAR sem nenhuma view. As linhas de
   `Cadastro.java` e `MostrarCadastro.java` no `.gitignore` também podem sair (a primeira foi apagada, a segunda
   nunca existiu com esse nome).
2. **Corrigir o seed.** Gravar hashes BCrypt reais em `database/seed.sql` (ou remover o colaborador
   `ADMINISTRADOR`, para que `/setup/admin` funcione). Hoje `BCrypt.checkpw` lança `IllegalArgumentException`
   (`Invalid salt version`) e o login responde 500. Opcional: `Passwords.matches` devolver `false` para hash
   inválido, em vez de lançar a exceção.
3. **Configurar o banco local.** `.env` com `ENV_DEV=LOCAL` e `LOCAL_DB_URL`, `LOCAL_USER`, `LOCAL_PASS`, mais
   `INITIAL_ADMIN_TOKEN` para o setup. Se o Tomcat do sistema for usado, as variáveis precisam estar no ambiente
   do serviço, porque ele não lê o `.env` da pasta do projeto. Sem elas, `DatabaseConnection` lança
   `IllegalStateException`, que nenhum servlet trata: aparece a página 500 padrão do Tomcat, e não `erro.jsp`.
4. **Teste ponta a ponta com MySQL.** Até agora nenhum fluxo foi executado com banco. Roteiro: cadastro → login →
   veículo → agendamento → cancelamento; setup do admin → login da equipe → atendimento → pagamento.
5. **Telas de teste das DAOs.** `Listar*`, `Consultar*`, `EditarCadastro`, `DeletarCadastro` e `MostrarCadastros`
   não pedem login e mostram o CPF de todos os clientes. Para a V1 local isso não impede o uso, mas elas devem
   ser protegidas ou removidas antes de qualquer deploy. `MostrarCadastros` e `cadastroT.jsp` não são mais
   alcançadas por nenhum fluxo. Em `DeletarCadastro.jsp`, o checkbox `CheckAll` é ignorado agora.
6. **Testes das DAOs novas** (`separacao-daos.md` 8.12), no padrão de `DAOClienteTest`. Para que fiquem no
   repositório, `/src/test/` também precisa sair do `.gitignore`.
7. **Menores:** 6.5 (`NivelAcesso` com peso), `jakarta.servlet-api` 6.0.0, nome do WAR no README, unificar os
   dois `schema.sql`.

---

## 5. Verificação

- `mvn compile`, `mvn test` (25 testes, 0 falhas) e `mvn package` passam.
- Smoke test: o WAR rodou num Tomcat 10.1 isolado (porta própria, `CATALINA_BASE` temporário), **sem banco**.

| Rota | Resultado | Observação |
|---|---|---|
| `/`, `/cadastro`, `/login`, `/colaborador/login`, `/Assets/CSS/style.css` | 200 | Deploy sem conflito de rota; as JSPs são encontradas. |
| `/setup/admin` | 503 | Esperado sem `INITIAL_ADMIN_TOKEN` (mostra `setup-admin.jsp` com aviso). |
| `/portal` | 302 → `/` | Sem sessão. |
| `/veiculos`, `/agendamentos` | 302 → `/login` | Sem sessão. |
| `/admin` | 302 → `/colaborador/login` | Sem sessão. |
| `POST /cadastro` com senha de 3 caracteres | 400 | "A senha deve ter ao menos 8 caracteres.", com os campos preenchidos. |
| `POST /cadastro` com CPF `123` | 400 | "CPF deve ter 11 dígitos." (mensagem de `Validacao`). |
| `POST /cadastro` válido | 500 | Esperado sem banco: `IllegalStateException: Variável de ambiente ausente ou vazia: LOCAL_DB_URL` (seção 4, item 3). |
| `/login?cadastro=sucesso` | 200 | Mostra "Cadastro realizado. Faça login." |
