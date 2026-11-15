# Plano: ajustes de usabilidade encontrados no teste como cliente (2026-11-15)

> **Status: apenas planejamento.** Nenhum código foi alterado. Este documento registra o diagnóstico,
> a viabilidade e a proposta de cada um dos 4 pontos, para decidirmos antes de implementar.

## Por que
Teste manual de ponta a ponta mostrou quatro pontos de usabilidade/regra de negócio. Dois são regras
que o sistema deveria impor (pagamento antes da lavagem; primeiro administrador) e dois são
comunicação com o usuário (erro de data; horários).

## Resumo

| # | Ponto | Causa encontrada | Viabilidade | Esforço |
|---|-------|------------------|-------------|---------|
| 1 | Sem caminho para cadastrar o 1º administrador | `/setup/admin` existe, mas nada leva até ele **e** o forward da servlet aponta para um JSP que não está lá | Alta | Pequeno |
| 2 | Atendimento avança sem pagamento | A regra de transição não consulta `pagamento`; o JSP sempre oferece "Iniciar lavagem" | Alta | Pequeno/médio |
| 3 | Data inválida mostra erro cru do servidor | `AdminAgendamentoServlet` usa `response.sendError`; o JSP não renderiza `erro` | Alta | Médio |
| 4 | Horários fixos no `painel-agendamentos` | `<select>` com 9 `<option>` escritos à mão; a lógica real (`horariosLivres`) existe, mas só na API mobile | Alta | Médio |

Ordem sugerida: 1 → 2 → 3 + 4 juntos (mesmo JSP e mesmo servlet).

---

## 1. Primeiro colaborador (administrador)

**Diagnóstico**
- `SetupAdminServlet` (`/setup/admin`) já implementa o fluxo: só funciona sem administrador, exige o
  token `INITIAL_ADMIN_TOKEN` (lido só de `System.getenv`) e usa `DAOColaborador.criarAdministradorInicial`
  (com `GET_LOCK`, então é seguro contra corrida).
- Falha 1: **nada redireciona para lá.** `index.jsp` leva a `/colaborador/login`, e `ColaboradorLoginServlet.doGet`
  só encaminha para o formulário de login. Banco vazio = ninguém consegue entrar e ninguém é avisado.
- Falha 2 (já registrada em `visao-geral-v2.md` e `analise-geral-v1.md`): o servlet faz forward para
  `/WEB-INF/views/setup-admin.jsp`, mas o arquivo está em `src/main/webapp/setup-admin.jsp`. Hoje a
  página não abre nem digitando a URL.
- Falha 3: `setup-admin.jsp` é HTML cru (sem o visual de `colaborador-login.jsp`) e o login ignora o
  parâmetro `?setup=sucesso` que o POST envia.

**Proposta**
1. Mover `setup-admin.jsp` para `WEB-INF/views/` (corrige a falha 2) e reaproveitar as classes `staff-login-*`.
2. `ColaboradorLoginServlet.doGet`: chamar `new DAOColaborador().existeAdministrador()`; se `false`,
   `sendRedirect` para `/setup/admin`. Se o banco falhar, **não** redirecionar: mostra o login normal
   (o erro de banco aparece no login de qualquer forma).
3. `colaborador-login.jsp`: mostrar aviso "Administrador criado, faça login" quando `param.setup == 'sucesso'`.
4. Sem `INITIAL_ADMIN_TOKEN` a página continua em 503 com instruções (comportamento atual, mantido).

**Riscos / decisões**
- Segurança: o redirecionamento só revela que a instalação está vazia; a criação continua protegida pelo token. Aceitável.
- Custo: 1 consulta extra por GET do login (`SELECT 1 ... LIMIT 1`, trivial).
- **Decisão sua:** manter o token obrigatório (recomendado) ou deixar o primeiro admin sem token em ambiente LOCAL?

**Testes:** `CadastroESetupTest` (forward correto), novo teste de `ColaboradorLoginServlet` (redirect quando não há admin; login normal quando há; banco falhando).

---

## 2. Atendimento sem pagamento confirmado

**Diagnóstico**
- Observação: o status no código é `EM_LAVAGEM` (rótulo "Iniciar lavagem" no JSP); `INICIAR_LAVAGEM` não existe.
- A regra mora em `DAOAtendimento.atualizar` (transação com `SELECT ... FOR UPDATE`): só verifica o grafo
  `StatusAtendimento.podeIrPara` e se o agendamento não está `CANCELADO`. **Não consulta `pagamento`.**
