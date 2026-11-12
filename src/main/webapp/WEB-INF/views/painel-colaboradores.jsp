<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <!doctype html>
    <html lang="pt-BR">

    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>Colaboradores — Fast Splash</title>
      <link rel="stylesheet" href="${pageContext.request.contextPath}/Assets/CSS/painel.css">
      <style>
        /* Botão de remoção de colaboradores */

        .form-remover-colaborador {
          display: inline-flex;
          margin: 0 0 0 8px;
        }

        .btn-remover-colaborador {
          color: #FF9B9B;
          border: 1px solid #A94B4B;
          background: transparent;
        }

        .btn-remover-colaborador:hover {
          background: #7A2929;
          color: #FFFFFF;
        }

        /* Colaboradores - tabela compacta */

        #collab-table-container .tabela-colaboradores {
          width: 100%;
          table-layout: fixed;
          border-collapse: collapse;
        }

        .tabela-colaboradores th,
        .tabela-colaboradores td {
          padding: 16px 12px;
          text-align: left;
          vertical-align: middle;
        }

        /* Quatro colunas: ID junto do nome, cargo, nível e ações. */
        .tabela-colaboradores th:nth-child(1),
        .tabela-colaboradores td:nth-child(1) {
          width: 43%;
        }

        .tabela-colaboradores th:nth-child(2),
        .tabela-colaboradores td:nth-child(2) {
          width: 17%;
        }

        .tabela-colaboradores th:nth-child(3),
        .tabela-colaboradores td:nth-child(3) {
          width: 20%;
        }

        .tabela-colaboradores th:nth-child(4),
        .tabela-colaboradores td:nth-child(4) {
          width: 20%;
        }

        .tabela-colaboradores td:nth-child(4) {
          white-space: nowrap;
        }

        .colaborador-info {
          display: flex;
          flex-direction: column;
          gap: 5px;
          min-width: 0;
        }

        .colaborador-info strong {
          color: #FFFFFF;
          font-size: 0.9rem;
        }

        .colaborador-email {
          color: #90B5CE;
          font-size: 0.78rem;
          font-weight: 400;
          overflow-wrap: anywhere;
        }

        .tabela-colaboradores td {
          overflow-wrap: anywhere;
        }

        .tabela-colaboradores tr.hide {
          display: none !important;
        }

        .booking-filters {
          display: flex;
          align-items: center;
          flex-wrap: wrap;
          gap: 12px;
          margin: 18px 0;
        }

        .booking-filters .search {
          flex: 1;
          min-width: 220px;
        }

        .booking-filters .search input {
          max-width: none;
          margin: 0;
        }

        #filtro-nivel-colaborador {
          min-height: 44px;
          padding: 10px 12px;
          border: 1px solid #365875;
          border-radius: 6px;
          background: #0B3050;
          color: #FFFFFF;
        }

        #filtro-nivel-colaborador option {
          background: #0B3050;
          color: #FFFFFF;
        }

        .hide {
          display: none !important;
        }

        /* Tabela de colaboradores */

        #collab-table-container .table-wrap {
          background: #0B3050;
          border: 1px solid #365875;
          border-radius: 14px;
          padding: 14px;
          overflow-x: auto;
        }

        #collab-table-container table {
          width: 100%;
          border-collapse: collapse;
        }

        #collab-table-container th,
        #collab-table-container td {
          padding: 16px 12px;
          text-align: left;
          vertical-align: middle;
          border-bottom: 1px solid #365875;
        }

        #collab-table-container th {
          color: #9FC7E0;
          font-size: 0.85rem;
          white-space: nowrap;
        }

        #collab-table-container td {
          color: #FFFFFF;
          font-size: 0.9rem;
        }

        #collab-table-container tr:last-child td {
          border-bottom: none;
        }

        #collab-table-container tr.hide {
          display: none !important;
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
            </div><span class="role admin">Administrador</span>
          </div>

          <nav class="ptabs" aria-label="Áreas do painel">
            <a href="${pageContext.request.contextPath}/admin/inicio">Início</a>
            <a href="${pageContext.request.contextPath}/painel/clientes">Clientes</a>
            <a href="${pageContext.request.contextPath}/painel/carros">Veículos</a>
            <a href="${pageContext.request.contextPath}/painel/agendamentos">Agendamentos</a>
            <a href="${pageContext.request.contextPath}/painel/atendimentos">Atendimentos</a>
            <a href="${pageContext.request.contextPath}/painel/pagamentos">Pagamentos</a>
            <a href="${pageContext.request.contextPath}/painel/colaboradores" class="on"
              aria-current="page">Colaboradores</a>
            <a href="${pageContext.request.contextPath}/painel/servicos">Serviços</a>
          </nav>

          <c:if test="${not empty erro}">
            <div class="err" role="alert" style="margin: 15px 0; color: #ff6b6b;">
              <strong>Não foi possível cadastrar o colaborador:</strong>
              <c:out value="${erro}" />
            </div>
          </c:if>

          <c:if test="${param.sucesso == '1'}">
            <div class="ok" role="status" style="margin: 15px 0;">
              Colaborador cadastrado com sucesso!
            </div>
          </c:if>

          <div id="view-list">
            <div class="phead">
              <div>
                <h2>Colaboradores</h2>
                <p class="small">Gerencie os colaboradores cadastrados no sistema.</p>
              </div>
              <button type="button" class="btn" id="btn-add-collab">Novo colaborador</button>
            </div>

            <div class="booking-filters">

              <div class="search">
                <input type="search" id="busca-colaborador" placeholder="Buscar por ID, nome ou e-mail..."
                  autocomplete="off">
              </div>

              <select id="filtro-nivel-colaborador">
                <option value="">Todos os níveis</option>
                <option value="OPERACIONAL">Operacional</option>
                <option value="ATENDENTE">Atendente</option>
                <option value="ADMINISTRADOR">Administrador</option>
              </select>

            </div>

            <div id="collab-table-container">

              <c:choose>
                <c:when test="${empty colaboradores}">
                  <p class="small">
                    Nenhum colaborador cadastrado.
                  </p>
                </c:when>

                <c:otherwise>
                  <div class="table-wrap">


                    <table class="tabela-colaboradores">
                      <thead>
                        <tr>
                          <th>Colaborador</th>
                          <th>Cargo</th>
                          <th>Nível de acesso</th>
                          <th>Ações</th>
                        </tr>
                      </thead>

                      <tbody>
                        <c:forEach var="colaborador" items="${colaboradores}">
                          <tr class="linha-colaborador"
                            data-busca="<c:out value='${colaborador.id} ${colaborador.nome} ${colaborador.email}' />"
                            data-nivel="${colaborador.nivelAcesso}">

                            <td>
                              <div class="colaborador-info">

                                <strong>#<c:out value="${colaborador.id}" /> — <c:out value="${colaborador.nome}" /></strong>


                                <span class="colaborador-email">
                                  <c:out value="${colaborador.email}" />
                                </span>
                              </div>
                            </td>

                            <td>
                              <c:out value="${colaborador.cargo}" />
                            </td>

                            <td>
                              <c:out value="${colaborador.nivelAcesso}" />
                            </td>

                            <td>
                              <button type="button" class="btn sm ghost editar-colaborador" data-id="${colaborador.id}"
                                data-nome="<c:out value='${colaborador.nome}' />"
                                data-cargo="<c:out value='${colaborador.cargo}' />"
                                data-email="<c:out value='${colaborador.email}' />"
                                data-nivel="${colaborador.nivelAcesso}">
                                Editar
                              </button>
                              <form method="post" action="${pageContext.request.contextPath}/admin/colaboradores"
                                  class="form-remover-colaborador">

                                  <input type="hidden" name="acao" value="remover">

                                  <input type="hidden" name="idColaborador" value="${colaborador.id}">

                                  <button type="submit" class="btn sm ghost btn-remover-colaborador">
                                    Remover
                                  </button>

                              </form>
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

          <div id="view-form" class="hide">
            <div class="fcard">
              <h2 id="form-title">Novo colaborador</h2>

              <form id="form-collab" method="post" action="${pageContext.request.contextPath}/admin/colaboradores">

                <input type="hidden" id="collab-acao" name="acao" value="criar">
                <input type="hidden" id="collab-id" name="idColaborador" value="">

                <div class="field">
                  <label for="collab-name">Nome completo</label>
                  <input type="text" id="collab-name" name="nome" maxlength="100" required>
                </div>

                <div class="field">
                  <label for="collab-email">E-mail</label>
                  <input type="email" id="collab-email" name="email" maxlength="150" required>
                </div>

                <div class="field">
                  <label for="collab-cargo">Cargo</label>
                  <input type="text" id="collab-cargo" name="cargo" maxlength="60" required>
                </div>

                <div class="field">
                  <label for="collab-role">Nível de acesso</label>
                  <select id="collab-role" name="nivelAcesso" required>
                    <option value="OPERACIONAL">Operacional</option>
                    <option value="ATENDENTE">Atendente</option>
                    <option value="ADMINISTRADOR">Administrador</option>
                  </select>
                </div>

                <div class="field">
                  <label for="collab-pass">Senha</label>
                  <input type="password" id="collab-pass" name="senha" minlength="8" maxlength="72"
                    autocomplete="new-password">
                </div>

                <div class="field">
                  <label for="collab-confirm">Confirmar senha</label>
                  <input type="password" id="collab-confirm" minlength="8" maxlength="72" autocomplete="new-password">
                </div>

                <div class="facts">
                  <button class="btn" type="submit">
                    Salvar colaborador
                  </button>

                  <button class="btn ghost" type="button" id="btn-cancel-collab">
                    Cancelar
                  </button>
                </div>
              </form>

            </div>
          </div>
        </div>
      </main>
      <script src="${pageContext.request.contextPath}/Assets/Js/painel.js"></script>

      <script>
        const formColaborador =
          document.getElementById("form-collab");

        formColaborador.addEventListener("submit", function (event) {
          const senha = document.getElementById("collab-pass");
          const confirmar = document.getElementById("collab-confirm");

          if (senha.value !== confirmar.value) {
            event.preventDefault();
            confirmar.setCustomValidity("As senhas não coincidem.");
            confirmar.reportValidity();
          }
        });

        document.getElementById("collab-confirm")
          .addEventListener("input", function () {
            this.setCustomValidity("");
          });
      </script>

      <script>
        const buscaColaborador =
          document.getElementById("busca-colaborador");

        const filtroNivel =
          document.getElementById("filtro-nivel-colaborador");

        function filtrarColaboradores() {

          const busca = buscaColaborador.value.trim().toLowerCase();
          const nivel = filtroNivel.value;

          document.querySelectorAll(".linha-colaborador")
            .forEach(linha => {

              const texto = (linha.dataset.busca || "").toLowerCase();

              const correspondeBusca = texto.includes(busca);
              const correspondeNivel =
                !nivel || linha.dataset.nivel === nivel;

              linha.classList.toggle(
                "hide",
                !(correspondeBusca && correspondeNivel)
              );
            });
        }

        buscaColaborador.addEventListener("input", filtrarColaboradores);
        filtroNivel.addEventListener("change", filtrarColaboradores);
      </script>

      <script>
        const formularioColaborador = document.getElementById("form-collab");
        const campoAcao = document.getElementById("collab-acao");
        const campoId = document.getElementById("collab-id");
        const campoSenha = document.getElementById("collab-pass");
        const campoConfirmar = document.getElementById("collab-confirm");

        document.querySelectorAll(".editar-colaborador").forEach(botao => {
          botao.addEventListener("click", () => {

            formularioColaborador.reset();

            campoAcao.value = "editar";
            campoId.value = botao.dataset.id;

            document.getElementById("collab-name").value = botao.dataset.nome;
            document.getElementById("collab-cargo").value = botao.dataset.cargo;
            document.getElementById("collab-email").value = botao.dataset.email;
            document.getElementById("collab-role").value = botao.dataset.nivel;

            campoSenha.value = "";
            campoConfirmar.value = "";
            campoConfirmar.setCustomValidity("");

            document.getElementById("form-title").textContent =
              "Editar colaborador";

            campoSenha.required = false;
            campoConfirmar.required = false;

            document.getElementById("view-list").classList.add("hide");
            document.getElementById("view-form").classList.remove("hide");
          });
        });

        document.getElementById("btn-add-collab").addEventListener("click", () => {
          campoAcao.value = "criar";
          campoId.value = "";

          document.getElementById("form-title").textContent =
            "Novo colaborador";

          campoSenha.required = true;
          campoConfirmar.required = true;
          campoConfirmar.setCustomValidity("");
        });

        formularioColaborador.addEventListener("submit", event => {
          if (campoAcao.value === "criar" && !campoSenha.value) {
            campoSenha.setCustomValidity("Informe uma senha.");
            campoSenha.reportValidity();
            event.preventDefault();
          }
        });

        campoSenha.addEventListener("input", () => {
          campoSenha.setCustomValidity("");
        });
      </script>

      <script>
        document.querySelectorAll(".form-remover-colaborador")
          .forEach(formulario => {

            formulario.addEventListener("submit", function (event) {

              const confirmado = confirm(
                "Deseja realmente remover este colaborador?\n\n" +
                "Ele perderá o acesso ao sistema, " +
                "mas seu histórico será preservado."
              );

              if (!confirmado) {
                event.preventDefault();
              }
            });
          });
      </script>

    </body>

    </html>