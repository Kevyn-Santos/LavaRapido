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
    <title>Consultar Cliente e Veículos</title>
</head>
<body>
    <div>
        <h1>Consultar cliente e veículos</h1>
        <form action="consultarClienteVeiculo" method="post">
            <!-- Campo numérico (e não select) para permitir testar IDs inexistentes -->
            <label for="consultaVeiculoIdUser">ID do usuario:</label>
            <input type="number" id="consultaVeiculoIdUser" name="IdUser" list="usuariosCadastrados" min="1" required>
            <datalist id="usuariosCadastrados">
                <c:forEach var="users" items="${currentUsers}">
                    <option value="${users.id_cliente}">${users.id_cliente} - ${users.nome}</option>
                </c:forEach>
            </datalist>

            <button type="submit">Enviar</button>
        </form>
    </div>

    <c:if test="${not empty usuario}">
        <table border="1">
            <tr>
                <th>ID</th>
                <th>Nome</th>
                <th>CPF</th>
                <th>Telefone</th>
                <th>Email</th>
            </tr>
            <tr>
                <td>${usuario.id_cliente}</td>
                <td>${usuario.nome}</td>
                <td>${usuario.cpf}</td>
                <td>${usuario.telefone}</td>
                <td>${usuario.email}</td>
            </tr>
        </table>

        <h2>Veículos</h2>
        <table border="1">
            <tr>
                <th>Placa</th>
                <th>Marca</th>
                <th>Modelo</th>
                <th>Cor</th>
            </tr>
            <c:forEach var="veiculo" items="${usuario.veiculos}">
                <tr>
                    <td>${veiculo.placa}</td>
                    <td>${veiculo.marca}</td>
                    <td>${veiculo.modelo}</td>
                    <td>${veiculo.cor}</td>
                </tr>
            </c:forEach>
        </table>
    </c:if>

    <div>
        <c:if test="${not empty erro}"><p style="color:red">${erro}</p></c:if>
    </div>

    <a href="${pageContext.request.contextPath}/index.jsp">Voltar</a>
</body>
</html>
