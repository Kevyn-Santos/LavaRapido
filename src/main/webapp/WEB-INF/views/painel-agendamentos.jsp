<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Agendamentos — Fast Splash</title>
  <link rel="stylesheet" href="../../Assets/CSS/painel.css">
  <style>
    .hide { display: none !important; }
    .tot { font-size: 1.05rem; margin: 14px 0 8px; color: var(--muted); }
    .tot b { font-size: 1.6rem; color: var(--ink); font-variation-settings: "wdth" 80; }
  </style>
</head>
<body>

<header class="top">
  <div class="top-in">
    <a class="lock" href="${pageContext.request.contextPath}/index.jsp">
      <span class="wm"><span class="f">fast</span> <span class="s">splash</span></span>
    </a>
    <nav class="nav-panel">
      <a href="${pageContext.request.contextPath}/index.jsp" class="btn ghost sm">Sair</a>
    </nav>
  </div>
</header>

<main class="page">
  <div class="wrap">
    <div class="who">
      <div>
        <p class="small">Bem-vindo(a)</p>
        <h1><c:out value="${sessionScope.colaboradorNome}" /></h1>
      </div>
      <span class="role admin">Administrador</span>
    </div>

    <nav class="ptabs" aria-label="Áreas do painel">
      <a href="painel.jsp">Início</a>
      <a href="painel-clientes.jsp">Clientes</a>
      <a href="painel-carros.jsp">Carros</a>
      <a href="painel-agendamentos.jsp" class="on" aria-current="page">Agendamentos</a>
      <a href="painel-atendimentos.jsp">Atendimentos</a>
      <a href="painel-pagamentos.jsp">Pagamentos</a>
      <a href="painel-colaboradores.jsp">Colaboradores</a>
      <a href="painel-servicos.jsp">Serviços</a>
    </nav>

    <!-- 1. TELA DA LISTA DE AGENDAMENTOS -->
    <div id="view-list">
      <div class="phead">
        <div>
          <h2>Agendamentos</h2>
          <p class="small">Crie, edite e gerencie agendamentos dos clientes.</p>
        </div>
        <button type="button" class="btn" id="btn-add-booking">Novo agendamento</button>
      </div>

      <div class="search">
        <input type="search" id="input-search" placeholder="Buscar por cliente, carro ou data...">
      </div>

      <div id="bookings-table-container"></div>
    </div>

    <!-- 2. TELA DO FORMULÁRIO -->
    <div id="view-form" class="hide">
      <div class="fcard">
        <h2 id="form-title">Novo agendamento</h2>
        <form id="form-booking">
          <input type="hidden" id="bk-id">

          <div class="field">
            <label for="bk-client">Cliente</label>
            <select id="bk-client" required></select>
          </div>

          <div class="field">
            <label for="bk-car">Veículo</label>
            <select id="bk-car" required><option value="">Selecione o cliente primeiro</option></select>
          </div>

          <div class="field">
            <label>Serviços Escolhidos</label>
            <div id="services-checkboxes"></div>
          </div>

          <div class="fgrid">
            <div class="field">
              <label for="bk-date">Data</label>
              <input type="date" id="bk-date" required>
            </div>
            <div class="field">
              <label for="bk-slot">Horário</label>
              <select id="bk-slot" required>
                <option value="08:00">08:00</option>
                <option value="09:00">09:00</option>
                <option value="10:00">10:00</option>
                <option value="11:00">11:00</option>
                <option value="13:00">13:00</option>
                <option value="14:00">14:00</option>
                <option value="15:00">15:00</option>
                <option value="16:00">16:00</option>
                <option value="17:00">17:00</option>
              </select>
            </div>
          </div>

          <p class="tot">Total do Agendamento: <b id="bk-total">R$ 0,00</b></p>
          <p class="err" id="form-error" role="alert" style="color: #B3261E; font-size: 0.9rem; margin-top: 8px;"></p>

          <div class="facts">
            <button class="btn" type="submit">Salvar Agendamento</button>
            <button class="btn ghost" type="button" id="btn-cancel-booking">Cancelar</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</main>

<script src="../../Assets/Js/painel.js"></script>
</body>
</html>