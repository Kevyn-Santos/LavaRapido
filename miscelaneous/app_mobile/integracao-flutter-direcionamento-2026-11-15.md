# Integração do app Flutter com a API: o que mudou e como seguir

> Registrado em 15/11/2026. Direcionamento para o time Flutter. Detalhes das rotas: `miscelaneous/openapi.yml`.
> Execução toda em ambiente **local** (emulador + Tomcat + MySQL); HTTPS/Render está fora de escopo e `api_config.dart` fica como está
> (`10.0.2.2:8080` no emulador; em celular físico troque `BASE_URI` pelo IP da máquina).

## 1. O que mudou na API

| Rota | Mudança |
|---|---|
| `GET /agendamentos` | Datas em ISO `yyyy-MM-dd`. Agora traz `status` (AGENDADO, CANCELADO, CONCLUIDO) e `status_atendimento` (null, AGUARDANDO, EM_LAVAGEM, FINALIZADO, ENTREGUE), além de `status_pagamento` e `forma_pagamento`. Serviços vêm como `id_servico[]`, `servicos[{id_servico, nome, valor}]` e `total_servico`. |
| `POST /agendamentos` | Data enviada como `yyyy-MM-dd` (o formato `dd/MM/yyyy` agora dá 400). |
| `POST /agendamentos/{id}/cancelar` | Novo. 404 se não existir, for de outro cliente ou não estiver mais `AGENDADO`. |
| `POST /agendamentos/{id}/pagar {forma}` | Novo. `PIX`, `CREDITO` ou `DEBITO` (`DINHEIRO` é só do atendente, no site). **409** = pagamento já processado (o atendente pode ter marcado no site, ou foi cancelado): recarregar a lista. |
| `GET /horarios?data=yyyy-MM-dd` | Novo. Lista `["06:00", "06:30", ...]` livre (grade 06:00–17:30, de 30 em 30 min). Data passada = `[]`; hoje = só o que ainda não passou. |
| `PATCH /veiculos/{id}` | Novo. Campos opcionais `placa, marca, modelo, cor`; devolve o veículo. |
| `POST /veiculos` | O 201 devolve o veículo completo, com `id_veiculo`. `cor` é opcional. |
| `GET /usuarios` | Devolve **um objeto** `{id, nome, cpf, telefone, email}`, não uma lista. `PATCH /usuarios {nome?, telefone?, email?}`. |

Regra geral: o app **nunca** envia o id do cliente; o servidor usa a sessão (cookie `JSESSIONID`, guardado pelo `APIClient`). Erros são sempre `{"erro": "mensagem"}` e viram `ApiException.mensagem`, pronta para mostrar ao usuário. Um 401 fora de `/auth/*` já dispara `APIClient.aoSessaoExpirar` (volta ao login), então as telas não precisam tratá-lo.

## 2. O que já está pronto no Dart (`lib/core/api/`)

- `ClienteApi`: `login`, `buscar()` (objeto), `atualizar({nome?, telefone?, email?})`.
- `ServicoApi.listar()` (público), `VeiculoApi` (`listar`, `cadastrar` → `VeiculoModel`, `atualizar`, `excluir`), `AgendamentoApi` (`listar`, `criar`, `cancelar`, `pagar(id, forma: FormaPagamento)`), `HorarioApi.livres(DateTime)`.
- `model/status_enums.dart`: `StatusAgendamento`, `StatusAtendimento`, `StatusPagamento`, `FormaPagamento` (use `FormaPagamento.doApp` para as opções do cliente). Status desconhecido vira `null`.
- Arquivos de `model/` em snake_case (`agendamento_model.dart` etc.).
- Testes de exemplo com `MockClient`: `test/cliente_api_test.dart`.
- No app: `Veiculo` agora tem `marca` (modelo, formulário e listas); `Sessao.limpar()` (logout) também chama `Repositorio.limpar()`, que apaga veículos e agendamentos em memória (o catálogo de serviços fica).

## 3. Como ligar as telas

**Ideia central:** manter os `ValueNotifier` do `Repositorio` e fazer dele a camada que fala com a API. As telas continuam em `ValueListenableBuilder`; só as ações viram `Future`. Cada ação: chama a API → só se der certo atualiza o notifier (ou recarrega com `listar()`). Nunca atualizar a memória antes: o servidor pode recusar. Cada tela passa a precisar de estado de carregando e de erro (`SnackBar` com `ApiException.mensagem`).

