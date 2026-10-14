<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Cadastro de Clientes</title>
</head>
<body>
    <h1>Cadastro de Clientes</h1>
    <% if (request.getAttribute("erro") != null) { %>
        <p role="alert"><%= request.getAttribute("erro") %></p>
    <% } %>
    <form method="post" action="${pageContext.request.contextPath}/cadastro">
        <label>Nome: <input type="text" name="nome" required></label><br><br>
        <label>CPF: <input type="text" name="cpf" inputmode="numeric" maxlength="14" required></label><br><br>
        <label>Telefone: <input type="text" name="telefone" required></label><br><br>
        <label>Email: <input type="email" name="email" required></label><br><br>
        <label>Senha: <input type="password" name="senha" minlength="8" required></label><br><br>
        <button type="submit">Cadastrar</button>
    </form>
    <p><a href="${pageContext.request.contextPath}/login">Já tenho cadastro</a></p>
</body>
</html>
