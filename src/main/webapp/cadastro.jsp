<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Criar conta — Fast Splash</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wdth,wght@12..96,75..100,200..800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="Assets/CSS/style.css">
</head>
<body>

<header class="top staff-login-header">
  <div class="top-in">
    <a class="lock" href="index.html" aria-label="Fast Splash, início">
      <span class="wm"><span class="f">fast</span> <span class="s">splash</span></span>
    </a>
    <nav><a href="index.html">Voltar ao início</a></nav>
  </div>
</header>

<main class="staff-login registration-page">
  <section class="staff-login-copy" aria-labelledby="registration-title">
    <p class="staff-login-kicker">Crie sua conta</p>
    <h1 id="registration-title">Lavagem rápida, com tempo para olhar.</h1>
    <p>Cadastre-se em um minuto, baixe o app e agende por lá. O carro você informa no app, na hora de agendar.</p>
  </section>

  <section class="staff-login-panel" aria-labelledby="registration-form-title">
    <div class="staff-login-card registration-card">
      <h2 id="registration-form-title">Criar conta</h2>
      <form action="cadastro" method="post">
        <div class="field">
          <label for="rn">Nome completo</label>
          <input id="rn" name="name" autocomplete="name" required placeholder="Seu nome completo">
        </div>

        <div class="fgrid">
          <div class="field">
            <label for="rc">CPF</label>
            <input id="rc" name="cpf" inputmode="numeric" maxlength="14" required placeholder="000.000.000-00">
          </div>
          <div class="field">
            <label for="rt">Telefone</label>
            <input id="rt" name="phone" type="tel" autocomplete="tel" required placeholder="(11) 99999-0000">
          </div>
        </div>

        <div class="field">
          <label for="re">E-mail</label>
          <input id="re" name="email" type="email" autocomplete="email" required placeholder="seu@email.com">
        </div>

        <div class="field">
          <label for="rp">Senha (mínimo 8 caracteres)</label>
          <input id="rp" name="pass" type="password" autocomplete="new-password" minlength="8" maxlength="72" required>
        </div>

        <label class="chk">
          <input type="checkbox" name="consent" required>
          <span>Aceito que meus dados sejam usados para agendamentos e para falar sobre minhas lavagens.</span>
        </label>

        <button class="btn" type="submit">Criar conta e baixar o app</button>
      </form>
    </div>
    <a class="staff-login-back" href="index.html">← Voltar ao site</a>
  </section>
</main>

</body>
</html>