<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Atendimentos — Fast Splash</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/Assets/CSS/painel.css">
</head>
<body class="panel-page">

<header class="top panel-page-header">
  <div class="top-in">
    <a class="lock" href="${pageContext.request.contextPath}/" aria-label="Fast Splash, início">
      <span class="wm"><span class="f">fast</span> <span class="s">splash</span></span>
    </a>
    <nav><a href="${pageContext.request.contextPath}/">Voltar ao início</a></nav>
  </div>
</header>

<main class="page">
  <div class="wrap">
    <div class="who">
      <div><p class="small">Bem-vindo(a)</p><h1><c:out value="${sessionScope.colaboradorNome}" /></h1></div>
      <span class="role admin">Administrador</span>
    </div>

    <nav class="ptabs" aria-label="Áreas do painel">
      <a href="${pageContext.request.contextPath}/admin/inicio">Início</a>
      <a href="${pageContext.request.contextPath}/painel/clientes">Clientes</a>
      <a href="${pageContext.request.contextPath}/painel/carros">Carros</a>
      <a href="${pageContext.request.contextPath}/painel/agendamentos">Agendamentos</a>
      <a href="${pageContext.request.contextPath}/painel/atendimentos" class="on" aria-current="page">Atendimentos</a>
      <a href="${pageContext.request.contextPath}/painel/pagamentos">Pagamentos</a>
      <a href="${pageContext.request.contextPath}/painel/colaboradores">Colaboradores</a>
      <a href="${pageContext.request.contextPath}/painel/servicos">Serviços</a>
    </nav>

    <div class="phead">
      <div><h2>Atendimentos</h2><p class="small">Acompanhe quem está sendo atendido e inicie o próximo.</p></div>
    </div>

    <div id="queues-container"></div>
  </div>
</main>

<script src="${pageContext.request.contextPath}/Assets/Js/painel.js?v=2"></script>
</body>
</html>