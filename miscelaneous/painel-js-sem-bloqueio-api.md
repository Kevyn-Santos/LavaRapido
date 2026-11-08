# `painel.js` deixa de esperar por uma API e de bloquear o envio dos formulários

Data: 2026-11-06

## Problema

`Assets/Js/painel.js` tinha três trechos que assumiam a existência de uma API REST que o front consumiria
em vez de submeter os formulários às servlets já existentes (`CadastroClienteServlet`, `VeiculoServlet`,
`AgendamentoServlet` etc.):

1. **`pendingMessage`** — string fixa "Integração com a API REST pendente. Nenhum dado foi enviado ou
   salvo." Era mostrada ao abrir um formulário (clique em "Novo ...") e ao submetê-lo.
2. **`showPending(container)`** — preenchia cada container de listagem (`clients-table-container`,
   `cars-table-container`, `queues-container`, `payments-container` etc.) com "Os dados deste módulo serão
   carregados pela API REST." em vez de deixar o conteúdo como veio do servidor.
3. **O handler de `submit`** chamava `event.preventDefault()` **incondicionalmente** no topo da função, e
   terminava chamando `showFormMessage(form, pendingMessage)`. Mesmo quando toda a validação client-side
   passava, o POST nunca saía do navegador — o `<form action="${pageContext.request.contextPath}/cadastro" ...>`
   (e equivalentes nos outros painéis) nunca era exercitado.

Os `<form>` das JSPs (`painel-clientes.jsp` e as demais) já têm `action`/`method="post"` apontando para as
servlets corretas. O JS é que impedia a requisição de chegar lá.

## Solução

Em `src/main/webapp/Assets/Js/painel.js`:

- Removida a constante `pendingMessage` e toda referência a ela.
- Removida a função `showPending` e sua chamada em `init()` — o `modules.forEach` agora só chama
  `setupForm(module)`, sem tocar nos containers de listagem.
- Reescrito o handler de `submit` de `setupForm`: o `event.preventDefault()` deixou de ser incondicional e
  passou a ocorrer **apenas** nos `return` de cada verificação de validação que falha (CPF, telefone, placa,
  `form.reportValidity()`). Quando tudo é válido, a função não chama `preventDefault` em lugar nenhum e o
  navegador segue o fluxo nativo do `<form>`: POST para o `action` da servlet.

Nada foi alterado em `db/`, `model/`, `servlet/` ou nas JSPs — a tarefa era só destravar o caminho que já
existia entre o front e as servlets, não construir uma API nova nem mexer na camada de persistência.

## Limitação conhecida (fora do escopo pedido)

Os containers de listagem (`clients-table-container` e os demais) continuam vazios: nenhuma JSP tem
`c:forEach` renderizando as linhas vindas do servlet, e a tarefa pediu para não tocar em JSPs/servlets/DAOs.
Preencher essas listagens com dados reais do servidor é um passo seguinte, não feito aqui.
