<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Meu perfil</title>
</head>
<body>
    <h1>Meu perfil</h1>
    <p><a href="${pageContext.request.contextPath}/portal">Voltar ao portal</a></p>
    <c:if test="${param.sucesso == '1'}"><p>Perfil atualizado com sucesso.</p></c:if>
    <c:if test="${not empty erro}"><p role="alert"><c:out value="${erro}"/></p></c:if>

    <h2>Dados pessoais</h2>
    <form method="post" action="${pageContext.request.contextPath}/perfil">
        <input type="hidden" name="acao" value="atualizar">
        <label>Nome: <input name="nome" maxlength="100" value="<c:out value='${cliente.nome}'/>" required></label><br><br>
        <label>Telefone: <input name="telefone" maxlength="20" value="<c:out value='${cliente.telefone}'/>" required></label><br><br>
        <label>E-mail: <input type="email" name="email" maxlength="150" value="<c:out value='${cliente.email}'/>" required></label><br><br>
        <label>Senha atual: <input type="password" name="senhaAtual" required></label><br><br>
        <label>Nova senha (opcional): <input type="password" name="novaSenha" minlength="8"></label><br><br>
        <button type="submit">Salvar alterações</button>
    </form>

    <h2>Excluir conta</h2>
    <form method="post" action="${pageContext.request.contextPath}/perfil">
        <input type="hidden" name="acao" value="excluir">
        <label>Confirme sua senha: <input type="password" name="senhaExcluir" required></label><br><br>
        <button type="submit">Excluir minha conta</button>
    </form>
</body>
</html>
