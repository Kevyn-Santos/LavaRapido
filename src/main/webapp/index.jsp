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
  <link rel="stylesheet" href="Assets/CSS/style.css">
</head>

<body>

  <!-- Cabeçalho de Navegação -->
  <header class="top landing-header">
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

   <!-- Hero Section com Efeito Sticky & Parallax -->
<section class="scene-hero" id="topo" data-scene="pin">
  <div class="pin">
    
    <!-- Vídeo do Opala 3D no fundo -->
    <video id="hero-video" class="hero-bg-video" autoplay muted loop playsinline>
      <source src="Assets/Video/lavagem-opala.mp4" type="video/mp4">
    </video>
    <div class="hero-overlay"></div>

    <!-- Hero Wordmark Monumental (fast splash) -->
    <h1 class="h-wm wm" aria-label="fast splash">
      <span class="wd-f f">fast</span> <span class="wd-s s">splash</span>
    </h1>

    <aside class="glass g1 glass-s" aria-label="Preço das lavagens">
      <span class="gl-k">Lavagens a partir de</span>
      <b>R$ 40,00</b>
    </aside>
    <div class="h-flood" aria-hidden="true">
      <svg class="h-flood-wave" viewBox="0 0 1440 100" preserveAspectRatio="none">
        <path class="we" d="M0,65 C240,100 420,20 720,55 C1000,90 1190,25 1440,60 L1440,100 L0,100 Z"></path>
      </svg>
    </div>

    <!-- Bloco do Canto Esquerdo -->
    <div class="h-text">
      <p class="sub">Lavagem de carros diversos. Crie sua conta, baixe o app e agende por lá.</p>
      <a class="btn ghost" href="#cadastro">Criar conta</a>
    </div>

  </div>
