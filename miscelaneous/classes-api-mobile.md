# Classes de API do app (veículos, agendamentos, serviços) e DELETE no APIClient

Registrado em 2026-11-14 22:01.

## O que mudou (`app-mobile/lib/core/api`)
- `api_client.dart`: novo `delete(endpoint)`, com o mesmo cookie de sessão e o mesmo tratamento de 401 dos outros métodos.
- `api_exception.dart`: `ApiException.deResposta(resposta)` lê o `{"erro": "..."}` do servidor; `comTratamentoDeRede(...)` converte timeout e falha de conexão em `ApiException` com mensagem amigável (antes repetido no `login`).
- `veiculo_api.dart` (`listar`, `cadastrar`, `excluir`), `agendamento_api.dart` (`listar`, `criar`), `servico_api.dart` (`listar`): antes arquivos vazios. Nenhuma chamada recebe ou envia o id do cliente; o servidor o tira da sessão (ver `autenticacao-sessao-api-mobile.md`).
- `model/`: `veiculoModel.dart` reescrito (`VeiculoModel`, chaves `id_veiculo`/`marca`; o anterior usava `id`/`clienteId` e não batia com a API), novos `ServicoModel.dart` e `AgendamentoModel.dart`.

## Por que
O login por sessão estava pronto, mas as demais telas ainda usavam o `Repositorio` em memória. Estas classes são a camada que as telas passarão a chamar no lugar dele.

## Detalhes que a integração das telas precisa respeitar
- O servidor exige **`marca`** ao cadastrar veículo e **`cor`** não nula; a tela atual de veículos só tem modelo, placa e cor.
- `POST /veiculos` responde 201 **sem o id** do veículo novo: depois de `cadastrar`, chamar `listar` de novo.
- `POST /agendamentos` espera a data `dd/MM/yyyy` e ids numéricos (a classe converte); `GET` devolve a data como `yyyy/MM/dd`.
- Cancelar agendamento ainda não existe no app. O servidor já implementa `POST /agendamentos/{id}/cancelar` (200/404; `cancelar-agendamento-api-mobile.md`); falta o método em `agendamento_api.dart` (time mobile).
- O app ainda usa `Servico`/`Veiculo`/`Agendamento` de `core/models` nas telas; os `*Model` da API são separados e a conversão fica para a integração das telas. As telas continuam usando `Repositorio`.

## Ligação com o projeto
Continua `plano-requisicoes-mobile-api.md` (pasta `lib/core/api/`, um arquivo por recurso) e usa a sessão de `autenticacao-sessao-api-mobile.md`. Verificado só com `dart analyze` (sem erros novos); não testado contra o Tomcat.
