# Testes do DatabaseConnection e de integração com MySQL real (Fase 4, parte 5 — fecha a Fase 4)

Registrado em 15/11/2026 13:32.

## O que foi feito
Suíte de **279 para 305 testes** (287 sem integração + 18 de integração), todos passando. Não foi preciso corrigir código.

### `DatabaseConnection` (8 testes, sem banco)
`db/DatabaseConnectionTest` + `DatabaseConnectionProbe`. Como a classe lê o ambiente ao carregar, cada cenário roda numa **JVM nova** (`ProcessBuilder`) com ambiente controlado e uma pasta de `.env` temporária (`-Ddotenv.dir`): o `.env` real nunca é lido e nenhuma conexão real é aberta (as URLs apontam para uma porta fechada). Cobre: variável ausente (`IllegalStateException` com o nome da variável e o caminho do `.env`), as três variáveis obrigatórias, valor em branco, `SQLException` propagada sem embrulhar, leitura do `.env`, `ENV_DEV=PROD` exigindo `PROD_*`, variável de ambiente vencendo o `.env`, `getConnection(Ambiente)` ignorando `ENV_DEV` e `ENV_DEV` inválido.

### Integração com MySQL real (18 testes)
- `db/integracao/IntegracaoDaosTest` (17): conexão; cliente (BCrypt real, SQLState 23 em CPF duplicado, remoção lógica); veículo (id gerado, placa normalizada, placa duplicada); serviço; agendamento (transação completa com atendimento e pagamento, recusas sem gravar nada, um por horário, cancelar libera o horário, cancelar só do dono, **concorrência: duas reservas simultâneas do mesmo horário, só uma vence**); atendimento (ciclo completo com datas e conclusão do agendamento, só OPERACIONAL vinculado); pagamento; colaborador (login, duplicado, remoção lógica, **administrador inicial com `GET_LOCK` real**, último administrador protegido, atualização parcial).
- `api/v1/FluxoApiIntegracaoTest` (1): fluxo do app com os **servlets reais da API e o banco real**: login (401/200 e sessão), serviços, veículo (201 sem cor, 409, 422), horários (24 → 23), agendamento 201, conflito 422, fora da grade 422, lista, cancelar 200/404, horário liberado, perfil (200/422) e exclusão de veículo.
- O `database/schema.sql` foi executado de verdade (sem as linhas `CREATE DATABASE`/`USE`) e criou todas as tabelas sem erro em MySQL 8.4.

## Como rodar
- **Comum (`mvn test`)**: os de integração são ignorados (`TESTE_INTEGRACAO` ausente); 287 testes, sem banco.
- **Com integração**: `bash miscelaneous/testes-integracao.sh` sobe um MySQL 8.4 descartável em Docker (porta 33307, banco `lava_rapido_teste`), roda `mvn test` com as variáveis certas e remove o container. Dá para passar argumentos ao Maven (`-Dtest=...`). Manual: exportar `TESTE_INTEGRACAO=1`, `LOCAL_DB_URL`, `LOCAL_USER`, `LOCAL_PASS` (as variáveis de ambiente valem mais que o `.env`).
- **Trava de segurança**: o nome do banco em `LOCAL_DB_URL` precisa terminar em `_teste`; senão o teste falha antes de conectar ("Recusado ... Nada foi alterado"), pois os testes apagam e recriam as tabelas. Verificado com `.../lava_rapido`. O banco do seu `.env` e o MySQL local do sistema não foram usados nem tocados.

## Limites
- Não há Tomcat nem HTTP real: os servlets são chamados direto com request/response falsos (o `ApiAuthFilter` tem teste próprio). O próximo passo, o roteiro de `curl`, cobre HTTP e cookie reais.
- O ramo com `INITIAL_ADMIN_TOKEN` de `/setup/admin` e os JSPs seguem sem teste.
- A imagem `mysql:8.4` ficou baixada no Docker local (~800 MB); `docker rmi mysql:8.4` libera o espaço.
- Os testes continuam fora do git (`/src/test/` no `.gitignore`); o script `miscelaneous/testes-integracao.sh` está versionado, mas só funciona com os testes na máquina.

## Ligação com o projeto
Fecha a Fase 4 de `plano-pendencias-api-mobile.md` (continua `testes-api-mobile.md`, `testes-daos.md`, `testes-servlets-site-painel.md`, `testes-modelos-passwords.md`). Valida contra o banco real as regras novas de `horarios-api-mobile.md`, `cancelar-agendamento-api-mobile.md` e `validacao-placa-dao-veiculo.md`.
