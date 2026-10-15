<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Servlet App</title>
</head>
<body>
    <h1>Lava Rápido</h1>
    <p>Agende serviços para o seu veículo e acompanhe o atendimento.</p>
    <p><a href="${pageContext.request.contextPath}/login">Entrar como cliente</a></p>
    <p><a href="${pageContext.request.contextPath}/cadastro">Criar conta de cliente</a></p>
    <p><a href="${pageContext.request.contextPath}/colaborador/login">Acesso da equipe</a></p>
    <p><a href="${pageContext.request.contextPath}/setup/admin">Configuração inicial (primeiro administrador)</a></p>
</body>
</html>
