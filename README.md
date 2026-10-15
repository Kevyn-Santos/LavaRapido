# Fast Splash

Frontend JSP preparado como aplicação WAR para Apache Tomcat 10.1 ou superior.

## Requisitos

- JDK 11 ou superior
- Maven 3.8 ou superior
- Apache Tomcat 10.1 ou superior

## Gerar o WAR

Na raiz do projeto, execute:

```sh
mvn clean package
```

O artefato será criado em `target/fast-splash.war`.

## Executar no Tomcat

Copie `target/fast-splash.war` para a pasta `webapps` do Tomcat e inicie o servidor. A aplicação ficará disponível em:

```text
http://localhost:8080/fast-splash/
```

O `index.jsp` está configurado como página inicial. HTML foi convertido para JSP; CSS e JavaScript são entregues como arquivos estáticos dentro de `src/main/webapp`.

## GitHub

O GitHub pode armazenar e versionar este projeto, mas o GitHub Pages não executa JSP. Para acessar as páginas JSP, publique o WAR em um servidor Java, como Apache Tomcat. O projeto atual é somente frontend: não implementa autenticação real, persistência no servidor ou banco de dados. Agendamentos de demonstração continuam salvos no `localStorage` do navegador.
