<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
  <meta name="description" content="Fast Splash — Agendamento e acompanhamento em tempo real para serviços de lava-rápido.">
  <title>Fast Splash — Lava-rápido</title>

  <!-- Fontes do Google -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wdth,wght@12..96,75..100,200..800&family=Instrument+Serif:ital@0;1&display=swap" rel="stylesheet">

  <!-- Estilo Externo -->
  <link rel="stylesheet" href="style.css">
</head>
<body>

  <!-- Cabeçalho de Navegação -->
  <header class="top">
    <div class="top-in">
      <a class="lock" href="#topo" aria-label="Fast Splash, início">
        <span class="wm"><span class="f">fast</span> <span class="s">splash</span></span>
      </a>
      <nav id="nav" aria-label="Navegação Principal">
        <a href="#servicos">Serviços</a>
        <a href="#contato">Como chegar</a>
        <a class="btn sm" href="#cadastro">Criar conta</a>
      </nav>
    </div>
  </header>

  <!-- Conteúdo Principal -->
  <main id="app" role="main">

    <!-- Hero Section -->
    <section class="scene-hero" id="topo">
      <div class="h-text">
        <h1 class="h-wm wm" aria-label="fast splash">
          <span class="wd-f f">fast</span> <span class="wd-s s">splash</span>
        </h1>
        <p class="sub">Lavagem de carros diversos. Crie sua conta e agende por lá.</p>
        <a class="btn" href="#cadastro">Criar conta</a>
      </div>
    </section>

    <!-- Seção de Serviços -->
    <section class="svc" id="servicos">
      <div class="wrap">
        <h2 class="svc-h">Quatro jeitos de lavar.</h2>
        <div class="svc-grid">
          <article class="svc-card">
            <svg width="30" height="30" viewBox="0 0 40 40" aria-hidden="true"><path d="M20 3C20 3 7 17 7 25a13 13 0 0 0 26 0C33 17 20 3 20 3z" fill="#0E6BAA"/></svg>
            <h3>Lavagem Simples</h3>
            <p class="small">Lavagem externa com secagem à mão.</p>
            <p class="price">R$ 40,00</p>
            <p class="small">cerca de 30 min</p>
          </article>

          <article class="svc-card">
            <svg width="30" height="30" viewBox="0 0 40 40" aria-hidden="true"><path d="M20 3C20 3 7 17 7 25a13 13 0 0 0 26 0C33 17 20 3 20 3z" fill="#0E6BAA"/></svg>
            <h3>Lavagem Completa</h3>
            <p class="small">Externa e interna: aspiração, painel e vidros.</p>
            <p class="price">R$ 70,00</p>
            <p class="small">cerca de 60 min</p>
          </article>

          <article class="svc-card">
            <svg width="30" height="30" viewBox="0 0 40 40" aria-hidden="true"><path d="M20 3C20 3 7 17 7 25a13 13 0 0 0 26 0C33 17 20 3 20 3z" fill="#0E6BAA"/></svg>
            <h3>Enceramento</h3>
            <p class="small">Cera aplicada à mão para proteger e dar brilho.</p>
            <p class="price">R$ 90,00</p>
            <p class="small">cerca de 60 min</p>
          </article>

          <article class="svc-card">
            <svg width="30" height="30" viewBox="0 0 40 40" aria-hidden="true"><path d="M20 3C20 3 7 17 7 25a13 13 0 0 0 26 0C33 17 20 3 20 3z" fill="#0E6BAA"/></svg>
            <h3>Detalhamento Interno</h3>
            <p class="small">Bancos, carpetes e plásticos com limpeza cuidadosa.</p>
            <p class="price">R$ 150,00</p>
            <p class="small">cerca de 90 min</p>
          </article>
        </div>

        <div class="how">
          <div>
            <b>Crie sua conta</b>
            <p class="small">Nome, contato e o seu carro.</p>
          </div>
          <div>
            <b>Baixe o app</b>
            <p class="small">Você vai direto para o download.</p>
          </div>
          <div>
            <b>Agende e acompanhe</b>
            <p class="small">Serviço, dia, horário e cada etapa da lavagem.</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Divisor Visual -->
    <div class="sep" style="background:#0E6BAA; --c1:#8FC9E8; --c2:#EDF3F4; --c3:var(--paper)" aria-hidden="true">
      <svg class="l3" viewBox="0 0 1680 96" preserveAspectRatio="none"><path d="M0 96 L0 40 Q 420 80 840 40 T 1680 40 L 1680 96 Z"/></svg>
    </div>

    <!-- Chamada para Cadastro -->
    <section class="cta-end" id="cadastro">
      <div class="cta-card">
        <div>
          <h2>Crie sua conta e baixe o app.</h2>
          <p>Leva um minuto. Depois é só agendar pelo celular.</p>
        </div>
        <a class="btn" href="cadastro.jsp">Criar conta</a>
      </div>
    </section>

    <!-- Seção de Contato e Localização -->
    <section class="info" id="contato">
      <div class="wrap">
        <h2 class="svc-h">Como chegar.</h2>
        <div class="info-grid">
          <div>
            <h3>Onde fica</h3>
            <p>Rua Exemplo, 123, Bairro, Cidade</p>
            <a class="btn ghost sm" href="https://maps.google.com" target="_blank" rel="noopener">Ver no mapa</a>
          </div>
          <div>
            <h3>Horário</h3>
            <ul class="hrs">
              <li><span>Segunda a sábado</span><b>8h às 18h</b></li>
              <li><span>Domingo</span><b>Fechado</b></li>
            </ul>
          </div>
          <div>
            <h3>Fale com a gente</h3>
            <p>(11) 90000-0000</p>
            <a class="btn sm" href="https://wa.me/5511900000000" target="_blank" rel="noopener">Chamar no WhatsApp</a>
          </div>
        </div>
        <p class="small" style="margin-top:28px">Endereço, horário e telefone são de exemplo.</p>
      </div>
    </section>

    <!-- Divisor Visual Footer -->
    <div class="sep" style="background:var(--paper-2); --c1:#8FC9E8; --c2:#0E6BAA; --c3:#06263F" aria-hidden="true">
      <svg class="l3" viewBox="0 0 1680 96" preserveAspectRatio="none"><path d="M0 96 L0 40 Q 420 80 840 40 T 1680 40 L 1680 96 Z"/></svg>
    </div>

  </main>

  <!-- Rodapé -->
  <footer class="ft">
    <div class="wrap">
      <div>
        <div class="lock v-neg">
          <span class="wm"><span class="f">fast</span> <span class="s">splash</span></span>
        </div>
      </div>
      <a class="lantern" href="acesso.jsp"><i aria-hidden="true"></i>Acesso da equipe</a>
    </div>
  </footer>