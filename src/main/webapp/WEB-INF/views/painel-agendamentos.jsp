<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <!doctype html>
    <html lang="pt-BR">

    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>Agendamentos — Fast Splash</title>
      <link rel="stylesheet" href="${pageContext.request.contextPath}/Assets/CSS/painel.css">
      <style>
        .hide {
          display: none !important;
        }

        .tot {
          font-size: 1.05rem;
          margin: 14px 0 8px;
          color: var(--muted);
        }

        .tot b {
          font-size: 1.6rem;
          color: var(--ink);
          font-variation-settings: "wdth" 80;
        }

        /* Organização da listagem de agendamentos */

        #bookings-table-container .booking-item {
          padding: 16px 0;
          border-bottom: 1px solid var(--line);
        }

        #bookings-table-container .booking-item:last-child {
          border-bottom: none;
        }

        #bookings-table-container .booking-main {
          display: grid;
          grid-template-columns:
            minmax(180px, 1.6fr) minmax(145px, 1fr) minmax(115px, 0.8fr) minmax(100px, auto);
          align-items: center;
          gap: 16px;
        }

        #bookings-table-container .booking-main>div {
          min-width: 0;
        }

        #bookings-table-container .booking-main .small {
          display: block;
          margin-bottom: 3px;
        }

        #bookings-table-container .booking-details {
          position: relative;
          min-width: 0;
        }

        #bookings-table-container .booking-details summary {
          cursor: pointer;
          font-weight: 700;
          color: var(--primary);
          white-space: nowrap;
        }

        #bookings-table-container .booking-details[open] {
          grid-column: 1 / -1;
        }

        #bookings-table-container .booking-details[open] .booking-extra {
          position: static;
          width: 100%;
          margin-top: 12px;
          padding: 16px;
          background: var(--paper);
          border: 1px solid var(--line);
          border-radius: 8px;
          box-shadow: none;
        }

        #booking-status-filter {
          background: var(--card);
          color: var(--ink);
          border: 1px solid var(--line);
          min-height: 44px;
          padding: 10px 14px;
          border-radius: 6px;
        }

        #booking-status-filter option {
          background: #0B3050;
          color: #FFFFFF;
        }

        @media (max-width: 860px) {
          #bookings-table-container .booking-main {
            grid-template-columns: 1fr;
          }
        }

        /* Popup de detalhes dos agendamentos */

        dialog.booking-modal {
          position: fixed;
          inset: 0;
          margin: auto;
          width: min(560px, calc(100vw - 32px));
          max-width: 560px;
          max-height: 85vh;
          padding: 28px;
          overflow-y: auto;

          background: #0B3050;
          color: #FFFFFF;
          border: 1px solid #365875;
          border-radius: 16px;
          box-shadow: 0 24px 70px rgba(0, 0, 0, 0.55);
        }

        dialog.booking-modal:not([open]) {
          display: none;
        }

        dialog.booking-modal::backdrop {
          background: rgba(0, 10, 20, 0.78);
          backdrop-filter: blur(4px);
        }

        .booking-modal-header {
          display: flex;
          align-items: flex-start;
          justify-content: space-between;
          gap: 16px;
          padding-bottom: 18px;
          margin-bottom: 20px;
          border-bottom: 1px solid #365875;
        }

        .booking-modal-header h2 {
          color: #FFFFFF;
          font-size: 1.65rem;
          line-height: 1.2;
        }

        .booking-modal .small {
          display: block;
          color: #9FC7E0;
          font-size: 0.82rem;
        }

        .booking-modal-content {
          display: grid;
          gap: 22px;
        }

        .booking-modal-content>div {
          min-width: 0;
        }

        .booking-modal-content strong {
          display: block;
          margin-top: 5px;
          color: #FFFFFF;
          font-size: 0.98rem;
          overflow-wrap: anywhere;
        }

        .booking-modal-grid {
          display: grid;
          grid-template-columns: repeat(2, minmax(0, 1fr));
          gap: 20px;
        }

        .booking-modal-total {
          display: flex !important;
          flex-direction: row !important;
          align-items: center;
          justify-content: space-between;
          gap: 16px;
          background: #06263F;
          padding: 16px;
          border-radius: 10px;
        }

        .booking-modal-total strong {
          font-size: 1.45rem;
          margin: 0;
        }

        .booking-modal-footer {
          display: flex;
          justify-content: flex-end;
          margin-top: 24px;
          padding-top: 18px;
          border-top: 1px solid #365875;
        }

        .booking-modal .booking-close {
          cursor: pointer;
        }

        .booking-modal-header .booking-close {
          background: transparent;
          border: none;
          color: #FFFFFF;
          font-size: 1.5rem;
          padding: 0 6px;
        }

        .booking-modal-footer .booking-close {
          background: #FF7A1A;
          color: #06263F;
          border: none;
          border-radius: 8px;
          padding: 10px 24px;
          font-weight: 700;
        }

        @media (max-width: 480px) {
          dialog.booking-modal {
            padding: 20px;
          }

          .booking-modal-grid {
            grid-template-columns: 1fr;
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
            <a href="${pageContext.request.contextPath}/painel/agendamentos" class="on"
              aria-current="page">Agendamentos</a>
            <a href="${pageContext.request.contextPath}/painel/atendimentos">Atendimentos</a>
            <a href="${pageContext.request.contextPath}/painel/pagamentos">Pagamentos</a>
            <a href="${pageContext.request.contextPath}/painel/colaboradores">Colaboradores</a>
            <a href="${pageContext.request.contextPath}/painel/servicos">Serviços</a>
          </nav>

          <!-- 1. TELA DA LISTA DE AGENDAMENTOS -->
          <div id="view-list">
            <div class="phead">
              <div>
                <h2>Agendamentos</h2>
                <p class="small">Crie, edite e gerencie agendamentos dos clientes.</p>
              </div>
              <button type="button" class="btn" id="btn-add-booking">Novo agendamento</button>
            </div>

            <div class="booking-filters" style="display:flex; gap:12px; align-items:center; flex-wrap:wrap;">
              <div class="search">
                <input type="search" id="input-search" placeholder="Cliente, veículo, placa, data ou ID...">
              </div>

              <select id="booking-status-filter" aria-label="Filtrar por status">
                <option value="">Todos os status</option>
                <option value="AGENDADO">Agendados</option>
                <option value="CONCLUIDO">Concluídos</option>
                <option value="CANCELADO">Cancelados</option>
              </select>
            </div>


            <div id="bookings-table-container">

              <c:choose>
                <c:when test="${empty agendamentos}">
                  <p class="small">Nenhum agendamento cadastrado.</p>
                </c:when>

                <c:otherwise>
                  <div class="tbl">

                    <c:forEach var="agendamento" items="${agendamentos}">

                      <div class="booking-item" data-status="${agendamento.status}"
                        data-search="<c:out value='${agendamento.id} ${agendamento.cliente} ${agendamento.veiculo} ${agendamento.placa} ${agendamento.data} ${agendamento.servicos}' />">

                        <div class="booking-main">
                          <div>
                            <strong>
                              #
                              <c:out value="${agendamento.id}" />
                              —
                              <c:out value="${agendamento.cliente}" />
                            </strong>
                            <p class="small">
                              <c:out value="${agendamento.veiculo}" />
                            </p>
                          </div>

                          <div>
                            <span class="small">Data e horário</span>
                            <p>
                              <c:out value="${agendamento.data}" />
                              <c:out value="${agendamento.horario}" />
                            </p>
                          </div>

                          <div>
                            <span class="small">Status</span>
                            <p>
                              <strong>
                                <c:out value="${agendamento.status}" />
                              </strong>
                            </p>
                          </div>

                          <button type="button" class="btn sm ghost booking-open"
                            data-dialog-id="detalhes-${agendamento.id}">
                            Ver detalhes
                          </button>

                        </div>

                        <dialog id="detalhes-${agendamento.id}" class="booking-modal">

                          <div class="booking-modal-header">
                            <div>
                              <h2>Agendamento #
                                <c:out value="${agendamento.id}" />
                              </h2>
                              <p class="small">Detalhes do agendamento</p>
                            </div>

                            <button type="button" class="booking-close" aria-label="Fechar detalhes">✕</button>
                          </div>

                          <div class="booking-modal-content">

                            <div>
                              <span class="small">Cliente</span>
                              <strong>
                                <c:out value="${agendamento.cliente}" />
                              </strong>
                            </div>

                            <div class="booking-modal-grid">

                              <div>
                                <span class="small">Veículo</span>
                                <strong>
                                  <c:out value="${agendamento.veiculo}" />
                                </strong>
                              </div>

                              <div>
                                <span class="small">Placa</span>
                                <strong>
                                  <c:out value="${agendamento.placa}" />
                                </strong>
                              </div>

                              <div>
                                <span class="small">Data</span>
                                <strong>
                                  <c:out value="${agendamento.data}" />
                                </strong>
                              </div>

                              <div>
                                <span class="small">Horário</span>
                                <strong>
                                  <c:out value="${agendamento.horario}" />
                                </strong>
                              </div>

                            </div>

                            <div>
                              <span class="small">Serviços contratados</span>
                              <strong>
                                <c:out value="${agendamento.servicos}" />
                              </strong>
                            </div>

                            <div class="booking-modal-total">
                              <span>Valor total</span>
                              <strong>R$
                                <c:out value="${agendamento.total}" />
                              </strong>
                            </div>

                            <div class="booking-modal-grid">
                              <div>
                                <span class="small">Status do agendamento</span>
                                <strong>
                                  <c:out value="${agendamento.status}" />
                                </strong>
                              </div>

                              <div>
                                <span class="small">Situação do pagamento</span>
                                <strong>
                                  <c:out
                                    value="${empty agendamento.statusPagamento ? 'Não informado' : agendamento.statusPagamento}" />
                                </strong>
                              </div>
                            </div>

                          </div>

                          <div class="booking-modal-footer">
                            <button type="button" class="btn ghost booking-close">
                              Fechar
                            </button>
                          </div>

                        </dialog>

                      </div>

                    </c:forEach>
                  </div>

                  <p id="booking-empty-filter" class="small hide">
                    Nenhum agendamento encontrado para esta pesquisa.
                  </p>
                </c:otherwise>
              </c:choose>
            </div>

          </div>
        </div>


        <!-- 2. TELA DO FORMULÁRIO -->
        <div id="view-form" class="hide">
          <div class="fcard">
            <h2 id="form-title">Novo agendamento</h2>
            <form id="form-booking" method="post" action="${pageContext.request.contextPath}/admin/agendamentos">
              <input type="hidden" id="bk-id">

              <input type="hidden" name="acao" value="agendar">

              <div class="field">
                <label for="bk-client">Cliente</label>

                <select id="bk-client" name="idCliente" required>
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

              <div class="field">
                <label for="bk-car">Veículo</label>

                <select id="bk-car" name="idVeiculo" required>
                  <option value="">Selecione o cliente primeiro</option>

                  <c:forEach var="cliente" items="${clientes}">
                    <c:forEach var="veiculo" items="${cliente.veiculos}">

                      <option value="${veiculo.id}" data-cliente-id="${cliente.id_cliente}">

                        #
                        <c:out value="${veiculo.id}" />
                        —
                        <c:out value="${veiculo.marca}" />
                        <c:out value="${veiculo.modelo}" />
                        (
                        <c:out value="${veiculo.placa}" />)

                      </option>

                    </c:forEach>
                  </c:forEach>

                </select>
              </div>

              <div class="field">
                <label>Serviços escolhidos</label>

                <div id="services-checkboxes">

                  <c:forEach var="servico" items="${servicos}">
                    <label class="service-option">

                      <span class="service-option-main">
                        <input type="checkbox" name="idServicos" value="${servico.id}" data-preco="${servico.preco}">
                        <c:out value="${servico.nome}" />
                      </span>

                      <span class="service-option-price">
                        R$
                        <c:out value="${servico.preco}" />
                      </span>

                    </label>
                  </c:forEach>

                </div>
              </div>

              <div class="fgrid">
                <div class="field">
                  <label for="bk-date">Data</label>
                  <input type="date" id="bk-date" name="data" required>
                </div>
                <div class="field">
                  <label for="bk-slot">Horário</label>
                  <select id="bk-slot" name="horario" required>
                    <option value="08:00">08:00</option>
                    <option value="09:00">09:00</option>
                    <option value="10:00">10:00</option>
                    <option value="11:00">11:00</option>
                    <option value="13:00">13:00</option>
                    <option value="14:00">14:00</option>
                    <option value="15:00">15:00</option>
                    <option value="16:00">16:00</option>
                    <option value="17:00">17:00</option>
                  </select>
                </div>
              </div>

              <p class="tot">Total do Agendamento: <b id="bk-total">R$ 0,00</b></p>
              <p class="err" id="form-error" role="alert" style="color: #B3261E; font-size: 0.9rem; margin-top: 8px;">
              </p>

              <div class="facts">
                <button class="btn" type="submit">Salvar Agendamento</button>
                <button class="btn ghost" type="button" id="btn-cancel-booking">Cancelar</button>
              </div>
            </form>
          </div>
        </div>
        </div>
      </main>

      <script src="${pageContext.request.contextPath}/Assets/Js/painel.js"></script>

      <script>
        const buscaAgendamento = document.getElementById("input-search");
        const filtroStatus = document.getElementById("booking-status-filter");

        function filtrarAgendamentos() {
          const busca = buscaAgendamento.value.trim().toLowerCase();
          const status = filtroStatus.value;

          let visiveis = 0;

          document.querySelectorAll(".booking-item").forEach(item => {

            const texto = (item.dataset.search || "").toLowerCase();

            const correspondeBusca = texto.includes(busca);
            const correspondeStatus =
              !status || item.dataset.status === status;

            const mostrar = correspondeBusca && correspondeStatus;

            item.classList.toggle("hide", !mostrar);

            if (mostrar) visiveis++;
          });

          const aviso = document.getElementById("booking-empty-filter");

          if (aviso) {
            aviso.classList.toggle("hide", visiveis > 0);
          }
        }

        buscaAgendamento.addEventListener("input", filtrarAgendamentos);
        filtroStatus.addEventListener("change", filtrarAgendamentos);
      </script>

      <script>
        document.querySelectorAll(".booking-open").forEach(botao => {

          botao.addEventListener("click", () => {

            const idDialog = botao.dataset.dialogId;
            const dialog = document.getElementById(idDialog);

            if (dialog) {
              dialog.showModal();
            }
          });
        });

        document.querySelectorAll(".booking-modal").forEach(dialog => {

          dialog.querySelectorAll(".booking-close").forEach(botao => {
            botao.addEventListener("click", () => dialog.close());
          });

          dialog.addEventListener("click", evento => {
            if (evento.target === dialog) {
              dialog.close();
            }
          });
        });
      </script>

      <script>
        const campoClienteAgendamento = document.getElementById("bk-client");
        const campoVeiculoAgendamento = document.getElementById("bk-car");

        // Guarda as opções recebidas do MySQL
        const veiculosDisponiveis = Array.from(
          campoVeiculoAgendamento.querySelectorAll(
            "option[data-cliente-id]"
          )
        ).map(opcao => ({
          id: opcao.value,
          clienteId: opcao.dataset.clienteId,
          descricao: opcao.textContent.trim().replace(/\s+/g, " ")
        }));

        function atualizarVeiculosAgendamento() {

          const idCliente = campoClienteAgendamento.value;

          campoVeiculoAgendamento.replaceChildren();

          const primeiraOpcao = document.createElement("option");
          primeiraOpcao.value = "";

          if (!idCliente) {
            primeiraOpcao.textContent = "Selecione o cliente primeiro";
            campoVeiculoAgendamento.appendChild(primeiraOpcao);
            return;
          }

          const veiculosCliente = veiculosDisponiveis.filter(
            veiculo => veiculo.clienteId === idCliente
          );

          primeiraOpcao.textContent = veiculosCliente.length
            ? "Selecione um veículo"
            : "Este cliente não possui veículos ativos";

          campoVeiculoAgendamento.appendChild(primeiraOpcao);

          veiculosCliente.forEach(veiculo => {

            const opcao = document.createElement("option");

            opcao.value = veiculo.id;
            opcao.textContent = veiculo.descricao;

            campoVeiculoAgendamento.appendChild(opcao);
          });
        }

        campoClienteAgendamento.addEventListener(
          "change",
          atualizarVeiculosAgendamento
        );

        atualizarVeiculosAgendamento();

        // Atualizar o valor total dos serviços selecionados
        const checkboxesServicos = document.querySelectorAll(
          '#services-checkboxes input[name="idServicos"]'
        );

        const totalAgendamento = document.getElementById("bk-total");

        function calcularTotalAgendamento() {

          let total = 0;

          checkboxesServicos.forEach(checkbox => {

            if (checkbox.checked) {
              const preco = Number(checkbox.dataset.preco);

              if (Number.isFinite(preco)) {
                total += preco;
              }
            }
          });

          totalAgendamento.textContent = total.toLocaleString("pt-BR", {
            style: "currency",
            currency: "BRL"
          });
        }

        // Recalcular sempre que selecionar ou desmarcar um serviço
        checkboxesServicos.forEach(checkbox => {
          checkbox.addEventListener("change", calcularTotalAgendamento);
        });

        // Atualizar também ao abrir Novo agendamento
        document.getElementById("btn-add-booking")
          .addEventListener("click", calcularTotalAgendamento);

        calcularTotalAgendamento();
      </script>

    </body>

    </html>