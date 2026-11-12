<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <fmt:setLocale value="pt_BR" />
            <!doctype html>
            <html lang="pt-BR">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <title>Serviços — Fast Splash</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/Assets/CSS/painel.css">
                <style>
                    .servicos-filtros {
                        display: flex;
                        align-items: center;
                        gap: 12px;
                        margin: 18px 0 16px;
                    }

                    .servicos-filtros input {
                        width: 100%;
                        min-height: 44px;
                        padding: 10px 14px;
                        background: #0b3050;
                        border: 1px solid #365875;
                        border-radius: 6px;
                        color: #fff;
                    }

                    .servicos-tabela-wrap {
                        background: #0b3050;
                        border: 1px solid #365875;
                        border-radius: 14px;
                        padding: 14px 18px;
                        overflow-x: auto;
                    }

                    .servicos-tabela {
                        width: 100%;
                        border-collapse: collapse;
                        table-layout: fixed;
                    }

                    .servicos-tabela th,
                    .servicos-tabela td {
                        text-align: left;
                        padding: 16px 12px;
                        border-bottom: 1px solid #365875;
                        vertical-align: middle;
                    }

                    .servicos-tabela th {
                        color: #9fc7e0;
                        font-size: .85rem;
                    }

                    .servicos-tabela td {
                        color: #fff;
                        font-size: .9rem;
                    }

                    .servicos-tabela tbody tr:last-child td {
                        border-bottom: 0;
                    }


                    .servicos-tabela th:nth-child(1) {
                        width: 55%;
                    }

                    .servicos-tabela th:nth-child(2) {
                        width: 20%;
                    }

                    .servicos-tabela th:nth-child(3) {
                        width: 25%;
                    }


                    .servico-nome {
                        display: block;
                        color: #fff;
                        font-weight: 700;
                    }

                    .servico-descricao {
                        display: block;
                        margin-top: 5px;
                        color: #9fc7e0;
                        font-size: .8rem;
                        font-weight: 400;
                        overflow-wrap: anywhere;
                    }

                    .servico-preco {
                        font-weight: 700;
                        white-space: nowrap;
                    }

                    .servico-acoes {
                        display: flex;
                        align-items: center;
                        flex-wrap: wrap;
                        gap: 8px;
                    }

                    .servico-acoes form {
                        display: inline-flex;
                        margin: 0;
                    }

                    .servico-acoes .btn {
                        white-space: nowrap;
                    }

                    .servico-remover {
                        color: #ffaaaa;
                        border-color: #984c50;
                    }

                    .servico-remover:hover {
                        background: #602b32;
                        color: #fff;
                    }

                    .linha-servico.hide {
                        display: none !important;
                    }

                    dialog.servico-modal {
                        position: fixed;
                        inset: 0;
                        margin: auto;
                        width: min(560px, calc(100vw - 32px));
                        max-width: 560px;
                        max-height: 88vh;
                        overflow-y: auto;
                        padding: 26px 30px;
                        background: #0b3050;
                        border: 1px solid #365875;
                        border-radius: 16px;
                        color: #fff;
                        box-shadow: 0 20px 65px #0009;
                    }

                    dialog.servico-modal:not([open]) {
                        display: none;
                    }

                    dialog.servico-modal::backdrop {
                        background: rgba(0, 10, 20, .75);
                    }

                    .servico-modal-cabecalho {
                        display: flex;
                        align-items: flex-start;
                        justify-content: space-between;
                        gap: 12px;
                        margin-bottom: 20px;
                    }

                    .servico-modal-cabecalho h2 {
                        margin: 0;
                    }

                    .servico-modal-fechar {
                        border: 0;
                        background: transparent;
                        color: #fff;
                        cursor: pointer;
                        font-size: 1.35rem;
                        padding: 2px 6px;
                    }

                    .servico-modal .field {
                        margin-bottom: 16px;
                    }

                    .servico-modal .field input {
                        display: block;
                        width: 100%;
                        box-sizing: border-box;
                        background: #061e32;
                        color: #fff;
                        border: 1px solid #365875;
                        border-radius: 5px;
                        padding: 12px;
                    }

                    .servico-modal .field label {
                        display: block;
                        margin-bottom: 7px;
                    }

                    .servico-modal .facts {
                        display: flex;
                        flex-wrap: wrap;
                        gap: 10px;
                        margin-top: 18px;
                    }

                    @media(max-width:600px) {
                        .servicos-tabela {
                            min-width: 560px;
                        }

                        dialog.servico-modal {
                            padding: 20px;
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
                        <nav><a href="${pageContext.request.contextPath}/admin/inicio">Voltar ao início</a></nav>
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
                            <span
                                class="role ${sessionScope.nivelAcesso == 'ADMINISTRADOR' ? 'admin' : sessionScope.nivelAcesso == 'ATENDENTE' ? 'atendente' : 'operacional'}">
                                <c:choose>
                                    <c:when test="${sessionScope.nivelAcesso == 'ADMINISTRADOR'}">Administrador</c:when>
                                    <c:when test="${sessionScope.nivelAcesso == 'ATENDENTE'}">Atendente</c:when>
                                    <c:otherwise>Operacional</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <nav class="ptabs" aria-label="Áreas do painel">
                            <a href="${pageContext.request.contextPath}/admin/inicio">Início</a>
                            <a href="${pageContext.request.contextPath}/painel/clientes">Clientes</a>
                            <a href="${pageContext.request.contextPath}/painel/carros">Veículos</a>
                            <a href="${pageContext.request.contextPath}/painel/agendamentos">Agendamentos</a>
                            <a href="${pageContext.request.contextPath}/painel/atendimentos">Atendimentos</a>
                            <a href="${pageContext.request.contextPath}/painel/pagamentos">Pagamentos</a>
                            <a href="${pageContext.request.contextPath}/painel/colaboradores">Colaboradores</a>
                            <a href="${pageContext.request.contextPath}/painel/servicos" class="on"
                                aria-current="page">Serviços</a>
                        </nav>
                        <div class="phead">
                            <div>
                                <h2>Serviços</h2>
                                <p class="small">Gerencie os serviços oferecidos pelo lava-rápido.</p>
                            </div>
                            <button type="button" class="btn" id="btn-novo-servico">Novo serviço</button>
                        </div>
                        <c:if test="${not empty erro}">
                            <p class="err" role="alert">
                                <c:out value="${erro}" />
                            </p>
                        </c:if>
                        <c:if test="${param.sucesso == '1'}">
                            <p class="ok" role="status">Operação realizada com sucesso.</p>
                        </c:if>
                        <div class="servicos-filtros">
                            <input type="search" id="busca-servico" placeholder="Buscar por ID, nome ou descrição..."
                                autocomplete="off" aria-label="Buscar serviços">
                        </div>
                        <c:choose>
                            <c:when test="${empty servicos}">
                                <p class="small">Nenhum serviço cadastrado.</p>
                            </c:when>
                            <c:otherwise>
                                <div class="servicos-tabela-wrap">
                                    <table class="servicos-tabela">
                                        <thead>
                                            <tr>
                                                <th>Serviço</th>
                                                <th>Preço</th>
                                                <th>Ações</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="servico" items="${servicos}">
                                                <tr class="linha-servico"
                                                    data-busca="<c:out value='${servico.id} ${servico.nome} ${servico.descricao}' />">

                                                    <td>
                                                        <span class="servico-nome">
                                                            #
                                                            <c:out value="${servico.id}" /> —
                                                            <c:out value="${servico.nome}" />
                                                        </span>

                                                        <span class="servico-descricao">
                                                            <c:out value="${servico.descricao}" />
                                                        </span>
                                                    </td>
                                                    <td class="servico-preco">
                                                        <fmt:formatNumber value="${servico.preco}" type="currency"
                                                            currencySymbol="R$ " minFractionDigits="2"
                                                            maxFractionDigits="2" />
                                                    </td>
                                                    <td>
                                                        <div class="servico-acoes">
                                                            <button type="button" class="btn sm ghost editar-servico"
                                                                data-id="${servico.id}"
                                                                data-nome="<c:out value='${servico.nome}' />"
                                                                data-descricao="<c:out value='${servico.descricao}' />"
                                                                data-preco="${servico.preco}">Editar</button>
                                                            <form method="post"
                                                                action="${pageContext.request.contextPath}/admin/servicos"
                                                                onsubmit="return confirm('Remover este serviço? O histórico será preservado.');">
                                                                <input type="hidden" name="acao" value="remover">
                                                                <input type="hidden" name="idServico"
                                                                    value="${servico.id}">
                                                                <button class="btn sm ghost servico-remover"
                                                                    type="submit">Remover</button>
                                                            </form>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </main>

                <dialog id="modal-servico" class="servico-modal" aria-labelledby="titulo-formulario">
                    <div class="servico-modal-cabecalho">
                        <h2 id="titulo-formulario">Novo serviço</h2>
                        <button type="button" class="servico-modal-fechar" id="fechar-modal-servico"
                            aria-label="Fechar">&times;</button>
                    </div>
                    <form method="post" id="form-servico" action="${pageContext.request.contextPath}/admin/servicos">
                        <input type="hidden" name="acao" value="salvar">
                        <input type="hidden" id="idServico" name="idServico">
                        <div class="field"><label for="nome">Nome</label>
                            <input id="nome" name="nome" maxlength="100" required>
                        </div>
                        <div class="field"><label for="descricao">Descrição</label>
                            <input id="descricao" name="descricao" maxlength="255">
                        </div>
                        <div class="field"><label for="preco">Preço (R$)</label>
                            <input id="preco" name="preco" type="number" min="0" step="0.01" required>
                        </div>
                        <div class="facts">
                            <button class="btn" type="submit">Salvar serviço</button>
                            <button class="btn ghost" type="button" id="btn-cancelar-servico">Cancelar</button>
                        </div>
                    </form>
                </dialog>
                <script>
                    (function () {
                        const modal = document.getElementById('modal-servico');
                        const form = document.getElementById('form-servico');
                        const titulo = document.getElementById('titulo-formulario');
                        const campoId = document.getElementById('idServico');
                        const nome = document.getElementById('nome');
                        const descricao = document.getElementById('descricao');
                        const preco = document.getElementById('preco');

                        document.getElementById('btn-novo-servico').addEventListener('click', () => {
                            form.reset();
                            campoId.value = '';
                            titulo.textContent = 'Novo serviço';
                            modal.showModal();
                        });
                        document.querySelectorAll('.editar-servico').forEach(botao => {
                            botao.addEventListener('click', () => {
                                form.reset();
                                campoId.value = botao.dataset.id;
                                nome.value = botao.dataset.nome;
                                descricao.value = botao.dataset.descricao;
                                preco.value = botao.dataset.preco;
                                titulo.textContent = 'Editar serviço';
                                modal.showModal();
                            });
                        });
                        const fechar = () => modal.close();
                        document.getElementById('btn-cancelar-servico').addEventListener('click', fechar);
                        document.getElementById('fechar-modal-servico').addEventListener('click', fechar);
                        modal.addEventListener('click', event => { if (event.target === modal) fechar(); });

                        const busca = document.getElementById('busca-servico');
                        busca.addEventListener('input', () => {
                            const termo = busca.value.trim().toLocaleLowerCase('pt-BR');
                            document.querySelectorAll('.linha-servico').forEach(linha => {
                                linha.classList.toggle('hide', !(linha.dataset.busca || '').toLocaleLowerCase('pt-BR').includes(termo));
                            });
                        });
                    })();
                </script>
            </body>

            </html>