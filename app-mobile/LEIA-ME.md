# Fast Splash — aplicativo Flutter conectado à API

Este é o aplicativo mobile. Ele consome a API Java do projeto na pasta pai; a API é quem acessa o MySQL. Não coloque credenciais do banco no Flutter.

## Abrir no Android Studio

1. Inicie o Docker Desktop e o serviço MySQL no Windows.
2. Siga `../INTEGRACAO_MOBILE.md` para configurar `.env` e iniciar o backend com `docker compose up -d --build`.
3. No Android Studio, use **Open** e selecione esta pasta `app-mobile`.
4. Aguarde a sincronização e execute `flutter pub get` no terminal.
5. Inicie um emulador Android e pressione **Run**.

## Endereço da API

O padrão está configurado para o emulador: `http://10.0.2.2:8080/FastSplash/api/v1`. O endereço `10.0.2.2` aponta para o Windows host a partir do emulador. Não use `localhost` no emulador.

Para celular físico, computador e celular devem estar na mesma rede Wi-Fi. Use o IPv4 do computador:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8080/FastSplash/api/v1
```

Troque o IP de exemplo pelo IPv4 real. Para todos os passos, consulte `../INTEGRACAO_MOBILE.md`.

## Funcionalidades integradas à API

- Login por e-mail e senha com sessão `JSESSIONID`.
- Consulta e edição do perfil.
- Catálogo de serviços vindo do banco.
- Listagem, cadastro, edição e exclusão de veículos.
- Consulta de horários e criação/listagem/cancelamento de agendamentos.
- Registro de forma e status de pagamento.
- Acompanhamento do status atualizado pelo painel web.

O cadastro de cliente pelo app e o processamento financeiro real não fazem parte desta versão. O pagamento registra a informação no banco, mas não cobra cartão nem gera Pix real.
