<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Login</title>
</head>
<body>
    <h1>Página de Login</h1>
    <% if (request.getParameter("cadastro") != null) { %>
        <p>Cadastro realizado. Entre com seus dados.</p>
    <% } %>
    <% if (request.getAttribute("erro") != null) { %>
        <p role="alert"><%= request.getAttribute("erro") %></p>
    <% } %>
    <form method="post" action="${pageContext.request.contextPath}/login">
        <label>Email: <input type="email" name="email" required></label><br><br>
        <label>Senha: <input type="password" name="senha" required></label><br><br>
        <button type="submit">Entrar</button>
    </form>
    <p><a href="${pageContext.request.contextPath}/cadastro">Criar conta de cliente</a></p>
    <p><a href="${pageContext.request.contextPath}/colaborador/login">Acesso da equipe</a></p>
</body>
</html>
