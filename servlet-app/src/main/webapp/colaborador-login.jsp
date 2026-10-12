<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Acesso da equipe</title>
</head>
<body>
    <h1>Acesso da equipe</h1>
    <c:if test="${param.setup == 'sucesso'}"><p>Administrador criado. Faça login.</p></c:if>
    <c:if test="${not empty erro}"><p role="alert"><c:out value="${erro}"/></p></c:if>
    <form method="post" action="${pageContext.request.contextPath}/colaborador/login">
        <label>E-mail: <input type="email" name="email" required></label><br><br>
        <label>Senha: <input type="password" name="senha" required></label><br><br>
        <button type="submit">Entrar</button>
    </form>
    <p><a href="${pageContext.request.contextPath}/">Voltar</a></p>
</body>
</html>
