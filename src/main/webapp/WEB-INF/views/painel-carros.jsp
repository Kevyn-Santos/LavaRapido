<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Carros — Fast Splash</title>
  <link rel="stylesheet" href="../../Assets/CSS/painel.css">
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
    <div class="who">
      <div><p class="small">Bem-vindo(a)</p><h1><c:out value="${sessionScope.colaboradorNome}" /></h1></div>
      <span class="role admin">Administrador</span>
    </div>

    <nav class="ptabs" aria-label="Áreas do painel">
      <a href="painel.jsp">Início</a>
      <a href="painel-clientes.jsp">Clientes</a>
      <a href="painel-carros.jsp" class="on" aria-current="page">Carros</a>
      <a href="painel-agendamentos.jsp">Agendamentos</a>
      <a href="painel-atendimentos.jsp">Atendimentos</a>
      <a href="painel-pagamentos.jsp">Pagamentos</a>
      <a href="painel-colaboradores.jsp">Colaboradores</a>
      <a href="painel-servicos.jsp">Serviços</a>
    </nav>

    <!-- 1. TELA DA LISTA DE CARROS -->
    <div id="view-list">
      <div class="phead">
        <div><h2>Carros dos clientes</h2><p class="small">Adicione e edite os carros de cada cliente.</p></div>
        <button type="button" class="btn" id="btn-add-car">Novo carro</button>
      </div>

      <div class="search">
        <input type="search" id="input-search" placeholder="Buscar por modelo, placa ou cliente...">
      </div>

      <div id="cars-table-container"></div>
    </div>

    <!-- 2. TELA DO FORMULÁRIO -->
    <div id="view-form" class="hide">
      <div class="fcard">
        <h2 id="form-title">Novo carro</h2>
        <form id="form-car">
          <input type="hidden" id="car-id">

          <div class="field">
            <label for="car-client">Cliente proprietário</label>
            <select id="car-client" required></select>
          </div>

          <div class="fgrid">
            <div class="field">
              <label for="car-model">Marca / Modelo</label>
              <input type="text" id="car-model" required placeholder="Ex: Onix Prata">
            </div>
            <div class="field">
              <label for="car-color">Cor</label>
              <input type="text" id="car-color" required placeholder="Ex: Prata">
            </div>
          </div>

          <div class="field">
            <label for="car-plate">Placa</label>
            <input type="text" id="car-plate" required placeholder="ABC1D23" maxlength="7" style="text-transform:uppercase">
          </div>

          <p class="err" id="form-error" role="alert" style="color: #B3261E; font-size: 0.9rem; margin-top: 8px;"></p>

          <div class="facts">
            <button class="btn" type="submit">Salvar carro</button>
            <button class="btn ghost" type="button" id="btn-cancel-car">Cancelar</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</main>

<script src="../../Assets/Js/painel.js"></script>
</body>
</html>