Ordem sugerida (do menos ao mais arriscado):
1. **Serviços:** `ServicoApi.listar()` ao abrir o app → `Repositorio.definirServicos` (já existe para isso).
2. **Pós-login:** carregar veículos e agendamentos nos notifiers. O logout já limpa (ver item 2).
3. **Veículos** (`meus_veiculos.dart`): `cadastrar`, `atualizar`, `excluir`. Mostrar a mensagem do servidor em 409 (placa repetida) e 422.
4. **Novo agendamento:** horários (item 5 abaixo) e `AgendamentoApi.criar`.
5. **Cancelar e pagar:** `cancelar` e, em seguida, `listar()` (o agendamento continua existindo como `CANCELADO`, não some). `pagar` com tratamento do 409.
6. **Acompanhamento:** mapear os status (item 4 abaixo) e remover o botão de demonstração que avança o status.

## 4. Pontos de divergência modelo do app × API

| Tema | Situação | Quem |
|---|---|---|
| **Serviços do agendamento** | O `Agendamento` do app tem 1 `Servico`; a API devolve `servicos[]` (nome e valor de cada um). Decisão: o app **lista todos os serviços**. API e `AgendamentoModel` prontos; falta o modelo/telas do app. Ver seção 5. | Flutter |
| **IDs e dados de exemplo** | IDs locais (`veiculo_exemplo`, `servico_1`) devem sair; passam a ser o id numérico do banco em texto (os models de `core/api/` já fazem isso). Remover o veículo e os 4 serviços fictícios do `Repositorio`. | Flutter |
| **Marca do veículo** | A API exige `marca`. Campo adicionado ao modelo `Veiculo`, ao formulário e às listas. | Feito |
| **Horário** | O app usa `showTimePicker` (qualquer minuto); a API só aceita a grade de 30 em 30 min. Ver seção 6. | A alinhar com o Flutter |
| **Status** | O app tem `StatusServico` (pendente, em andamento, concluído); a API tem 3 status independentes. Sugestão: `status == CANCELADO` → cancelado; `status_atendimento == null` ou `AGUARDANDO` → "Agendado"; `EM_LAVAGEM` → "Em andamento"; `FINALIZADO`/`ENTREGUE` → "Concluído". Quem avança o atendimento é o atendente no site. | Flutter |
| **Pagamento** | Hoje só marca `pago = true`. Deve chamar `pagar` e, em 409, avisar e recarregar. | Flutter |
| **Logout** | `Sessao.limpar()` limpa sessão, cookie e dados em memória. | Feito |

## 5. Vários serviços por agendamento (consulta) — implementado (opção B)

`GET /agendamentos` agora devolve, além de `id_servico[]` e `total_servico` (mantidos), o campo
`servicos: [{id_servico, nome, valor}]`. O `valor` é o **valor praticado** na época do agendamento
(`agendamento_servico.valor_praticado`), não o preço atual do catálogo; a soma dos `valor` é o `total_servico`.
A tela não depende do catálogo para listar os itens.

- **Dart (feito):** `AgendamentoModel.servicos` é uma `List<ServicoDoAgendamento>` (`id`, `nome`, `valor`). Exemplo em `test/agendamento_api_test.dart`.
- **Falta no app (Flutter):** o modelo `Agendamento` da UI (`core/models/agendamento.dart`) ainda tem um único `Servico servico`; trocar por uma lista de serviços (nome + valor) e mostrar todos nas telas de agendamentos, acompanhamento e início (`proximoAgendamento`).
- **Criar:** nada mudou na API (`AgendamentoApi.criar` já aceita `idServicos` em lista). A tela de novo agendamento só precisa permitir selecionar mais de um serviço.

## 6. A alinhar com o time Flutter

- Seletor de horário: trocar `showTimePicker` por lista de chips/dropdown alimentada por `HorarioApi.livres(data)`, recarregada ao mudar a data; tratar lista vazia ("sem horários neste dia").
- Quem adapta o `Agendamento` da UI à lista de serviços (seção 5) e o mapeamento de status da seção 4.
- Se o fluxo de pagamento fica na tela atual ou numa tela nova.

## 7. Fora de escopo (decisão do grupo)

Logout no servidor, cadastro pela API, CORS, estorno ao cancelar agendamento pago, notificações, HTTPS/Render.
