# Variáveis de ambiente

Data: 2026-10-18

Levantamento de todas as variáveis de ambiente lidas pelo projeto: quem lê, por qual mecanismo, o que acontece
se faltarem e como definir cada uma em cada ambiente (Tomcat local, Docker e Render). O app mobile
(`app-mobile/`) não lê nenhuma variável própria; só aparecem as variáveis do template de build do Flutter.

---

## 1. Os dois mecanismos de leitura

O projeto lê variáveis de duas formas diferentes, e isso muda onde cada uma pode ser definida.

### 1.1 Biblioteca `dotenv-java` (só em `DatabaseConnection`)

```java
private static final Dotenv dotenv = Dotenv.configure().ignoreIfMissing().load();
```

- Lê o arquivo `.env` da pasta indicada pela propriedade de sistema **`dotenv.dir`** ou pela variável
  **`DOTENV_DIR`** (nessa ordem). Sem nenhuma das duas, lê da **pasta onde a JVM foi iniciada** (`./`, padrão da
  biblioteca), que **não** é a raiz do projeto quando o Tomcat é o do sistema (ver 4.3). `ignoreIfMissing()` faz
  com que a falta do arquivo não seja erro. A pasta configurável existe desde o commit `54c7310`.
- `dotenv.get(chave)` consulta **primeiro `System.getenv(chave)`** e só depois o `.env`. Uma variável de
  ambiente real sempre vence o arquivo. Isso foi conferido no bytecode da versão 3.2.0 (`DotenvImpl.get`).
- Por isso o mesmo código serve para os dois casos: no desenvolvimento o valor vem do `.env`; no Docker e no
  Render, das variáveis do sistema.
- O objeto é `static`: o `.env` é lido uma vez, quando a classe é carregada. Mudou o valor, é preciso reiniciar o
  Tomcat (ou recarregar a aplicação).

### 1.2 `System.getenv` direto (só em `SetupAdminServlet`)

`INITIAL_ADMIN_TOKEN` é lido com `System.getenv`, **sem** passar pela `dotenv`. Colocar essa variável no `.env`
**não funciona**: ela precisa ser uma variável de ambiente real do processo do Tomcat.

---

## 2. Variáveis da aplicação

| Variável | Obrigatória | Mecanismo | Onde é pedida | Se faltar |
|---|---|---|---|---|
| `dotenv.dir` (propriedade `-D`) ou `DOTENV_DIR` | Não | `System.getProperty`, depois `System.getenv` | `DatabaseConnection.pastaEnv`, na carga da classe | O `.env` é procurado em `./` (pasta de início da JVM). |
| `ENV_DEV` | Não (padrão `LOCAL`) | `dotenv` | `DatabaseConnection.java:24` (campo `PADRAO`), na carga da classe | Usa `LOCAL`. |
| `LOCAL_DB_URL` | Sim, se `ENV_DEV=LOCAL` | `dotenv` | `DatabaseConnection.getConnection(Ambiente)` → `ChaveObrigatoria` (`:40`), a cada conexão | `IllegalStateException: Variável de ambiente ausente ou vazia: LOCAL_DB_URL` |
| `LOCAL_USER` | Sim, se `ENV_DEV=LOCAL` | `dotenv` | idem | idem |
| `LOCAL_PASS` | Sim, se `ENV_DEV=LOCAL` | `dotenv` | idem | idem |
| `PROD_DB_URL` | Sim, se `ENV_DEV=PROD` | `dotenv` | idem | idem, com o prefixo `PROD_` |
| `PROD_USER` | Sim, se `ENV_DEV=PROD` | `dotenv` | idem | idem |
| `PROD_PASS` | Sim, se `ENV_DEV=PROD` | `dotenv` | idem | idem |
| `INITIAL_ADMIN_TOKEN` | Só para criar o 1º admin | `System.getenv` | `SetupAdminServlet.java:79` (`configurado`, no GET e no POST) e `:48` (comparação do token no POST) | `/setup/admin` responde 503 com o aviso de configuração indisponível. |

Detalhes:

- **`ENV_DEV`** aceita `LOCAL` ou `PROD`, sem diferenciar maiúsculas e ignorando espaços (`trim().toUpperCase()`).
  Ele escolhe o prefixo das três variáveis seguintes. Um valor diferente (ex.: `DEV`) faz `Ambiente.valueOf`
  falhar **na carga da classe** (`ExceptionInInitializerError`), e toda tentativa de acesso ao banco passa a
  falhar até o Tomcat ser reiniciado.
