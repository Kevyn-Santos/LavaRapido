<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Painel - Novo Agendamento — Fast Splash</title>
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
      <a href="painel-novo-agendamento.jsp" class="active">Novo Agendamento</a>
      <a href="painel-agendamentos.jsp">Agendamentos</a>
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

    <div class="two-col">
      <!-- Formularil: Agendar em nome do cliente -->
      <div class="card-panel">
        <h2>Agendar em nome do cliente</h2>
        <form id="booking-form">
          <div class="field">
            <label for="booking-client">Cliente</label>
            <select id="booking-client" name="cliente" required>
              <option value="">Escolha um cliente</option>
              <option value="1" data-name="Maria Silva" data-car="Picape branca, JKL7M89">Maria Silva - JKL7M89</option>
              <option value="2" data-name="Clara Nunes" data-car="Hatch prata, MNP4M25">Clara Nunes - MNP4M25</option>
            </select>
            <a href="painel-clientes.jsp" class="small" style="color:#9FBACB; margin-top:4px; display:inline-block;">Cliente novo? Cadastre primeiro</a>
          </div>

          <div class="field" style="margin-top:16px;">
            <label>Serviços</label>
            <div class="svc-checkboxes">
              <label>
                <div><input type="checkbox" name="svc" value="simples" data-label="Lavagem simples" data-price="40"> Lavagem simples</div>
                <span class="price">R$ 40,00</span>
              </label>
              <label>
                <div><input type="checkbox" name="svc" value="completa" data-label="Lavagem completa" data-price="70"> Lavagem completa</div>
                <span class="price">R$ 70,00</span>
              </label>
              <label>
                <div><input type="checkbox" name="svc" value="enceramento" data-label="Enceramento" data-price="90"> Enceramento</div>
                <span class="price">R$ 90,00</span>
              </label>
              <label>
                <div><input type="checkbox" name="svc" value="detalhamento" data-label="Detalhamento interno" data-price="150"> Detalhamento interno</div>
                <span class="price">R$ 150,00</span>
              </label>
            </div>
          </div>

          <div class="fgrid">
            <div class="field">
              <label for="booking-date">Dia</label>
              <input id="booking-date" type="date" name="dia" required>
            </div>
            <div class="field">
              <label for="booking-time">Horário</label>
              <select id="booking-time" name="horario" required>
                <option value="">Escolha o dia</option>
                <option value="09:00">09:00</option>
                <option value="10:00">10:00</option>
                <option value="13:00">13:00</option>
              </select>
            </div>
          </div>
        </form>
      </div>

      <!-- Resumo e Confirmação -->
      <div class="card-panel" aria-live="polite">
        <div class="summary-title" id="summary-client">Nome do cliente</div>
        <div class="summary-title" style="font-size:1.1rem; font-weight:700; margin-bottom:4px;">Serviços</div>
        <div class="summary-services" id="summary-services">Selecione um ou mais serviços</div>
        <div class="summary-price" id="summary-price">Total - R$ 0,00</div>

        <div class="summary-grid">
          <div>
            <b>Dia</b>
            <span id="summary-date">Escolha o dia</span>
          </div>
          <div>
            <b>Horário</b>
            <span id="summary-time">Escolha o horário</span>
          </div>
        </div>

        <p class="booking-feedback" id="booking-feedback" role="status"></p>
        <button class="btn" id="create-booking" type="button" style="width:100%;">Criar agendamento</button>
      </div>
    </div>
  </div>
</main>

<script src="painel-agendamento.js"></script>
</body>
</html>