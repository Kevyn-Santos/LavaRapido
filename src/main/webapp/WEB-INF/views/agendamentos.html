<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Agendamentos</title>
</head>
<body>
    <h1>Agendamentos</h1>
    <p><a href="${pageContext.request.contextPath}/portal">Voltar à área do cliente</a></p>
    <c:if test="${not empty erro}"><p role="alert"><c:out value="${erro}"/></p></c:if>
    <c:if test="${param.sucesso == '1'}"><p>Operação concluída com sucesso.</p></c:if>
    <h2>Novo agendamento</h2>
    <c:choose>
        <c:when test="${empty veiculos}"><p>Cadastre um veículo antes de agendar.</p></c:when>
        <c:when test="${empty servicos}"><p>Não há serviços disponíveis no momento.</p></c:when>
        <c:otherwise>
            <form method="post" action="${pageContext.request.contextPath}/agendamentos">
                <input type="hidden" name="acao" value="agendar">
                <label>Veículo:
                    <select name="idVeiculo" required>
                        <c:forEach var="veiculo" items="${veiculos}">
                            <option value="${veiculo.id}"><c:out value="${veiculo.placa}"/> — <c:out value="${veiculo.marca}"/> <c:out value="${veiculo.modelo}"/></option>
                        </c:forEach>
                    </select>
                </label><br><br>
                <label>Data: <input type="date" name="data" min="${dataMinima}" required></label><br><br>
                <label>Horário: <input type="time" name="horario" required></label><br><br>
                <fieldset>
                    <legend>Serviços (selecione um ou mais)</legend>
                    <c:forEach var="servico" items="${servicos}">
                        <label>
                            <input type="checkbox" name="idServicos" value="${servico.id}">
                            <c:out value="${servico.nome}"/> — R$ <c:out value="${servico.preco}"/>
                            <c:if test="${not empty servico.descricao}">(<c:out value="${servico.descricao}"/>)</c:if>
                        </label><br>
                    </c:forEach>
                </fieldset><br>
                <button type="submit">Confirmar agendamento</button>
            </form>
        </c:otherwise>
    </c:choose>
    <h2>Meus agendamentos</h2>
    <c:choose>
        <c:when test="${empty agendamentos}"><p>Nenhum agendamento encontrado.</p></c:when>
        <c:otherwise>
            <table border="1" cellpadding="6">
                <thead><tr><th>Veículo</th><th>Data</th><th>Horário</th><th>Serviços (total)</th><th>Agendamento</th><th>Pagamento</th><th>Ação</th></tr></thead>
                <tbody>
                    <c:forEach var="agendamento" items="${agendamentos}">
                        <tr>
                            <td><c:out value="${agendamento.placa}"/> — <c:out value="${agendamento.veiculo}"/></td>
                            <td><c:out value="${agendamento.data}"/></td>
                            <td><c:out value="${agendamento.horario}"/></td>
                            <td>R$ <c:out value="${agendamento.total}"/></td>
                            <td><c:out value="${agendamento.status}"/></td>
                            <td><c:out value="${agendamento.statusPagamento}"/>
                                <c:if test="${not empty agendamento.formaPagamento}"> — <c:out value="${agendamento.formaPagamento}"/></c:if>
                            </td>
                            <td>
                                <c:if test="${agendamento.status == 'AGENDADO'}">
                                    <form method="post" action="${pageContext.request.contextPath}/agendamentos">
                                        <input type="hidden" name="acao" value="cancelar">
                                        <input type="hidden" name="idAgendamento" value="${agendamento.id}">
                                        <button type="submit">Cancelar</button>
                                    </form>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:otherwise>
    </c:choose>
</body>
</html>
