<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Colaboradores — Fast Splash</title>
  <link rel="stylesheet" href="../../Assets/CSS/painel.css">
  <style> .hide { display: none !important; } </style>
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
    <div class="who"><div><p class="small">Bem-vindo(a)</p><h1>Ana Paula</h1></div><span class="role admin">Administrador</span></div>

    <nav class="ptabs" aria-label="Áreas do painel">
      <a href="painel.jsp">Início</a>
      <a href="painel-clientes.jsp">Clientes</a>
      <a href="painel-carros.jsp">Carros</a>
      <a href="painel-agendamentos.jsp">Agendamentos</a>
      <a href="painel-atendimentos.jsp">Atendimentos</a>
      <a href="painel-pagamentos.jsp">Pagamentos</a>
      <a href="painel-colaboradores.jsp" class="on" aria-current="page">Colaboradores</a>
      <a href="painel-servicos.jsp">Serviços</a>
    </nav>

    <div id="view-list">
      <div class="phead">
        <div><h2>Equipa</h2><p class="small">Gerencie os funcionários.</p></div>
        <button type="button" class="btn" id="btn-add-collab">Novo colaborador</button>
      </div>
      <div id="collab-table-container"></div>
    </div>

    <div id="view-form" class="hide">
      <div class="fcard">
        <h2 id="form-title">Novo colaborador</h2>
        <form id="form-collab">
          <input type="hidden" id="collab-id">
          <div class="field"><label for="collab-name">Nome completo</label><input type="text" id="collab-name" required></div>
          <div class="fgrid">
            <div class="field"><label for="collab-email">E-mail</label><input type="email" id="collab-email" required></div>
            <div class="field"><label for="collab-role">Nível de Acesso</label>
              <select id="collab-role" required><option value="atendente">Atendente</option><option value="admin">Administrador</option></select>
            </div>
          </div>
          <div class="facts"><button class="btn" type="submit">Salvar Colaborador</button><button class="btn ghost" type="button" id="btn-cancel-collab">Cancelar</button></div>
        </form>
      </div>
    </div>
  </div>
</main>
<script src="../../Assets/Js/painel.js"></script>
</body>
</html>