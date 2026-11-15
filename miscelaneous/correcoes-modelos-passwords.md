# Correções: valor monetário, id do Cliente e Passwords.matches

Registrado em 15/11/2026 13:20.

## O que mudou
1. **`Validacao.valorMonetario` só aceita reais e centavos.** Mais de 2 casas decimais (`10.125`, `0.001`) lança `IllegalArgumentException("<campo> deve ter no máximo 2 casas decimais.")` em vez de arredondar. `10.5` e `10.500` continuam válidos (zeros à direita não contam) e saem com escala 2. Alinha o modelo (`Servico`, `Pagamento`, `ItemAgendamento`) com `ServicoServlet`/`AdminServlet`, que já recusavam.
2. **`Cliente` com um id só.** O campo `id_cliente` foi removido: `getId_cliente()` lê de `getId()` (0 enquanto não persistido) e `setId_cliente(int)` delega para `setId` (uma única vez, positivo). O nome do getter foi mantido porque `painel-carros.jsp` usa `${cliente.id_cliente}` e `ClienteApiServlet`/`AuthApiServlet` o chamam. Mudança de comportamento: `setId_cliente(0)` agora lança `IllegalArgumentException`, e chamar duas vezes lança `IllegalStateException`; nenhum código de produção usava o setter.
3. **`Passwords.matches` não lança mais exceção por hash ruim.** Devolve `false` quando a senha ou o hash são nulos, ou quando o jBCrypt rejeita o hash (prefixo/custo inválido, hash vazio ou curto). Hashes com prefixo `$2y$` e `$2b$` (mesmo algoritmo do `$2a$`) são aceitos: o prefixo é trocado por `$2a$` antes da conferência.

## Por quê
Itens 1 e 2: observações de `testes-modelos-passwords.md` (regra de preço divergente e id duplicado). Item 3: o login com um hash inválido no banco virava erro 500 em vez de 401 (o seed tem hashes de teste e um `$2y$`). O grupo decidiu não usar os dados do seed; a correção continua valendo para qualquer hash estragado ou gerado por outra ferramenta.

## Testes
Suíte 279, **toda passando** (`mvn package` volta a funcionar sem `-DskipTests`). Alterados/novos: `ValidacaoTest` (recusa de 3 casas, aceita 10.5 e 10.500), `PessoasETest` (id único e `Servico` com 1.999), `PasswordsTest` (`$2y$`/`$2b$` conferem, hash vazio, curto e inválido devolvem false).

## Pendente (não pedido)
- Limite de 72 bytes do BCrypt: `/cadastro` e o painel de clientes ainda não têm máximo de senha (decidir se limitam a 72 bytes).
- `Validacao.valorMonetario` não tem limite superior (a coluna é DECIMAL(10,2)); os servlets limitam a precisão a 10 dígitos.
