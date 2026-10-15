<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Cadastro de clientes</title>
</head>
<body>
    <h1>Cadastro de clientes</h1>
    <c:if test="${not empty erro}"><p role="alert"><c:out value="${erro}"/></p></c:if>
    <form method="post" action="${pageContext.request.contextPath}/cadastro">
        <label>Nome: <input type="text" name="nome" maxlength="100" required></label><br><br>
        <label>CPF: <input type="text" name="cpf" inputmode="numeric" maxlength="14" required></label><br><br>
        <label>Telefone: <input type="tel" name="telefone" maxlength="20" required></label><br><br>
        <label>E-mail: <input type="email" name="email" maxlength="150" required></label><br><br>
        <label>Senha (mínimo 8 caracteres): <input type="password" name="senha" minlength="8" required></label><br><br>
        <button type="submit">Cadastrar</button>
    </form>
    <p><a href="${pageContext.request.contextPath}/login">Já tenho cadastro</a></p>
</body>
</html>
