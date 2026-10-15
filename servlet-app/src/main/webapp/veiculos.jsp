<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Meus veículos</title>
</head>
<body>
    <h1>Meus veículos</h1>
    <p><a href="${pageContext.request.contextPath}/portal">Voltar à área do cliente</a></p>
    <c:if test="${not empty erro}"><p role="alert"><c:out value="${erro}"/></p></c:if>
    <h2>Adicionar veículo</h2>
    <form method="post" action="${pageContext.request.contextPath}/veiculos">
        <input type="hidden" name="acao" value="adicionar">
        <label>Placa: <input name="placa" maxlength="10" required></label><br><br>
        <label>Marca: <input name="marca" maxlength="60" required></label><br><br>
        <label>Modelo: <input name="modelo" maxlength="60" required></label><br><br>
        <label>Cor: <input name="cor" maxlength="30"></label><br><br>
        <button type="submit">Salvar veículo</button>
    </form>
    <h2>Veículos cadastrados</h2>
    <c:choose>
        <c:when test="${empty veiculos}"><p>Nenhum veículo cadastrado.</p></c:when>
        <c:otherwise>
            <table border="1" cellpadding="6">
                <thead><tr><th>Placa</th><th>Marca</th><th>Modelo</th><th>Cor</th><th>Ação</th></tr></thead>
                <tbody>
                    <c:forEach var="veiculo" items="${veiculos}">
                        <tr>
                            <td>
                                <form method="post" action="${pageContext.request.contextPath}/veiculos">
                                    <input type="hidden" name="acao" value="atualizar">
                                    <input type="hidden" name="idVeiculo" value="${veiculo.id}">
                                    <input name="placa" maxlength="10" value="<c:out value='${veiculo.placa}'/>" required>
                            </td>
                            <td>
                                    <input name="marca" maxlength="60" value="<c:out value='${veiculo.marca}'/>" required>
                            </td>
                            <td>
                                    <input name="modelo" maxlength="60" value="<c:out value='${veiculo.modelo}'/>" required>
                            </td>
                            <td>
                                    <input name="cor" maxlength="30" value="<c:out value='${veiculo.cor}'/>">
                            </td>
                            <td>
                                    <button type="submit">Salvar</button>
                                </form>
                                <form method="post" action="${pageContext.request.contextPath}/veiculos">
                                    <input type="hidden" name="acao" value="remover">
                                    <input type="hidden" name="idVeiculo" value="${veiculo.id}">
                                    <button type="submit">Remover</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:otherwise>
    </c:choose>
</body>
</html>
