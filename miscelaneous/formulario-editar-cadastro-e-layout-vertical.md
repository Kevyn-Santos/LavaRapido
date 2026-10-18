# Formulário de edição de cadastro e formulários empilhados no `index.jsp`

Data: 2026-10-07

Mudança só no front. A lógica do servlet `/editarCadastro` ainda não foi implementada.

## O que mudou

### `src/main/webapp/index.jsp`
- Novo formulário **Editar cadastro** abaixo de "Deletar cadastro":
  - `action="editarCadastro"`, `method="post"`.
  - `<select name="IdUser">` (obrigatório) para escolher o usuário. As opções vêm de
    `${queryUsers}` (`users.id_cliente` e `users.name`), o mesmo atributo usado em `cadastroT.jsp`.
  - Campos opcionais, todos enviados como String:
    - `nome` (text)
    - `email` (email)
    - `telefone` (text, `maxlength="12"`)
- Removido um `<a href="">` sem fechamento, logo depois do formulário de cadastro.
  Ele transformava todo o conteúdo abaixo dele em link.

### `src/main/webapp/Assets/CSS/style.css`
- `body`: adicionados `flex-direction: column`, `gap: 30px`, `padding: 30px 0` e
  `box-sizing: border-box`. Agora os formulários ficam um abaixo do outro, e não mais lado a lado.
- `select` recebeu o mesmo estilo de `input`.

## Pendências
- O dropdown fica vazio enquanto nenhum servlet preencher `queryUsers` antes de abrir o `index.jsp`.
  É preciso fazer `request.setAttribute("queryUsers", dao.getUsuarios())` e depois o forward para o `index.jsp`.
- O servlet `EditarCadastro` precisa:
  - ler `IdUser`, `nome`, `email` e `telefone`;
  - ignorar os campos que vierem vazios;
  - atualizar no banco só os campos preenchidos.
