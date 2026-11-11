<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <!doctype html>
    <html lang="pt-BR">

    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>Veículos — Fast Splash</title>
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
            <a href="${pageContext.request.contextPath}/painel/carros" class="on" aria-current="page">Veículos</a>
            <a href="${pageContext.request.contextPath}/painel/agendamentos">Agendamentos</a>
            <a href="${pageContext.request.contextPath}/painel/atendimentos">Atendimentos</a>
            <a href="${pageContext.request.contextPath}/painel/pagamentos">Pagamentos</a>
            <a href="${pageContext.request.contextPath}/painel/colaboradores">Colaboradores</a>
            <a href="${pageContext.request.contextPath}/painel/servicos">Serviços</a>
          </nav>

          <!-- 1. TELA DA LISTA DE CARROS -->
          <div id="view-list">
            <div class="phead">
              <div>
                <h2>Veículos dos clientes</h2>
                <p class="small">Cadastre e gerencie os veículos de cada cliente.</p>
              </div>
              <button type="button" class="btn" id="btn-add-car">Novo veículo</button>
            </div>

            <div class="field">
              <div class="booking-client-search">

                <label for="filtro-cliente">
                  Buscar cliente por nome ou ID
                </label>

                <input type="search" id="filtro-cliente" placeholder="Digite o nome ou ID do cliente..."
                  autocomplete="off">

                <div id="sugestoes-clientes" class="booking-client-results" hidden>

                  <c:forEach var="cliente" items="${clientes}">
                    <button type="button" class="booking-client-option" data-id="${cliente.id_cliente}"
                      data-nome="<c:out value='${cliente.nome}' />">

                      #
                      <c:out value="${cliente.id_cliente}" />
                      —
                      <c:out value="${cliente.nome}" />

                    </button>
                  </c:forEach>

                </div>

              </div>

              <p class="small">
                Digite para localizar um cliente e selecione uma sugestão.
              </p>
            </div>

            <div id="cars-table-container">

              <div class="tbl">

                <div class="thead trow carrow">
                  <div>Veículo</div>
                  <div>Modelo</div>
                  <div>Placa</div>
                  <div>Cor</div>
                  <div>Ações</div>
                </div>

                <c:forEach var="cliente" items="${clientes}">

                  <c:forEach var="veiculo" items="${cliente.veiculos}">

                    <div class="trow carrow hide" data-cliente-id="${cliente.id_cliente}"
                      data-veiculo-id="${veiculo.id}" data-marca="<c:out value='${veiculo.marca}' />"
                      data-modelo="<c:out value='${veiculo.modelo}' />" data-placa="<c:out value='${veiculo.placa}' />"
                      data-cor="<c:out value='${veiculo.cor}' />">
                      <div data-l="Veículo">
                        <strong>
                          #
                          <c:out value="${veiculo.id}" />
                          —
                          <c:out value="${veiculo.marca}" />
                        </strong>
                      </div>

                      <div data-l="Modelo">
                        <c:out value="${veiculo.modelo}" />
                      </div>

                      <div data-l="Placa">
                        <c:out value="${veiculo.placa}" />
                      </div>

                      <div data-l="Cor">
                        <c:out value="${veiculo.cor}" />
                      </div>

                      <div class="acts" data-l="Ações">

                        <button type="button" class="btn sm ghost btn-edit-car" data-veiculo-id="${veiculo.id}">
                          Editar
                        </button>

                        <button type="button" class="btn sm danger btn-remove-car" data-veiculo-id="${veiculo.id}">
                          Remover
                        </button>

                      </div>

                    </div>

                  </c:forEach>

                </c:forEach>

              </div>

            </div>
          </div>

          <!-- 2. TELA DO FORMULÁRIO -->
          <div id="view-form" class="hide">
            <div class="fcard">
              <h2 id="form-title">Manter</h2>
              <form id="form-car" action="${pageContext.request.contextPath}/admin/veiculos" method="post"> <input
                  type="hidden" name="acao" value="salvar">
                <input type="hidden" id="car-id" name="idVeiculo">
                <input type="hidden" id="car-client-id" name="idCliente">
                <div class="field">
                  <label for="car-client">Cliente proprietário</label>

                  <select id="car-client" required>
                    <option value="">Selecione um cliente</option>

                    <c:forEach var="cliente" items="${clientes}">
                      <option value="${cliente.id_cliente}">
                        #
                        <c:out value="${cliente.id_cliente}" />
                        —
                        <c:out value="${cliente.nome}" />
                      </option>
                    </c:forEach>
                  </select>
                </div>

                <div class="fgrid">
                  <div class="field">
                    <label for="car-brand">Marca</label>
                    <input type="text" id="car-brand" name="marca" required maxlength="60" placeholder="Ex: Chevrolet">
                  </div>

                  <div class="field">
                    <label for="car-model">Modelo</label>
                    <input type="text" id="car-model" name="modelo" required maxlength="60" placeholder="Ex: Onix">
                  </div>
                  <div class="field">
                    <label for="car-color">Cor</label>
                    <input type="text" id="car-color" name="cor" placeholder="Ex: Prata" maxlength="30">
                  </div>
                </div>

                <div class="field">
                  <label for="car-plate">Placa</label>
                  <input type="text" id="car-plate" name="placa" required placeholder="ABC1D23" maxlength="7"
                    style="text-transform:uppercase">
                </div>

                <p class="err" id="form-error" role="alert" style="color: #B3261E; font-size: 0.9rem; margin-top: 8px;">
                </p>

                <div class="facts">
                  <button class="btn" type="submit">Salvar veículo</button>
                  <button class="btn ghost" type="button" id="btn-cancel-car">Cancelar</button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </main>

      <script>
        const campoBusca = document.getElementById("filtro-cliente");
        const listaSugestoes = document.getElementById("sugestoes-clientes");

        const opcoes = Array.from(
          listaSugestoes.querySelectorAll(".booking-client-option")
        );

        function mostrarCarros(idCliente) {
          document.querySelectorAll(
            "#cars-table-container [data-cliente-id]"
          ).forEach(linha => {
            linha.classList.toggle(
              "hide",
              !idCliente || linha.dataset.clienteId !== idCliente
            );
          });
        }

        campoBusca.addEventListener("input", function () {

          const texto = this.value.trim().toLowerCase();

          mostrarCarros(null);

          if (!texto) {
            listaSugestoes.hidden = true;
            return;
          }

          let encontrados = 0;

          opcoes.forEach(opcao => {

            const nome = opcao.dataset.nome.toLowerCase();
            const id = opcao.dataset.id;

            const corresponde =
              nome.includes(texto) ||
              id.includes(texto.replace("#", ""));

            opcao.classList.toggle("hide", !corresponde);

            if (corresponde) {
              encontrados++;
            }
          });

          listaSugestoes.hidden = encontrados === 0;
        });

        opcoes.forEach(opcao => {

          opcao.addEventListener("click", function () {

            const id = this.dataset.id;
            const nome = this.dataset.nome;

            campoBusca.value = "#" + id + " — " + nome;

            listaSugestoes.hidden = true;

            mostrarCarros(id);
          });
        });

        document.addEventListener("click", function (evento) {
          if (!evento.target.closest(".booking-client-search")) {
            listaSugestoes.hidden = true;
          }
        });

        document.querySelectorAll(".btn-edit-car").forEach(botao => {

          botao.addEventListener("click", function () {

            const linha = this.closest(".trow.carrow");

            const idVeiculo = linha.dataset.veiculoId;

            const idCliente = linha.dataset.clienteId;

            const campoCliente = document.getElementById("car-client");

            campoCliente.value = idCliente;
            campoCliente.disabled = true;

            document.getElementById("car-id").value = idVeiculo;
            document.getElementById("car-brand").value = linha.dataset.marca;
            document.getElementById("car-model").value = linha.dataset.modelo;
            document.getElementById("car-plate").value = linha.dataset.placa;
            document.getElementById("car-plate").setCustomValidity("");
            document.getElementById("car-color").value = linha.dataset.cor;

            document.getElementById("form-title").textContent =
              "Editar veículo #" + idVeiculo;

            document.getElementById("view-list").classList.add("hide");
            document.getElementById("view-form").classList.remove("hide");

          });

        });

        document.getElementById("btn-cancel-car").addEventListener("click", function () {

          document.getElementById("view-form").classList.add("hide");
          document.getElementById("view-list").classList.remove("hide");

        });
      </script>

      <script src="${pageContext.request.contextPath}/Assets/Js/painel.js?v=2"></script>
      <script>
        const formularioCarro = document.getElementById("form-car");
        const seletorProprietario = document.getElementById("car-client");
        const idProprietario = document.getElementById("car-client-id");
        const idVeiculo = document.getElementById("car-id");

        // Abrir o formulário para um carro novo
        document.getElementById("btn-add-car").addEventListener("click", () => {

          formularioCarro.reset();

          document.getElementById("car-plate").setCustomValidity("");

          idVeiculo.value = "";
          idProprietario.value = "";

          seletorProprietario.disabled = false;
          seletorProprietario.value = "";

          document.getElementById("form-title").textContent =
            "Novo veículo";
        });

        // Guardar o proprietário escolhido
        seletorProprietario.addEventListener("change", () => {
          idProprietario.value = seletorProprietario.value;
        });

        // Completar os dados necessários para edição
        document.querySelectorAll(".btn-edit-car").forEach(botao => {

          botao.addEventListener("click", () => {

            const linha = botao.closest(".trow.carrow");
            const clienteId = linha.dataset.clienteId;

            idVeiculo.value = linha.dataset.veiculoId;
            idProprietario.value = clienteId;

            seletorProprietario.value = clienteId;
            seletorProprietario.disabled = true;
          });
        });

        // Validar o proprietário antes de salvar
        formularioCarro.addEventListener("submit", evento => {

          if (!seletorProprietario.disabled) {
            idProprietario.value = seletorProprietario.value;
          }

          if (!idProprietario.value) {
            evento.preventDefault();
            alert("Selecione o cliente proprietário.");
          }
        });
      </script>

    </body>

    </html>