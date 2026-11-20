flutter pub get# Fast Splash — execução integrada (MySQL + API Java + Flutter)

Este projeto está preparado para o Flutter conversar com a API Java, e a API acessar o MySQL. **O aplicativo Android não acessa o MySQL diretamente** e não deve conter usuário ou senha do banco.

## 1. O que precisa estar instalado no Windows

- MySQL Server 8.0 ou superior (serviço `MySQL80` iniciado);
- Docker Desktop aberto e em execução;
- Android Studio com o plugin Flutter e o SDK Flutter configurados;
- um emulador Android criado no Android Studio ou um celular Android.

A API é executada no Docker usando Java 25 e Tomcat 11 (compatível com Jakarta Servlet 6.1). O banco continua sendo o MySQL instalado no Windows.

## 2. Preparar o banco (somente se ainda não existir)

No MySQL Workbench, execute nesta ordem, apenas se o banco ainda não tiver sido criado:

1. `database/schema.sql`
2. `database/seed.sql`

**Não execute o `seed.sql` novamente em um banco que já contém os dados.** Ele insere registros e pode duplicar os dados.

### Atualizar o cliente João para login de teste

Se você já executou o schema e o seed e o cliente João existe, execute uma única vez `database/cliente_teste_joao.sql` no MySQL Workbench. O script atualiza somente `id_cliente = 1` com o e-mail de teste conhecido; não apaga veículos nem agendamentos.

Credenciais de teste após executar o script:

- E-mail: `joao.silva@teste.com`
- Senha: `Joao@123456`
- CPF sintético: `29342140955`

O CPF passa pela validação matemática local do app, mas é apenas um dado sintético de teste, não uma confirmação de que foi emitido pela Receita Federal.

## 3. Configurar a conexão da API com o MySQL

Na pasta raiz `FastSplash-integrado`, copie `.env.example` e dê ao arquivo copiado exatamente o nome `.env` (sem `.txt`). Abra `.env` e preencha `LOCAL_PASS` com a senha do usuário MySQL `fast_splash_app` já criado no seu servidor. Não coloque a senha do usuário `root` no aplicativo Flutter.

O conteúdo deve seguir este formato:

```dotenv
ENV_DEV=LOCAL
LOCAL_DB_URL=jdbc:mysql://host.docker.internal:3306/lava_rapido
LOCAL_USER=fast_splash_app
LOCAL_PASS=SUA_SENHA_CONFIGURADA_PARA_FAST_SPLASH_APP
```

`host.docker.internal` é importante: dentro do container, `localhost` apontaria para o próprio container, não para o Windows.

O usuário MySQL `fast_splash_app` precisa ter permissão no banco `lava_rapido` e aceitar conexões originadas pelo Docker. Se o MySQL responder `Access denied`, verifique no MySQL Workbench o host permitido para esse usuário (por exemplo, `%`) e as permissões. Não envie o conteúdo do `.env` para ninguém.

## 4. Iniciar a API (Docker)

1. Abra o Docker Desktop e espere aparecer como em execução.
2. Abra o CMD na pasta raiz `FastSplash-integrado` (a mesma pasta onde está `docker-compose.yml`).
3. Remova o container antigo, caso ainda exista (isso não apaga o MySQL nem os dados do banco):

```bat
docker rm -f fast-splash-backend
```

4. Execute:

```bat
docker compose up -d --build
```

Na primeira vez, o Docker baixa as imagens e compila a API; pode demorar alguns minutos. Se o container antigo não existir, o comando de remoção apenas informará que ele não foi encontrado; prossiga normalmente. O container publica o Tomcat na porta `8080` do Windows e o WAR usa o contexto `/FastSplash`.

Confira se está ativo:

```bat
docker compose ps
```

Se precisar consultar o log:

```bat
docker compose logs -f backend
```

Para parar a API:

```bat
docker compose down
```

Não é necessário iniciar outro Tomcat instalado no Windows ao mesmo tempo. Use o backend do Docker descrito aqui.

## 5. Abrir e executar o aplicativo no Android Studio

1. No Android Studio, escolha **Open**.
2. Selecione a pasta `app-mobile` que está dentro de `FastSplash-integrado` (não selecione a pasta `android`).
3. Aguarde o Android Studio reconhecer o projeto Flutter e sincronizar.
4. Abra o terminal integrado do Android Studio e execute:

```bat
flutter pub get
```

5. Inicie um emulador Android pelo Device Manager.
6. Selecione o dispositivo na barra superior e pressione **Run**.

A URL padrão em `app-mobile/lib/core/api/api_config.dart` é:

```text
http://10.0.2.2:8080/FastSplash/api/v1
```

No emulador, `10.0.2.2` aponta para o Windows host. Não troque por `localhost`.

### Usar celular físico

O computador e o celular devem estar na mesma rede Wi-Fi. Descubra o IPv4 do computador com `ipconfig` e execute no terminal do Android Studio, substituindo o IP:

```bat
flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8080/FastSplash/api/v1
```

Se necessário, permita conexões de entrada na porta 8080 no Firewall do Windows para a rede privada.

## 6. Teste de ponta a ponta

Com MySQL, Docker e emulador ligados:

1. Abra o Fast Splash no emulador.
2. Entre com `joao.silva@teste.com` e `Joao@123456` (depois de executar o SQL de atualização do João).
3. Confira o catálogo de serviços.
4. Abra **Perfil > Meus veículos** para consultar e cadastrar veículos.
5. Crie um agendamento: o app consulta os horários livres, envia o veículo e os serviços à API, e a API grava no MySQL.
6. Confira o agendamento na aba Agenda.
7. Teste cancelamento e registro de pagamento de teste.
8. Confira os dados no site/painel ou no MySQL Workbench.

## 7. O que está ligado e limites atuais

- Login por e-mail e senha, com sessão HTTP (`JSESSIONID`) mantida pelo Flutter.
- Perfil do cliente consultado e atualizado pela API.
- Catálogo de serviços consultado no banco.
- Veículos: listar, cadastrar, editar e excluir pela API.
- Horários livres consultados na API.
- Agendamentos: listar, criar e cancelar pela API.
- Registro da forma/status de pagamento no banco.
- Acompanhamento do status atualizado pelo painel web.

Limites: cadastro de cliente pelo mobile não existe nesta versão (use o cadastro web); pagamento apenas registra a informação no sistema, sem gateway, QR Code Pix ou cobrança real; notificações e estorno automático não estão implementados. O login é por e-mail, não por CPF.

## 8. Diagnóstico rápido

- **Não foi possível conectar:** confirme que o Docker Desktop está ativo e `docker compose ps` mostra o backend em execução.
- **HTTP 404:** confirme a URL com `/FastSplash/api/v1` e veja os logs do backend.
- **HTTP 401 no login:** confira e-mail, senha e se o script `cliente_teste_joao.sql` foi executado. As senhas placeholder do seed não autenticam.
- **HTTP 401 depois do login:** entre novamente; a sessão pode ter expirado.
- **HTTP 500 / erro de banco:** confira o `.env`, as permissões do usuário MySQL `fast_splash_app` e os logs com `docker compose logs -f backend`.
- **Porta 8080 ocupada:** pare o outro Tomcat/serviço que esteja usando a porta ou ajuste o lado esquerdo do mapeamento em `docker-compose.yml` e a URL `API_BASE_URL` do Flutter.

A configuração HTTP sem TLS do Manifest é apenas para desenvolvimento local. Para produção, publique a API em HTTPS e remova `usesCleartextTraffic="true"`.
