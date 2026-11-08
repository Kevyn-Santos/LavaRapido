<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Serviços — Fast Splash</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/Assets/CSS/painel.css">
  <style> .hide { display: none !important; } </style>
</head>
<body class="panel-page">
<header class="top panel-page-header"><div class="top-in">
  <a class="lock" href="${pageContext.request.contextPath}/index.jsp" aria-label="Fast Splash, início">
    <span class="wm"><span class="f">fast</span> <span class="s">splash</span></span>
  </a>
  <nav><a href="${pageContext.request.contextPath}/index.jsp">Voltar ao início</a></nav>
</div></header>
<main class="page"><div class="wrap">
  <div class="who"><div><p class="small">Bem-vindo(a)</p><h1><c:out value="${sessionScope.colaboradorNome}" /></h1></div><span class="role admin">Administrador</span></div>
  <nav class="ptabs" aria-label="Áreas do painel">
    <a href="${pageContext.request.contextPath}/admin/">Início</a>
    <a href="${pageContext.request.contextPath}/clientes">Clientes</a>
    <a href="${pageContext.request.contextPath}/servicos" class="on" aria-current="page">Serviços</a>
  </nav>

  <div class="phead">
    <div><h2>Serviços e preços</h2><p class="small">Cadastre, edite ou remova os serviços oferecidos.</p></div>
    <a class="btn" href="${pageContext.request.contextPath}/servicos">Novo serviço</a>
<header class="top panel-page-header">
  <div class="top-in">
    <a class="lock" href="${pageContext.request.contextPath}/" aria-label="Fast Splash, início">
      <span class="wm"><span class="f">fast</span> <span class="s">splash</span></span>
    </a>
    <nav><a href="${pageContext.request.contextPath}/">Voltar ao início</a></nav>
  </div>
  <c:if test="${not empty erro}"><p class="err" role="alert"><c:out value="${erro}" /></p></c:if>
  <c:if test="${param.sucesso == '1'}"><p class="ok" role="status">Serviço salvo com sucesso.</p></c:if>

  <div class="fcard">
    <h2><c:choose><c:when test="${not empty servicoEdicao}">Editar serviço</c:when><c:otherwise>Novo serviço</c:otherwise></c:choose></h2>
    <form method="post" action="${pageContext.request.contextPath}/servicos">
      <input type="hidden" name="acao" value="salvar">
      <input type="hidden" name="idServico" value="${servicoEdicao.id}">
      <div class="field"><label for="nome">Nome</label><input id="nome" name="nome" required maxlength="100" value="<c:out value='${servicoEdicao.nome}' />"></div>
      <div class="field"><label for="descricao">Descrição</label><input id="descricao" name="descricao" maxlength="255" value="<c:out value='${servicoEdicao.descricao}' />"></div>
      <div class="field"><label for="preco">Preço</label><input id="preco" name="preco" type="number" min="0" step="0.01" required value="${servicoEdicao.preco}"></div>
      <div class="facts"><button class="btn" type="submit">Salvar serviço</button><a class="btn ghost" href="${pageContext.request.contextPath}/servicos">Cancelar</a></div>
    </form>
  </div>

  <div class="table-wrap"><table>
    <thead><tr><th>Nome</th><th>Descrição</th><th>Preço</th><th>Ações</th></tr></thead>
    <tbody><c:forEach var="servico" items="${servicos}">
      <tr>
        <td><c:out value="${servico.nome}" /></td>
        <td><c:out value="${servico.descricao}" /></td>
        <td>R$ <c:out value="${servico.preco}" /></td>
        <td>
          <a class="btn ghost" href="${pageContext.request.contextPath}/servicos?editar=${servico.id}">Editar</a>
          <form method="post" action="${pageContext.request.contextPath}/servicos" style="display:inline">
            <input type="hidden" name="acao" value="remover"><input type="hidden" name="idServico" value="${servico.id}">
            <button class="btn ghost" type="submit" onclick="return confirm('Remover este serviço?')">Excluir</button>
          </form>
        </td>
      </tr>
    </c:forEach></tbody>
  </table></div>
</div></main>
</body>
</html>
