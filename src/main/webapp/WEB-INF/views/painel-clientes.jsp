<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <!doctype html>
    <html lang="pt-BR">

    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>Clientes — Fast Splash</title>
      <link rel="stylesheet" href="${pageContext.request.contextPath}/Assets/CSS/painel.css">
    </head>

    <body class="panel-page">

      <header class="top panel-page-header">
        <div class="top-in">
          <a class="lock" href="${pageContext.request.contextPath}/admin/inicio" aria-label="Fast Splash, início">
            <span class="wm"><span class="f">fast</span> <span class="s">splash</span></span>
          </a>

          <nav>
            <a href="${pageContext.request.contextPath}/admin/inicio">
              Voltar ao painel
            </a>
          </nav>
        </div>
      </header>

      <main class="page">
        <div class="wrap">
          <c:if test="${not empty erro}">
            <div role="alert" style="padding: 14px; margin: 15px 0;
              border: 1px solid #ff6b6b;
              border-radius: 8px;
              color: #ffb3b3;">
              <strong>Erro ao salvar cliente:</strong>
              <c:out value="${erro}" />
            </div>
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
            <a href="${pageContext.request.contextPath}/painel/clientes" class="on" aria-current="page">Clientes</a>
            <a href="${pageContext.request.contextPath}/painel/carros">Veículos</a>
            <a href="${pageContext.request.contextPath}/painel/agendamentos">Agendamentos</a>
            <a href="${pageContext.request.contextPath}/painel/atendimentos">Atendimentos</a>
            <a href="${pageContext.request.contextPath}/painel/pagamentos">Pagamentos</a>

            <c:if test="${sessionScope.nivelAcesso == 'ADMINISTRADOR'}">
              <a href="${pageContext.request.contextPath}/painel/colaboradores">Colaboradores</a>
              <a href="${pageContext.request.contextPath}/painel/servicos">Serviços</a>
            </c:if>

            <a href="${pageContext.request.contextPath}/painel/historico">Histórico</a>

          </nav>

          <!-- 1. TELA DA LISTA DE CLIENTES -->
          <div id="view-list">
            <div class="phead">
              <div>
                <h2>Clientes</h2>
                <p class="small">Cadastre, edite ou remova clientes do sistema.</p>
              </div>
              <button type="button" class="btn" id="btn-add-client">Novo cliente</button>
            </div>

            <div class="search">
              <input type="search" id="input-search" placeholder="Buscar por nome, e-mail ou CPF...">
            </div>

            <div id="clients-table-container">
              <c:if test="${empty clientes}">
                <p class="small">Nenhum cliente cadastrado.</p>
              </c:if>
              <c:if test="${not empty clientes}">
                <div class="tbl">
                  <div class="thead trow crow">
                    <div>Cliente</div>
                    <div>CPF</div>
                    <div>Telefone</div>
                    <div>Ações</div>
                  </div>
                  <c:forEach items="${clientes}" var="cliente">
                    <div class="trow crow" data-id="${cliente.id_cliente}" data-nome="<c:out value='${cliente.nome}' />"
                      data-cpf="<c:out value='${cliente.cpf}' />" data-telefone="<c:out value='${cliente.telefone}' />"
                      data-email="<c:out value='${cliente.email}' />">
                      <div data-l="Cliente">
                        <strong>
                          #
                          <c:out value="${cliente.id_cliente}" />
                          —
                          <c:out value="${cliente.nome}" />
                        </strong>
                        <p class="small">
                          <c:out value="${cliente.email}" />
                        </p>
                      </div>
                      <div data-l="CPF" class="cpf-formatado">
                        <c:out value="${cliente.cpf}" />
                      </div>
                      <div data-l="Telefone" class="telefone-formatado">
                        <c:out value="${cliente.telefone}" />
                      </div>
                      <div class="acts" data-l="Ações">

                        <button type="button" class="btn sm ghost btn-edit-client">
                          Editar
                        </button>

                        <form method="post" action="${pageContext.request.contextPath}/clientes" style="display:inline"
                          onsubmit="return confirm('Deseja realmente remover este cliente? O histórico será preservado.');">

                          <input type="hidden" name="acao" value="remover">

                          <input type="hidden" name="idCliente" value="${cliente.id_cliente}">

                          <button type="submit" class="btn sm danger">
                            Remover
                          </button>

                        </form>

                      </div>
                    </div>
                  </c:forEach>
                </div>
              </c:if>
            </div>
          </div>

          <!-- 2. TELA DO FORMULÁRIO -->
          <div id="view-form" class="hide">
            <div class="fcard">
              <h2 id="form-title">Novo cliente</h2>
              <form id="form-client" action="${pageContext.request.contextPath}/clientes" method="post">
                <input type="hidden" name="acao" value="salvar">
                <input type="hidden" id="client-id" name="idCliente">

                <div class="field">
                  <label for="client-name">Nome completo</label>
                  <input type="text" id="client-name" name="nome" required placeholder="Ex: Marina Alves">
                </div>

                <div class="fgrid">
                  <div class="field">
                    <label for="client-cpf">CPF</label>
                    <input type="text" id="client-cpf" name="cpf" required inputmode="numeric"
                      placeholder="000.000.000-00" maxlength="14">
                  </div>
                  <div class="field">
                    <label for="client-phone">Telefone</label>
                    <input type="tel" id="client-phone" name="telefone" required inputmode="numeric"
                      placeholder="(11) 99999-9999" maxlength="15">
                  </div>
                </div>

                <div class="field">
                  <label for="client-email">E-mail</label>
                  <input type="email" id="client-email" name="email" required placeholder="cliente@exemplo.com">
                </div>

                <div class="field">
                  <label for="client-pass">Senha</label>
                  <input type="password" id="client-pass" name="senha" required autocomplete="new-password"
                    minlength="8" maxlength="72">
                </div>

                <p class="err" id="form-error" role="alert"></p>

                <div class="facts">
                  <button class="btn" type="submit">Salvar cliente</button>
                  <button class="btn ghost" type="button" id="btn-cancel-client">Cancelar</button>
                </div>
              </form>
            </div>
          </div>

        </div>

        </div>
      </main>

      <script>
        document.getElementById("btn-add-client").addEventListener("click", () => {

          const formulario = document.getElementById("form-client");

          formulario.reset();

          document.getElementById("client-id").value = "";

          const senha = document.getElementById("client-pass");
          senha.value = "";
          senha.required = true;

          document.getElementById("form-title").textContent = "Novo cliente";

          document.getElementById("view-list").classList.add("hide");
          document.getElementById("view-form").classList.remove("hide");

        });
        document.querySelectorAll(".btn-edit-client").forEach(botao => {
          botao.addEventListener("click", () => {

            const linha = botao.closest(".trow");

            document.getElementById("client-id").value = linha.dataset.id;
            document.getElementById("client-name").value = linha.dataset.nome;
            document.getElementById("client-cpf").value =
              formatarCpf(linha.dataset.cpf || "");

            document.getElementById("client-phone").value =
              formatarTelefone(linha.dataset.telefone || "");
            document.getElementById("client-email").value = linha.dataset.email;

            const senha = document.getElementById("client-pass");
            senha.value = "";
            senha.required = false;

            document.getElementById("form-title").textContent =
              "Editar cliente #" + linha.dataset.id;

            document.getElementById("view-list").classList.add("hide");
            document.getElementById("view-form").classList.remove("hide");

          });
        });

        document.getElementById("btn-cancel-client").addEventListener("click", () => {
          document.getElementById("view-form").classList.add("hide");
          document.getElementById("view-list").classList.remove("hide");
        });

        // PESQUISA DE CLIENTES
        const campoBusca = document.getElementById("input-search");

        campoBusca.addEventListener("input", function () {
          const busca = this.value.trim().toLowerCase();
          const buscaNumerica = busca.replace(/\D/g, "");

          document.querySelectorAll("#clients-table-container .trow[data-id]")
            .forEach(linha => {

              const nome = (linha.dataset.nome || "").toLowerCase();
              const email = (linha.dataset.email || "").toLowerCase();
              const cpf = (linha.dataset.cpf || "").replace(/\D/g, "");

              const encontrado =
                nome.includes(busca) ||
                email.includes(busca) ||
                (buscaNumerica.length > 0 && cpf.includes(buscaNumerica));

              linha.classList.toggle("hide", !encontrado);
            });
        });

        // Formatação visual de CPF
        document.querySelectorAll(".cpf-formatado").forEach(elemento => {

          const cpf = elemento.textContent.replace(/\D/g, "");

          if (cpf.length === 11) {
            elemento.textContent = cpf.replace(
              /(\d{3})(\d{3})(\d{3})(\d{2})/,
              "$1.$2.$3-$4"
            );
          }
        });

        // Formatação visual de telefone
        document.querySelectorAll(".telefone-formatado").forEach(elemento => {

          const telefone = elemento.textContent.replace(/\D/g, "");

          if (telefone.length === 11) {
            elemento.textContent = telefone.replace(
              /(\d{2})(\d{5})(\d{4})/,
              "($1) $2-$3"
            );
          } else if (telefone.length === 10) {
            elemento.textContent = telefone.replace(
              /(\d{2})(\d{4})(\d{4})/,
              "($1) $2-$3"
            );
          }
        });

        // Máscara automática de CPF
        const campoCpf = document.getElementById("client-cpf");

        function formatarCpf(valor) {
          const numeros = valor.replace(/\D/g, "").slice(0, 11);

          return numeros
            .replace(/^(\d{3})(\d)/, "$1.$2")
            .replace(/^(\d{3})\.(\d{3})(\d)/, "$1.$2.$3")
            .replace(/\.(\d{3})(\d)/, ".$1-$2");
        }

        campoCpf.addEventListener("input", function () {
          this.value = formatarCpf(this.value);
        });


        // Máscara automática de telefone
        const campoTelefone = document.getElementById("client-phone");

        function formatarTelefone(valor) {
          const numeros = valor.replace(/\D/g, "").slice(0, 11);

          if (numeros.length <= 2) {
            return numeros.length ? "(" + numeros : "";
          }

          const ddd = numeros.slice(0, 2);
          const restante = numeros.slice(2);

          if (restante.length <= 4) {
            return "(" + ddd + ") " + restante;
          }

          if (numeros.length <= 10) {
            return "(" + ddd + ") " +
              restante.slice(0, -4) + "-" +
              restante.slice(-4);
          }

          return "(" + ddd + ") " +
            restante.slice(0, 5) + "-" +
            restante.slice(5);
        }

        campoTelefone.addEventListener("input", function () {
          this.value = formatarTelefone(this.value);
        });


      </script>

    </body>

    </html>