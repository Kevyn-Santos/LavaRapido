# LavaRapido

### Objetivo

Construir um site de lava rápido utilizando Servlets, JSP e BD numa arquitetura MVC(Model-View-Controller).

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