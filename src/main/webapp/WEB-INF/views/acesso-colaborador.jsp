<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Acesso da Equipe — Fast Splash</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wdth,wght@12..96,75..100,200..800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="../../Assets/CSS/style.css">
</head>
<body>

<header class="top">
  <div class="top-in">
    <a class="lock" href="../../index.jsp">
      <span class="wm"><span class="f">fast</span> <span class="s">splash</span></span>
    </a>
    <nav><a href="../../index.jsp">Voltar ao site</a></nav>
  </div>
</header>

<main class="page">
  <div class="narrow">
    <h1>Acesso da equipe</h1>
    <p class="lead">Painel interno de agendamentos e fila de lavagem.</p>
    
    <div class="blk">
      <form action="painel.jsp" method="post">
        <div class="field">
          <label for="se">E-mail</label>
          <input id="se" name="email" type="email" required value="admin@fastsplash.com">
        </div>
        <div class="field">
          <label for="sp">Palavra-passe</label>
          <input id="sp" name="pass" type="password" required value="123456">
        </div>
        <button class="btn" type="submit" style="width:100%">Entrar no painel</button>
      </form>
    </div>
    <a href="index.jsp" class="small">Voltar ao site principal</a>
  </div>
</main>

</body>
</html>