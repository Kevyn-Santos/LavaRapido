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
        <style>
          /* Tabela compacta de atendimentos */
          #queues-container .table-wrap {
            background: #0B3050;
            border: 1px solid #365875;
            border-radius: 14px;
            padding: 16px;
            overflow: visible;
          }

          #queues-container table {
            width: 100%;
            border-collapse: collapse;
          }

          #queues-container th,
          #queues-container td {
            padding: 15px 12px;
            text-align: left;
            vertical-align: middle;
            border-bottom: 1px solid #365875;
          }

          /* Ocultar da listagem as informações que estarão no popup */
          #queues-container th:nth-child(3),
          #queues-container td:nth-child(3),
          #queues-container th:nth-child(4),
          #queues-container td:nth-child(4),
          #queues-container th:nth-child(6),
          #queues-container td:nth-child(6) {
            display: none;
          }

          /* Popup de gerenciamento */
          dialog.atendimento-modal {
            position: fixed;
            inset: 0;
            margin: auto;
            width: min(560px, calc(100vw - 32px));
            max-height: 85vh;
            overflow-y: auto;
            padding: 26px;
            border-radius: 16px;
            border: 1px solid #365875;
            background: #0B3050;
            color: #FFFFFF;
            box-shadow: 0 24px 70px rgba(0, 0, 0, .55);
          }

          dialog.atendimento-modal:not([open]) {
            display: none;
          }

          dialog.atendimento-modal::backdrop {
            background: rgba(0, 10, 20, .75);
          }

          .atendimento-modal-topo {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 16px;
            margin-bottom: 18px;
          }

          .atendimento-modal-topo h2 {
            color: #FFFFFF;
          }

          .atendimento-resumo {
            display: grid;
            gap: 8px;
            padding: 16px;
            margin-bottom: 20px;
            border-radius: 10px;
            background: #06263F;
          }

          .atendimento-modal .field {
            margin-bottom: 16px;
          }

          .atendimento-modal input[type="checkbox"] {
            width: 18px;
            height: 18px;
            min-height: 0;
            margin-right: 8px;
            vertical-align: middle;
            accent-color: #FF7A1A;
          }

          .atendimento-modal .field label {
            margin-bottom: 8px;
          }

          .atendimento-modal button {
            cursor: pointer;
          }

          .atendimento-modal .fechar-atendimento {
            margin-top: 12px;
          }

          .atendimento-modal-topo .fechar-atendimento {
            background: transparent;
            color: #FFFFFF;
            border: 0;
            font-size: 24px;
            margin: 0;
          }

          /* Melhor contraste no filtro de status */
          #filtro-status-atendimento,
          #filtro-status-atendimento option {
            background: #0B3050;
            color: #FFFFFF;
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

            <div class="booking-filters">

              <div class="search">
                <input type="search" id="busca-atendimento" placeholder="Buscar por cliente ou placa...">
              </div>

              <select id="filtro-status-atendimento" aria-label="Filtrar por status">

                <option value="">Todos os status</option>
                <option value="AGUARDANDO">Aguardando</option>
                <option value="EM_LAVAGEM">Em lavagem</option>
                <option value="FINALIZADO">Finalizados</option>

              </select>

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
                          <th>Data</th>
                          <th>Placa</th>
                          <th>Horario</th>
                          <th>Status</th>
                          <th>Colaboradores</th>
                          <th>Acao</th>
                        </tr>
                      </thead>

                      <tbody>
                        <c:forEach var="atendimento" items="${atendimentos}">

                          <tr class="linha-atendimento" data-cliente="<c:out value='${atendimento.cliente}' />"
                            data-placa="<c:out value='${atendimento.placa}' />" data-status="${atendimento.status}">
                            <td>
                              <c:out value="${atendimento.cliente}" />
                            </td>

                            <td>
                              <c:out value="${atendimento.data}" />
                            </td>

                            <td>
                              <c:out value="${atendimento.placa}" />
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

                                <c:when test="${atendimento.status == 'ENTREGUE'}">
                                  Atendimento encerrado (histórico)
                                </c:when>

                                <c:otherwise>

                                  <button type="button" class="btn sm ghost abrir-atendimento"
                                    data-dialog="atendimento-${atendimento.id}">
                                    Gerenciar
                                  </button>

                                  <dialog id="atendimento-${atendimento.id}" class="atendimento-modal">

                                    <div class="atendimento-modal-topo">
                                      <div>
                                        <h2>Atendimento #
                                          <c:out value="${atendimento.id}" />
                                        </h2>
                                        <p class="small">Gerenciar atendimento</p>
                                      </div>

                                      <button type="button" class="fechar-atendimento" aria-label="Fechar">✕</button>
                                    </div>

                                    <div class="atendimento-resumo">
                                      <p><strong>Cliente:</strong>
                                        <c:out value="${atendimento.cliente}" />
                                      </p>

                                      <p><strong>Placa:</strong>
                                        <c:out value="${atendimento.placa}" />
                                      </p>

                                      <p><strong>Data:</strong>
                                        <c:out value="${atendimento.data}" />
                                      </p>

                                      <p><strong>Horário:</strong>
                                        <c:out value="${atendimento.horario}" />
                                      </p>

                                      <p><strong>Status atual:</strong>
                                        <c:out value="${atendimento.status}" />
                                      </p>

                                      <p><strong>Colaboradores vinculados:</strong>
                                        <c:out
                                          value="${empty atendimento.colaboradores ? 'Nenhum' : atendimento.colaboradores}" />
                                      </p>
                                    </div>
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
                                              <option value="FINALIZADO">
                                                Finalizado
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

                                          <c:if test="${colaborador.nivelAcesso == 'OPERACIONAL'}">

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

                                          </c:if>

                                        </c:forEach>
                                      </div>


                                      <c:choose>
                                        <c:when test="${atendimento.status == 'FINALIZADO'}"> <button class="btn sm"
                                            type="submit">
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

                                    <button type="button" class="btn ghost fechar-atendimento">
                                      Fechar
                                    </button>
                                  </dialog>

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

        <script>
          const buscaAtendimento =
            document.getElementById("busca-atendimento");

          const filtroStatusAtendimento =
            document.getElementById("filtro-status-atendimento");

          function filtrarAtendimentos() {

            const busca = buscaAtendimento.value
              .trim()
              .toLowerCase();

            const status = filtroStatusAtendimento.value;

            document.querySelectorAll(".linha-atendimento")
              .forEach(linha => {

                const cliente =
                  (linha.dataset.cliente || "").toLowerCase();

                const placa =
                  (linha.dataset.placa || "").toLowerCase();

                const statusAtendimento =
                  linha.dataset.status || "";

                const correspondeBusca =
                  cliente.includes(busca) ||
                  placa.includes(busca);

                const correspondeStatus =
                  !status || statusAtendimento === status;

                linha.classList.toggle(
                  "hide",
                  !(correspondeBusca && correspondeStatus)
                );
              });
          }

          buscaAtendimento.addEventListener(
            "input", filtrarAtendimentos
          );

          filtroStatusAtendimento.addEventListener(
            "change", filtrarAtendimentos
          );
        </script>
        <script>
          document.querySelectorAll(".abrir-atendimento").forEach(botao => {

            botao.addEventListener("click", () => {
              const dialog = document.getElementById(
                botao.dataset.dialog
              );

              if (dialog) {
                dialog.showModal();
              }
            });
          });

          document.querySelectorAll(".atendimento-modal").forEach(dialog => {

            dialog.querySelectorAll(".fechar-atendimento")
              .forEach(botao => {
                botao.addEventListener("click", () => {
                  dialog.close();
                });
              });

          });
        </script>
      </body>

      </html>