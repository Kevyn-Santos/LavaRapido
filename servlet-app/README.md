

- JDK 17
- Maven
- MySQL 8+



Execute `../src/main/resources/schema.sql` em uma instância MySQL. A aplicação usa estas variáveis de ambiente:

| Variável | Padrão |
| --- | --- |
| `DB_URL` | `jdbc:mysql://localhost:3306/lava_rapido?useUnicode=true&characterEncoding=UTF-8&serverTimezone=America/Sao_Paulo` |
| `DB_USER` | `root` |
| `DB_PASSWORD` | vazio |
| `INITIAL_ADMIN_TOKEN` | não definido |

Defina `INITIAL_ADMIN_TOKEN` com um valor forte antes de iniciar a aplicação. A primeira conta administrativa é criada uma única vez em `/setup/admin`, usando esse token; depois da criação, o endpoint é bloqueado. Não compartilhe nem registre o token.


Na pasta do projeto:

```powershell
mvn clean package
mvn jetty:run
```

Abra `http://localhost:8080/`. Clientes podem criar conta, cadastrar, editar e remover veículos e agendar serviços. A equipe entra em `/colaborador/login`; administradores podem cadastrar, editar e remover serviços e colaboradores, enquanto atendentes administram pagamentos e a equipe operacional atualiza os atendimentos.

O pagamento é registrado manualmente no sistema; não há integração com adquirente ou processamento de cartão/PIX.
