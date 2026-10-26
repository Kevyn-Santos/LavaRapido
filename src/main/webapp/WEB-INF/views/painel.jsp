<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Painel — Fast Splash</title>
  <link rel="stylesheet" href="../../Assets/CSS/painel.css">
</head>
<body>

<header class="top">
  <div class="top-in">
    <a class="lock" href="${pageContext.request.contextPath}/index.jsp">
      <img src="${pageContext.request.contextPath}/Assets/Img/logo_fastsplash.png" alt="Fast Splash" class="logo-img">
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

    <div class="phead">
      <div>
        <h2>Módulos</h2>
        <p class="small">Escolha uma área para trabalhar. O ponto laranja marca o que é exclusivo do administrador.</p>
      </div>
    </div>

    <div class="pgrid">
      <a class="pcard" href="painel-clientes.jsp">
        <svg class="pi" viewBox="0 0 24 24"><circle cx="9" cy="8" r="3.2"/><path d="M3 20c0-3.5 3-5.5 6-5.5s6 2 6 5.5"/><circle cx="17" cy="9" r="2.5"/><path d="M17 14.5c2.5 0 4.5 1.5 4.5 4"/></svg>
        <b class="pt">Clientes</b>
        <span class="pc">Cadastre, edite e remova os clientes do lava-rápido.</span>
      </a>

      <a class="pcard" href="painel-carros.jsp">
        <svg class="pi" viewBox="0 0 24 24"><path d="M3 16v-3.5L5.5 7h9l4 4.5H21V16"/><circle cx="8" cy="17" r="2"/><circle cx="17" cy="17" r="2"/></svg>
        <b class="pt">Carros</b>
        <span class="pc">Adicione e edite os carros de cada cliente.</span>
      </a>

      <a class="pcard" href="painel-agendamentos.jsp">
        <svg class="pi" viewBox="0 0 24 24"><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18M8 3v4M16 3v4"/></svg>
        <b class="pt">Agendamentos</b>
        <span class="pc">Agende pelo cliente e cancele agendamentos. Veja serviço, data, horário e preço.</span>
      </a>

      <a class="pcard" href="painel-atendimentos.jsp">
        <svg class="pi" viewBox="0 0 24 24"><path d="M12 3C12 3 5 11 5 15a7 7 0 0 0 14 0C19 11 12 3 12 3z"/></svg>
        <b class="pt">Atendimentos</b>
        <span class="pc">Acompanhe os atendimentos em andamento e inicie o próximo.</span>
      </a>

      <a class="pcard" href="painel-pagamentos.jsp">
        <svg class="pi" viewBox="0 0 24 24"><rect x="3" y="6" width="18" height="13" rx="2"/><path d="M3 10h18M16 15h2"/></svg>
        <b class="pt">Pagamentos</b>
        <span class="pc">Veja os valores e registre a forma de pagamento de cada atendimento.</span>
      </a>

      <a class="pcard" href="painel-colaboradores.jsp">
        <i class="pdot" title="Exclusivo do administrador"></i>
        <svg class="pi" viewBox="0 0 24 24"><rect x="5" y="3" width="14" height="18" rx="2"/><circle cx="12" cy="10" r="2.5"/><path d="M8 17c0-2 2-3 4-3s4 1 4 3"/></svg>
        <b class="pt">Colaboradores</b>
        <span class="pc">Gerencie quem trabalha aqui e o nível de acesso de cada pessoa.</span>
      </a>

      <a class="pcard" href="painel-servicos.jsp">
        <i class="pdot" title="Exclusivo do administrador"></i>
        <svg class="pi" viewBox="0 0 24 24"><path d="M3 12V4h8l10 10-8 8z"/><circle cx="8" cy="8" r="1.4"/></svg>
        <b class="pt">Serviços</b>
        <span class="pc">Defina os serviços oferecidos, a duração e os preços.</span>
      </a>
    </div>
  </div>
</main>

</body>
</html>