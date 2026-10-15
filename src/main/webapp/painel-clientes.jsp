<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Painel - Clientes — Fast Splash</title>
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
      <a href="painel-clientes.jsp" class="active">Cliente</a>
      <a href="painel-novo-agendamento.jsp">Novo Agendamento</a>
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
      <!-- Coluna Esquerda: Lista de Clientes -->
      <div class="card-panel">
        <h2>Cliente (2)</h2>
        
        <div class="client-item">
          <div class="client-info">
            <b>Maria Silva</b>
            <span>Maria@gmail.com</span>
          </div>
          <div class="client-car">
            <b>Picape branca</b>
            <span>JKL7M89</span>
          </div>
          <div class="client-phone">(11) 99999-0001</div>
        </div>

        <div class="client-item">
          <div class="client-info">
            <b>Clara Nunes</b>
            <span>Clara@gmail.com</span>
          </div>
          <div class="client-car">
            <b>Hatch Prata</b>
            <span>MNP4M25</span>
          </div>
          <div class="client-phone">(11) 99999-0002</div>
        </div>
      </div>

      <!-- Coluna Direita: Formulário Cadastrar Cliente -->
      <div class="card-panel">
        <h2>Cadastrar cliente</h2>
        <form action="#" method="post">
          <div class="field">
            <label>Nome completo</label>
            <input type="text" name="nome" required>
          </div>

          <div class="field">
            <label>E-mail</label>
            <input type="email" name="email" required>
          </div>

          <div class="field">
            <label>Telefone</label>
            <input type="tel" name="telefone" required>
          </div>

          <div class="fgrid">
            <div class="field">
              <label>Carro (marca e modelo)</label>
              <input type="text" name="modelo">
            </div>
            <div class="field">
              <label>Cor</label>
              <input type="text" name="cor">
            </div>
          </div>

          <div class="field">
            <label>Placa</label>
            <input type="text" name="placa">
          </div>

          <button class="btn" type="submit" style="width:100%; margin-top:12px;">Criar agendamento</button>
        </form>
      </div>
    </div>
  </div>
</main>

</body>
</html>