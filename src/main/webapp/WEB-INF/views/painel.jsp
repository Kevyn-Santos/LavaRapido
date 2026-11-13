<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
      <!doctype html>
      <html lang="pt-BR">

      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Painel — Fast Splash</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/Assets/CSS/painel.css">

        <style>
          .agenda-hoje {
            margin: 28px 0 36px;
            padding: 26px;
            background: #0b3050;
            border: 1px solid #365875;
            border-radius: 16px;
          }

          .agenda-hoje-topo {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            margin-bottom: 20px;
          }

          .agenda-hoje h2 {
            margin: 0;
            color: #fff;
          }

          .agenda-hoje-subtitulo {
            margin: 6px 0 0;
            color: #9fc7e0;
            font-size: .9rem;
          }

          .agenda-hoje-total {
            padding: 8px 12px;
            border-radius: 10px;
            background: #153f60;
            color: #fff;
            font-weight: 700;
            white-space: nowrap;
          }

          .agenda-hoje-item {
            display: flex;
            align-items: center;
            gap: 18px;
            padding: 16px 0;
            border-bottom: 1px solid #365875;
          }

          .agenda-hoje-item:last-child {
            border-bottom: 0;
          }

          .agenda-hoje-horario {
            min-width: 76px;
            padding: 12px;
            background: #062238;
            border-radius: 10px;
            color: #fff;
            font-weight: 700;
            text-align: center;
          }

          .agenda-hoje-info {
            flex: 1;
            min-width: 0;
          }

          .agenda-hoje-info strong {
            display: block;
            color: #fff;
            margin-bottom: 5px;
          }

          .agenda-hoje-info span {
            display: block;
            color: #9fc7e0;
            font-size: .88rem;
            overflow-wrap: anywhere;
          }

          .agenda-hoje-vazia {
            padding: 22px 0;
            color: #9fc7e0;
            text-align: center;
          }

          @media (max-width: 600px) {
            .agenda-hoje {
              padding: 18px;
            }

            .agenda-hoje-item {
              gap: 12px;
            }

            .agenda-hoje-horario {
              min-width: 62px;
              padding: 10px 6px;
            }
          }


          .agenda-hoje-item {
            justify-content: space-between;
          }

          .agenda-hoje-detalhes {
            flex-shrink: 0;
            border: 1px solid #52718b;
            border-radius: 8px;
            background: transparent;
            color: #fff;
            padding: 10px 14px;
            font-weight: 700;
            cursor: pointer;
          }

          .agenda-hoje-detalhes:hover {
            background: #17496a;
          }

          .agenda-popup {
            position: fixed;
            inset: 0;
            margin: auto;
            width: min(540px, calc(100vw - 32px));
            max-height: 85vh;
            overflow-y: auto;
            box-sizing: border-box;
            padding: 26px;
            border: 1px solid #365875;
            border-radius: 16px;
            background: #0b3050;
            color: #fff;
          }

          .agenda-popup:not([open]) {
            display: none;
          }

          .agenda-popup::backdrop {
            background: rgba(0, 10, 20, .78);
          }

          .agenda-popup-topo,
          .agenda-popup-rodape {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
          }

          .agenda-popup-topo {
            border-bottom: 1px solid #365875;
            padding-bottom: 18px;
          }

          .agenda-popup-topo h2 {
            margin: 0;
          }

          .agenda-popup-conteudo {
            display: grid;
            gap: 20px;
            padding: 22px 0;
          }

          .agenda-popup-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 18px;
          }

          .agenda-popup-campo span {
            display: block;
            margin-bottom: 5px;
            color: #9fc7e0;
            font-size: .8rem;
          }

          .agenda-popup-campo strong {
            display: block;
            overflow-wrap: anywhere;
          }

          .agenda-popup-pagamento {
            border-top: 1px solid #365875;
            padding-top: 18px;
          }

          .agenda-popup-total {
            margin-top: 18px;
            padding: 15px;
            background: #062238;
            border-radius: 10px;
            display: flex;
            justify-content: space-between;
            gap: 12px;
          }

          .agenda-popup-rodape {
            border-top: 1px solid #365875;
            padding-top: 18px;
            justify-content: flex-end;
            flex-wrap: wrap;
          }

          .agenda-popup-fechar,
          .agenda-popup-iniciar {
            padding: 11px 15px;
            border-radius: 8px;
            font-weight: 700;
            cursor: pointer;
          }

          .agenda-popup-fechar {
            border: 1px solid #52718b;
            background: transparent;
            color: #fff;
          }

          .agenda-popup-iniciar {
            border: 0;
            background: #ff8617;
            color: #071c2f;
          }

          @media (max-width: 600px) {
            .agenda-hoje-item {
              flex-wrap: wrap;
            }

            .agenda-popup-grid {
              grid-template-columns: 1fr;
            }
          }


          .agenda-form-iniciar {
            display: flex;
            flex-direction: column;
            align-items: stretch;
            gap: 16px;
            width: 100%;
          }

          .agenda-lavadores {
            border: 1px solid #365875;
            border-radius: 10px;
            padding: 14px;
            margin: 0;
            min-width: 0;
          }

          .agenda-lavadores legend {
            padding: 0 6px;
            color: #9fc7e0;
            font-weight: 700;
            font-size: .9rem;
          }

          .agenda-lavador-opcao {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 9px 4px;
            color: #fff;
            cursor: pointer;
          }

          .agenda-lavador-opcao input {
            width: 17px;
            height: 17px;
            accent-color: #ff8617;
          }

          .agenda-lavadores-vazio {
            color: #9fc7e0;
            font-size: .85rem;
          }

          .agenda-form-iniciar .agenda-popup-iniciar {
            align-self: flex-end;
          }

          .agenda-popup-iniciar:disabled {
            opacity: .5;
            cursor: not-allowed;
          }


          .panel-page-header .btn-sair {
            background: transparent;
            color: #ffffff;
            border: 1px solid #52718b;
            border-radius: 8px;
            padding: 9px 20px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            transition: background 0.2s ease;
          }

          .panel-page-header .btn-sair:hover {
            background: #17496a;
            border-color: #9fc7e0;
          }

          .panel-page-header nav form {
            margin: 0;
          }
        </style>

      </head>

      <body class="panel-page panel-home">

        <header class="top panel-page-header">
          <div class="top-in">
            <a class="lock" href="${pageContext.request.contextPath}/" aria-label="Fast Splash, início">
              <span class="wm"><span class="f">fast</span> <span class="s">splash</span></span>
            </a>

            <nav>
              <form method="post" action="${pageContext.request.contextPath}/sair">
                <button type="submit" class="btn-sair">
                  Sair
                </button>
              </form>
            </nav>

          </div>
        </header>

        <main class="page">
          <div class="wrap">
            <section class="dashboard-welcome" aria-labelledby="dashboard-title">
              <div class="dashboard-welcome-top">
                <div class="dashboard-profile">
                  <span class="dashboard-avatar" id="collaborator-initials" aria-hidden="true"></span>
                  <div>
                    <h1 id="dashboard-title">
                      <span id="dashboard-greeting">Olá</span>,
                      <span id="collaborator-name">
                        <c:out value="${sessionScope.colaboradorNome}" />
                      </span>
                    </h1>
                    <p id="dashboard-date"></p>
                  </div>
                </div>
                <span
                  class="dashboard-role role
          ${sessionScope.nivelAcesso == 'ADMINISTRADOR' ? 'admin' : sessionScope.nivelAcesso == 'ATENDENTE' ? 'atendente' : 'operacional'}">
                  <c:choose>
                    <c:when test="${sessionScope.nivelAcesso == 'ADMINISTRADOR'}">Administrador</c:when>
                    <c:when test="${sessionScope.nivelAcesso == 'ATENDENTE'}">Atendente</c:when>
                    <c:otherwise>Operacional</c:otherwise>
                  </c:choose>
                </span>
              </div>

            </section>


            <section class="agenda-hoje" aria-labelledby="agenda-hoje-titulo">

              <div class="agenda-hoje-topo">
                <div>
                  <h2 id="agenda-hoje-titulo">
                    Agendamentos de hoje
                  </h2>
                  <p class="agenda-hoje-subtitulo">
                    Programação do dia, organizada por horário.
                  </p>
                </div>

                <span class="agenda-hoje-total">
                  ${agendamentosHoje.size()} agendamento(s)
                </span>
              </div>

              <c:choose>
                <c:when test="${empty agendamentosHoje}">
                  <p class="agenda-hoje-vazia">
                    Nenhum agendamento previsto para hoje.
                  </p>
                </c:when>

                <c:otherwise>
                  <div class="agenda-hoje-lista">


                    <c:forEach var="agendamento" items="${agendamentosHoje}">

                      <div class="agenda-hoje-item">

                        <div class="agenda-hoje-horario">
                          <c:out value="${agendamento.horario.substring(0,5)}" />
                        </div>

                        <div class="agenda-hoje-info">
                          <strong>
                            #
                            <c:out value="${agendamento.id}" /> —
                            <c:out value="${agendamento.cliente}" />
                          </strong>

                          <span>
                            <c:out value="${agendamento.veiculo}" />
                            ·
                            <c:out value="${agendamento.placa}" />
                          </span>

                          <span>
                            <c:out value="${agendamento.servicos}" />
                          </span>
                        </div>

                        <button type="button" class="agenda-hoje-detalhes" data-popup="agenda-popup-${agendamento.id}">
                          Ver detalhes
                        </button>
                      </div>

                      <dialog id="agenda-popup-${agendamento.id}" class="agenda-popup">

                        <div class="agenda-popup-topo">
                          <div>
                            <h2>
                              Agendamento #
                              <c:out value="${agendamento.id}" />
                            </h2>
                            <p class="agenda-hoje-subtitulo">
                              Detalhes do agendamento
                            </p>
                          </div>

                          <button type="button" class="agenda-popup-fechar">
                            Fechar
                          </button>
                        </div>

                        <div class="agenda-popup-conteudo">

                          <div class="agenda-popup-campo">
                            <span>Cliente</span>
                            <strong>
                              <c:out value="${agendamento.cliente}" />
                            </strong>
                          </div>

                          <div class="agenda-popup-grid">

                            <div class="agenda-popup-campo">
                              <span>Veículo</span>
                              <strong>
                                <c:out value="${agendamento.veiculo}" />
                              </strong>
                            </div>

                            <div class="agenda-popup-campo">
                              <span>Placa</span>
                              <strong>
                                <c:out value="${agendamento.placa}" />
                              </strong>
                            </div>

                            <div class="agenda-popup-campo">
                              <span>Data</span>
                              <strong>
                                <c:out value="${agendamento.data}" />
                              </strong>
                            </div>

                            <div class="agenda-popup-campo">
                              <span>Horário</span>
                              <strong>
                                <c:out value="${agendamento.horario.substring(0,5)}" />
                              </strong>
                            </div>

                            <div class="agenda-popup-campo">
                              <span>Agendamento</span>
                              <strong>
                                <c:out value="${agendamento.statusAgendamento}" />
                              </strong>
                            </div>

                            <div class="agenda-popup-campo">
                              <span>Atendimento</span>
                              <strong>
                                <c:out value="${agendamento.statusAtendimento}" />
                              </strong>
                            </div>

                          </div>

                          <div class="agenda-popup-campo">
                            <span>Serviços contratados</span>
                            <strong>
                              <c:out value="${agendamento.servicos}" />
                            </strong>
                          </div>

                          <div class="agenda-popup-pagamento">

                            <h3>Pagamento</h3>

                            <div class="agenda-popup-grid">

                              <div class="agenda-popup-campo">
                                <span>Situação</span>
                                <strong>
                                  <c:out
                                    value="${empty agendamento.statusPagamento ? 'Não informado' : agendamento.statusPagamento}" />
                                </strong>
                              </div>

                              <div class="agenda-popup-campo">
                                <span>Forma de pagamento</span>
                                <strong>
                                  <c:out
                                    value="${empty agendamento.formaPagamento ? 'Não informada' : agendamento.formaPagamento}" />
                                </strong>
                              </div>

                            </div>

                            <div class="agenda-popup-total">
                              <span>Valor total</span>

                              <strong>
                                <c:choose>
                                  <c:when test="${not empty agendamento.valorTotal}">
                                    <fmt:formatNumber value="${agendamento.valorTotal}" type="currency"
                                      currencySymbol="R$ " minFractionDigits="2" maxFractionDigits="2" />
                                  </c:when>
                                  <c:otherwise>
                                    Não informado
                                  </c:otherwise>
                                </c:choose>
                              </strong>
                            </div>

                          </div>

                        </div>

                        <div class="agenda-popup-rodape">

                          <button type="button" class="agenda-popup-fechar">
                            Fechar
                          </button>

                          <c:if
                            test="${agendamento.statusAtendimento == 'AGUARDANDO' and not empty agendamento.idAtendimento}">


                            <form method="post" action="${pageContext.request.contextPath}/admin/inicio"
                              class="agenda-form-iniciar"
                              onsubmit="return confirm('Deseja iniciar este atendimento com os lavadores selecionados?');">

                              <input type="hidden" name="acao" value="iniciarAtendimento">

                              <input type="hidden" name="idAtendimento" value="${agendamento.idAtendimento}">

                              <fieldset class="agenda-lavadores">
                                <legend>Lavadores responsáveis</legend>

                                <c:set var="temLavadores" value="false" />

                                <c:forEach var="colaborador" items="${colaboradores}">
                                  <c:if test="${colaborador.nivelAcesso == 'OPERACIONAL'}">

                                    <c:set var="temLavadores" value="true" />

                                    <label class="agenda-lavador-opcao">
                                      <input type="checkbox" name="idColaboradores" value="${colaborador.id}">

                                      <span>
                                        <c:out value="${colaborador.nome}" />
                                      </span>
                                    </label>

                                  </c:if>
                                </c:forEach>

                                <c:if test="${not temLavadores}">
                                  <p class="agenda-lavadores-vazio">
                                    Nenhum lavador ativo disponível.
                                  </p>
                                </c:if>
                              </fieldset>

                              <button type="submit" class="agenda-popup-iniciar" ${not temLavadores ? 'disabled' : '' }>
                                Iniciar atendimento
                              </button>

                            </form>


                          </c:if>

                        </div>

                      </dialog>

                    </c:forEach>


                  </div>
                </c:otherwise>
              </c:choose>

            </section>

            <div class="phead">
              <div>
                <h2>Acesso rápido</h2>
                <p class="small">Gerencie clientes, veículos, agendamentos, atendimentos e demais operações do
                  lava-rápido.</p>
              </div>
            </div>

            <div class="pgrid">
              <a class="pcard" href="${pageContext.request.contextPath}/painel/clientes">
                <svg class="pi" viewBox="0 0 24 24">
                  <circle cx="9" cy="8" r="3.2" />
                  <path d="M3 20c0-3.5 3-5.5 6-5.5s6 2 6 5.5" />
                  <circle cx="17" cy="9" r="2.5" />
                  <path d="M17 14.5c2.5 0 4.5 1.5 4.5 4" />
                </svg>
                <b class="pt">Clientes</b>
                <span class="pc">Cadastre, edite e remova os clientes do lava-rápido.</span>
              </a>

              <a class="pcard" href="${pageContext.request.contextPath}/painel/carros">
                <svg class="pi" viewBox="0 0 24 24">
                  <path d="M3 16v-3.5L5.5 7h9l4 4.5H21V16" />
                  <circle cx="8" cy="17" r="2" />
                  <circle cx="17" cy="17" r="2" />
                </svg>
                <b class="pt">Veículos</b>
                <span class="pc">Adicione e edite os veículos de cada cliente.</span>
              </a>

              <a class="pcard" href="${pageContext.request.contextPath}/painel/agendamentos">
                <svg class="pi" viewBox="0 0 24 24">
                  <rect x="3" y="5" width="18" height="16" rx="2" />
                  <path d="M3 10h18M8 3v4M16 3v4" />
                </svg>
                <b class="pt">Agendamentos</b>
                <span class="pc">Agende pelo cliente e cancele agendamentos. Veja serviço, data, horário e preço.</span>
              </a>

              <a class="pcard" href="${pageContext.request.contextPath}/painel/atendimentos">
                <svg class="pi" viewBox="0 0 24 24">
                  <path d="M12 3C12 3 5 11 5 15a7 7 0 0 0 14 0C19 11 12 3 12 3z" />
                </svg>
                <b class="pt">Atendimentos</b>
                <span class="pc">Acompanhe os atendimentos em andamento e inicie o próximo.</span>
              </a>

              <a class="pcard" href="${pageContext.request.contextPath}/painel/pagamentos">
                <svg class="pi" viewBox="0 0 24 24">
                  <rect x="3" y="6" width="18" height="13" rx="2" />
                  <path d="M3 10h18M16 15h2" />
                </svg>
                <b class="pt">Pagamentos</b>
                <span class="pc">Veja os valores e registre a forma de pagamento de cada atendimento.</span>
              </a>

              <c:if test="${sessionScope.nivelAcesso == 'ADMINISTRADOR'}">

                <a class="pcard" href="${pageContext.request.contextPath}/painel/colaboradores">
                  <i class="pdot" title="Exclusivo do administrador"></i>
                  <svg class="pi" viewBox="0 0 24 24">
                    <rect x="5" y="3" width="14" height="18" rx="2" />
                    <circle cx="12" cy="10" r="2.5" />
                    <path d="M8 17c0-2 2-3 4-3s4 1 4 3" />
                  </svg>
                  <b class="pt">Colaboradores</b>
                  <span class="pc">Gerencie quem trabalha aqui e o nível de acesso de cada pessoa.</span>
                </a>

                <a class="pcard" href="${pageContext.request.contextPath}/painel/servicos">
                  <i class="pdot" title="Exclusivo do administrador"></i>
                  <svg class="pi" viewBox="0 0 24 24">
                    <path d="M3 12V4h8l10 10-8 8z" />
                    <circle cx="8" cy="8" r="1.4" />
                  </svg>
                  <b class="pt">Serviços</b>
                  <span class="pc">Defina os serviços oferecidos, a duração e os preços.</span>
              </c:if>
              </a>
            </div>
          </div>
        </main>

        <script src="${pageContext.request.contextPath}/Assets/Js/bdPainel.js"></script>


        <script>
          document.querySelectorAll(".agenda-hoje-detalhes").forEach(botao => {
            botao.addEventListener("click", () => {
              const popup = document.getElementById(botao.dataset.popup);

              if (popup) {
                popup.showModal();
              }
            });
          });

          document.querySelectorAll(".agenda-popup").forEach(popup => {

            popup.querySelectorAll(".agenda-popup-fechar").forEach(botao => {
              botao.addEventListener("click", () => {
                popup.close();
              });
            });

            popup.addEventListener("click", evento => {
              if (evento.target === popup) {
                popup.close();
              }
            });

          });


          document.querySelectorAll(".agenda-form-iniciar").forEach(form => {

            form.addEventListener("submit", evento => {

              const selecionados = form.querySelectorAll(
                'input[name="idColaboradores"]:checked'
              );

              if (selecionados.length === 0) {
                evento.preventDefault();
                alert("Selecione pelo menos um lavador para iniciar o atendimento.");
              }

            });

          });

        </script>


      </body>

      </html>