- Todo agendamento já nasce com uma linha em `pagamento` (`status_pagamento = 'PENDENTE'`, criada em
  `DAOAgendamento.criar`), então a informação necessária sempre existe.
- `painel-atendimentos.jsp` oferece "Iniciar lavagem" sempre que `status == AGUARDANDO`.

**Proposta (defesa em duas camadas)**
1. **Regra no DAO (obrigatória):** no mesmo `SELECT ... FOR UPDATE`, fazer `LEFT JOIN pagamento` e, quando
   `atual == AGUARDANDO` e `proximo == EM_LAVAGEM`, exigir `status_pagamento = 'PAGO'`; senão lançar
   `IllegalArgumentException("Pagamento ainda não confirmado...")`. Fica dentro da transação, então não há corrida
   com a tela de pagamentos.
2. **Tela:** `AtendimentoView` ganha `statusPagamento` (a `listar()` já passa a juntar `pagamento`); o JSP
   desabilita a opção e mostra "Aguardando pagamento" quando não for `PAGO`.
3. **Mensagem de erro:** `AdminServlet.doPost` já devolve `IllegalArgumentException` como `erro` (a confirmar
   na implementação); a mensagem deve dizer quem resolve.

**Riscos / decisões**
- Hoje `/admin/pagamentos` exige `ATENDENTE` e `/admin/atendimentos` exige `OPERACIONAL`: o operacional não
  consegue quitar. A mensagem precisa dizer "peça ao atendente registrar o pagamento".
- **Decisão sua:** se o pagamento for revertido de `PAGO` para `PENDENTE`/`CANCELADO` depois de a lavagem
  iniciar, bloquear a reversão em `DAOPagamento.atualizar`? Recomendo bloquear quando o atendimento já passou de `AGUARDANDO`.
- Mudar o construtor do record `AtendimentoView` quebra `DAOAtendimentoTest` e testes de servlet: atualização esperada.
- A API mobile não altera atendimento, então não é afetada.

**Testes:** DAO (AGUARDANDO→EM_LAVAGEM com pagamento PENDENTE/CANCELADO falha; com PAGO passa; demais transições não mudam), JSP/servlet (mensagem), integração com MySQL real (`testes-integracao.sh`).

---

## 3. Mensagem amigável para data inválida

**Diagnóstico**
- O formulário afetado é `#form-booking` em `painel-agendamentos.jsp` (POST `/admin/agendamentos`).
- `AdminAgendamentoServlet` trata `DateTimeParseException`, `IllegalArgumentException` (data passada, horário fora
  da grade etc.) e conflito SQL com **`response.sendError`**, o que gera a página de erro do Tomcat. É por isso que
  a mensagem sai "do servidor".
- A servlet do cliente (`AgendamentoServlet`) já faz o certo: define `erro` e dá forward. Mas
  `painel-agendamentos.jsp` não tem nenhum `${erro}`; só existe um `<p id="form-error">` vazio.
- O `<input type="date">` não tem `min`, e o JS do formulário (`painel.js`) não valida data.

**Proposta (três camadas)**
1. **Cliente (prevenção):** `min` = hoje no `<input type="date">` (calculado no JS pelo fuso local, como já
   faz `painel-agendamento.js`) e checagem no submit que escreve em `#form-error` (já existe, só falta usar) e
   marca o campo com `setCustomValidity`. Cobre a maioria dos casos sem ir ao servidor.
2. **Servidor (garantia):** trocar os `sendError` por mensagem de volta na própria tela. Como a lista da página
   é carregada por outra servlet (`/painel/*`), o caminho mais barato é Post/Redirect/Get com *flash* na sessão
   (`erroAgendamento` + dados digitados) e redirect para `/painel/agendamentos`; a tela lê e limpa o atributo.
   Alternativa: extrair o carregamento de dados para `WebSupport` e dar forward (como faz a servlet do cliente).
3. **Tela:** exibir `erro` num bloco de alerta acima do formulário, **reabrir a visão do formulário** (hoje começa
   oculta, `view-form hide`) e preservar o que o usuário digitou. "Popup": o projeto já usa `<dialog>` nos detalhes;
   recomendo mensagem inline (acessível, não bloqueia), usando `<dialog>` só se preferir modal.

