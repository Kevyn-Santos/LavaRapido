<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Criar conta — Fast Splash</title>

  <link rel="icon" href="Assets/Img/favicon.ico">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wdth,wght@12..96,75..100,200..800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/Assets/CSS/style.css">
</head>
<body>

<header class="top staff-login-header">
  <div class="top-in">
    <a class="lock" href="index.jsp" aria-label="Fast Splash, início">
      <img class="logo-fastsplash" src="Assets/Img/logo_fastsplash.png" alt="Fast Splash">
    </a>
    <nav><a href="index.jsp">Voltar ao inicio</a></nav>
  </div>
</header>

<main class="staff-login registration-page">
  <section class="staff-login-copy" aria-labelledby="registration-title">
    <p class="staff-login-kicker">Crie sua conta</p>
    <h1 id="registration-title">Lavagem rapida, com tempo para olhar.</h1>
    <p>Cadastre-se em um minuto, baixe o app e agende por la. O carro voce informa no app, na hora de agendar.</p>
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
            <input id="rt" name="phone" type="tel" inputmode="numeric" maxlength="15" autocomplete="tel" required placeholder="(11) 99999-0000">
          </div>
        </div>

        <div class="field">
          <label for="re">E-mail</label>
          <input id="re" name="email" type="email" autocomplete="email" required placeholder="seu@email.com">
        </div>

        <div class="field">
          <label for="rp">Senha (minimo 8 caracteres)</label>
          <input id="rp" name="pass" type="password" autocomplete="new-password" minlength="8" maxlength="72" required>
        </div>

        <label class="chk">
          <input type="checkbox" name="consent" required>
          <span>Aceito que meus dados sejam usados para agendamentos e para falar sobre minhas lavagens.</span>
        </label>

        <button class="btn" type="submit">Criar conta e baixar o app</button>
      </form>
    </div>
    <a class="staff-login-back" href="index.jsp"><- Voltar ao site</a>
  </section>
</main>

<script>
  (function () {
    'use strict';

    // Mesmas regras de máscara/validação do painel (Assets/Js/painel.js)
    function soDigitos(v, max) { return String(v || '').replace(/\D/g, '').slice(0, max); }

    function maskCPF(v) {
      const d = soDigitos(v, 11);
      if (d.length > 9) return d.slice(0, 3) + '.' + d.slice(3, 6) + '.' + d.slice(6, 9) + '-' + d.slice(9);
      if (d.length > 6) return d.slice(0, 3) + '.' + d.slice(3, 6) + '.' + d.slice(6);
      if (d.length > 3) return d.slice(0, 3) + '.' + d.slice(3);
      return d;
    }

    function validCPF(value) {
      const d = soDigitos(value, 11);
      if (d.length !== 11 || /^(\d)\1{10}$/.test(d)) return false;
      for (let pos = 9; pos <= 10; pos++) {
        let soma = 0;
        for (let i = 0; i < pos; i++) soma += Number(d[i]) * (pos + 1 - i);
        if ((soma * 10) % 11 % 10 !== Number(d[pos])) return false;
      }
      return true;
    }

    function formatPhone(v) {
      const d = soDigitos(v, 11);
      if (d.length <= 2) return d ? '(' + d : '';
      const ddd = '(' + d.slice(0, 2) + ') ';
      if (d.length <= 10) return ddd + d.slice(2, 6) + (d.length > 6 ? '-' + d.slice(6) : '');
      return ddd + d.slice(2, 7) + (d.length > 7 ? '-' + d.slice(7) : '');
    }

    const cpf = document.getElementById('rc');
    const tel = document.getElementById('rt');

    // CPF: mantém o cursor na posição certa ao reformatar no meio do texto
    cpf.addEventListener('input', function () {
      const caret = cpf.selectionStart || 0;
      const antes = cpf.value.slice(0, caret).replace(/\D/g, '').length;
      const formatado = maskCPF(cpf.value);
      cpf.value = formatado;
      let pos = 0, cont = 0;
      while (pos < formatado.length && cont < antes) {
        if (/\d/.test(formatado[pos])) cont++;
        pos++;
      }
      cpf.setSelectionRange(pos, pos);
      cpf.setCustomValidity(validCPF(cpf.value) ? '' : 'Informe um CPF válido com 11 dígitos.');
    });

    tel.addEventListener('input', function () {
      tel.value = formatPhone(tel.value);
      const n = soDigitos(tel.value, 11).length;
      tel.setCustomValidity(n === 10 || n === 11 ? '' : 'Informe um telefone com DDD e 8 ou 9 dígitos.');
    });
  })();
</script>

</body>
</html>