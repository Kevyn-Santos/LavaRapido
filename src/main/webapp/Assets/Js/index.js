let heroParallaxFrame = null;

function updateHeroParallax() {
  const hero = document.querySelector('.scene-hero[data-scene="pin"]');
  const pin = hero && hero.querySelector('.pin');
  if (!hero || !pin) return;

  const rect = hero.getBoundingClientRect();
  const availableHeight = hero.offsetHeight - pin.offsetHeight;
  const p = availableHeight > 0
    ? Math.min(Math.max(-rect.top / availableHeight, 0), 1)
    : 0;
  const f = Math.min(Math.max((p - 0.25) / 0.65, 0), 1);

  hero.style.setProperty('--p', p.toFixed(4));
  hero.style.setProperty('--f', f.toFixed(4));
}

function scheduleHeroParallax() {
  if (heroParallaxFrame !== null) return;
  heroParallaxFrame = window.requestAnimationFrame(() => {
    heroParallaxFrame = null;
    updateHeroParallax();
  });
}

// Executa durante o scroll e no carregamento/redimensionamento
window.addEventListener('scroll', scheduleHeroParallax, { passive: true });
window.addEventListener('resize', scheduleHeroParallax);
window.addEventListener('load', scheduleHeroParallax);
updateHeroParallax();
