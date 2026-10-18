(() => {
  'use strict';

  const storageKey = 'fastsplash_db_v4';
  const grid = document.querySelector('.svc-grid');
  const iconPath = 'M20 3C20 3 7 17 7 25a13 13 0 0 0 26 0C33 17 20 3 20 3z';
  const money = new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' });

  if (!grid) return;

  function createServiceCard(service) {
    const card = document.createElement('article');
    card.className = 'svc-card';

    const icon = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    icon.setAttribute('width', '30');
    icon.setAttribute('height', '30');
    icon.setAttribute('viewBox', '0 0 40 40');
    icon.setAttribute('aria-hidden', 'true');
    const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    path.setAttribute('d', iconPath);
    path.setAttribute('fill', '#0E6BAA');
    icon.append(path);

    const name = document.createElement('h3');
    name.textContent = service.name;
    const description = document.createElement('p');
    description.className = 'small';
    description.textContent = service.desc || '';
    const price = document.createElement('p');
    price.className = 'price';
    price.textContent = money.format(Number(service.price));

    card.append(icon, name, description, price);
    if (Number.isFinite(Number(service.min)) && Number(service.min) > 0) {
      const duration = document.createElement('p');
      duration.className = 'small';
      duration.textContent = `cerca de ${Number(service.min)} min`;
      card.append(duration);
    }
    return card;
  }

  function renderServices(services) {
    if (!Array.isArray(services)) {
      throw new Error('A lista de serviços salva não é válida.');
    }
    const available = services.filter(service =>
      service && service.active !== false && typeof service.name === 'string' &&
      Number.isFinite(Number(service.price)) && Number(service.price) >= 0
    );
    grid.replaceChildren();
    if (available.length === 0) {
      const message = document.createElement('p');
      message.className = 'small';
      message.textContent = 'Nenhum serviço disponível no momento.';
      grid.append(message);
      return;
    }
    available.forEach(service => grid.append(createServiceCard(service)));
  }

  function loadServices() {
    try {
      const saved = localStorage.getItem(storageKey);
      if (saved === null) return;
      const database = JSON.parse(saved);
      if (!database || !Array.isArray(database.services)) {
        throw new Error('Os dados salvos não contêm um catálogo válido.');
      }
      renderServices(database.services);
    } catch (error) {
      console.error('Não foi possível atualizar os serviços do site.', error);
    }
  }

  window.addEventListener('storage', event => {
    if (event.key === storageKey) loadServices();
  });
  loadServices();
})();
