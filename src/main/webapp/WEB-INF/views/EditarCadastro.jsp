<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><!DOCTYPE html>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/Assets/CSS/style.css">
    <title>Editar Cadastro</title>
</head>
<body>
    <div>
        <h1>Editar cadastro</h1>
        <form action="editarCadastro" method="post">
            <label for="editIdUser">Usuario:</label>
            <select id="editIdUser" name="IdUser" required>
                <option value="" disabled selected>Selecione um usuario</option>
                <c:forEach var="users" items="${currentUsers}">
                    <option value="${users.id_cliente}">${users.id_cliente} - ${users.nome}</option>
                </c:forEach>
            </select>

            <label for="editNome">Nome (opcional):</label>
            <input type="text" id="editNome" name="nome">

            <label for="editEmail">Email (opcional):</label>
            <input type="email" id="editEmail" name="email">

            <label for="editTelefone">Telefone (opcional):</label>
            <input type="text" id="editTelefone" name="telefone" placeholder="(00) 00000-0000" maxlength="15">

            <button type="submit">Enviar</button>
        </form>
    </div>

    <div>
        <c:if test="${not empty atualização}"><p style="color:white">${atualização}</p></c:if>
    </div>

    <div>
        <c:if test="${not empty erro}"><p style="color:red">${erro}</p></c:if>
    </div>
</body>
</html>