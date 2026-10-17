# Análise geral do projeto — versão 1.0

Data: 2026-10-16

Objetivo: verificar se o projeto compila e roda. Pontos de segurança e performance ficam fora do escopo desta versão.

**Resumo:** a versão 1.0 **não compila** no estado atual. Depois de corrigir a compilação (testado numa cópia), o WAR é gerado e os testes passam, mas a aplicação **não roda de ponta a ponta**: os fluxos de login, cadastro, portal e admin quebram por JSPs ausentes ou com caminho errado.

## O que o projeto faz

Site de lava-rápido em Servlets + JSP + MySQL, empacotado como WAR para Tomcat 10.1 / Java 25.

- **Fluxo novo** (`LavaRapidoRepository`, `ClienteRepository`, `WebSupport`):
  - Cliente: cadastro, login com sessão, portal, veículos e agendamentos. Cada agendamento cria, na mesma transação, o atendimento e o pagamento pendente.
  - Colaborador: login, criação do administrador inicial via `INITIAL_ADMIN_TOKEN` e painel `/admin/*` com controle por nível de acesso (serviços, equipe, atendimentos, pagamentos).
  - Senhas com BCrypt.
- **Telas de teste das DAOs** (`DAOCliente`): listar, consultar, editar e excluir clientes, acessadas pelos links do `index.jsp` antigo.
- **Conexão**: `DatabaseConnection` lê `.env` ou variáveis do sistema (dotenv). `ENV_DEV` escolhe entre `LOCAL_*` e `PROD_*`.
- **Deploy**: `Dockerfile` multi-stage para o Render (Maven 3.9, depois Tomcat 10.1 com JRE 25), publicando como `ROOT.war`.

## Bloqueio para compilar

1. **23 erros de compilação.** Os métodos de `LavaRapidoRepository` e `ClienteRepository` são package-private (resto da época em que tudo ficava em `com.example`). As servlets em `com.splash.web.servlet` não conseguem acessá-los. Exemplo:

   ```
   listarVeiculos(int) is not public in com.splash.web.db.LavaRapidoRepository; cannot be accessed from outside package
   ```

   Correção: trocar `static` por `public static` nos métodos usados pelas servlets. Testado numa cópia: `mvn clean package` passa, com os testes, e gera `target/SplashFast.war`.

## Bloqueios para rodar

Smoke test: WAR corrigido implantado num Tomcat 10.1.55 isolado, sem banco configurado.

| Rota | Resultado | Causa |
|---|---|---|
| `/`, `/index.jsp`, `/health.jsp`, `/cadastro.jsp`, CSS | 200 | ok |
| `/portal`, `/veiculos`, `/agendamentos`, `/admin/*` | 302 | ok, redireciona para o login |
| `/login`, `/login.jsp` | 404 | `login.jsp` não existe mais |
| `/colaborador/login`, `/cadastroServlet`, `/setup/admin` | 404 | forward para `/colaborador-login.jsp`, `/cadastroT.jsp` e `/setup-admin.jsp` na raiz; os arquivos estão em `WEB-INF/views/` |
| telas `/listar*` | 500 | esperado sem banco: `Variável de ambiente ausente ou vazia: LOCAL_DB_URL` |

Problemas que impedem o uso real:

