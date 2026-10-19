# Teste ponta a ponta no Tomcat local e mapa das telas

Data: 2026-10-18

Status: **executado**. É o primeiro teste do projeto **com banco**. Ele responde se a aplicação roda num Tomcat
local e fecha o item 4 de `repositorios-removidos-e-cadastro-unico.md` (seção 4). O seed **não** foi usado: por
decisão do projeto, os dados nascem do próprio fluxo (setup do admin → serviços → cadastro do cliente → ...).

---

## 1. Resposta curta

**Sim, o projeto roda num Tomcat 10.1 local com Java 25 e MySQL 8.** Todos os fluxos de cliente e de equipe
funcionaram de ponta a ponta. O teste encontrou um defeito, já corrigido: a lista de atendimentos do admin
respondia 500 (ver 3).

## 2. Ambiente do teste

| Item | Valor |
|---|---|
| Tomcat | 10.1 do sistema (`/usr/share/tomcat10`), mas com `CATALINA_BASE` isolado em pasta temporária e porta própria, sem mexer no Tomcat em execução |
| Java | Temurin 25 |
| MySQL | 8.0.46, **instância descartável** (porta 3307, pasta temporária). Só o `database/schema.sql`, sem seed. O banco `lava_rapido` local (porta 3306) não foi tocado. |
| Variáveis | Só por variáveis de ambiente do processo (`ENV_DEV`, `LOCAL_*`, `INITIAL_ADMIN_TOKEN`). O Tomcat foi iniciado fora da pasta do projeto, então o `.env` não foi lido. É a mesma situação do Docker e do Render (ver `variaveis-de-ambiente.md`). |
| WAR | `mvn package` do commit atual |

## 3. Defeito encontrado e corrigido

`WEB-INF/views/admin.jsp` montava a lista de colaboradores selecionados com `concat(',', ..., ',')`. `concat` não
existe na EL nem na JSTL `fn:`, e o Jasper lançava `ELException: função [:concat] não encontrada`. Toda a seção
`/admin/atendimentos` respondia 500 para qualquer perfil, inclusive o 400 de "transição não permitida", porque o
`doPost` reaproveita o `doGet` para mostrar o erro. A correção usa o operador de concatenação da EL 3.0, `+=`:

```jsp
${fn:contains(',' += atendimento.idsColaboradores += ',', ',' += colaborador.id += ',') ? 'selected' : ''}
```

Commit `a0c18cd`. Depois da correção, a lista abre e a equipe já atribuída vem pré-selecionada.

## 4. Resultado

| Fluxo | Passo | Resultado |
|---|---|---|
| Setup | `GET /setup/admin` → token errado → token certo → `GET` de novo | 200 → 403 → 302 `/colaborador/login?setup=sucesso` → 410 |
| Equipe | Login com senha errada / certa | 401 / 302 `/admin` |
| Equipe | Criar 2 serviços (`preco` com vírgula e com ponto) | 302 `?sucesso=1`; os dois aparecem na lista |
| Equipe | Criar colaborador `OPERACIONAL`; repetir o e-mail | 302 / 409 |
| Cliente | `GET /cadastro` → `POST` com CPF e telefone com máscara e e-mail com maiúsculas | 200 → 302 `/login?cadastro=sucesso` |
| Cliente | Mesmo cadastro de novo | 409 "CPF ou e-mail já cadastrado." |
| Cliente | Dados gravados | CPF `12345678901`, telefone `11987654321`, e-mail em minúsculas, senha com hash BCrypt (`$2a$`) |
| Cliente | Login com senha errada / certa (e-mail com maiúsculas) | 401 / 302 `/portal` ("Olá, Maria Silva") |
| Cliente | Adicionar veículo `abc1d23`; repetir a placa | 302 (gravado como `ABC1D23`) / 409 |
| Cliente | Agendar com 2 serviços; mesmo veículo, dia e horário | 302 (total 65,50 e pagamento `PENDENTE` criados) / 409 |
| Cliente | Agendar outro e cancelar | 302; agendamento e pagamento `CANCELADO` |
| Equipe | Atendimento → `EM_LAVAGEM` com colaborador → voltar para `AGUARDANDO` → `FINALIZADO` | 302 → 400 (transição não permitida) → 302; agendamento `CONCLUIDO` |
| Equipe | Pagamento → `PAGO` / `PIX` | 302; o cliente vê `CONCLUIDO` e `PAGO` em `/agendamentos` |
| Acesso | `OPERACIONAL` em `/admin/atendimentos` / `/admin/pagamentos` / `/admin/servicos` | 200 / 403 / 403 |
| Acesso | Sessão de equipe em `/agendamentos` | 302 `/login` |
| Sessão | `POST /sair` e depois `/portal` | 302 `/` e 302 `/` |
| Teste | As cinco telas `/listar*` sem login | 200 (mostram os dados, ver 5.2) |

### Ordem para começar do zero, sem seed

1. Rodar `database/schema.sql` num MySQL vazio.
2. Definir as variáveis do banco e `INITIAL_ADMIN_TOKEN` (`variaveis-de-ambiente.md`, seção 4) e iniciar o Tomcat.
3. `/setup/admin`: criar o administrador com o token.
4. `/colaborador/login` → `/admin/servicos`: cadastrar os serviços. Sem serviço, `/agendamentos` mostra "Não há
   serviços disponíveis".
