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
    <title>Deletar Cadastro</title>
</head>
<body>
    <div>
        <h1>Deletar cadastro</h1>
        <form action="deletarCadastro" method="post">
            <label for="deleteIdUser">Usuario:</label>
            <select id="deleteIdUser" name="IdUser" required>
                <option value="" disabled selected>Selecione um usuario</option>
                <c:forEach var="users" items="${currentUsers}">
                    <option value="${users.id_cliente}">${users.id_cliente} - ${users.nome}</option>
                </c:forEach>
            </select>

            <div>
                <input type="checkbox" id="CheckAll" name="CheckAll" value="true">
                <label for="CheckAll">Deseja excluir os agendamentos e veículos do usuario?</label>
            </div>

            <button type="submit">Enviar</button>
        </form>
    </div>

    <div>
        <c:if test="${not empty sucesso}"><p style="color:white">${sucesso}</p></c:if>
    </div>

    <div>
        <c:if test="${not empty erro}"><p style="color:red">${erro}</p></c:if>
    </div>

    <a href="${pageContext.request.contextPath}/index.jsp">Voltar</a>
</body>
</html>
