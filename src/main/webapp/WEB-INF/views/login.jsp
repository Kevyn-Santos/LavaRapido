<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Entrar</title>
</head>
<body>
    <h1>Área do cliente</h1>
    <c:if test="${param.cadastro == 'sucesso'}"><p>Cadastro realizado. Faça login.</p></c:if>
    <c:if test="${not empty erro}"><p role="alert"><c:out value="${erro}"/></p></c:if>
    <form method="post" action="${pageContext.request.contextPath}/login">
        <label>E-mail: <input type="email" name="email" value="<c:out value='${param.email}'/>" required></label><br><br>
        <label>Senha: <input type="password" name="senha" required></label><br><br>
        <button type="submit">Entrar</button>
    </form>
    <p><a href="${pageContext.request.contextPath}/cadastro">Criar conta</a></p>
    <p><a href="${pageContext.request.contextPath}/">Voltar</a></p>
</body>
</html>
