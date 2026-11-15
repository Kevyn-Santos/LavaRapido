# Validação da placa em DAOVeiculo.inserir

Registrado em 15/11/2026 13:06.

## O que mudou
- `DAOVeiculo.inserir` chama `Validacao.placa` antes de abrir a conexão: remove hífen, põe em maiúsculas e exige o formato antigo (`ABC1234`) ou Mercosul (`ABC1D23`); inválida lança `IllegalArgumentException("Placa inválida.")` (ou "Placa é obrigatória."). A placa gravada é sempre a normalizada.
- `VeiculoServlet` (site): novo `catch (IllegalArgumentException)` devolve 400, reexibe a lista com a mensagem. Antes qualquer `IllegalArgumentException` da DAO (ex.: cliente inativo) escapava como erro 500.
- `VeiculoApiServlet`: placa inválida vira 422 com a mensagem (o catch já existia); o 201 devolve a placa normalizada igual à gravada (antes `abc-1d23` voltava `ABC-1D23` e o banco guardava outra coisa).
- `AdminVeiculoServlet` já validava com `Validacao.placa`; segue igual (validação dupla inofensiva).

## Por quê
Era o bug que o teste `placaInvalida` apontava: o site e a API aceitavam qualquer texto de até 10 caracteres como placa. Com a regra na DAO, as três portas de entrada (site, painel e API) passam a ter a mesma regra.

## Testes
Suíte 216, **todos passando** (`mvn package` volta a funcionar). Novos/alterados: `DAOVeiculoTest` (placa inválida sem abrir conexão; placa antiga e Mercosul com hífen), `VeiculoEAgendamentoServletTest.placaInvalida` (recusa da DAO vira 400 com mensagem), `VeiculoApiServletTest` (422 para placa inválida; placa normalizada no 201).

## Fora do escopo
`DAOVeiculo.atualizar` continua sem validar a placa; hoje só `AdminVeiculoServlet` o chama e ele valida antes. Se outro chamador surgir, mover a validação para lá também. Placas já gravadas fora do formato não são afetadas.
