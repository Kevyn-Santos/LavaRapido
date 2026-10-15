<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Criar conta — Fast Splash</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wdth,wght@12..96,75..100,200..800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="style.css">
</head>
<body>

<header class="top">
  <div class="top-in">
    <a class="lock" href="index.jsp">
      <span class="wm"><span class="f">fast</span> <span class="s">splash</span></span>
    </a>
    <nav><a href="index.jsp">Voltar ao início</a></nav>
  </div>
</header>

<main class="reg-page">
  <div class="reg-card">
    <h2>Crie a sua conta</h2>
    <p>São apenas quatro campos. O veículo será informado na app ao agendar.</p>
    
    <form action="baixar-app.jsp" method="post">
      <div class="field">
        <label for="rn">Nome completo</label>
        <input id="rn" name="name" required placeholder="O seu nome">
      </div>
      
      <div class="fgrid">
        <div class="field">
          <label for="rt">Telemóvel</label>
          <input id="rt" name="phone" type="tel" required placeholder="(11) 99999-0000">
        </div>
        <div class="field">
          <label for="re">E-mail</label>
          <input id="re" name="email" type="email" required placeholder="seu@email.com">
        </div>
      </div>

      <div class="field">
        <label for="rp">Palavra-passe (mínimo 6 carateres)</label>
        <input id="rp" name="pass" type="password" minlength="6" required>
      </div>

      <label class="chk">
        <input type="checkbox" name="consent" required>
        <span>Aceito que os meus dados sejam usados para agendamentos.</span>
      </label>

      <button class="btn" type="submit">Criar conta e baixar a app</button>
    </form>
    <p class="small" style="margin-top:16px"><a href="index.jsp">Voltar ao site</a></p>
  </div>
</main>

</body>
</html>