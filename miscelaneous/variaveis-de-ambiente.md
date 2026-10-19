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

- Lê o arquivo `.env` da **pasta onde a JVM foi iniciada** (`./`, padrão da biblioteca), e não da pasta do projeto.
  `ignoreIfMissing()` faz com que a falta do arquivo não seja erro.
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
- **Falta de variável do banco:** a `IllegalStateException` não é `SQLException`, então `WebSupport.erroBanco` não
  a trata. A resposta é a página 500 padrão do Tomcat, não `erro.jsp` (confirmado no smoke test). As páginas que
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
ambiente reais.

---

## 4. Como definir em cada ambiente

### 4.1 Tomcat isolado, IDE ou `catalina.sh` na mão

O `.env` precisa estar na pasta de onde o Tomcat é iniciado. `INITIAL_ADMIN_TOKEN` vai como variável do processo:

```shell
cd /caminho/do/projeto          # pasta que contém o .env
INITIAL_ADMIN_TOKEN='um-token-forte' $CATALINA_HOME/bin/catalina.sh run
```

### 4.2 Tomcat do sistema (Debian/Ubuntu, `systemctl` `tomcat10`)

O `/usr/libexec/tomcat10/tomcat-start.sh` faz `cd $CATALINA_BASE` antes de iniciar. Por isso a `dotenv` procura
**`/var/lib/tomcat10/.env`**, e não o `.env` do projeto (hoje esse arquivo não existe). Duas opções:

- copiar o `.env` para `/var/lib/tomcat10/.env`, legível pelo usuário `tomcat` (vale só para as variáveis da
  `dotenv`); **ou**
- exportar as variáveis em `/etc/default/tomcat10`, que o script carrega com `.`. É preciso usar `export`, senão
  elas não chegam à JVM. **É a única forma de passar `INITIAL_ADMIN_TOKEN`** nesse Tomcat:

  ```shell
  export ENV_DEV=LOCAL
  export LOCAL_DB_URL=jdbc:mysql://localhost:3306/lava_rapido
  export LOCAL_USER=...
  export LOCAL_PASS=...
  export INITIAL_ADMIN_TOKEN=...
  ```

  Depois: `sudo systemctl restart tomcat10`. (Uma alternativa é `systemctl edit tomcat10` com linhas `Environment=`.)

Observação: em `/etc/default/tomcat10`, `JAVA_HOME=usr/lib/jvm/temurin-25-jdk-amd64/` está sem a `/` inicial.
O Tomcat sobe com o Java 25 mesmo assim (`tomcat-locate-java.sh` encontra outro caminho), mas vale corrigir.

### 4.3 Docker local

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

### 4.4 Render

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
.env (pasta de início da JVM) ─┐
                               ├─► Dotenv.get ─► DatabaseConnection ─► todas as DAOs
System.getenv ─────────────────┤   (sistema vence o .env)
                               └─► SetupAdminServlet (só System.getenv) ─► /setup/admin
Render/Docker: PORT ─► CMD ─► -Dport.http ─► server.xml (porta do Tomcat)
```

Documentos relacionados: `refatoracao-conexao.md` (criação do `DatabaseConnection` com `dotenv`),
`analise-geral-v1.md` (item 9) e `teste-ponta-a-ponta-tomcat-local.md` (teste feito só com variáveis de sistema).
