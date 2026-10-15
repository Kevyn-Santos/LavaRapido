<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Área do cliente</title>
</head>
<body>
    <h1>Olá, <c:out value="${sessionScope.clienteNome}"/></h1>
    <p><a href="${pageContext.request.contextPath}/veiculos">Meus veículos</a></p>
    <p><a href="${pageContext.request.contextPath}/agendamentos">Meus agendamentos</a></p>
    <form method="post" action="${pageContext.request.contextPath}/sair">
        <button type="submit">Sair</button>
    </form>
</body>
</html>
