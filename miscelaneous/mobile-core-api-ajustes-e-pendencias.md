# app-mobile/lib/core/api: ajustes feitos e pendências

Registrado em 2026-11-15 15:20.

## Feito
Alinha o cliente HTTP do Flutter com a API depois das mudanças de `api-datas-iso-status-e-patch-veiculo.md` e `pagamento-api-mobile.md`.
1. **Datas ISO.** `AgendamentoModel.fromJson` lê `data_agendamento` como `yyyy-MM-dd` (antes quebrava com `yyyy/MM/dd`) e `AgendamentoApi.criar` envia `yyyy-MM-dd` (antes `dd/MM/yyyy`, que agora dá 400).
2. **Métodos novos.**
   - `AgendamentoApi.cancelar(id)` → `POST /agendamentos/{id}/cancelar`.
   - `AgendamentoApi.pagar(id, forma: 'PIX'|'CREDITO'|'DEBITO')` → `POST /agendamentos/{id}/pagar`; 409 = já processado, recarregar com `listar()`.
   - `HorarioApi.livres(DateTime)` (arquivo novo `horario_api.dart`) → `GET /horarios?data=yyyy-MM-dd`.
   - `VeiculoApi.atualizar(id, {placa, marca, modelo, cor})` → `PATCH /veiculos/{id}`, devolve o `VeiculoModel`.
- `dart analyze lib/core/api`: sem problemas. Não há testes Dart para esses métodos e as telas ainda não os chamam.

## Pendências (não feitas)
1. **`AgendamentoModel` sem `status` e `status_atendimento`** que o `GET /agendamentos` já devolve; criar enums no Dart. Corrigir também o resto do comentário de cabeçalho.
2. **`VeiculoApi.cadastrar`:** o 201 já traz `id_veiculo` (ver `ajuste-veiculos-api-mobile.md`), então deve retornar `VeiculoModel` em vez de exigir `listar()` de novo; `cor` é opcional na API mas obrigatória no Dart.
3. ~~**`Clienteapi`**~~ **Resolvida** em `mobile-core-api-cliente-api.md` (`ClienteApi.buscar()` devolve objeto; `atualizar` por PATCH).
4. **HTTPS e ambiente:** `APIClient` usa `Uri.http` (sem TLS), o que impede o uso no Render; `BASE_URI` fixo em `10.0.2.2:8080` (só emulador). Adicionar opção de esquema/host em `api_config.dart`.
5. **Logout:** não há rota no servidor (fora de escopo), mas o app precisa de um ponto que chame `APIClient.limparSessao()`.
6. **Nomes dos arquivos em `model/`** misturam PascalCase e camelCase.
7. **Telas:** `Repositorio` em memória ainda é a fonte de dados; ligar as telas às classes de `core/api/` (inclui o `Agendamento` do app ter um único serviço, enquanto a API devolve `id_servico[]`).

Fora de escopo por decisão do grupo: estorno ao cancelar agendamento pago e notificações.
