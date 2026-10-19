<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Configurar administrador inicial</title>
</head>
<body>
    <h1>Configuração inicial</h1>
    <c:choose>
        <c:when test="${configuracaoIndisponivel}">
            <p role="alert">A configuração inicial ainda não foi habilitada no servidor.</p>
            <p>Defina a variável de ambiente <code>INITIAL_ADMIN_TOKEN</code> com um token forte e reinicie o Tomcat. Depois, use o mesmo token no formulário abaixo.</p>
            <p>O MySQL também precisa estar iniciado e configurado para que a conta possa ser criada.</p>
        </c:when>
        <c:otherwise>
            <p>Crie o primeiro administrador. Esta página ficará indisponível após a criação da conta.</p>
        </c:otherwise>
    </c:choose>
    <c:if test="${not empty erro}"><p role="alert"><c:out value="${erro}"/></p></c:if>
    <c:if test="${not configuracaoIndisponivel}">
        <form method="post" action="${pageContext.request.contextPath}/setup/admin">
            <label>Token inicial: <input type="password" name="token" required></label><br><br>
            <label>Nome: <input name="nome" maxlength="100" required></label><br><br>
            <label>Cargo: <input name="cargo" maxlength="60" required></label><br><br>
            <label>E-mail: <input type="email" name="email" maxlength="150" required></label><br><br>
            <label>Senha (mínimo 8 caracteres): <input type="password" name="senha" minlength="8" required></label><br><br>
            <button type="submit">Criar administrador</button>
        </form>
    </c:if>
</body>
</html>
