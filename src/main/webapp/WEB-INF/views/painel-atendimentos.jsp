<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Atendimentos — Fast Splash</title>
  <link rel="stylesheet" href="../../Assets/CSS/painel.css">
</head>
<body>

<header class="top">
  <div class="top-in">
    <a class="lock" href="../../index.jsp"><span class="wm"><span class="f">fast</span> <span class="s">splash</span></span></a>
    <nav class="nav-panel"><a href="../../index.jsp" class="btn ghost sm">Sair</a></nav>
  </div>
</header>

<main class="page">
  <div class="wrap">
    <div class="who">
      <div><p class="small">Bem-vindo(a)</p><h1>Ana Paula</h1></div>
      <span class="role admin">Administrador</span>
    </div>

    <nav class="ptabs" aria-label="Áreas do painel">
      <a href="painel.jsp">Início</a>
      <a href="painel-clientes.jsp">Clientes</a>
      <a href="painel-carros.jsp">Carros</a>
      <a href="painel-agendamentos.jsp">Agendamentos</a>
      <a href="painel-atendimentos.jsp" class="on" aria-current="page">Atendimentos</a>
      <a href="painel-pagamentos.jsp">Pagamentos</a>
      <a href="painel-colaboradores.jsp">Colaboradores</a>
      <a href="painel-servicos.jsp">Serviços</a>
    </nav>

    <div class="phead">
      <div><h2>Atendimentos</h2><p class="small">Acompanhe quem está sendo atendido e inicie o próximo.</p></div>
    </div>

    <div id="queues-container"></div>
  </div>
</main>

<script src="../../Assets/Js/painel.js?v=2"></script>
</body>
</html>