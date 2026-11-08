<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Clientes — Fast Splash</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/Assets/CSS/painel.css">
</head>
<body class="panel-page">
<header class="top panel-page-header"><div class="top-in">
  <a class="lock" href="${pageContext.request.contextPath}/index.jsp" aria-label="Fast Splash, início">
    <span class="wm"><span class="f">fast</span> <span class="s">splash</span></span>
  </a>
  <nav><a href="${pageContext.request.contextPath}/index.jsp">Voltar ao início</a></nav>
</div></header>
<main class="page"><div class="wrap">
  <div class="who"><div><p class="small">Bem-vindo(a)</p><h1><c:out value="${sessionScope.colaboradorNome}" /></h1></div><span class="role admin">Painel</span></div>
  <nav class="ptabs" aria-label="Áreas do painel">
    <a href="${pageContext.request.contextPath}/admin/">Início</a>
    <a href="${pageContext.request.contextPath}/clientes" class="on" aria-current="page">Clientes</a>
    <a href="${pageContext.request.contextPath}/servicos">Serviços</a>
  </nav>

  <div class="phead"><div><h2>Clientes</h2><p class="small">Cadastre, edite ou remova clientes.</p></div><a class="btn" href="${pageContext.request.contextPath}/clientes">Novo cliente</a></div>
  <c:if test="${not empty erro}"><p class="err" role="alert"><c:out value="${erro}" /></p></c:if>
  <c:if test="${param.sucesso == '1'}"><p class="ok" role="status">Cliente salvo com sucesso.</p></c:if>

  <div class="fcard">
    <h2><c:choose><c:when test="${not empty clienteEdicao}">Editar cliente</c:when><c:otherwise>Novo cliente</c:otherwise></c:choose></h2>
    <form method="post" action="${pageContext.request.contextPath}/clientes">
      <input type="hidden" name="acao" value="salvar"><input type="hidden" name="idCliente" value="${clienteEdicao.id_cliente}">
      <div class="field"><label for="nome">Nome completo</label><input id="nome" name="nome" required maxlength="100" value="<c:out value='${clienteEdicao.nome}' />"></div>
      <div class="field"><label for="cpf">CPF</label><input id="cpf" name="cpf" required maxlength="14" value="<c:out value='${clienteEdicao.cpf}' />"></div>
      <div class="field"><label for="telefone">Telefone</label><input id="telefone" name="telefone" required maxlength="20" value="<c:out value='${clienteEdicao.telefone}' />"></div>
      <div class="field"><label for="email">E-mail</label><input id="email" name="email" type="email" required maxlength="150" value="<c:out value='${clienteEdicao.email}' />"></div>
      <div class="field"><label for="senha">Senha <c:if test="${not empty clienteEdicao}">(deixe em branco para manter)</c:if></label><input id="senha" name="senha" type="password" minlength="8" maxlength="72" <c:if test="${empty clienteEdicao}">required</c:if>></div>
      <div class="facts"><button class="btn" type="submit">Salvar cliente</button><a class="btn ghost" href="${pageContext.request.contextPath}/clientes">Cancelar</a></div>
    </form>
  </div>

  <div class="table-wrap"><table>
    <thead><tr><th>Nome</th><th>CPF</th><th>Telefone</th><th>E-mail</th><th>Ações</th></tr></thead>
    <tbody><c:forEach var="cliente" items="${clientes}">
      <tr>
        <td><c:out value="${cliente.nome}" /></td><td><c:out value="${cliente.cpf}" /></td>
        <td><c:out value="${cliente.telefone}" /></td><td><c:out value="${cliente.email}" /></td>
        <td><a class="btn ghost" href="${pageContext.request.contextPath}/clientes?editar=${cliente.id_cliente}">Editar</a>
          <form method="post" action="${pageContext.request.contextPath}/clientes" style="display:inline">
            <input type="hidden" name="acao" value="remover"><input type="hidden" name="idCliente" value="${cliente.id_cliente}">
            <button class="btn ghost" type="submit" onclick="return confirm('Remover este cliente e os registros vinculados?')">Excluir</button>
          </form>
        </td>
      </tr>
    </c:forEach></tbody>
  </table></div>
</div></main>
</body>
</html>
