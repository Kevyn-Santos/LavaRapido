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
        .hide {
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
            <a href="${pageContext.request.contextPath}/painel/carros">Carros</a>
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
                <h2>Equipa</h2>
                <p class="small">Gerencie os funcionários.</p>
              </div>
              <button type="button" class="btn" id="btn-add-collab">Novo colaborador</button>
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
                    <table>
                      <thead>
                        <tr>
                          <th>ID</th>
                          <th>Nome</th>
                          <th>Cargo</th>
                          <th>E-mail</th>
                          <th>Nível de acesso</th>
                        </tr>
                      </thead>

                      <tbody>
                        <c:forEach var="colaborador" items="${colaboradores}">

                          <tr>
                            <td>
                              <c:out value="${colaborador.id}" />
                            </td>

                            <td>
                              <c:out value="${colaborador.nome}" />
                            </td>

                            <td>
                              <c:out value="${colaborador.cargo}" />
                            </td>

                            <td>
                              <c:out value="${colaborador.email}" />
                            </td>

                            <td>
                              <c:out value="${colaborador.nivelAcesso}" />
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
                    autocomplete="new-password" required>
                </div>

                <div class="field">
                  <label for="collab-confirm">Confirmar senha</label>
                  <input type="password" id="collab-confirm" minlength="8" maxlength="72" autocomplete="new-password"
                    required>
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
    </body>

    </html>