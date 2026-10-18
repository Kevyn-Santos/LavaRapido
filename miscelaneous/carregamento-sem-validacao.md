# Carregamento de entidades sem revalidação (`Cliente.carregar`)

Data: 2026-10-12
Relacionado: ponto 13 de `resumo-testes-dao-e-openapi.md`

## Problema

A `DAOCliente` montava cada `Cliente` lido do banco com os setters públicos (`setNome`, `setEmail`,
`setTelefone`). Esses setters **validam**. Por isso, um único registro fora do padrão no banco
(telefone com máscara, e-mail antigo, nome vazio) lançava `IllegalArgumentException` e **derrubava a
listagem inteira**. O `setCPF` não validava, então o comportamento nem era consistente.

Validar a **entrada** de dados e reconstruir algo que **já foi gravado** são coisas diferentes. A validação deve
acontecer quando o dado entra no sistema, não toda vez que ele é lido do banco.

## Solução

Existe agora uma única porta de entrada para reconstruir um `Cliente` persistido, e ela não passa pela validação.

### `Pessoa`: `protected void carregarDadosPessoa(String nome, String email)`
- Atribui `nome` e `email` direto nos campos privados.
- É `protected`, então só subclasses e o pacote `model` enxergam o método. DAOs e servlets não têm acesso.
- Os setters públicos continuam `final` e validando.

### `Cliente`: `public static Cliente carregar(int id, String nome, String cpf, String telefone, String email)`
- Cria um `Cliente` novo e preenche todos os campos de uma vez, sem validar.
- Preenche também o `id` de `EntidadeBase` via `setId(id)`, além do `id_cliente`. Assim `getId()` e
  `isPersistido()` passam a funcionar para clientes carregados, e o `${users.id}` de `cadastroT.jsp` deixa de vir vazio.
- A `senha_hash` não é carregada porque os SELECTs atuais não a buscam.

### `DAOCliente`: `private Cliente mapearCliente(ResultSet rs)`
- Converte a linha atual do `ResultSet` chamando `Cliente.carregar(...)`.
- É usado por `getUsuarios()` e por `getusuario(id)`, o que remove o mapeamento duplicado.

#### Em outras palavras:

Foi feita uma separação de funções no código. 

Antes a montagem e recuperação dos dados ficavam na mesma entidade, agora a construção do cliente para uma `Rs` é responsabilidade do modelo, enquanto o povoamento dele com os registros do banco é responsabilidade da DAO.

## Quando usar cada caminho

| Situação | Use |
|---|---|
| Dado novo vindo do usuário (formulário, API) | construtor completo `new Cliente(...)` ou setters, que **validam** |
| Dado lido do banco | `Cliente.carregar(...)`, que **não valida** |

> **Regra:** nunca chame `Cliente.carregar(...)` com dados de `request.getParameter(...)`.

## Por que não usar setters próprios para consulta (`setTelefoneConsulta(...)`)?

1. **Alteram um objeto que já existe.** Um setter público pode ser chamado em qualquer objeto, a qualquer
   momento. Por exemplo, um servlet poderia fazer `cliente.setTelefoneConsulta(request.getParameter("telefone"))`
   e colocar um dado não validado num `Cliente` que já tinha passado pela validação. O factory só **cria** objetos novos
   e não consegue desfazer a validação de um objeto existente.
2. **Dobram a API.** Seriam dois setters por campo, em cada entidade (`Cliente`, `Colaborador`, `Veiculo`, ...).
   O autocomplete passa a oferecer as duas versões, e alguém escolhe a errada sem perceber. Os setters de
   `Pessoa` são `final` justamente para impedir que alguém contorne a validação.
3. **O objeto pode ficar incompleto.** Com setters avulsos, é fácil esquecer um campo. O factory recebe tudo de uma vez,
   e o compilador acusa se faltar algum argumento.
4. **O nome mostra a intenção.** `Cliente.carregar(...)` deixa claro que o dado vem do banco. É um padrão conhecido
   (reconstituição): o JPA/Hibernate faz o mesmo, preenchendo os campos sem chamar os setters.

**Limitação conhecida:** `carregar` precisa ser `public`, porque a DAO está em outro pacote e Java não tem "friend".
Alguém ainda poderia chamá-lo com dados do request, mas isso fica bem visível num code review. Para isolar de vez, seria
preciso mover o código que monta o `Cliente` a partir do `ResultSet` para o pacote `model`, e por enquanto não compensa.

## Para as próximas entidades

Para criar DAOs de `Colaborador`, `Veiculo` etc., siga o mesmo padrão:
1. Um método `protected` de carregamento na superclasse, quando houver campos herdados.
2. Um `public static X carregar(...)` na entidade, com todos os campos que o SELECT retorna.
3. Um `private X mapearX(ResultSet rs)` na DAO, reaproveitado por todos os SELECTs.

## Testes (`DAOClienteTest`, 27 testes, todos passando)

Testes novos:
- `getUsuarios`, **registro fora do padrão não derruba a listagem**: uma linha com nome vazio, CPF `123`,
  telefone `(11) 9999` e e-mail inválido é carregada sem exceção, com os valores preservados.
- `getUsuarios`, **preenche o `id` de `EntidadeBase`**: `getId()`, `getId_cliente()` e `isPersistido()` estão corretos.
- `getusuario`, **id inexistente**: lança `IllegalArgumentException`.

Teste ajustado:
- `insertUsuario`: o `catch` que encapsulava a exceção foi removido da DAO. O teste agora garante que a
  **`SQLException` original** é propagada, o que permite ao servlet `Cadastro` tratar
  `SQLIntegrityConstraintViolationException` e responder 409 (ponto 3 do resumo).

## Pendências relacionadas (não feitas)

- Ponto 11a: validar telefone/e-mail no `EditarCadastro` antes do `updateUsuarios` e corrigir o `maxlength="12"` do input.
- Ponto 11b: remover `setContentType("text/plain")` e o `PrintWriter` sem uso do `EditarCadastro` e do `Cadastro`.
- Opcional: `CHECK` constraints no `schema.sql` para o banco também barrar dados inválidos.
