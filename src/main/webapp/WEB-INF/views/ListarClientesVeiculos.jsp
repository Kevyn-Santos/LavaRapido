<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/Assets/CSS/style.css">
    <title>Clientes e Veículos</title>
</head>
<body>
    <div>
        <h1>Clientes e veículos</h1>

        <table border="1">
            <tr>
                <th>ID</th>
                <th>Nome</th>
                <th>CPF</th>
                <th>Telefone</th>
                <th>Email</th>
                <th>Placa</th>
                <th>Marca</th>
                <th>Modelo</th>
                <th>Cor</th>
            </tr>
            <!-- Cada linha do JOIN vira um Cliente com um veículo, então um cliente pode aparecer mais de uma vez -->
            <c:forEach var="users" items="${clientesVeiculos}">
                <c:forEach var="veiculo" items="${users.veiculos}">
                    <tr>
                        <td>${users.id_cliente}</td>
                        <td>${users.nome}</td>
                        <td>${users.cpf}</td>
                        <td>${users.telefone}</td>
                        <td>${users.email}</td>
                        <td>${veiculo.placa}</td>
                        <td>${veiculo.marca}</td>
                        <td>${veiculo.modelo}</td>
                        <td>${veiculo.cor}</td>
                    </tr>
                </c:forEach>
            </c:forEach>
        </table>
    </div>

    <div>
        <c:if test="${not empty erro}"><p style="color:red">${erro}</p></c:if>
    </div>

    <a href="${pageContext.request.contextPath}/index.jsp">Voltar</a>
</body>
</html>