5. Opcional: `/admin/colaboradores` para criar atendentes e operacionais.
6. `/cadastro` → `/login` → `/veiculos` → `/agendamentos` pelo lado do cliente.

## 5. Mapa das telas

### 5.1 Telas finais (fluxo do produto)

| Rota | Servlet | View | Acesso |
|---|---|---|---|
| `/` | — | `index.jsp` | Público |
| `/cadastro` | `CadastroClienteServlet` | `cadastro.jsp` | Público |
| `/login` | `LoginServlet` | `WEB-INF/views/login.jsp` | Público |
| `/colaborador/login` | `ColaboradorLoginServlet` | `WEB-INF/views/colaborador-login.jsp` | Público |
| `/setup/admin` | `SetupAdminServlet` | `WEB-INF/views/setup-admin.jsp` | Público, só até existir um administrador |
| `/portal` | `PortalServlet` | `WEB-INF/views/portal.jsp` | Cliente |
| `/veiculos` | `VeiculoServlet` | `WEB-INF/views/veiculos.jsp` | Cliente |
| `/agendamentos` | `AgendamentoServlet` | `WEB-INF/views/agendamentos.jsp` | Cliente |
| `/sair` | `LogoutServlet` | — | Cliente ou equipe |
| `/admin`, `/admin/atendimentos` | `AdminServlet` | `WEB-INF/views/admin.jsp` | Equipe, `OPERACIONAL` ou acima |
| `/admin/pagamentos` | `AdminServlet` | `WEB-INF/views/admin.jsp` | `ATENDENTE` ou acima |
| `/admin/servicos`, `/admin/colaboradores` | `AdminServlet` | `WEB-INF/views/admin.jsp` | `ADMINISTRADOR` |
| (erro de banco) | `WebSupport.erroBanco` | `WEB-INF/views/erro.jsp` | — |
| `/health.jsp` | — | `health.jsp` | Público (health check) |

Só `index.jsp` e `cadastro.jsp` carregam o CSS do site. As outras telas finais são HTML sem estilo: funcionam,
mas ainda não têm o visual do site.

### 5.2 Telas de teste (removidas)

> **Atualização (2026-10-18):** todas as telas abaixo foram apagadas no commit `23d4d4b`. Elas serão recriadas
> depois como telas finais. Os métodos do `DAOCliente` que elas usavam continuam no código e cobertos pelo
> `DAOClienteTest`.

Eram as telas criadas para testar o `DAOCliente`. Respondiam **sem login** e mostravam nome, CPF, telefone e
e-mail de **todos** os clientes.

| Rota de listagem (GET) | Ação (POST) | View | Método testado |
|---|---|---|---|
| `/listarCadastros` | `/editarCadastro` | `EditarCadastro.jsp` | `getUsuarios`, `updateUsuarios` |
| `/listarCadastrosExclusao` | `/deletarCadastro` | `DeletarCadastro.jsp` | `deleteusuario` |
| `/listarCadastrosConsulta` | `/consultarCadastro` | `ConsultarCadastro.jsp` | `getusuario` |
| `/listarClientesVeiculos` | — | `ListarClientesVeiculos.jsp` | `getUsuariosVeiculo` |
| `/listarClienteVeiculoConsulta` | `/consultarClienteVeiculo` | `ConsultarClienteVeiculo.jsp` | `getUsuarioveiculo` |
| — | `/mostrarCadastros` | `cadastroT.jsp` | `getUsuarios` |

Funções que ficam **sem tela** até serem recriadas: editar e excluir cliente (cliente editando o próprio cadastro
ou equipe gerenciando clientes). Cuidado para a futura exclusão: `veiculo` usa `ON DELETE RESTRICT`, então
excluir um cliente com veículo responde 409.

## 6. O que ainda falta para a MVP V1 local

Substitui a lista da seção 4 de `repositorios-removidos-e-cadastro-unico.md`:

| Item | Situação |
|---|---|
| Versionar views e testes | **Feito** (commit `71a7190`). |
| Seed com hash inválido | **Fora do escopo**: o seed não será usado por enquanto. Se voltar a ser usado, precisa de hashes BCrypt reais e não pode criar o administrador. |
| Teste ponta a ponta com banco | **Feito** (este arquivo). |
| Variáveis de ambiente | **Documentadas** em `variaveis-de-ambiente.md`. O `.env` da raiz do projeto pode ser lido com `DOTENV_DIR`/`-Ddotenv.dir` (commit `54c7310`). Falta aplicar no Tomcat do sistema a seção 4.3 de lá (`/etc/default/tomcat10`, `LANG=C.UTF-8`, permissão do usuário `tomcat`). Ainda pendente: tratar a `IllegalStateException` de variável ausente para cair em `erro.jsp`. |
| Telas de teste sem login | **Feito**: removidas (5.2). Editar e excluir cliente ficam para telas finais futuras. |
| Estilo das telas finais | **Pendente** (5.1). |
| Testes das DAOs novas, 6.5, `servlet-api` 6.0, README, dois `schema.sql` | **Pendentes** (menores). |
