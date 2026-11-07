<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Painel — Fast Splash</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/Assets/CSS/painel.css">
</head>
<body class="panel-page panel-home">

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
    <section class="dashboard-welcome" aria-labelledby="dashboard-title">
      <div class="dashboard-welcome-top">
        <div class="dashboard-profile">
          <span class="dashboard-avatar" id="collaborator-initials" aria-hidden="true"></span>
          <div>
            <h1 id="dashboard-title">
              <span id="dashboard-greeting">Olá</span>,
              <span id="collaborator-name"><c:out value="${sessionScope.colaboradorNome}" /></span>
            </h1>
            <p id="dashboard-date"></p>
          </div>
        </div>
        <span class="dashboard-role role
          ${sessionScope.nivelAcesso == 'ADMINISTRADOR' ? 'admin' : sessionScope.nivelAcesso == 'ATENDENTE' ? 'atendente' : 'operacional'}">
          <c:choose>
            <c:when test="${sessionScope.nivelAcesso == 'ADMINISTRADOR'}">Administrador</c:when>
            <c:when test="${sessionScope.nivelAcesso == 'ATENDENTE'}">Atendente</c:when>
            <c:otherwise>Operacional</c:otherwise>
          </c:choose>
        </span>
      </div>
      <div class="dashboard-actions">
        <a class="btn" href="painel-agendamentos.jsp">Novo agendamento</a>
        <a class="btn btn-light" href="painel-atendimentos.jsp">Iniciar atendimento</a>
      </div>
    </section>

    <div class="phead">
      <div>
        <h2>Módulos</h2>
        <p class="small">Escolha uma área para trabalhar. O ponto laranja marca o que é exclusivo do administrador.</p>
      </div>
    </div>

    <div class="pgrid">
      <a class="pcard" href="${pageContext.request.contextPath}/painel/clientes">
        <svg class="pi" viewBox="0 0 24 24"><circle cx="9" cy="8" r="3.2"/><path d="M3 20c0-3.5 3-5.5 6-5.5s6 2 6 5.5"/><circle cx="17" cy="9" r="2.5"/><path d="M17 14.5c2.5 0 4.5 1.5 4.5 4"/></svg>
        <b class="pt">Clientes</b>
        <span class="pc">Cadastre, edite e remova os clientes do lava-rápido.</span>
      </a>

      <a class="pcard" href="${pageContext.request.contextPath}/painel/carros">
        <svg class="pi" viewBox="0 0 24 24"><path d="M3 16v-3.5L5.5 7h9l4 4.5H21V16"/><circle cx="8" cy="17" r="2"/><circle cx="17" cy="17" r="2"/></svg>
        <b class="pt">Carros</b>
        <span class="pc">Adicione e edite os carros de cada cliente.</span>
      </a>

      <a class="pcard" href="${pageContext.request.contextPath}/painel/agendamentos">
        <svg class="pi" viewBox="0 0 24 24"><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18M8 3v4M16 3v4"/></svg>
        <b class="pt">Agendamentos</b>
        <span class="pc">Agende pelo cliente e cancele agendamentos. Veja serviço, data, horário e preço.</span>
      </a>

      <a class="pcard" href="${pageContext.request.contextPath}/painel/atendimentos">
        <svg class="pi" viewBox="0 0 24 24"><path d="M12 3C12 3 5 11 5 15a7 7 0 0 0 14 0C19 11 12 3 12 3z"/></svg>
        <b class="pt">Atendimentos</b>
        <span class="pc">Acompanhe os atendimentos em andamento e inicie o próximo.</span>
      </a>

      <a class="pcard" href="${pageContext.request.contextPath}/painel/pagamentos">
        <svg class="pi" viewBox="0 0 24 24"><rect x="3" y="6" width="18" height="13" rx="2"/><path d="M3 10h18M16 15h2"/></svg>
        <b class="pt">Pagamentos</b>
        <span class="pc">Veja os valores e registre a forma de pagamento de cada atendimento.</span>
      </a>

      <a class="pcard" href="${pageContext.request.contextPath}/painel/colaboradores">
        <i class="pdot" title="Exclusivo do administrador"></i>
        <svg class="pi" viewBox="0 0 24 24"><rect x="5" y="3" width="14" height="18" rx="2"/><circle cx="12" cy="10" r="2.5"/><path d="M8 17c0-2 2-3 4-3s4 1 4 3"/></svg>
        <b class="pt">Colaboradores</b>
        <span class="pc">Gerencie quem trabalha aqui e o nível de acesso de cada pessoa.</span>
      </a>

      <a class="pcard" href="${pageContext.request.contextPath}/painel/servicos">
        <i class="pdot" title="Exclusivo do administrador"></i>
        <svg class="pi" viewBox="0 0 24 24"><path d="M3 12V4h8l10 10-8 8z"/><circle cx="8" cy="8" r="1.4"/></svg>
        <b class="pt">Serviços</b>
        <span class="pc">Defina os serviços oferecidos, a duração e os preços.</span>
      </a>
    </div>
  </div>
</main>

<script src="../../Assets/Js/bdPainel.js"></script>

</body>
</html>