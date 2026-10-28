<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Acesso da equipe — Fast Splash</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wdth,wght@12..96,75..100,200..800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="../../Assets/CSS/style.css">
</head>
<body>

<header class="top staff-login-header">
  <div class="top-in">
    <a class="lock" href="${pageContext.request.contextPath}/index.jsp" aria-label="Fast Splash, início">
      <span class="wm"><span class="f">fast</span> <span class="s">splash</span></span>
    </a>
    <nav><a href="${pageContext.request.contextPath}/index.jsp">Voltar ao início</a></nav>
  </div>
</header>

<main class="staff-login">
  <section class="staff-login-copy" aria-labelledby="staff-login-title">
    <p class="staff-login-kicker">Área interna</p>
    <h1 id="staff-login-title">Gestão Fast Splash para a equipe.</h1>
    <p>Este ambiente é exclusivo para colaboradores autorizados do Fast Splash.</p>
  </section>

  <section class="staff-login-panel" aria-labelledby="staff-login-form-title">
    <div class="staff-login-card">
      <h2 id="staff-login-form-title">Entrar no painel</h2>
      <c:if test="${not empty erro}">
        <p class="staff-login-error" role="alert"><c:out value="${erro}" /></p>
      </c:if>
      <form action="${pageContext.request.contextPath}/colaborador/login" method="post">
        <div class="field">
          <label for="staff-email">E-mail</label>
          <input id="staff-email" name="email" type="email" autocomplete="username" required>
        </div>
        <div class="field">
          <label for="staff-password">Senha</label>
          <input id="staff-password" name="senha" type="password" autocomplete="current-password" required>
        </div>
        <button class="btn" type="submit">Entrar no painel</button>
      </form>
    </div>
    <a class="staff-login-back" href="../../index.html">← Voltar ao site</a>
  </section>
</main>

</body>
</html>