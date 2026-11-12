<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
      <!doctype html>
      <html lang="pt-BR">

      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Pagamentos — Fast Splash</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/Assets/CSS/painel.css">

        <style>
          #filtro-status-pagamento,
          #filtro-status-pagamento option {
            background: #0B3050;
            color: #FFFFFF;
            border: 1px solid #365875;
          }

          #filtro-status-pagamento {
            min-height: 44px;
            padding: 10px 12px;
            border-radius: 6px;
          }

          /* Organização do painel Pagamentos */

          #payments-container .table-wrap {
            background: #0B3050;
            border: 1px solid #365875;
            border-radius: 14px;
            padding: 18px;
            overflow-x: auto;
          }

          #payments-container table {
            width: 100%;
            border-collapse: collapse;
            table-layout: auto;
          }

          #payments-container th,
          #payments-container td {
            padding: 15px 12px;
            border-bottom: 1px solid #365875;
            text-align: left;
            vertical-align: middle;
          }

          #payments-container th {
            color: #9FC7E0;
            font-size: 0.85rem;
          }

          #payments-container td {
            color: #FFFFFF;
            font-size: 0.9rem;
          }

          #payments-container tr:last-child td {
            border-bottom: none;
          }

          #payments-container td:nth-child(4) {
            white-space: nowrap;
            font-weight: 700;
          }

          #payments-container select {
            background: #06263F;
            color: #FFFFFF;
            border: 1px solid #365875;
            border-radius: 6px;
            padding: 8px;
            min-width: 125px;
          }

          #payments-container select option {
            background: #06263F;
            color: #FFFFFF;
          }

          #payments-container form {
            display: flex;
            align-items: center;
            gap: 8px;
          }

          #payments-container .btn {
            white-space: nowrap;
          }


          /* Filtros de pesquisa e situação do pagamento */
          .payment-filters {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
            margin: 18px 0;
          }

          .payment-filters .search {
            flex: 1 1 260px;
            min-width: 220px;
            margin: 0;
          }

          .payment-filters .search input {
            display: block;
            width: 100%;
            max-width: none;
            margin: 0;
          }

          #filtro-status-pagamento {
            min-width: 170px;
          }

          /* Esconde os pagamentos que não correspondem aos filtros */
          #payments-container tr.hide {
            display: none !important;
          }


          /* Etapa 32.7: listagem compacta e janela de detalhes */
          #payments-container .payment-list {
            background: #0B3050;
            border: 1px solid #365875;
            border-radius: 14px;
            padding: 12px 18px;
            overflow-x: auto;
          }

          #payments-container .payment-list table {
            width: 100%;
            border-collapse: collapse;
          }

          #payments-container .payment-list th,
          #payments-container .payment-list td {
            padding: 15px 12px;
            text-align: left;
            vertical-align: middle;
            border-bottom: 1px solid #365875;
          }

          #payments-container .payment-list th {
            color: #9FC7E0;
          }

          #payments-container .payment-list tr:last-child td {
            border-bottom: 0;
          }

          .payment-sub {
            display: block;
            margin-top: 5px;
            color: #9FC7E0;
            font-size: .78rem;
          }

          .payment-value {
            font-weight: 700;
            white-space: nowrap;
          }

          dialog.payment-modal {
            position: fixed;
            inset: 0;
            margin: auto;
            width: min(560px, calc(100vw - 32px));
            max-width: 560px;
            max-height: 85vh;
            overflow-y: auto;
            padding: 26px;
            border: 1px solid #365875;
            border-radius: 16px;
            background: #0B3050;
            color: white;
            box-shadow: 0 24px 70px rgba(0, 0, 0, .5);
          }

          dialog.payment-modal:not([open]) {
            display: none;
          }

          dialog.payment-modal::backdrop {
            background: rgba(0, 10, 20, .76);
          }

          .payment-modal-header {
            display: flex;
            justify-content: space-between;
            gap: 16px;
            border-bottom: 1px solid #365875;
            padding-bottom: 16px;
            margin-bottom: 20px;
          }

          .payment-modal-header h2 {
            color: #fff;
          }

          .payment-modal .small {
            color: #9FC7E0;
            display: block;
          }

          .payment-modal-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 18px;
          }

          .payment-modal-grid strong {
            display: block;
            margin-top: 5px;
            overflow-wrap: anywhere;
            color: #fff;
          }

          .payment-modal-total {
            background: #06263F;
            border-radius: 10px;
            padding: 16px;
            margin: 22px 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 14px;
          }

          .payment-modal-total strong {
            font-size: 1.3rem;
          }

          .payment-icon-close {
            border: 0;
            background: transparent;
            color: white;
            font-size: 1.4rem;
            cursor: pointer;
          }

          .payment-confirm-form {
            display: grid;
            gap: 12px;
            padding-bottom: 18px;
          }

          .payment-confirm-form select {
            min-height: 44px;
            padding: 10px;
            background: #06263F;
            border: 1px solid #365875;
            border-radius: 6px;
            color: white;
          }

          .payment-confirm-form select option {
            background: #06263F;
            color: white;
          }

          .payment-confirm-form .btn {
            justify-self: start;
          }

          .payment-modal-footer {
            display: flex;
            justify-content: flex-end;
            border-top: 1px solid #365875;
            padding-top: 16px;
          }

          @media (max-width: 540px) {
            .payment-modal-grid {
              grid-template-columns: 1fr;
            }

            #payments-container .payment-list th,
            #payments-container .payment-list td {
              padding: 10px 6px;
            }
          }
        </style>
      </head>

      <body class="panel-page">

        <header class="top panel-page-header">
          <div class="top-in">
            <a class="lock" href="${pageContext.request.contextPath}/" aria-label="Fast Splash, início">
              <span class="wm"><span class="f">fast</span> <span class="s">splash</span></span>
            </a>
            <nav><a href="${pageContext.request.contextPath}/">Voltar ao início</a></nav>
          </div>
        </header>

        <main class="page">
          <div class="wrap">
            <c:if test="${param.sucesso == '1'}">
              <p class="ok" role="status">
                Operação realizada com sucesso.
              </p>
            </c:if>

            <c:if test="${not empty erro}">
              <p class="err" role="alert">
                <c:out value="${erro}" />
              </p>
            </c:if>
            <div class="who">
              <div>
                <p class="small">Bem-vindo(a)</p>
                <h1>
                  <c:out value="${sessionScope.colaboradorNome}" />
                </h1>
              </div>
              <span class="role admin">Administrador</span>
            </div>

            <nav class="ptabs" aria-label="Áreas do painel">
              <a href="${pageContext.request.contextPath}/admin/inicio">Início</a>
              <a href="${pageContext.request.contextPath}/painel/clientes">Clientes</a>
              <a href="${pageContext.request.contextPath}/painel/carros">Veículos</a>
              <a href="${pageContext.request.contextPath}/painel/agendamentos">Agendamentos</a>
              <a href="${pageContext.request.contextPath}/painel/atendimentos">Atendimentos</a>
              <a href="${pageContext.request.contextPath}/painel/pagamentos" class="on"
                aria-current="page">Pagamentos</a>
              <a href="${pageContext.request.contextPath}/painel/colaboradores">Colaboradores</a>
              <a href="${pageContext.request.contextPath}/painel/servicos">Serviços</a>
            </nav>

            <div class="phead">
              <div>
                <h2>Pagamentos</h2>
                <p class="small">Registre e consulte os pagamentos de lavagens.</p>
              </div>
            </div>


            <c:set var="totalPendente" value="${0}" />
            <c:set var="totalRecebido" value="${0}" />

            <c:forEach var="pagamento" items="${pagamentos}">
              <c:choose>
                <c:when test="${pagamento.status == 'PENDENTE'}">
                  <c:set var="totalPendente" value="${totalPendente + pagamento.valor}" />
                </c:when>
                <c:when test="${pagamento.status == 'PAGO'}">
                  <c:set var="totalRecebido" value="${totalRecebido + pagamento.valor}" />
                </c:when>
              </c:choose>
            </c:forEach>

            <div class="sums">
              <div>
                <span class="small">Pendente</span>
                <b id="sum-pending">
                  <fmt:formatNumber value="${totalPendente}" type="currency" currencySymbol="R$ " minFractionDigits="2"
                    maxFractionDigits="2" />
                </b>
              </div>

              <div>
                <span class="small">Recebido</span>
                <b id="sum-received">
                  <fmt:formatNumber value="${totalRecebido}" type="currency" currencySymbol="R$ " minFractionDigits="2"
                    maxFractionDigits="2" />
                </b>
              </div>
            </div>

            <div class="payment-filters">

              <div class="search">
                <input type="search" id="busca-pagamento" placeholder="Buscar por cliente ou placa..."
                  autocomplete="off">
              </div>

              <select id="filtro-status-pagamento" aria-label="Filtrar pagamentos">

                <option value="">Todos os status</option>
                <option value="PENDENTE">Pendentes</option>
                <option value="PAGO">Pagos</option>
                <option value="CANCELADO">Cancelados</option>

              </select>

            </div>

            <div id="payments-container">

              <c:choose>
                <c:when test="${empty pagamentos}">
                  <p class="small">
                    Nenhum pagamento encontrado.
                  </p>
                </c:when>

                <c:otherwise>
                  <div class="table-wrap payment-list">
                    <table>
                      <thead>
                        <tr>
                          <th>Cliente</th>
                          <th>Valor</th>
                          <th>Status</th>
                          <th>Ações</th>
                        </tr>
                      </thead>
                      <tbody>
                        <c:forEach var="pagamento" items="${pagamentos}">
                          <tr class="linha-pagamento" data-cliente="<c:out value='${pagamento.cliente}' />"
                            data-placa="<c:out value='${pagamento.placa}' />" data-status="${pagamento.status}">

                            <td>
                              <strong>
                                #
                                <c:out value="${pagamento.id}" /> —
                                <c:out value="${pagamento.cliente}" />
                              </strong>

                              <span class="payment-sub">
                                Agendamento #
                                <c:out value="${pagamento.idAgendamento}" />
                              </span>
                            </td>

                            <td class="payment-value">
                              <fmt:formatNumber value="${pagamento.valor}" type="currency" currencySymbol="R$ "
                                minFractionDigits="2" maxFractionDigits="2" />
                            </td>
                            <td>
                              <c:out value="${pagamento.status}" />
                            </td>
                            <td>
                              <button class="btn sm ghost payment-open" type="button"
                                data-modal="pagamento-${pagamento.id}">
                                Gerenciar
                              </button>
                            </td>
                          </tr>
                        </c:forEach>
                      </tbody>
                    </table>
                  </div>

                  <%-- Popups fora da tabela, para manter o HTML válido e a listagem compacta --%>
                    <c:forEach var="pagamento" items="${pagamentos}">
                      <dialog id="pagamento-${pagamento.id}" class="payment-modal">
                        <div class="payment-modal-header">
                          <div>
                            <h2>Pagamento #
                              <c:out value="${pagamento.id}" />
                            </h2>
                            <p class="small">Agendamento #
                              <c:out value="${pagamento.idAgendamento}" />
                            </p>
                          </div>
                          <button type="button" class="payment-close payment-icon-close" aria-label="Fechar">✕</button>
                        </div>

                        <div class="payment-modal-grid">
                          <div><span class="small">Cliente</span>
                            <strong>
                              <c:out value="${pagamento.cliente}" />
                            </strong>
                          </div>
                          <div><span class="small">Placa</span>
                            <strong>
                              <c:out value="${pagamento.placa}" />
                            </strong>
                          </div>
                          <div><span class="small">Data</span>
                            <strong>
                              <c:out value="${pagamento.data}" />
                            </strong>
                          </div>
                          <div><span class="small">Horário</span>
                            <strong>
                              <c:out value="${pagamento.horario}" />
                            </strong>
                          </div>
                          <div><span class="small">Situação</span>
                            <strong>
                              <c:out value="${pagamento.status}" />
                            </strong>
                          </div>
                          <div><span class="small">Forma de pagamento</span>
                            <strong>
                              <c:out value="${empty pagamento.forma ? 'Não informada' : pagamento.forma}" />
                            </strong>
                          </div>
                        </div>

                        <div class="payment-modal-total">
                          <span>Valor total</span>
                          <strong>
                            <fmt:formatNumber value="${pagamento.valor}" type="currency" currencySymbol="R$ "
                              minFractionDigits="2" maxFractionDigits="2" />
                          </strong>
                        </div>

                        <c:if test="${pagamento.status == 'PENDENTE'}">
                          <form class="payment-confirm-form" method="post"
                            action="${pageContext.request.contextPath}/admin/pagamentos"
                            onsubmit="return confirm('Confirmar o recebimento deste pagamento?');">
                            <input type="hidden" name="idPagamento" value="${pagamento.id}" />
                            <input type="hidden" name="status" value="PAGO" />
                            <label for="forma-pagamento-${pagamento.id}">Forma de pagamento</label>
                            <select id="forma-pagamento-${pagamento.id}" name="formaPagamento" required>
                              <option value="">Selecione uma forma</option>
                              <option value="PIX">PIX</option>
                              <option value="DINHEIRO">Dinheiro</option>
                              <option value="CREDITO">Crédito</option>
                              <option value="DEBITO">Débito</option>
                            </select>
                            <button class="btn" type="submit">Confirmar pagamento</button>
                          </form>
                        </c:if>

                        <div class="payment-modal-footer">
                          <button class="btn ghost payment-close" type="button">Fechar</button>
                        </div>
                      </dialog>
                    </c:forEach>
                </c:otherwise>
              </c:choose>

            </div>

          </div>
        </main>

        <script src="${pageContext.request.contextPath}/Assets/Js/painel.js?v=2"></script>

        <script>
          const buscaPagamento = document.getElementById("busca-pagamento");
          const filtroPagamento = document.getElementById("filtro-status-pagamento");

          function filtrarPagamentos() {

            const busca = buscaPagamento.value.trim().toLowerCase();
            const status = filtroPagamento.value;

            document.querySelectorAll(".linha-pagamento").forEach(linha => {

              const cliente = (linha.dataset.cliente || "").toLowerCase();
              const placa = (linha.dataset.placa || "").toLowerCase();

              const correspondeBusca =
                cliente.includes(busca) ||
                placa.includes(busca);

              const correspondeStatus =
                !status || linha.dataset.status === status;

              linha.classList.toggle(
                "hide",
                !(correspondeBusca && correspondeStatus)
              );
            });
          }

          buscaPagamento.addEventListener("input", filtrarPagamentos);
          filtroPagamento.addEventListener("change", filtrarPagamentos);
        </script>

        <script>
          document.querySelectorAll(".payment-open").forEach(botao => {
            botao.addEventListener("click", () => {
              const janela = document.getElementById(botao.dataset.modal);
              if (janela) janela.showModal();
            });
          });
          document.querySelectorAll(".payment-modal").forEach(janela => {
            janela.querySelectorAll(".payment-close").forEach(botao => {
              botao.addEventListener("click", () => janela.close());
            });
          });
        </script>
      </body>

      </html>