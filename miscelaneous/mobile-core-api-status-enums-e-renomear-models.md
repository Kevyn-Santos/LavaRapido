# app-mobile/lib/core/api: enums de status, `cadastrar` com retorno e arquivos em snake_case

Registrado em 2026-11-15.

## O que foi feito
1. **Enums de status** em `core/api/model/status_enums.dart`: `StatusAgendamento`, `StatusAtendimento`, `StatusPagamento` e `FormaPagamento`. Cada um tem `valor` (texto da API) e `fromJson`, que devolve `null` para null/valor desconhecido (o app não quebra se a API ganhar um status novo). `FormaPagamento.doApp` lista as formas que o cliente pode enviar (PIX, CREDITO, DEBITO); `dinheiro` só chega do servidor.
2. **`AgendamentoModel`** agora lê `status` e `status_atendimento` (já devolvidos por `GET /agendamentos`) e usa enums também em `statusPagamento` e `formaPagamento`. Comentário de cabeçalho corrigido.
   - **Quebra de contrato no Dart:** `AgendamentoApi.pagar(id, forma:)` recebe `FormaPagamento` em vez de `String`.
3. **`VeiculoApi.cadastrar`** retorna `VeiculoModel` (o 201 já traz `id_veiculo`), sem precisar de `listar()` depois. `cor` é opcional (`String?`) e só é enviada se não estiver vazia.
4. **Arquivos de `model/` renomeados para snake_case:** `agendamento_model.dart`, `cliente_model.dart`, `servico_model.dart`, `veiculo_model.dart` (via `git mv`; imports atualizados). Branches Flutter abertas que importam os nomes antigos precisam ajustar o import.

`dart analyze lib`: só o aviso já existente `_futuroCliente` não usado em `perfil_cliente.dart`. Não há testes Dart para esses métodos.

## Por que / ligação com o projeto
Fecha as pendências 1, 2 e 6 de `mobile-core-api-ajustes-e-pendencias.md`, para o time Flutter ligar as telas (pendência 7) já com tipos fortes, sem strings soltas de status.

## Continua pendente (decisão: adiar)
- **`Clienteapi` → `ClienteApi`** (pendência 3): renomear, fixar `/usuarios`, `getCliente` espera lista mas a API devolve objeto (o perfil quebra), usar `comTratamentoDeRede`/`ApiException`. Afeta `login_cliente.dart` e `perfil_cliente.dart`.
- **HTTPS e ambiente** (pendência 4): `APIClient` usa `Uri.http` e `BASE_URI` fixo `10.0.2.2:8080`. Plano: `String.fromEnvironment` (`API_SCHEME`, `API_HOST`, `API_PATH`) em `api_config.dart`; no Render o contexto é `/` (`ROOT.war`), não `/SplashFast`.
- **Logout** (pendência 5): já existe, `Sessao.limpar()` chama `APIClient.limparSessao()` (usado em `perfil_cliente.dart`). Nada a fazer.
- **Telas** (pendência 7): ligar às classes de `core/api/`; atenção ao `Agendamento` do app com um serviço só vs. `id_servico[]`.
