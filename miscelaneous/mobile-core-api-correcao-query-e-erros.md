# app-mobile/core/api: correção da query string e das mensagens de erro

Registrado em 2026-11-15.

## Bugs corrigidos (achados pelos testes unitários locais de `app-mobile/test/api/`, não versionados)
1. **Query string perdida** (`api_client.dart`): `Uri.http(host, '/…/horarios?data=…')` codificava o `?` como `%3F`, então `HorarioApi.livres` nunca enviava `data`. `_uri` agora separa o endpoint com `Uri.parse` e passa `path` + `queryParameters`.
2. **Erro de leitura parecia falta de conexão** (`api_exception.dart`): `comTratamentoDeRede` capturava tudo como "Não foi possível conectar ao servidor.". Agora só `SocketException`, `http.ClientException` e `HandshakeException` usam essa mensagem; `FormatException`/`TypeError` viram "Resposta inesperada do servidor." e qualquer outro erro "Ocorreu um erro inesperado. Tente novamente."; os dois últimos vão para `debugPrint` com a pilha. Continua sempre `ApiException` para as telas.

## Atenção para o time Flutter
Se uma tela mostrar "Resposta inesperada do servidor." logo na primeira chamada, verifique ids não numéricos (os do `Repositorio` atual, como `veiculo_exemplo`, não servem para `AgendamentoApi.criar`) e o log do `debugPrint`.

`dart analyze lib test` limpo; `flutter test`: 64 testes passando (incluindo os locais).
