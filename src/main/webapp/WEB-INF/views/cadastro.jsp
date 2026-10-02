<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Infos de cadastros</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/Assets/CSS/style.css">
</head>
<body>
    <div class="container">
        <h1>Cadastro Realizado com sucesso!</h1>

        <table border="1">
                <tr>
                    <th>ID</th>
                    <th>Nome</th>
                    <th>CPF</th>
                    <th>Telefone</th>
                    <th>Email</th>
                </tr>
                <!-- Iterate over the list passed from the servlet -->
                <c:forEach var="users" items="${queryUsers}">
                    <tr>
                        <td>${users.id_cliente}</td>
                        <td>${users.name}</td>
                        <td>${users.cpf}</td>
                        <td>${users.telefone}</td>
                        <td>${users.email}</td>
                    </tr>
                </c:forEach>
            </table>

        <a href="${pageContext.request.contextPath}/index.jsp">Voltar</a>
    </div>
</body>
</html>