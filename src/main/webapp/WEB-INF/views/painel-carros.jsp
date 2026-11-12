<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <!doctype html>
    <html lang="pt-BR">

    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>Veículos — Fast Splash</title>
      <link rel="stylesheet" href="${pageContext.request.contextPath}/Assets/CSS/painel.css">

      <style>
        .car-client-chooser {
          display: grid;
          grid-template-columns: minmax(0, 2fr) minmax(210px, 1fr);
          gap: 14px;
          align-items: end;
          margin: 16px 0 20px;
        }
        .car-client-select, .car-client-search-action { min-width: 0; }
        .car-client-select label, .car-client-search-action label { display: block; margin-bottom: 8px; }
        #lista-clientes, #abrir-pesquisa-cliente {
          width: 100%; min-height: 44px; box-sizing: border-box; margin: 0;
        }
        #lista-clientes {
          padding: 10px 12px; background: #0B3050; color: white;
          border: 1px solid #365875; border-radius: 6px;
        }
        #lista-clientes option { background: #0B3050; color: white; }
        .popup-pesquisa-cliente {
          position: fixed; inset: 0; margin: auto;
          width: min(560px, calc(100vw - 32px)); max-height: 82vh;
          overflow-y: auto; box-sizing: border-box; padding: 24px;
          border: 1px solid #365875; border-radius: 14px;
          background: #0B3050; color: white;
          box-shadow: 0 24px 70px rgba(0, 0, 0, .5);
        }
        .popup-pesquisa-cliente:not([open]) { display: none; }
        .popup-pesquisa-cliente::backdrop { background: rgba(0, 10, 20, .75); }
        .popup-pesquisa-topo { display: flex; align-items: center; justify-content: space-between; gap: 16px; margin-bottom: 20px; }
        .popup-pesquisa-topo h2 { margin: 0; }
        .popup-pesquisa-cliente .booking-client-search { position: static; }
        #filtro-cliente { width: 100%; box-sizing: border-box; min-height: 44px; }
        .popup-pesquisa-cliente .booking-client-results {
          position: static; display: block; width: 100%; max-height: 320px;
          overflow-y: auto; box-sizing: border-box; margin-top: 12px;
          background: #082741; border: 1px solid #365875; border-radius: 8px;
        }
        .popup-pesquisa-cliente .booking-client-results[hidden] { display: none !important; }
        .popup-pesquisa-cliente .booking-client-option {
          display: block; width: 100%; text-align: left; padding: 12px;
          color: white; background: transparent; border: 0; cursor: pointer;
        }
        .popup-pesquisa-cliente .booking-client-option:hover, .popup-pesquisa-cliente .booking-client-option:focus-visible {
          background: #184d73;
        }
        .popup-pesquisa-cliente .booking-client-option.hide { display: none !important; }
        @media (max-width: 700px) { .car-client-chooser { grid-template-columns: 1fr; } }
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
                <h2>Veículos</h2>
                <p class="small">Cadastre e gerencie os veículos de cada cliente.</p>
              </div>
              <button type="button" class="btn" id="btn-add-car">Novo veículo</button>
            </div>

            <div class="car-client-chooser">
              <div class="car-client-select">
                <label for="lista-clientes">Selecionar cliente</label>
                <select id="lista-clientes">
                  <option value="">Selecione um cliente</option>
                  <c:forEach var="cliente" items="${clientes}">
                    <option value="${cliente.id_cliente}">
                      #<c:out value="${cliente.id_cliente}" /> — <c:out value="${cliente.nome}" />
                    </option>
                  </c:forEach>
                </select>
              </div>
              <div class="car-client-search-action">
                <label for="abrir-pesquisa-cliente">Pesquisar cliente</label>
                <button type="button" class="btn ghost" id="abrir-pesquisa-cliente">
                  Pesquisar por nome ou ID
                </button>
              </div>
            </div>

            <dialog id="popup-pesquisa-cliente" class="popup-pesquisa-cliente" aria-labelledby="titulo-pesquisa-cliente">
              <div class="popup-pesquisa-topo">
                <h2 id="titulo-pesquisa-cliente">Pesquisar cliente</h2>
                <button type="button" id="fechar-pesquisa-cliente" class="btn sm ghost">Fechar</button>
              </div>
              <div class="booking-client-search">
                <label for="filtro-cliente">Nome ou ID do cliente</label>
                <input type="search" id="filtro-cliente" placeholder="Digite o nome ou ID..." autocomplete="off">
                <div id="sugestoes-clientes" class="booking-client-results" hidden>
                  <c:forEach var="cliente" items="${clientes}">
                    <button type="button" class="booking-client-option"
                            data-id="${cliente.id_cliente}"
                            data-nome="<c:out value='${cliente.nome}' />">
                      #<c:out value="${cliente.id_cliente}" /> — <c:out value="${cliente.nome}" />
                    </button>
                  </c:forEach>
                </div>
              </div>
            </dialog>

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
                    <div class="trow carrow hide"
                         data-cliente-id="${cliente.id_cliente}"
                         data-veiculo-id="${veiculo.id}"
                         data-marca="<c:out value='${veiculo.marca}' />"
                         data-modelo="<c:out value='${veiculo.modelo}' />"
                         data-placa="<c:out value='${veiculo.placa}' />"
                         data-cor="<c:out value='${veiculo.cor}' />">
                      <div data-l="Veículo"><strong>#<c:out value="${veiculo.id}" /> — <c:out value="${veiculo.marca}" /></strong></div>
                      <div data-l="Modelo"><c:out value="${veiculo.modelo}" /></div>
                      <div data-l="Placa"><c:out value="${veiculo.placa}" /></div>
                      <div data-l="Cor"><c:out value="${veiculo.cor}" /></div>
                      <div class="acts" data-l="Ações">
                        <button type="button" class="btn sm ghost btn-edit-car" data-veiculo-id="${veiculo.id}">Editar</button>
                        <button type="button" class="btn sm danger btn-remove-car" data-veiculo-id="${veiculo.id}">Remover</button>
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
        const listaClientes = document.getElementById("lista-clientes");
        const popupPesquisa = document.getElementById("popup-pesquisa-cliente");
        const opcoes = Array.from(listaSugestoes.querySelectorAll(".booking-client-option"));

        function mostrarCarros(idCliente) {
          document.querySelectorAll("#cars-table-container [data-cliente-id]").forEach(linha => {
            linha.classList.toggle("hide", !idCliente || linha.dataset.clienteId !== idCliente);
          });
        }

        listaClientes.addEventListener("change", function () {
          mostrarCarros(this.value);
          listaSugestoes.hidden = true;
        });

        function filtrarOpcoes() {
          const texto = campoBusca.value.trim().toLowerCase();
          let encontrados = 0;
          opcoes.forEach(opcao => {
            const corresponde = opcao.dataset.nome.toLowerCase().includes(texto) ||
              opcao.dataset.id.includes(texto.replace("#", ""));
            opcao.classList.toggle("hide", !corresponde);
            if (corresponde) encontrados++;
          });
          listaSugestoes.hidden = encontrados === 0;
        }

        campoBusca.addEventListener("input", filtrarOpcoes);
        opcoes.forEach(opcao => {
          opcao.addEventListener("click", function () {
            listaClientes.value = this.dataset.id;
            mostrarCarros(this.dataset.id);
            popupPesquisa.close();
          });
        });

        document.getElementById("abrir-pesquisa-cliente").addEventListener("click", () => {
          campoBusca.value = "";
          filtrarOpcoes();
          popupPesquisa.showModal();
          campoBusca.focus();
        });
        document.getElementById("fechar-pesquisa-cliente").addEventListener("click", () => popupPesquisa.close());
        popupPesquisa.addEventListener("click", evento => {
          if (evento.target === popupPesquisa) popupPesquisa.close();
        });

        document.querySelectorAll(".btn-edit-car").forEach(botao => {
          botao.addEventListener("click", function () {
            const linha = this.closest(".trow.carrow");
            const idVeiculo = linha.dataset.veiculoId;
            const campoCliente = document.getElementById("car-client");
            campoCliente.value = linha.dataset.clienteId;
            campoCliente.disabled = true;
            document.getElementById("car-id").value = idVeiculo;
            document.getElementById("car-brand").value = linha.dataset.marca;
            document.getElementById("car-model").value = linha.dataset.modelo;
            document.getElementById("car-plate").value = linha.dataset.placa;
            document.getElementById("car-plate").setCustomValidity("");
            document.getElementById("car-color").value = linha.dataset.cor;
            document.getElementById("form-title").textContent = "Editar veículo #" + idVeiculo;
            document.getElementById("view-list").classList.add("hide");
            document.getElementById("view-form").classList.remove("hide");
          });
        });
        document.getElementById("btn-cancel-car").addEventListener("click", () => {
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