</section>

    <div class="sep sep--blue-to-navy" aria-hidden="true">
      <svg viewBox="0 0 1920 120" preserveAspectRatio="none">
        <rect width="1920" height="120" fill="#0E6BAA" />
        <path fill="#EDF3F4" opacity="0.85" d="M0,60 C160,59 200,74 360,69 C520,64 560,53 720,58 C880,64 960,75 1120,68 C1280,62 1360,51 1520,55 C1680,60 1800,71 1920,54 L1920,120 L0,120 Z"></path>
        <path fill="#8FC9E8" opacity="0.8" d="M0,68 C180,78 250,57 430,61 C610,65 700,82 880,75 C1060,67 1140,55 1320,62 C1500,69 1600,83 1760,73 C1840,68 1880,58 1920,55 L1920,120 L0,120 Z"></path>
        <path fill="#06263F" d="M0,84 C180,93 300,71 480,76 C660,81 740,98 920,90 C1100,82 1200,68 1380,76 C1560,84 1640,99 1800,86 C1860,80 1890,70 1920,68 L1920,120 L0,120 Z"></path>
      </svg>
    </div>

    <!-- Seção de Serviços -->
    <section class="svc" id="servicos">
      <div class="wrap">
        <h2 class="svc-h reveal">Quatro jeitos de lavar.</h2>
        <div class="svc-grid">
          
          <article class="svc-card reveal delay-1">
            <a class="go" href="#cadastro" aria-label="Reservar serviço">↗</a>
            <svg width="30" height="30" viewBox="0 0 40 40" aria-hidden="true">
              <path d="M20 3C20 3 7 17 7 25a13 13 0 0 0 26 0C33 17 20 3 20 3z" fill="#8FC9E8" />
            </svg>
            <h3>Lavagem Simples</h3>
            <p class="small">Lavagem externa com secagem à mão.</p>
            <p class="price">R$ 40,00</p>
            <p class="small">cerca de 30 min</p>
          </article>

          <article class="svc-card reveal delay-2">
            <a class="go" href="#cadastro" aria-label="Reservar serviço">↗</a>
            <svg width="30" height="30" viewBox="0 0 40 40" aria-hidden="true">
              <path d="M20 3C20 3 7 17 7 25a13 13 0 0 0 26 0C33 17 20 3 20 3z" fill="#8FC9E8" />
            </svg>
            <h3>Lavagem Completa</h3>
            <p class="small">Externa e interna: aspiração, painel e vidros.</p>
            <p class="price">R$ 70,00</p>
            <p class="small">cerca de 60 min</p>
          </article>

          <article class="svc-card reveal delay-3">
            <a class="go" href="#cadastro" aria-label="Reservar serviço">↗</a>
            <svg width="30" height="30" viewBox="0 0 40 40" aria-hidden="true">
              <path d="M20 3C20 3 7 17 7 25a13 13 0 0 0 26 0C33 17 20 3 20 3z" fill="#8FC9E8" />
            </svg>
            <h3>Enceramento</h3>
            <p class="small">Cera aplicada à mão para proteger e dar brilho.</p>
            <p class="price">R$ 90,00</p>
            <p class="small">cerca de 60 min</p>
          </article>

          <article class="svc-card reveal delay-4">
            <a class="go" href="#cadastro" aria-label="Reservar serviço">↗</a>
            <svg width="30" height="30" viewBox="0 0 40 40" aria-hidden="true">
              <path d="M20 3C20 3 7 17 7 25a13 13 0 0 0 26 0C33 17 20 3 20 3z" fill="#8FC9E8" />
            </svg>
            <h3>Detalhamento Interno</h3>
            <p class="small">Bancos, carpetes e plásticos com limpeza cuidadosa.</p>
            <p class="price">R$ 150,00</p>
            <p class="small">cerca de 90 min</p>
          </article>
        </div>

        <div class="how">
          <div class="reveal delay-1">
            <b>Crie sua conta</b>
            <p class="small">Nome, contato e o seu carro.</p>
          </div>
          <div class="reveal delay-2">
            <b>Baixe o app</b>
            <p class="small">Você vai direto para o download.</p>
          </div>
          <div class="reveal delay-3">
            <b>Agende e acompanhe</b>
            <p class="small">Serviço, dia, horário e cada etapa da lavagem.</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Chamada para Cadastro -->
    <section class="cta-end" id="cadastro">
      <div class="cta-card reveal">
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
        <h2 class="svc-h reveal">Como chegar.</h2>
        <div class="info-grid">
          <div class="reveal delay-1">
            <h3>Onde fica</h3>
            <p>Rua Exemplo, 123, Bairro, Cidade</p>
            <a class="btn ghost sm" href="https://maps.google.com" target="_blank" rel="noopener">Ver no mapa</a>
          </div>
          <div class="reveal delay-2">
            <h3>Horário</h3>
            <ul class="hrs">
              <li><span>Segunda a sábado</span><b>8h às 18h</b></li>
              <li><span>Domingo</span><b>Fechado</b></li>
            </ul>
          </div>
          <div class="reveal delay-3">
            <h3>Fale com a gente</h3>
            <p>(11) 90000-0000</p>
            <a class="btn sm" href="https://wa.me/5511900000000" target="_blank" rel="noopener">Chamar no WhatsApp</a>
          </div>
        </div>
        <p class="small reveal" style="margin-top:28px">Endereço, horário e telefone são de exemplo.</p>
      </div>
    </section>

    <!-- Transição das informações para o rodapé -->
    <div class="sep sep--contact-to-navy" aria-hidden="true">
      <svg viewBox="0 0 1920 120" preserveAspectRatio="none">
        <rect width="1920" height="120" fill="var(--wave-top)" />
        <path fill="#8FC9E8" opacity="0.75" d="M0,60 C160,59 200,74 360,69 C520,64 560,53 720,58 C880,64 960,75 1120,68 C1280,62 1360,51 1520,55 C1680,60 1800,71 1920,54 L1920,120 L0,120 Z"></path>
        <path fill="#0E6BAA" opacity="0.8" d="M0,68 C180,78 250,57 430,61 C610,65 700,82 880,75 C1060,67 1140,55 1320,62 C1500,69 1600,83 1760,73 C1840,68 1880,58 1920,55 L1920,120 L0,120 Z"></path>
        <path fill="var(--wave-bottom)" d="M0,84 C180,93 300,71 480,76 C660,81 740,98 920,90 C1100,82 1200,68 1380,76 C1560,84 1640,99 1800,86 C1860,80 1890,70 1920,68 L1920,120 L0,120 Z"></path>
      </svg>
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
      <a class="lantern" href="colaborador/login"><i aria-hidden="true"></i>Acesso da equipe</a>
    </div>
  </footer>

  <script src="Assets/Js/index.js"></script>
  
  <!-- SCRIPT PARA A ANIMAÇÃO (REVEAL) -->
  <script>
    function revealElements() {
      const reveals = document.querySelectorAll('.reveal');
      const windowHeight = window.innerHeight;
      
      reveals.forEach(element => {
        const elementTop = element.getBoundingClientRect().top;
        const revealPoint = 80;
        
        if (elementTop < windowHeight - revealPoint) {
          element.classList.add('active');
        }
      });
    }

    // Ouve o scroll para disparar a animação
    window.addEventListener('scroll', revealElements);
    
    // Dispara imediatamente para o conteúdo que já está na tela
    window.addEventListener('load', revealElements);
  </script>
</body>
</html>