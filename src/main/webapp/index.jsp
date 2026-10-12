<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Formulário de cadastro</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/Assets/CSS/style.css">
</head>
<body>
    <div>
        <h1>Cadastro</h1>
        <form action="cadastro" method="post">
            <label for="nome">Nome:</label>
            <input type="text" id="nome" name="nome">

            <label for="cpf">CPF:</label>
            <input type="text" id="cpf" name="cpf" placeholder="000.000.000-00" maxlength="11">

            <label for="telefone">Telefone:</label>
            <input type="text" id="telefone" name="telefone" placeholder="(00) 00000-0000" maxlength="11">

            <label for="email">Email:</label>
            <input type="email" id="email" name="email">

            <label for="senha">Senha:</label>
            <input type="password" id="senha" name="senha" maxlength="10">

            <button type="submit">Enviar</button>
        </form>
    </div>
    <div>
        <c:if test="${not empty erro}"><p style="color:red">${erro}</p></c:if>
    </div>
        <div>
            <a href="${pageContext.request.contextPath}/listarExclusão" hidden>Exclusão de cadastro</a>
        </div>

        <div>
            <a href="${pageContext.request.contextPath}/listarCadastros">Edição de cadastro</a>
        </div>



</body>
</html>