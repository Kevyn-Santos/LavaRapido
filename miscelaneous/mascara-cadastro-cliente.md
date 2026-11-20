# Máscara de CPF e telefone em `cadastro.jsp`

**O que mudou:** `src/main/webapp/cadastro.jsp` ganhou um `<script>` inline com máscara e validação para CPF (`#rc`) e telefone (`#rt`), e o campo de telefone recebeu `maxlength="15"` e `inputmode="numeric"` (CPF já tinha `maxlength="14"`).

**Por quê:** a tela pública de cadastro aceitava qualquer texto nesses campos, ao contrário do formulário de cliente do painel (`painel-clientes.jsp` + `Assets/Js/painel.js`, `setupClientMasks`).

**Como:** as funções (`maskCPF`, `validCPF`, `formatPhone`) seguem as de `painel.js`: CPF `000.000.000-00` com dígitos verificadores (`setCustomValidity`), telefone `(11) 99999-0000` ou `(11) 9999-0000` (10 ou 11 dígitos), cursor preservado no CPF. O script ficou na própria página porque `cadastro.jsp` é pública e não carrega `painel.js`.

**Vínculo com o projeto:** o `CadastroClienteServlet` (`/cadastro`) continua recebendo `cpf`/`phone` com pontuação e normalizando via `Cliente`/`Validacao`, como já ocorre no painel. A validação no navegador é só conveniência; a do servidor segue valendo.
