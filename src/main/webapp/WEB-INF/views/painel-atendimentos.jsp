<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
      <!doctype html>
      <html lang="pt-BR">

      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Atendimentos — Fast Splash</title>
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
              <a href="${pageContext.request.contextPath}/painel/atendimentos" class="on"
                aria-current="page">Atendimentos</a>
              <a href="${pageContext.request.contextPath}/painel/pagamentos">Pagamentos</a>
              <a href="${pageContext.request.contextPath}/painel/colaboradores">Colaboradores</a>
              <a href="${pageContext.request.contextPath}/painel/servicos">Serviços</a>
            </nav>

            <div class="phead">
              <div>
                <h2>Atendimentos</h2>
                <p class="small">Acompanhe quem está sendo atendido e inicie o próximo.</p>
              </div>
            </div>


            <div id="queues-container">

              <c:if test="${param.sucesso == '1'}">
                <p class="ok" role="status">
                  Atendimento atualizado com sucesso.
                </p>
              </c:if>

              <c:if test="${not empty erro}">
                <p class="err" role="alert">
                  <c:out value="${erro}" />
                </p>
              </c:if>

              <c:choose>

                <c:when test="${empty atendimentos}">
                  <p class="small">
                    Nenhum atendimento encontrado.
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
                          <th>Horario</th>
                          <th>Status</th>
                          <th>Colaboradores</th>
                          <th>Acao</th>
                        </tr>
                      </thead>

                      <tbody>
                        <c:forEach var="atendimento" items="${atendimentos}">

                          <tr>
                            <td>
                              <c:out value="${atendimento.cliente}" />
                            </td>

                            <td>
                              <c:out value="${atendimento.placa}" />
                            </td>

                            <td>
                              <c:out value="${atendimento.data}" />
                            </td>

                            <td>
                              <c:out value="${atendimento.horario}" />
                            </td>

                            <td>
                              <c:out value="${atendimento.status}" />
                            </td>

                            <td>
                              <c:out value="${atendimento.colaboradores}" />
                            </td>

                            <td>
                              <c:choose>

                                <c:when test="${atendimento.statusAgendamento == 'CANCELADO'}">
                                  Agendamento cancelado
                                </c:when>

                                <c:otherwise>
                                  <form method="post" action="${pageContext.request.contextPath}/admin/atendimentos">

                                    <input type="hidden" name="idAtendimento" value="${atendimento.id}" />

                                    <div class="field">
                                      <label>Proximo status</label>

                                      <select name="status" required>

                                        <c:choose>
                                          <c:when test="${atendimento.status == 'AGUARDANDO'}">
                                            <option value="EM_LAVAGEM">
                                              Iniciar lavagem
                                            </option>
                                          </c:when>

                                          <c:when test="${atendimento.status == 'EM_LAVAGEM'}">
                                            <option value="FINALIZADO">
                                              Finalizar
                                            </option>
                                          </c:when>

                                          <c:when test="${atendimento.status == 'FINALIZADO'}">
                                            <option value="ENTREGUE">
                                              Entregar
                                            </option>
                                          </c:when>

                                          <c:otherwise>
                                            <option value="ENTREGUE">
                                              Entregue
                                            </option>
                                          </c:otherwise>
                                        </c:choose>

                                      </select>
                                    </div>


                                    <div class="field">
                                      <label>Colaboradores</label>

                                      <c:forEach var="colaborador" items="${colaboradores}">

                                        <c:set var="colaboradorSelecionado" value="false" />

                                        <c:forTokens items="${atendimento.idsColaboradores}" delims=","
                                          var="idSelecionado">

                                          <c:if test="${idSelecionado == colaborador.id}">
                                            <c:set var="colaboradorSelecionado" value="true" />
                                          </c:if>

                                        </c:forTokens>

                                        <label style="display:block;">

                                          <input type="checkbox" name="idColaboradores" value="${colaborador.id}"
                                            ${colaboradorSelecionado ? 'checked' : '' } />

                                          <c:out value="${colaborador.nome}" />

                                        </label>

                                      </c:forEach>
                                    </div>


                                    <c:choose>
                                      <c:when test="${atendimento.status == 'ENTREGUE'}">
                                        <button class="btn sm" type="submit">
                                          Salvar colaboradores
                                        </button>
                                      </c:when>

                                      <c:otherwise>
                                        <button class="btn sm" type="submit">
                                          Atualizar
                                        </button>
                                      </c:otherwise>
                                    </c:choose>

                                  </form>
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