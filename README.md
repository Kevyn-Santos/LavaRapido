# LavaRapido

## Objetivo

Construir um site de lava rápido utilizando Servlets, JSP e BD numa arquitetura MVC(Model-View-Controller).

### Stack:
- Frontend - HTML  / CSS / JSP
- Backend: Java(Servlets)
- BD: MySQL
- WebServer: Tomcat(Necessário instalar)
- Gerenciador de dependências: Maven(Necessário instalar)

## Estrutura de pastas

Obs: Os arquivos `gitkeep` foram colocados nas pastas apenas para o git rastrea-las, eles podem ser tirados sem problemas.

```markdown
App/
├── pom.xml  <--- Gerenciador de dependências do JAVA
└── src/main/  <--- Diretório principal para o Backend
    ├── java/com/exemplo/web/
    │   ├── model/ <--- Diretório de modelos de dados; As representações no Backend das tabelas do BD
    │   │    
    │   ├── db/  <--- Diretório de conexão com BD;
    │   │
    │   └── servlet/ <--- Diretório dos endpoints(URLs) do site;
    │    
    │
    └── webapp/  <--- Diretório principal para o Frontend
            ├── index.jsp <--- JSP principal de acesso público
            └── WEB-INF/ <--- diretório de acesso as JSPs
                |
                ├── Assets <--- diretório de recursos adicionais
                |   ├── CSS/
                |   ├── Img/
                │                
                ├── views/  <--- diretório das JSPs
```

+ `model/` contém as representações das tabelas do Banco de dados para o Backend, bem como os métodos de inclusão e acesso de dados
+ `servlet/` contém os endpoints do site. Cada classe é um endpoint de URL que executa alguma ação para as Views.
+ `webapp` comporta todo o frontend. O que esta diretamente abaixo dele pode ser acessado pela URL se o usuário fizer a busca
+ `WEB-INF` Tudo o que esta dentro dele só pode ser acessado por um redirecionamento pelo servlet, ou seja, o usuário só pode entrar nessas páginas se o backend o redirecionar para cá. Por isso as JSPs e demais recursos do site devem ficar dentro desse diretório.
+ `Views` Aqui ficarão as JSPs feitas pelo frontend.

## Dependências

Esse projeto possui as seguintes depêndencias:
```xml
<!--JARKATA-->

<groupId>jakarta.servlet</groupId>
<artifactId>jakarta.servlet-api</artifactId>
<version>6.1.0</version>
<scope>provided</scope>

<!--MySQL Connector-->

<groupId>com.mysql</groupId>
<artifactId>mysql-connector-j</artifactId>
<version>9.7.0</version>

<!--Maven WAR plugin-->
<groupId>org.apache.maven.plugins</groupId>
<artifactId>maven-war-plugin</artifactId>
<version>3.5.1</version>

```
+ JARKATA - É uma biblioteca do Java para a criação de Servlets. Ela disponibiliza a api e recursos necessários para o desenvolvimento e manuseio de servlets e JSPs
+ MySQL Connector - A conexão com o banco de dados é feita através do JDBC, uma ‘interface’ que não reconhece o banco ao qual se conecta. Esse driver indica para o JDBC que é utilizado o MySQL.
+ O projeto usará o gerenciador de dependências `Maven`. Ele por padrão compila os projetos num arquivo `.jar`, mas o Tomcat não suporta esses arquivos. Este plugin faz com que o `maven` compile o projeto em `.WAR`, que pode ser lido e executado pelo tomcat.

## Banco de dados

### Requisitos

- MySQL 8.0.16 ou superior;
- MySQL Workbench ou outro cliente compatível com MySQL.

---

### Arquivos

#### `schema.sql`

Responsável por criar a estrutura do banco de dados.

Ele contém:

- criação do banco `lava_rapido`;
- criação das tabelas;
- chaves primárias;
- chaves estrangeiras;
- restrições `UNIQUE`;
- restrições `CHECK`;
- campos `ENUM`;
- índices;
- regras `ON DELETE` e `ON UPDATE`.

#### `seed.sql`

Responsável por inserir dados fictícios de desenvolvimento e testes.

O arquivo contém registros de exemplo para:

- clientes;
- veículos;
- serviços;
- agendamentos;
- serviços contratados;
- colaboradores;
- atendimentos;
- colaboradores vinculados aos atendimentos;
- pagamentos.

> **Importante:** o `seed.sql` deve ser executado em um banco recém-criado e vazio, logo após o `schema.sql`.

Os dados de relacionamento do `seed.sql` assumem que os campos `AUTO_INCREMENT` iniciam em `1`.

---

### Como criar o banco

#### 1. Executar o `schema.sql`

Abra o arquivo:

```text
database/schema.sql
```

Execute todo o conteúdo do arquivo.

O `schema.sql` será responsável pela criação do banco de dados `lava_rapido`, das tabelas e de todos os relacionamentos necessários.

#### 2. Executar o `seed.sql`

Após a criação do banco, abra o arquivo:

```text
database/seed.sql
```

Execute todo o conteúdo do arquivo.

Esse arquivo adiciona dados fictícios utilizados para desenvolvimento e testes.

---

### Ordem de execução

Os arquivos devem ser executados nesta ordem:

```text
schema.sql
    ↓
seed.sql
```

1. O `schema.sql` cria toda a estrutura do banco de dados.
2. O `seed.sql` adiciona os dados iniciais de desenvolvimento e testes.

---

### Observações

- O `schema.sql` deve ser executado antes do `seed.sql`.
- O `seed.sql` foi criado para ser executado em um banco recém-criado e vazio.
- Os IDs utilizados nos relacionamentos assumem que os campos `AUTO_INCREMENT` começam em `1`.
- Os pagamentos estão relacionados diretamente aos agendamentos.
- Dessa forma, um pagamento pode ser registrado antes da criação ou do início de um atendimento.
- A tabela `atendimento` representa a execução do serviço após o agendamento.
- A tabela `pagamento` armazena as informações referentes ao pagamento do agendamento.
- As formas de pagamento disponíveis no banco são `DINHEIRO`, `PIX`, `CREDITO` e `DEBITO`.
- Os dados presentes no `seed.sql` são fictícios e destinados apenas ao desenvolvimento e aos testes do sistema.

## Instalação:

A instalação do projeto é feita com o Maven, depois incluindo o Artifact do projeto na pasta de execução de sites do tomcat.

`mvn` são os comandos do maven. Estes compilarão o projeto e criarão a pasta `Target`.
```shell
# Na pasta raiz do projeto
mvn compile
mvn package
mvn install
```

Após a compilação é necessário incluir o war gerado em `$CATALINA_BASE/webapps`, aqui é onde ficam os Websites executados pelo tomcat.
Abaixo estão os comandos com os caminhos mais comuns de '$CATALINA_BASE/webapps' na instalação do tomcat no linux e no windows. 
Note que esses caminhos podem mudar dependendo da instalação, então na dúvida encontrem `$CATALINA_BASE/webapps` nos seus sistemas.

```shell

# Linux Debian / Ubuntu
sudo cp target/SplashFast-1.0.war /var/lib/tomcat10/webapps

# Windows. Rodando o CMD como admin 
xcopy "target/SplashFast-1.0.war" "C:\Program Files\Apache Software Foundation\Tomcat 10.x\webapps\" /E /H /C /I
```