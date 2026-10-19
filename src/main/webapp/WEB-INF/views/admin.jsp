<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Gestão do lava-rápido</title>
</head>
<body>
    <h1>Gestão do lava-rápido</h1>
    <p>Olá, <c:out value="${sessionScope.colaboradorNome}"/> — perfil <c:out value="${sessionScope.nivelAcesso}"/></p>
    <nav>
        <a href="${pageContext.request.contextPath}/admin">Início</a> |
        <a href="${pageContext.request.contextPath}/admin/atendimentos">Atendimentos</a>
        <c:if test="${sessionScope.nivelAcesso == 'ADMINISTRADOR' || sessionScope.nivelAcesso == 'ATENDENTE'}">
            | <a href="${pageContext.request.contextPath}/admin/pagamentos">Pagamentos</a>
        </c:if>
        <c:if test="${sessionScope.nivelAcesso == 'ADMINISTRADOR'}">
            | <a href="${pageContext.request.contextPath}/admin/servicos">Serviços</a>
            | <a href="${pageContext.request.contextPath}/admin/colaboradores">Colaboradores</a>
        </c:if>
    </nav>
    <form method="post" action="${pageContext.request.contextPath}/sair">
        <button type="submit">Sair</button>
    </form>
    <c:if test="${not empty erro}"><p role="alert"><c:out value="${erro}"/></p></c:if>
    <c:if test="${param.sucesso == '1'}"><p>Operação concluída com sucesso.</p></c:if>

    <c:if test="${secao == 'inicio'}">
        <h2>Painel</h2>
        <p>Use a navegação para acompanhar atendimentos e, conforme seu perfil, administrar serviços, equipe e pagamentos.</p>
    </c:if>

    <c:if test="${secao == 'servicos'}">
        <h2>Catálogo de serviços</h2>
        <form method="post" action="${pageContext.request.contextPath}/admin/servicos">
            <input type="hidden" name="acao" value="salvar">
            <label>Nome: <input name="nome" maxlength="100" required></label>
            <label>Descrição: <input name="descricao" maxlength="255"></label>
            <label>Preço: <input type="number" name="preco" min="0" step="0.01" required></label>
            <button type="submit">Adicionar serviço</button>
        </form>
        <c:forEach var="servico" items="${servicos}">
            <form method="post" action="${pageContext.request.contextPath}/admin/servicos">
                <input type="hidden" name="acao" value="salvar">
                <input type="hidden" name="idServico" value="${servico.id}">
                <label>Nome: <input name="nome" maxlength="100" value="<c:out value='${servico.nome}'/>" required></label>
                <label>Descrição: <input name="descricao" maxlength="255" value="<c:out value='${servico.descricao}'/>"></label>
                <label>Preço: <input type="number" name="preco" min="0" step="0.01" value="${servico.preco}" required></label>
                <button type="submit">Salvar</button>
            </form>
            <form method="post" action="${pageContext.request.contextPath}/admin/servicos">
                <input type="hidden" name="acao" value="remover">
                <input type="hidden" name="idServico" value="${servico.id}">
                <button type="submit">Remover serviço</button>
            </form>
            <hr>
        </c:forEach>
    </c:if>

    <c:if test="${secao == 'colaboradores'}">
        <h2>Cadastrar colaborador</h2>
        <form method="post" action="${pageContext.request.contextPath}/admin/colaboradores">
            <label>Nome: <input name="nome" maxlength="100" required></label><br><br>
            <label>Cargo: <input name="cargo" maxlength="60" required></label><br><br>
            <label>E-mail: <input type="email" name="email" maxlength="150" required></label><br><br>
            <label>Senha: <input type="password" name="senha" minlength="8" required></label><br><br>
            <label>Nível de acesso:
                <select name="nivelAcesso">
                    <option value="OPERACIONAL">Operacional</option>
                    <option value="ATENDENTE">Atendente</option>
                    <option value="ADMINISTRADOR">Administrador</option>
                </select>
            </label>
            <button type="submit">Cadastrar</button>
        </form>
        <h2>Equipe</h2>
        <table border="1" cellpadding="6">
            <thead><tr><th>Nome</th><th>Cargo</th><th>Nível</th><th>E-mail</th></tr></thead>
            <tbody>
                <c:forEach var="colaborador" items="${colaboradores}">
                    <tr>
                        <td><c:out value="${colaborador.nome}"/></td>
                        <td><c:out value="${colaborador.cargo}"/></td>
                        <td><c:out value="${colaborador.nivelAcesso}"/></td>
                        <td><c:out value="${colaborador.email}"/></td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </c:if>

    <c:if test="${secao == 'atendimentos'}">
        <h2>Atendimentos</h2>
        <table border="1" cellpadding="6">
            <thead><tr><th>Cliente</th><th>Placa</th><th>Agendamento</th><th>Status</th><th>Equipe</th><th>Ação</th></tr></thead>
            <tbody>
                <c:forEach var="atendimento" items="${atendimentos}">
                    <tr>
                        <td><c:out value="${atendimento.cliente}"/></td>
                        <td><c:out value="${atendimento.placa}"/></td>
                        <td><c:out value="${atendimento.data}"/> <c:out value="${atendimento.horario}"/></td>
                        <td><c:out value="${atendimento.status}"/> (<c:out value="${atendimento.statusAgendamento}"/>)</td>
                        <td><c:out value="${atendimento.colaboradores}"/></td>
                        <td>
                            <c:if test="${atendimento.statusAgendamento != 'CANCELADO'}">
                                <form method="post" action="${pageContext.request.contextPath}/admin/atendimentos">
                                    <input type="hidden" name="idAtendimento" value="${atendimento.id}">
                                    <label>Status:
                                        <select name="status">
                                            <c:if test="${atendimento.status == 'AGUARDANDO'}">
                                                <option value="AGUARDANDO" selected>Aguardando</option>
                                                <option value="EM_LAVAGEM">Em lavagem</option>
                                            </c:if>
                                            <c:if test="${atendimento.status == 'EM_LAVAGEM'}">
                                                <option value="EM_LAVAGEM" selected>Em lavagem</option>
                                                <option value="FINALIZADO">Finalizado</option>
                                            </c:if>
                                            <c:if test="${atendimento.status == 'FINALIZADO'}">
                                                <option value="FINALIZADO" selected>Finalizado</option>
                                                <option value="ENTREGUE">Entregue</option>
                                            </c:if>
                                            <c:if test="${atendimento.status == 'ENTREGUE'}">
                                                <option value="ENTREGUE" selected>Entregue</option>
                                            </c:if>
                                        </select>
                                    </label>
                                    <label>Equipe:
                                        <select name="idColaboradores" multiple>
                                            <c:forEach var="colaborador" items="${colaboradores}">
                                                <option value="${colaborador.id}"
                                                    ${fn:contains(',' += atendimento.idsColaboradores += ',',
                                                        ',' += colaborador.id += ',') ? 'selected' : ''}>
                                                    <c:out value="${colaborador.nome}"/>
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </label>
                                    <button type="submit">Atualizar</button>
                                </form>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </c:if>

    <c:if test="${secao == 'pagamentos'}">
        <h2>Pagamentos</h2>
        <table border="1" cellpadding="6">
            <thead><tr><th>Cliente</th><th>Agendamento</th><th>Valor</th><th>Status</th><th>Forma atual</th><th>Ação</th></tr></thead>
            <tbody>
                <c:forEach var="pagamento" items="${pagamentos}">
                    <tr>
                        <td><c:out value="${pagamento.cliente}"/></td>
                        <td>#<c:out value="${pagamento.idAgendamento}"/> — <c:out value="${pagamento.placa}"/>, <c:out value="${pagamento.data}"/> <c:out value="${pagamento.horario}"/></td>
                        <td>R$ <c:out value="${pagamento.valor}"/></td>
                        <td><c:out value="${pagamento.status}"/></td>
                        <td><c:out value="${pagamento.forma}"/></td>
                        <td>
                            <c:if test="${pagamento.status == 'PENDENTE'}">
                                <form method="post" action="${pageContext.request.contextPath}/admin/pagamentos">
                                    <input type="hidden" name="idPagamento" value="${pagamento.id}">
                                    <label>Forma:
                                        <select name="formaPagamento">
                                            <option value="DINHEIRO">Dinheiro</option>
                                            <option value="PIX">PIX</option>
                                            <option value="CREDITO">Crédito</option>
                                            <option value="DEBITO">Débito</option>
                                        </select>
                                    </label>
                                    <button name="status" value="PAGO">Registrar pagamento</button>
                                    <button name="status" value="CANCELADO">Cancelar pagamento</button>
                                </form>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </c:if>
</body>
</html>
