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
              <a href="${pageContext.request.contextPath}/painel/carros">Carros</a>
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

            <div id="payments-container">

              <c:choose>
                <c:when test="${empty pagamentos}">
                  <p class="small">
                    Nenhum pagamento encontrado.
                  </p>
                </c:when>

                <c:otherwise>
                  <div class="table-wrap">
                    <table>
                      <thead>
                        <tr>
                          <th>Cliente</th>
                          <th>Placa</th>
                          <th>Data</th>
                          <th>Valor</th>
                          <th>Status</th>
                          <th>Ação</th>
                        </tr>
                      </thead>

                      <tbody>
                        <c:forEach var="pagamento" items="${pagamentos}">
                          <tr>
                            <td>
                              <c:out value="${pagamento.cliente}" />
                            </td>

                            <td>
                              <c:out value="${pagamento.placa}" />
                            </td>

                            <td>
                              <c:out value="${pagamento.data}" />
                            </td>

                            <td>
                              <fmt:formatNumber value="${pagamento.valor}" type="currency" currencySymbol="R$ "
                                minFractionDigits="2" maxFractionDigits="2" />
                            </td>

                            <td>
                              <c:out value="${pagamento.status}" />
                            </td>

                            <td>
                              <c:choose>
                                <c:when test="${pagamento.status == 'PENDENTE'}">

                                  <form method="post" action="${pageContext.request.contextPath}/admin/pagamentos">

                                    <input type="hidden" name="idPagamento" value="${pagamento.id}" />

                                    <input type="hidden" name="status" value="PAGO" />

                                    <select name="formaPagamento" required>
                                      <option value="">
                                        Forma de pagamento
                                      </option>
                                      <option value="PIX">PIX</option>
                                      <option value="DINHEIRO">Dinheiro</option>
                                      <option value="CREDITO">Crédito</option>
                                      <option value="DEBITO">Débito</option>
                                    </select>

                                    <button class="btn sm" type="submit">
                                      Confirmar
                                    </button>

                                  </form>
                                </c:when>

                                <c:otherwise>
                                  <c:out value="${pagamento.forma}" />
                                </c:otherwise>
                              </c:choose>
                            </td>
                          </tr>
                        </c:forEach>
                      </tbody>
                    </table>
                  </div>
                </c:otherwise>
              </c:choose>

            </div>

          </div>
        </main>

        <script src="${pageContext.request.contextPath}/Assets/Js/painel.js?v=2"></script>
      </body>

      </html>