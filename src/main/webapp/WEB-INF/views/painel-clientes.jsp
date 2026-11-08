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
    <div class="who">
      <div>
        <p class="small">Bem-vindo(a)</p>
        <h1><c:out value="${sessionScope.colaboradorNome}" /></h1>
      </div>
      <span class="role admin">Administrador</span>
    </div>

    <nav class="ptabs" aria-label="Áreas do painel">
      <a href="${pageContext.request.contextPath}/admin/inicio">Início</a>
      <a href="${pageContext.request.contextPath}/painel/clientes" class="on" aria-current="page">Clientes</a>
      <a href="${pageContext.request.contextPath}/painel/carros">Carros</a>
      <a href="${pageContext.request.contextPath}/painel/agendamentos">Agendamentos</a>
      <a href="${pageContext.request.contextPath}/painel/atendimentos">Atendimentos</a>
      <a href="${pageContext.request.contextPath}/painel/pagamentos">Pagamentos</a>
      <a href="${pageContext.request.contextPath}/painel/colaboradores">Colaboradores</a>
      <a href="${pageContext.request.contextPath}/painel/servicos">Serviços</a>
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

      <div id="clients-table-container">
        <c:if test="${empty clientes}">
          <p class="small">Nenhum cliente cadastrado.</p>
        </c:if>
        <c:if test="${not empty clientes}">
          <div class="tbl">
            <div class="thead trow crow">
              <div>Cliente</div>
              <div>Telefone</div>
              <div>Carros</div>
              <div>Ações</div>
            </div>
            <c:forEach items="${clientes}" var="cliente">
              <div class="trow crow" data-id="${cliente.id_cliente}">
                <div data-l="Cliente">
                  <strong><c:out value="${cliente.nome}" /></strong>
                  <p class="small"><c:out value="${cliente.email}" /></p>
                </div>
                <div data-l="Telefone"><c:out value="${cliente.telefone}" /></div>
                <div data-l="Carros">
                  <c:choose>
                    <c:when test="${empty cliente.veiculos}">—</c:when>
                    <c:otherwise>
                      <c:forEach items="${cliente.veiculos}" var="veiculo" varStatus="vs">
                        <c:if test="${not vs.first}">, </c:if><c:out value="${veiculo.marca} ${veiculo.modelo}" />
                      </c:forEach>
                    </c:otherwise>
                  </c:choose>
                </div>
                <div class="acts" data-l="Ações">
                  <button type="button" class="btn sm ghost">Editar</button>
                  <button type="button" class="btn sm danger">Remover</button>
                </div>
              </div>
            </c:forEach>
          </div>
        </c:if>
      </div>
    </div>

    <!-- 2. TELA DO FORMULÁRIO -->
    <div id="view-form" class="hide">
      <div class="fcard">
        <h2 id="form-title">Novo cliente</h2>
        <form id="form-client" action="${pageContext.request.contextPath}/cadastro" method="post">
          <input type="hidden" id="client-id">

          <div class="field">
            <label for="client-name">Nome completo</label>
            <input type="text" id="client-name" name="name" required placeholder="Ex: Marina Alves">
          </div>

          <div class="fgrid">
            <div class="field">
              <label for="client-cpf">CPF</label>
              <input type="text" id="client-cpf" name="cpf" required placeholder="000.000.000-00" maxlength="14">
            </div>
            <div class="field">
              <label for="client-phone">Telefone</label>
              <input type="tel" id="client-phone" name="phone" required placeholder="(11) 99999-0000">
            </div>
          </div>

          <div class="field">
            <label for="client-email">E-mail</label>
            <input type="email" id="client-email" name="email" required placeholder="cliente@exemplo.com">
          </div>

          <div class="field">
            <label for="client-pass">Senha</label>
            <input type="password" id="client-pass" name="pass" required autocomplete="new-password" minlength="8" maxlength="72">
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
