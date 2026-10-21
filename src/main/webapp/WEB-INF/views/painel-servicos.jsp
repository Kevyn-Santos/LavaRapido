<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Serviços — Fast Splash</title>
  <link rel="stylesheet" href="../../Assets/CSS/painel.css">
  <style> .hide { display: none !important; } </style>
</head>
<body>

<header class="top">
  <div class="top-in">
    <a class="lock" href="${pageContext.request.contextPath}/index.jsp"><span class="wm"><span class="f">fast</span> <span class="s">splash</span></span></a>
    <nav class="nav-panel"><a href="${pageContext.request.contextPath}/index.jsp" class="btn ghost sm">Sair</a></nav>
  </div>
</header>

<main class="page">
  <div class="wrap">
    <div class="who"><div><p class="small">Bem-vindo(a)</p><h1>Ana Paula</h1></div><span class="role admin">Administrador</span></div>

    <nav class="ptabs" aria-label="Áreas do painel">
      <a href="painel.jsp">Início</a>
      <a href="painel-clientes.jsp">Clientes</a>
      <a href="painel-carros.jsp">Carros</a>
      <a href="painel-agendamentos.jsp">Agendamentos</a>
      <a href="painel-atendimentos.jsp">Atendimentos</a>
      <a href="painel-pagamentos.jsp">Pagamentos</a>
      <a href="painel-colaboradores.jsp">Colaboradores</a>
      <a href="painel-servicos.jsp" class="on" aria-current="page">Serviços</a>
    </nav>

    <div id="view-list">
      <div class="phead">
        <div><h2>Serviços e Preços</h2><p class="small">Edite os preços e tipos de lavagem.</p></div>
        <button type="button" class="btn" id="btn-add-service">Novo serviço</button>
      </div>
      <div id="services-table-container"></div>
    </div>

    <div id="view-form" class="hide">
      <div class="fcard">
        <h2 id="form-title">Novo serviço</h2>
        <form id="form-service">
          <input type="hidden" id="svc-id">
          <div class="field"><label for="svc-name">Nome do serviço</label><input type="text" id="svc-name" required></div>
          <div class="field"><label for="svc-desc">Descrição / Detalhes</label><input type="text" id="svc-desc" required></div>
          <div class="fgrid">
            <div class="field"><label for="svc-min">Duração Média (min)</label><input type="number" id="svc-min" required min="5" step="5"></div>
            <div class="field"><label for="svc-price">Preço R$</label><input type="number" id="svc-price" required min="0" step="0.01"></div>
          </div>
          <div class="facts"><button class="btn" type="submit">Salvar Serviço</button><button class="btn ghost" type="button" id="btn-cancel-service">Cancelar</button></div>
        </form>
      </div>
    </div>
  </div>
</main>
<script src="../../Assets/Js/painel.js"></script>
</body>
</html>