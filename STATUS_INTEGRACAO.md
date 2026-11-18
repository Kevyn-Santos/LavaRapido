# Status da integração Flutter + API + MySQL

## Configuração consolidada nesta entrega

- Flutter usa `http://10.0.2.2:8080/FastSplash/api/v1` por padrão no emulador.
- A API Java lê as configurações de banco do `.env`/ambiente do container.
- `docker-compose.yml` inicia o backend e publica `8080:10000`.
- Dockerfile usa Tomcat 11 com Java 25, compatível com Jakarta Servlet 6.1.
- O WAR é publicado como `FastSplash.war`, mantendo o contexto `/FastSplash` esperado pelo Flutter.
- O MySQL permanece no Windows; o container acessa o host por `host.docker.internal`.
- `database/cliente_teste_joao.sql` atualiza apenas o cliente de teste João, se ele já existir.

## Funcionalidades mobile já implementadas no código

- Login por CPF/senha e cookie `JSESSIONID`.
- Perfil, catálogo, veículos, horários, agendamentos, cancelamento e registro de pagamento via API.
- O estado mobile não mantém listas fictícias de serviços, veículos ou agendamentos como fonte de dados.

## Limites funcionais conhecidos

- Cadastro de cliente pela API mobile não existe; cadastro permanece no site.
- Pagamento apenas registra forma/status, sem gateway financeiro real.
- Notificações e estorno automático não implementados.

## Validação pendente no computador do usuário

O arquivo ZIP foi inspecionado e as configurações foram alinhadas estaticamente. Este ambiente não tem Flutter nem Docker disponíveis, portanto não foi possível executar `flutter pub get`, `flutter test`, compilar a imagem Docker ou validar uma consulta real ao MySQL. A confirmação final depende de executar os passos em `INTEGRACAO_MOBILE.md` no Windows com Docker Desktop, MySQL e Android Studio.