- **`<PREFIXO>_DB_URL`** é a URL JDBC completa, por exemplo `jdbc:mysql://localhost:3306/lava_rapido`.
- **Falta de variável do banco:** a mensagem diz em qual arquivo a variável foi procurada, por exemplo
  `... LOCAL_DB_URL (procurada nas variáveis do sistema e em /var/lib/tomcat10/.env)`. A `IllegalStateException`
  não é `SQLException`, então `WebSupport.erroBanco` não a trata. A resposta é a página 500 padrão do Tomcat, não `erro.jsp` (confirmado no smoke test). As páginas que
  não usam o banco (`/`, `/cadastro` no GET, `/login` no GET) continuam abrindo.
- **`INITIAL_ADMIN_TOKEN`:** o token digitado no formulário é comparado com `MessageDigest.isEqual`, que leva o
  mesmo tempo com qualquer entrada. Depois que existe um `ADMINISTRADOR`, `/setup/admin` responde 410 e a
  variável pode ser removida.

## 3. Variáveis do container (Dockerfile)

Não são lidas pelo código Java; servem para configurar o Tomcat dentro da imagem.

| Variável | Onde | Função |
|---|---|---|
| `PORT` | `Dockerfile:35` (`CMD`) | Injetada pelo Render. Vira `-Dport.http=${PORT:-10000}` em `CATALINA_OPTS`, e o `server.xml` usa `${port.http}` (alterado pelo `sed` da linha 20). Padrão: `10000`. |
| `JAVA_OPTS` | `Dockerfile:32` (`ENV`) | `-XX:MaxRAMPercentage=60 -XX:+UseSerialGC`: limita o heap para os 512 MB do plano gratuito do Render. Pode ser sobrescrita na execução. |
| `CATALINA_OPTS` | `Dockerfile:35` (`CMD`) | Montada pelo próprio `CMD` com `export`. Um valor definido de fora é **substituído**, não somado. |

O `.dockerignore` exclui o `.env`. Dentro do container, todas as variáveis da seção 2 precisam ser variáveis de
ambiente reais. Não defina `dotenv.dir`/`DOTENV_DIR` no Docker nem no Render.

---

## 4. Como definir em cada ambiente

### 4.1 Por que o `.env` da raiz do projeto não é lido sozinho

O WAR roda a partir de `webapps/` e não carrega nenhuma informação sobre onde está o código-fonte. A única pasta
que a aplicação conhece é a pasta onde a JVM foi iniciada. Por isso é preciso **dizer** onde está o `.env`, com
`-Ddotenv.dir=<raiz do projeto>` (ou `DOTENV_DIR`). Assim só o "ponteiro" fica na configuração do Tomcat, e as
credenciais continuam num único `.env`, na raiz do projeto.

Alternativas descartadas:

- **Empacotar o `.env` no WAR** (a `dotenv` também procura no classpath): a senha iria para o WAR e para a imagem
  Docker.
- **Gravar o caminho do projeto no build** (filtro do Maven com `${project.basedir}`): o WAR ficaria preso à máquina
  onde foi gerado, e no Docker o caminho seria `/build`.

### 4.2 Tomcat isolado, IDE ou `catalina.sh` na mão

Basta iniciar a partir da raiz do projeto ou passar a pasta. `INITIAL_ADMIN_TOKEN` vai como variável do processo:

```shell
CATALINA_OPTS="-Ddotenv.dir=/caminho/do/projeto" INITIAL_ADMIN_TOKEN='um-token-forte' $CATALINA_HOME/bin/catalina.sh run
```

Na IDE (configuração de execução do Tomcat), coloque `-Ddotenv.dir=<raiz do projeto>` nas *VM options* (no
IntelliJ, `$PROJECT_DIR$` funciona) ou use a raiz do projeto como *working directory*.

### 4.3 Tomcat do sistema (Debian/Ubuntu, `systemctl` `tomcat10`)

O `/usr/libexec/tomcat10/tomcat-start.sh` carrega `/etc/default/tomcat10` com `.` e faz `cd $CATALINA_BASE` antes
de iniciar. Sem configuração, o `.env` é procurado em **`/var/lib/tomcat10/.env`**. Para ler o `.env` do projeto,
são necessários três ajustes, todos com `sudo`.

**1. Apontar a pasta e corrigir o locale** em `/etc/default/tomcat10`:

```shell
JAVA_HOME=/usr/lib/jvm/temurin-25-jdk-amd64/
JAVA_OPTS="-Djava.awt.headless=true"
export LANG=C.UTF-8
export DOTENV_DIR="/home/kevyn/Documents/Faculdade/JAVA/LavaRápido/SplashFast"
export INITIAL_ADMIN_TOKEN='um-token-forte'   # só até criar o 1º administrador
```

- **`LANG=C.UTF-8` é obrigatório** enquanto o caminho tiver caracteres fora do ASCII (o `á` de `LavaRápido`).
  Um serviço do systemd começa com o locale `C`, e a JVM não consegue converter o caminho:
  `InvalidPathException: Malformed input or input contains unmappable characters`. O erro acontece na carga do
  `DatabaseConnection` e derruba todo acesso ao banco até o Tomcat ser reiniciado. `-Dsun.jnu.encoding=UTF-8` **não**
  resolve; o que resolve é o locale. (Outra saída: um caminho sem acento, como um link simbólico
  `ln -s ".../LavaRápido/SplashFast" ~/splashfast` e `DOTENV_DIR=/home/kevyn/splashfast`.)
