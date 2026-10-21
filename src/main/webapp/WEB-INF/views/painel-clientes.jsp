<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Clientes — Fast Splash</title>
  <link rel="stylesheet" href="../../Assets/CSS/painel.css">
</head>
<body>

<header class="top">
  <div class="top-in">
    <a class="lock" href="index.jsp">
      <span class="wm"><span class="f">fast</span> <span class="s">splash</span></span>
    </a>
    <nav class="nav-panel">
      <a href="index.jsp" class="btn ghost sm">Sair</a>
    </nav>
  </div>
</header>

<main class="page">
  <div class="wrap">
    <div class="who">
      <div>
        <p class="small">Bem-vindo(a)</p>
        <h1>Ana Paula</h1>
      </div>
      <span class="role admin">Administrador</span>
    </div>

    <nav class="ptabs" aria-label="Áreas do painel">
      <a href="painel.html">Início</a>
      <a href="painel-clientes.html" class="on" aria-current="page">Clientes</a>
      <a href="painel-carros.html">Carros</a>
      <a href="painel-agendamentos.html">Agendamentos</a>
      <a href="painel-atendimentos.html">Atendimentos</a>
      <a href="painel-pagamentos.html">Pagamentos</a>
      <a href="painel-colaboradores.html">Colaboradores</a>
      <a href="painel-servicos.html">Serviços</a>
    </nav>

    <!-- 1. TELA DA LISTA DE CLIENTES -->
    <div id="view-list">
      <div class="phead">
        <div>
          <h2>Clientes</h2>
          <p class="small">Cadastre, edite ou remova clientes do sistema.</p>
        </div>
        <button type="button" class="btn" id="btn-add-client">Novo cliente</button>
      </div>

      <div class="search">
        <input type="search" id="input-search" placeholder="Buscar por nome, e-mail ou CPF...">
      </div>

      <div id="clients-table-container"></div>
    </div>

    <!-- 2. TELA DO FORMULÁRIO -->
    <div id="view-form" class="hide">
      <div class="fcard">
        <h2 id="form-title">Novo cliente</h2>
        <form id="form-client">
          <input type="hidden" id="client-id">

          <div class="field">
            <label for="client-name">Nome completo</label>
            <input type="text" id="client-name" required placeholder="Ex: Marina Alves">
          </div>

          <div class="fgrid">
            <div class="field">
              <label for="client-cpf">CPF</label>
              <input type="text" id="client-cpf" required placeholder="000.000.000-00" maxlength="14">
            </div>
            <div class="field">
              <label for="client-phone">Telefone</label>
              <input type="tel" id="client-phone" required placeholder="(11) 99999-0000">
            </div>
          </div>

          <div class="field">
            <label for="client-email">E-mail</label>
            <input type="email" id="client-email" required placeholder="cliente@exemplo.com">
          </div>

          <p class="err" id="form-error" role="alert"></p>

          <div class="facts">
            <button class="btn" type="submit">Salvar cliente</button>
            <button class="btn ghost" type="button" id="btn-cancel-client">Cancelar</button>
          </div>
        </form>
      </div>
    </div>

  </div>
</main>

<script src="../../Assets/Js/painel.js"></script>
</body>
</html>