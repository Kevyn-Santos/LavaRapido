<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!doctype html>
            <html lang="pt-BR">

            <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <title>Histórico de Clientes — FastSplash</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/Assets/CSS/painel.css">
                <style>
                    .historico-intro {
                        margin-bottom: 24px;
                    }

                    .historico-intro h1 {
                        font-size: clamp(1.7rem, 3vw, 2.3rem);
                        margin-bottom: 7px;
                    }

                    .historico-pesquisa {
                        display: flex;
                        gap: 12px;
                        flex-wrap: wrap;
                        margin: 20px 0 25px;
                    }

                    .historico-pesquisa input {
                        flex: 1 1 270px;
                        min-width: 0;
                        min-height: 44px;
                        border: 1px solid var(--line);
                        border-radius: 8px;
                        background: var(--card);
                        color: var(--ink);
                        padding: 10px 14px;
                    }

                    .historico-pesquisa button {
                        border-radius: 8px;
                    }

                    .historico-lista {
                        display: grid;
                        gap: 12px;
                    }

                    .historico-item {
                        padding: 20px;
                        background: var(--card);
                        border: 1px solid var(--line);
                        border-radius: 12px;
                    }

                    .historico-item-topo {
                        display: flex;
                        justify-content: space-between;
                        align-items: flex-start;
                        flex-wrap: wrap;
                        gap: 10px;
                    }

                    .historico-item h2 {
                        font-size: 1.15rem;
                        margin: 0 0 8px;
                    }

                    .historico-status {
                        display: inline-block;
                        padding: 4px 11px;
                        border-radius: 999px;
                        font-size: .8rem;
                        font-weight: 700;
                        background: var(--paper-2);
                        border: 1px solid var(--line);
                    }

                    .historico-dados {
                        display: flex;
                        flex-wrap: wrap;
                        gap: 8px 22px;
                        margin: 8px 0 16px;
                        color: var(--muted);
                        font-size: .9rem;
                        overflow-wrap: anywhere;
                    }

                    .historico-contadores {
                        display: flex;
                        gap: 12px;
                        flex-wrap: wrap;
                    }

                    .historico-contadores span {
                        padding: 8px 12px;
                        background: var(--paper);
                        border: 1px solid var(--line);
                        border-radius: 8px;
                        font-size: .9rem;
                    }

                    .historico-aviso {
                        padding: 22px;
                        background: var(--card);
                        border: 1px dashed var(--line);
                        border-radius: 12px;
                        color: var(--muted);
                    }

                    .historico-voltar {
                        display: inline-block;
                        margin-bottom: 22px;
                        color: var(--primary);
                        font-weight: 700;
                    }

                    .historico-acoes {
                        margin-top: 16px;
                    }

                    .historico-acoes .btn {
                        display: inline-flex;
                        border-radius: 9px;
                    }

                    .historico-detalhes {
                        margin-top: 28px;
                        padding-top: 24px;
                        border-top: 1px solid var(--line);
                    }

                    .historico-detalhes h2 {
                        font-size: clamp(1.4rem, 2.5vw, 1.9rem);
                        margin-bottom: 8px;
                    }

                    .historico-detalhes-intro {
                        margin-bottom: 20px;
                    }

                    .historico-registros {
                        display: grid;
                        gap: 15px;
                    }

                    .historico-registro {
                        background: var(--card);
                        border: 1px solid var(--line);
                        border-radius: 12px;
                        padding: 20px;
                    }

                    .historico-registro-topo {
                        display: flex;
                        justify-content: space-between;
                        align-items: start;
                        flex-wrap: wrap;
                        gap: 10px;
                        margin-bottom: 18px;
                    }

                    .historico-registro-topo h3 {
                        font-size: 1.12rem;
                        margin-bottom: 5px;
                    }

                    .historico-registro-status {
                        padding: 5px 10px;
                        background: var(--paper-2);
                        border: 1px solid var(--line);
                        border-radius: 999px;
                        font-size: .8rem;
                        font-weight: 700;
                    }

                    .historico-registro-grid {
                        display: grid;
                        grid-template-columns: repeat(3, minmax(0, 1fr));
                        gap: 16px;
                    }

                    .historico-campo {
                        display: grid;
                        gap: 5px;
                        min-width: 0;
                    }

                    .historico-campo>span {
                        color: var(--muted);
                        font-size: .83rem;
                    }

                    .historico-campo>strong {
                        font-size: .95rem;
                        overflow-wrap: anywhere;
                    }

                    .historico-resumo {
                        margin-top: 20px;
                        padding-top: 16px;
                        border-top: 1px solid var(--line);
                        display: flex;
                        align-items: flex-end;
                        justify-content: space-between;
                        flex-wrap: wrap;
                        gap: 14px;
                    }

                    .historico-resumo strong {
                        font-size: 1.22rem;
                    }

                    @media (max-width: 720px) {
                        .historico-registro-grid {
                            grid-template-columns: repeat(2, minmax(0, 1fr));
                        }
                    }

                    @media (max-width: 480px) {
                        .historico-registro-grid {
                            grid-template-columns: 1fr;
                        }
                    }
                </style>
            </head>

            <body class="panel-page">
                <header class="top panel-page-header">
                    <div class="top-in">
                        <a class="lock" href="${pageContext.request.contextPath}/admin/inicio"
                            aria-label="FastSplash, painel inicial">
                            <span class="wm"><span class="f">fast</span> <span class="s">splash</span></span>
                        </a>
                        <nav><a href="${pageContext.request.contextPath}/admin/inicio">Voltar ao painel</a></nav>
                    </div>
                </header>

                <main class="page">
                    <div class="wrap">

                        <nav class="ptabs" aria-label="Áreas do painel">
                            <a href="${pageContext.request.contextPath}/admin/inicio">Início</a>
                            <a href="${pageContext.request.contextPath}/painel/clientes">Clientes</a>
                            <a href="${pageContext.request.contextPath}/painel/carros">Veículos</a>
                            <a href="${pageContext.request.contextPath}/painel/agendamentos">Agendamentos</a>
                            <a href="${pageContext.request.contextPath}/painel/atendimentos">Atendimentos</a>
                            <a href="${pageContext.request.contextPath}/painel/pagamentos">Pagamentos</a>

                            <c:if test="${sessionScope.nivelAcesso == 'ADMINISTRADOR'}">
                                <a href="${pageContext.request.contextPath}/painel/colaboradores">Colaboradores</a>
                                <a href="${pageContext.request.contextPath}/painel/servicos">Serviços</a>
                            </c:if>

                            <a href="${pageContext.request.contextPath}/painel/historico" class="on"
                                aria-current="page">Histórico</a>
                        </nav>

                        <a class="historico-voltar" href="${pageContext.request.contextPath}/admin/inicio">← Início</a>
                        <section class="historico-intro">
                            <h1>Histórico de Clientes</h1>
                            <p class="small">Consulte informações e registros associados a um cliente. Nenhum dado pode
                                ser alterado nesta página.</p>
                        </section>

                        <form class="historico-pesquisa" method="get"
                            action="${pageContext.request.contextPath}/painel/historico" role="search">
                            <input name="pesquisa" type="search" maxlength="100" required
                                placeholder="Digite o nome ou ID do cliente"
                                aria-label="Pesquisar por nome ou ID do cliente" value="<c:out value='${pesquisa}' />">
                            <button type="submit" class="btn">Pesquisar</button>
                        </form>

                        <c:choose>
                            <c:when test="${empty pesquisa}">
                                <p class="historico-aviso">Digite um nome ou ID para começar a consulta.</p>
                            </c:when>
                            <c:when test="${empty clientesHistorico}">
                                <p class="historico-aviso">Nenhum cliente encontrado para a pesquisa informada.</p>
                            </c:when>
                            <c:otherwise>
                                <p class="small" style="margin-bottom: 14px;">Clientes encontrados:
                                    <c:out value="${clientesHistorico.size()}" />
                                </p>
                                <div class="historico-lista">
                                    <c:forEach var="cliente" items="${clientesHistorico}">
                                        <article class="historico-item">
                                            <div class="historico-item-topo">
                                                <h2>#
                                                    <c:out value="${cliente.id}" /> —
                                                    <c:out value="${cliente.nome}" />
                                                </h2>
                                                <span class="historico-status">
                                                    <c:choose>
                                                        <c:when test="${cliente.ativo}">Ativo</c:when>
                                                        <c:otherwise>Inativo</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </div>
                                            <div class="historico-dados">
                                                <span>E-mail:
                                                    <c:out value="${cliente.email}" />
                                                </span>
                                                <span>Telefone:
                                                    <c:out value="${cliente.telefone}" />
                                                </span>
                                            </div>
                                            <div class="historico-contadores">
                                                <span>Veículos: <strong>
                                                        <c:out value="${cliente.totalVeiculos}" />
                                                    </strong></span>
                                                <span>Agendamentos: <strong>
                                                        <c:out value="${cliente.totalAgendamentos}" />
                                                    </strong></span>
                                            </div>
                                            <div class="historico-acoes">
                                                <c:url var="urlHistoricoCliente" value="/painel/historico">
                                                    <c:param name="pesquisa" value="${pesquisa}" />
                                                    <c:param name="idCliente" value="${cliente.id}" />
                                                </c:url>
                                                <a class="btn sm" href="${urlHistoricoCliente}">Ver histórico</a>
                                            </div>
                                        </article>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <c:if test="${not empty idClienteSelecionado}">
                            <section class="historico-detalhes" aria-labelledby="historico-detalhes-titulo">
                                <h2 id="historico-detalhes-titulo">Histórico do cliente #
                                    <c:out value="${idClienteSelecionado}" />
                                </h2>
                                <p class="small historico-detalhes-intro">Registros ordenados dos mais recentes para os
                                    mais antigos. Apenas consulta.</p>

                                <c:choose>
                                    <c:when test="${empty registrosHistorico}">
                                        <p class="historico-aviso">Nenhum agendamento encontrado para este cliente.</p>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="historico-registros">
                                            <c:forEach var="registro" items="${registrosHistorico}">
                                                <article class="historico-registro">
                                                    <div class="historico-registro-topo">
                                                        <div>
                                                            <h3>Agendamento #
                                                                <c:out value="${registro.id}" />
                                                            </h3>
                                                            <p class="small">
                                                                <fmt:formatDate value="${registro.data}"
                                                                    pattern="dd/MM/yyyy" />
                                                                ·
                                                                <c:out value="${registro.horario}" />
                                                            </p>
                                                        </div>
                                                        <span class="historico-registro-status">
                                                            <c:out value="${registro.statusAgendamento}" />
                                                        </span>
                                                    </div>

                                                    <div class="historico-registro-grid">
                                                        <div class="historico-campo"><span>Veículo</span><strong>
                                                                <c:out value="${registro.veiculo}" />
                                                            </strong></div>
                                                        <div class="historico-campo"><span>Placa</span><strong>
                                                                <c:out value="${registro.placa}" />
                                                            </strong></div>
                                                        <div class="historico-campo"><span>ID do veículo</span><strong>#
                                                                <c:out value="${registro.idVeiculo}" />
                                                            </strong></div>
                                                        <div class="historico-campo"><span>Serviços
                                                                contratados</span><strong>
                                                                <c:out value="${registro.servicos}"
                                                                    default="Não informado" />
                                                            </strong></div>
                                                        <div class="historico-campo"><span>Atendimento</span><strong>
                                                                <c:out
                                                                    value="${empty registro.statusAtendimento ? 'Não informado' : registro.statusAtendimento}" />
                                                            </strong></div>
                                                        <div class="historico-campo"><span>Pagamento</span><strong>
                                                                <c:out
                                                                    value="${empty registro.statusPagamento ? 'Não informado' : registro.statusPagamento}" />
                                                            </strong></div>
                                                        <div class="historico-campo"><span>Forma de
                                                                pagamento</span><strong>
                                                                <c:out
                                                                    value="${empty registro.formaPagamento ? 'Não informada' : registro.formaPagamento}" />
                                                            </strong></div>
                                                        <div class="historico-campo"><span>Início do
                                                                atendimento</span><strong>
                                                                <c:choose>
                                                                    <c:when test="${not empty registro.dataInicio}">
                                                                        <fmt:formatDate value="${registro.dataInicio}"
                                                                            pattern="dd/MM/yyyy HH:mm" />
                                                                    </c:when>
                                                                    <c:otherwise>Não registrado</c:otherwise>
                                                                </c:choose>
                                                            </strong></div>
                                                        <div class="historico-campo"><span>Fim do
                                                                atendimento</span><strong>
                                                                <c:choose>
                                                                    <c:when test="${not empty registro.dataFim}">
                                                                        <fmt:formatDate value="${registro.dataFim}"
                                                                            pattern="dd/MM/yyyy HH:mm" />
                                                                    </c:when>
                                                                    <c:otherwise>Não registrado</c:otherwise>
                                                                </c:choose>
                                                            </strong></div>
                                                    </div>
                                                    <div class="historico-resumo">
                                                        <div class="historico-campo"><span>Total dos
                                                                serviços</span><strong>
                                                                <fmt:formatNumber value="${registro.totalServicos}"
                                                                    type="currency" currencySymbol="R$ " />
                                                            </strong></div>
                                                        <div class="historico-campo"><span>Valor do
                                                                pagamento</span><strong>
                                                                <c:choose>
                                                                    <c:when test="${not empty registro.valorPagamento}">
                                                                        <fmt:formatNumber
                                                                            value="${registro.valorPagamento}"
                                                                            type="currency" currencySymbol="R$ " />
                                                                    </c:when>
                                                                    <c:otherwise>Não informado</c:otherwise>
                                                                </c:choose>
                                                            </strong></div>
                                                    </div>
                                                </article>
                                            </c:forEach>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </section>
                        </c:if>
                    </div>
                </main>
            </body>

            </html>