- O `export` é necessário: sem ele, a variável não chega à JVM.
- `INITIAL_ADMIN_TOKEN` não é lido do `.env` (seção 1.2), por isso também vai aqui.
- A linha `JAVA_HOME` do arquivo atual está sem a `/` inicial (`usr/lib/...`). O Tomcat sobe mesmo assim, porque
  `tomcat-locate-java.sh` encontra o Java por outro caminho, mas vale corrigir.

**2. Dar ao usuário `tomcat` acesso de leitura ao `.env`.** Hoje `/home/kevyn` tem permissão `750`, e o usuário
`tomcat` não consegue nem entrar na pasta. As outras pastas do caminho já permitem a passagem (`x` para outros).

```shell
sudo setfacl -m u:tomcat:x /home/kevyn                 # só atravessar, sem listar
chmod 600 /caminho/do/projeto/.env                      # hoje está 664: qualquer usuário lê as senhas
sudo setfacl -m u:tomcat:r /caminho/do/projeto/.env
```

O serviço usa `ProtectSystem=strict`, que deixa `/home` só para leitura. É o que basta: não há `ProtectHome`.

**3. Reiniciar:** `sudo systemctl restart tomcat10`. Para conferir, um login com senha errada em
`http://localhost:8080/SplashFast/login` deve responder "E-mail ou senha inválidos" (401), e não uma página 500.
Se der 500, o log (`/var/log/tomcat10/localhost.*.log`) mostra em qual arquivo `.env` a variável foi procurada.

Alternativa sem `DOTENV_DIR`: exportar as próprias variáveis do banco (`ENV_DEV`, `LOCAL_*`) em
`/etc/default/tomcat10`. Funciona, mas duplica as credenciais fora do projeto.

### Verificação (Tomcat isolado, iniciado fora da pasta do projeto)

| Configuração | `POST /login` com senha errada |
|---|---|
| Sem `dotenv.dir` | 500: `LOCAL_DB_URL (procurada ... em <CATALINA_BASE>/.env)` |
| `-Ddotenv.dir=<raiz>` | 401: `.env` lido, banco consultado |
| `-Ddotenv.dir=<raiz>` e locale `C` | 500: `InvalidPathException` |
| `-Ddotenv.dir=<raiz>`, locale `C` e `-Dsun.jnu.encoding=UTF-8` | 500: `InvalidPathException` |
| `-Ddotenv.dir=<raiz>` e `LANG=C.UTF-8` | 401 |

### 4.4 Docker local

Nada é necessário no **build**. O estágio de build roda `mvn package -DskipTests` sem acessar o banco. As
variáveis entram só na **execução**. Não use `ARG`/`ENV` com senhas no `Dockerfile`: elas ficariam gravadas nas
camadas da imagem.

```shell
docker build -t splashfast .
docker run --env-file .env -e INITIAL_ADMIN_TOKEN=... -p 10000:10000 splashfast
```

- `--env-file` transforma o `.env` em variáveis reais, mas **não remove aspas**. `ENV_DEV="LOCAL"` chegaria com
  as aspas e faria `Ambiente.valueOf` falhar. No arquivo usado com Docker, escreva os valores sem aspas.
- Dentro do container, `localhost` é o próprio container. Para usar o MySQL da máquina, use
  `host.docker.internal` (com `--add-host=host.docker.internal:host-gateway` no Linux) ou `--network host`.

### 4.5 Render

No painel do serviço (Environment):

| Variável | Valor |
|---|---|
| `ENV_DEV` | `PROD` |
| `PROD_DB_URL`, `PROD_USER`, `PROD_PASS` | Dados do MySQL de produção |
| `INITIAL_ADMIN_TOKEN` | Token forte, só até criar o 1º administrador; depois pode ser removido |
| `PORT` | Não definir: o Render injeta |

---

## 5. Como se liga ao resto do projeto

```
.env (dotenv.dir/DOTENV_DIR ou ./) ─┐
                               ├─► Dotenv.get ─► DatabaseConnection ─► todas as DAOs
System.getenv ─────────────────┤   (sistema vence o .env)
                               └─► SetupAdminServlet (só System.getenv) ─► /setup/admin
Render/Docker: PORT ─► CMD ─► -Dport.http ─► server.xml (porta do Tomcat)
```

Documentos relacionados: `refatoracao-conexao.md` (criação do `DatabaseConnection` com `dotenv`),
`analise-geral-v1.md` (item 9) e `teste-ponta-a-ponta-tomcat-local.md` (teste feito só com variáveis de sistema).