**Riscos / decisões**
- Confirmar na implementação como `PainelServlet` carrega os dados da página (define qual das duas rotas do item 2 é menor).
- Padronizar também as mensagens traduzidas (`GradeHorarios` e `DAOAgendamento.criar` já têm texto em português).
- **Decisão sua:** inline (recomendado) ou modal `<dialog>`?

**Testes:** `VeiculoEAgendamentoServletTest`/`PainelEAdminServletTest` (erro deixa de ser `sendError`, vira atributo/flash), teste manual com data passada, data vazia e horário já ocupado.

---

## 4. Horários reais no painel de agendamentos

**Diagnóstico**
- `<select id="bk-slot">` tem 9 opções fixas (08:00–17:00, de hora em hora, sem 12:00).
- A grade real é `GradeHorarios`: 06:00–17:30, de 30 em 30 min (24 horários), **um agendamento por horário**.
  `DAOAgendamento.horariosLivres(data)` já devolve só os livres e, no dia de hoje, remove os que já passaram.
- Hoje esse cálculo só é exposto por `GET /api/v1/horarios`, que passa por `ApiAuthFilter` (token do app) e usa
  data `dd/MM/yyyy`; o painel usa sessão de colaborador, então não pode chamá-lo.
- Consequência: o painel oferece horários que a regra rejeita (ocupado/passado/fora da grade) e esconde os válidos (06:00, 08:30...).

**Proposta**
1. Novo endpoint JSON para o painel, protegido pela sessão e pelo mesmo nível de `/admin/agendamentos` (`OPERACIONAL`),
   por exemplo `GET /admin/horarios?data=yyyy-MM-dd` → `["06:00","06:30",...]`, reaproveitando `horariosLivres`
   (sem duplicar regra). Data inválida ou vazia → 400 com `{"erro": ...}`.
2. JS do formulário: ao mudar a data, `fetch` do endpoint e reconstruir o `<select>`. Antes de escolher a data o
   select fica desabilitado com "Escolha a data"; sem vagas mostra "Sem horários livres nesta data" e bloqueia o envio.
3. Remover as 9 `<option>` fixas do JSP.
4. A corrida continua tratada: se outro operador pegar o horário entre o fetch e o envio, `criar` rejeita dentro da
   transação e o item 3 mostra a mensagem.

**Alternativa descartada:** renderizar no servidor com a data escolhida via recarga de página. Mais simples, mas
piora a usabilidade (perde o que foi digitado) e não ajuda o item 3.

**Riscos / decisões**
- Fuso: `LocalDate.now()`/`LocalTime.now()` usam o fuso do servidor (Render costuma ser UTC): vale checar, pois
  afeta "hoje" e a poda dos horários passados. Tema já relevante para o app mobile.
- Cache: o endpoint não deve ser cacheado (cabeçalho `Cache-Control: no-store`).

**Testes:** novo teste do servlet (200 com lista, 400 data inválida, 401/403 sem sessão ou nível), reaproveitando o padrão de `HorarioApiServletTest`; manual: data de hoje, data com horário ocupado, data passada.

---

## Como isso se liga ao projeto
- Itens 1 e 2 completam regras de negócio que hoje dependem de "o operador lembrar" (instalação inicial e
  cobrança antes do serviço), alinhadas com o ciclo `AGUARDANDO → EM_LAVAGEM → FINALIZADO → ENTREGUE` e com a
  tabela `pagamento` criada junto do agendamento.
- Itens 3 e 4 fazem o painel web usar a mesma fonte de verdade de horários que o app mobile
  (`GradeHorarios` + `DAOAgendamento.horariosLivres`), registrada em `horarios-api-mobile.md`.
- Documentação a atualizar quando implementar: `openapi.yml` (novo endpoint do painel, se for documentado),
  `teste-ponta-a-ponta-tomcat-local.md` (mapa de rotas), `variaveis-de-ambiente.md` (se mudar a regra do token) e
  limpar o pendente de `visao-geral-v2.md` sobre `setup-admin.jsp`.

## Próximos passos (aguardando sua decisão)
1. Token do setup: obrigatório sempre (recomendado) ou opcional em LOCAL?
2. Bloquear a reversão de pagamento após o início da lavagem?
3. Erro de data: inline (recomendado) ou modal?
4. Aprovar a ordem 1 → 2 → 3+4 e começar pelo item 1.
