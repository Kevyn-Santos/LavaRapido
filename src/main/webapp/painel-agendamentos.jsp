<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Painel - Agendamentos — Fast Splash</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wdth,wght@12..96,75..100,200..800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="style.css">
  <link rel="stylesheet" href="painel.css">
</head>
<body>

<header class="top">
  <div class="top-in">
    <a class="lock" href="index.jsp">
      <span class="wm"><span class="f">fast</span> <span class="s">splash</span></span>
    </a>
    <nav class="nav-panel">
      <a href="painel-clientes.jsp">Cliente</a>
      <a href="painel-novo-agendamento.jsp">Novo Agendamento</a>
      <a href="painel-agendamentos.jsp" class="active">Agendamentos</a>
    </nav>
  </div>
</header>

<main class="page">
  <div class="wrap">
    <div class="panel-header">
      <a href="index.jsp" class="back">&larr; Voltar</a>
      <h1>Painel</h1>
      <div class="sub">Nome (administrativo)</div>
    </div>

    <div class="date-selector">
      <button>&lt;</button>
      <h2>Quinta-Feira, 1 de outubro</h2>
      <button>&gt;</button>
    </div>
    <div class="filter-sub">3 Agendamento (s) ativo (s) hoje - clique numa etapa para filtrar.</div>

    <div class="card-panel">
      <div id="created-bookings" aria-live="polite"></div>
      <!-- Item 1 -->
      <div class="booking-card">
        <svg class="car-icon" viewBox="0 0 60 30">
          <path d="M5 20 L15 10 L35 10 L48 20 L55 20 L55 25 L5 25 Z" stroke="#FF7A1A" stroke-width="2" fill="none"/>
          <circle cx="15" cy="25" r="4" fill="#FF7A1A"/>
          <circle cx="45" cy="25" r="4" fill="#FF7A1A"/>
        </svg>

        <div class="booking-client">
          <b>Maria Silva</b>
          <span>Picape branca, JKL7M89</span>
        </div>

        <div class="booking-service">
          <b>Detalhamento interno</b>
          <span>R$ 150,00, pagamento pendente</span>
        </div>

        <div class="booking-actions">
          <select>
            <option value="agendado" selected>Agendado</option>
            <option value="chegou">Chegou</option>
            <option value="lavando">Em lavagem</option>
            <option value="pronto">Pronto</option>
          </select>
          <button class="btn-cancel">Cancelar</button>
        </div>
      </div>

      <!-- Item 2 -->
      <div class="booking-card">
        <svg class="car-icon" viewBox="0 0 60 30">
          <path d="M8 20 L18 12 L32 12 L42 20 L52 20 L52 25 L8 25 Z" stroke="#FF7A1A" stroke-width="2" fill="none"/>
          <circle cx="18" cy="25" r="4" fill="#FF7A1A"/>
          <circle cx="42" cy="25" r="4" fill="#FF7A1A"/>
        </svg>

        <div class="booking-client">
          <b>Clara Nunes</b>
          <span>Hatch prata, MNP4M25</span>
        </div>

        <div class="booking-service">
          <b>Lavagem simples, Enceramentos</b>
          <span>R$ 130,00, pagamento pendente</span>
        </div>

        <div class="booking-actions">
          <select>
            <option value="agendado" selected>Agendado</option>
            <option value="chegou">Chegou</option>
            <option value="lavando">Em lavagem</option>
            <option value="pronto">Pronto</option>
          </select>
          <button class="btn-cancel">Cancelar</button>
        </div>
      </div>
    </div>
  </div>
</main>

<script src="painel-agendamento.js"></script>
</body>
</html>