2. **Forwards com caminho errado.** `PortalServlet`, `AgendamentoServlet`, `VeiculoServlet`, `AdminServlet`, `SetupAdminServlet`, `ColaboradorLoginServlet`, `CadastroClienteServlet` e `WebSupport.erroBanco` fazem forward para `/xxx.jsp`. O caminho correto é `/WEB-INF/views/xxx.jsp`. Mesmo após o login, o portal, o admin e a página de erro dão 404.
3. **`login.jsp` foi apagado.** `LoginServlet` depende dele. É preciso recriá-lo em `WEB-INF/views/`.
4. **Formulário de cadastro errado.** `CadastroClienteServlet` faz forward para `cadastroT.jsp`, que é a tabela de sucesso do fluxo antigo, não um formulário. O `cadastro.jsp` novo (landing) envia para `baixar-app.jsp`, que não existe, com campos `name` e `phone`. A servlet espera `nome`, `cpf`, `telefone`, `email` e `senha`.
5. **O `index.jsp` novo não leva a nenhuma servlet.** Ele aponta para `cadastro.jsp` e para `WEB-INF/Views/acesso.jsp`, que é inacessível pela URL e não existe. O `cadastro.jsp` carrega `style.css` relativo à raiz e recebe 404; o arquivo fica em `Assets/CSS/`.
6. **O `.gitignore` esconde arquivos essenciais.** Ele ignora `/src/main/webapp/WEB-INF/views/`, `/src/main/resources/` e `/src/test/`. No git só existe `views/.gitkeep`. Um clone ou o build no Render geram um WAR sem nenhuma view, e os testes não são versionados.
7. **O seed é incompatível com o login.** O `seed.sql` grava `senha_hash` como texto `HASH...`, não como bcrypt. `BCrypt.checkpw` lança `IllegalArgumentException` (`Invalid salt version`), que o `LoginServlet` não trata: o login de um usuário do seed responde 500.
8. **Não há como criar o primeiro admin com o seed carregado.** O seed já cria um colaborador `ADMINISTRADOR` com hash inválido. Por isso `/setup/admin` responde 410 e esse admin não consegue logar, deixando o painel sem acesso. Correção: remover o admin do seed ou gravar um hash bcrypt real.
9. **Variáveis de ambiente.**
   - O `.env` local está com `ENV_DEV="PROD"`, ou seja, aponta para o MySQL da Aiven. Em desenvolvimento, cuidado com escritas no banco de produção.
   - O Tomcat do sistema (`/var/lib/tomcat10`) roda em outro diretório e não encontra o `.env`. As credenciais precisam ser definidas como variáveis de ambiente do serviço.
   - No Docker, o `.env` é excluído pelo `.dockerignore`. No Render, defina `ENV_DEV`, `PROD_DB_URL`, `PROD_USER`, `PROD_PASS` e `INITIAL_ADMIN_TOKEN`.
   - Sem essas variáveis, o erro é `IllegalStateException`, não `SQLException`. O `erroBanco` não o captura, e o resultado é a página 500 padrão do Tomcat.

## Pontos menores (não impedem a execução)

- O README cita `SplashFast-1.0.war`, mas o `finalName` gera `SplashFast.war`, implantado em `/SplashFast`.
- `jakarta.servlet-api` 6.1 corresponde ao Tomcat 11; o Tomcat 10.1 implementa a 6.0. Compila e roda, mas o ideal é usar 6.0.0 com `provided`.
- As JSPs misturam as URIs `jakarta.tags.core` e `http://java.sun.com/jsp/jstl/core`. As duas funcionam com o JSTL 3.0 da Glassfish.
- As rotas legadas `/cadastro` e `/mostrarCadastros` gravam a senha sem hash, e o login com bcrypt falha para esses usuários.
- `database/schema.sql` e `src/main/resources/schema.sql` divergem, e o segundo está no `.gitignore`.

## O que funciona

- Com o item 1 corrigido: compilação, testes da DAO, empacotamento e deploy no Tomcat 10.1 / Java 25.
- O SQL dos repositórios confere com `schema.sql`: tabelas, colunas, enums e transações de agendamento e cancelamento.
- Controle de sessão e de nível de acesso (os redirects 302 estão corretos).
- `EncodingFilter`, assets em `/Assets/CSS` e `health.jsp`.

## Ordem mínima para a 1.0 rodar

1. Tornar `public` os métodos dos dois repositórios.
2. Corrigir os forwards para `/WEB-INF/views/...`.
3. Recriar `login.jsp` e um formulário de cadastro real; ligar `index.jsp` e `cadastro.jsp` a `/cadastroServlet` e `/login`.
4. Remover `WEB-INF/views/` e `src/test/` do `.gitignore` e versionar as views.
5. Ajustar o seed (hash bcrypt real ou sem o admin) e configurar as variáveis de ambiente.

## Limitações desta análise

- Nenhum teste foi feito com banco: o acesso ao MySQL local foi bloqueado por permissão. Os fluxos que dependem do banco (login real, agendamento, painel) não foram executados.
- O build e o smoke test usaram uma cópia isolada do projeto. Nenhum arquivo do projeto foi alterado.
