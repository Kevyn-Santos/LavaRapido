# `flutter analyze` em `app-mobile/` — erros, origem e correção (2026-11-18)

Comando: `cd app-mobile && flutter analyze --no-pub` (3 issues, 1,7 s).

## Por que registrar

O app Flutter (`flash_splash`) está sendo ligado à API `/api/v1/*` (ver `integracao-flutter-direcionamento-2026-11-15.md`). O commit `436b31a` ("Integra login de cliente por CPF") deixou a análise estática quebrada, então `flutter run`/build não compila. Este registro lista os problemas e como resolvê-los. **Nenhuma correção de código foi aplicada; as correções abaixo são proposta.**

## Issues

| # | Nível | Local | Código | Mensagem |
|---|-------|-------|--------|----------|
| 1 | warning | `analysis_options.yaml:4:5` | `unrecognized_error_code` | `'missing_asset' isn't a recognized diagnostic code` |
| 2 | error | `lib/features/auth/login_cliente.dart:65:27` | `undefined_method` | `The method 'carregarCatalogo' isn't defined for the type 'Repositorio'` |
| 3 | error | `lib/features/auth/login_cliente.dart:66:27` | `undefined_method` | `The method 'carregarDadosCliente' isn't defined for the type 'Repositorio'` |

## Origem e correção

### 1. `missing_asset` em `analysis_options.yaml`

- **Origem:** `analyzer.errors.missing_asset: ignore` (linhas 3–4, com comentário "Evita que a falta temporária de um asset trave a análise"). `missing_asset` não é diagnóstico do analyzer; asset ausente é verificado pelo build do Flutter via `pubspec.yaml`. A chave não tem efeito.
- **Correção:** remover o comentário e a linha `missing_asset: ignore`, mantendo o `exclude`. Se um asset realmente faltar, corrigir o `flutter: assets:` do `pubspec.yaml`.

### 2 e 3. `Repositorio.carregarCatalogo` e `Repositorio.carregarDadosCliente`

- **Origem:** o commit `436b31a` mudou só `login_cliente.dart`, `cliente_api.dart`, `AuthApiServlet.java` e `DAOCliente.java`. `_entrar()` em `login_cliente.dart` (linhas 65–66) passou a chamar, após o login, `Repositorio.carregarCatalogo()` e `Repositorio.carregarDadosCliente()`. Esses métodos não existem em `lib/core/data/repositorio.dart` do repositório (só há `definirServicos`, `limpar`, `placaExiste`, add/atualizar/remover de veículo e agendamento, `marcarComoPago`, `atualizarStatus`). Provavelmente ficaram em alteração local não commitada do autor.
- **Correção proposta** em `lib/core/data/repositorio.dart`:
  - `static Future<void> carregarCatalogo()`: `ServicoApi().listar()` (`GET /servicos`, público), converter cada `ServicoModel` em `Servico` e chamar `definirServicos(...)`.
  - `static Future<void> carregarDadosCliente()`: `VeiculoApi().listar()` e `AgendamentoApi().listar()`, converter `VeiculoModel`/`AgendamentoModel` em `Veiculo`/`Agendamento` e atribuir a `veiculos.value` e `agendamentos.value` (o `AgendamentoModel.servicos` e os enums de `status_enums.dart` mapeiam o status do app).
  - Exceções `ApiException` sobem até o `try/on ApiException` de `_entrar()`, que já mostra "Login realizado, mas não foi possível carregar seus dados".
  - Conferir antes os construtores em `lib/core/models/*.dart` e os campos de `lib/core/api/model/*.dart`.
- **Alternativa:** se o autor tiver os métodos localmente, apenas commitar o `repositorio.dart` dele.

## Verificação após corrigir

1. `cd app-mobile && flutter analyze --no-pub` → `No issues found!`.
2. `flutter test`.
3. Login manual no app contra Tomcat local: catálogo, veículos e agendamentos do cliente aparecem.

## Ligação com o projeto

Peça pendente da integração descrita em `CLAUDE.md` ("wiring [telas] às classes de API"): `Repositorio` (memória) passa a ser populado por `core/api/` (`ServicoApi`, `VeiculoApi`, `AgendamentoApi`) logo após `POST /auth/login`, usando a sessão `JSESSIONID` mantida pelo `APIClient`.
