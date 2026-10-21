(function() {
  'use strict';

  const KEY = 'fastsplash_db_v4'; // Atualizado para forçar correção dos dados

  // ==========================================================================
  // 1. GESTÃO DO BANCO DE DADOS (Com Auto-Recuperação)
  // ==========================================================================
  function seedDB() {
    return {
      seq: 30,
      services: [
        { id: 'sv1', name: 'Lavagem Simples', desc: 'Lavagem externa com secagem à mão.', min: 30, price: 40, active: true },
        { id: 'sv2', name: 'Lavagem Completa', desc: 'Externa e interna: aspiração, painel e vidros.', min: 60, price: 70, active: true },
        { id: 'sv3', name: 'Enceramento', desc: 'Cera aplicada à mão para proteger e dar brilho.', min: 60, price: 90, active: true },
        { id: 'sv4', name: 'Detalhamento Interno', desc: 'Bancos, carpetes e plásticos com limpeza profunda.', min: 90, price: 150, active: true }
      ],
      staff: [
        { id: 's1', name: 'Ana Paula', email: 'admin@fastsplash.com', role: 'admin' },
        { id: 's2', name: 'Bruno Lima', email: 'lavador@fastsplash.com', role: 'atendente' }
      ],
      clients: [], cars: [], bookings: []
    };
  }

  function getDB() {
    const defaultDB = seedDB();
    // Tenta puxar a versão nova, ou as antigas para não perder os seus clientes cadastrados
    let data = localStorage.getItem(KEY) || localStorage.getItem('fastsplash_db_v3') || localStorage.getItem('fastsplash_db_v2');
    
    if (data) {
      try {
        let db = JSON.parse(data);
        db.clients = db.clients || [];
        db.cars = db.cars || [];
        db.bookings = db.bookings || [];
        // Se serviços ou staff estiverem vazios/corrompidos, injeta os originais para não quebrar a tela
        db.services = (db.services && db.services.length > 0) ? db.services : defaultDB.services;
        db.staff = (db.staff && db.staff.length > 0) ? db.staff : defaultDB.staff;
        db.seq = db.seq || defaultDB.seq;
        saveDB(db); // Regrava limpo
        return db;
      } catch(e) {}
    }
    saveDB(defaultDB);
    return defaultDB;
  }

  function saveDB(db) { localStorage.setItem(KEY, JSON.stringify(db)); }
  function safeLow(str) { return String(str || '').toLowerCase().trim(); }
  function escapeHTML(str) { return String(str || '').replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m])); }
  function fmtMoney(v) { return Number(v || 0).toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' }); }
  function maskCPF(v) {
    let d = String(v || '').replace(/\D/g, '').slice(0, 11);
    if (d.length > 9) return d.slice(0,3)+'.'+d.slice(3,6)+'.'+d.slice(6,9)+'-'+d.slice(9);
    if (d.length > 6) return d.slice(0,3)+'.'+d.slice(3,6)+'.'+d.slice(6);
    if (d.length > 3) return d.slice(0,3)+'.'+d.slice(3);
    return d;
  }
  function validCPF(value) {
    const digits = String(value || '').replace(/\D/g, '');
    if (digits.length !== 11 || /^(\d)\1{10}$/.test(digits)) return false;
    for (let position = 9; position <= 10; position++) {
      let sum = 0;
      for (let index = 0; index < position; index++) {
        sum += Number(digits[index]) * (position + 1 - index);
      }
      const digit = (sum * 10) % 11 % 10;
      if (digit !== Number(digits[position])) return false;
    }
    return true;
  }
  function phoneDigits(v) { return String(v || '').replace(/\D/g, '').slice(0, 11); }
  function formatPhone(v) {
    const d = phoneDigits(v);
    if (d.length <= 2) return d ? `(${d}` : '';
    const area = `(${d.slice(0, 2)}) `;
    if (d.length <= 10) {
      return area + d.slice(2, 6) + (d.length > 6 ? `-${d.slice(6)}` : '');
    }
    return area + d.slice(2, 7) + (d.length > 7 ? `-${d.slice(7)}` : '');
  }
  function plateValue(v) { return String(v || '').toUpperCase().replace(/[^A-Z0-9]/g, '').slice(0, 7); }
  function validPlate(v) { return /^[A-Z]{3}\d[A-Z]\d{2}$/.test(v); }

  // ==========================================================================
  // 2. LÓGICA DE SERVIÇOS NO AGENDAMENTO (Corrige a imagem enviada)
  // ==========================================================================
  function setupBookingForm() {
    const db = getDB();
    const clientSelect = document.getElementById('bk-client');
    const carSelect = document.getElementById('bk-car');
    const svcsContainer = document.getElementById('services-checkboxes');
    const totalEl = document.getElementById('bk-total');

    let clientSearch = document.getElementById('bk-client-search');
    let clientResults = document.getElementById('bk-client-results');
    if (clientSelect) {
      let searchField = clientSearch && clientSearch.closest('.booking-client-search');
      if (!searchField) {
        searchField = document.createElement('div');
        searchField.className = 'booking-client-search';
        if (clientSearch) searchField.append(clientSearch);
      }
      if (!clientSearch) {
        clientSearch = document.createElement('input');
        clientSearch.id = 'bk-client-search';
        clientSearch.type = 'search';
        clientSearch.placeholder = 'Digite o nome do cliente';
        clientSearch.autocomplete = 'off';
        searchField.prepend(clientSearch);
      }
      if (!clientResults) {
        clientResults = document.createElement('div');
        clientResults.id = 'bk-client-results';
        clientResults.className = 'booking-client-results';
        clientResults.setAttribute('role', 'listbox');
      }
      if (clientResults.parentElement !== searchField) searchField.append(clientResults);
      clientSearch.setAttribute('role', 'combobox');
      clientSearch.setAttribute('aria-autocomplete', 'list');
      clientSearch.setAttribute('aria-expanded', 'false');
      clientSearch.setAttribute('aria-controls', clientResults.id);
      const selectField = clientSelect.closest('label') || clientSelect;
      if (searchField.parentElement !== selectField.parentElement) {
        selectField.parentElement.insertBefore(searchField, selectField);
      }
      selectField.classList.add('hide');
      selectField.style.setProperty('display', 'none', 'important');
      clientSelect.required = false;
      if (carSelect) carSelect.required = false;
    }

    function calcTotal() {
      if (!totalEl) return;
      let sum = 0;
      document.querySelectorAll('#services-checkboxes input[type="checkbox"]:checked').forEach(chk => {
        const s = getDB().services.find(x => x.id === chk.value);
        if (s) sum += s.price;
      });
      totalEl.textContent = fmtMoney(sum);
    }

    function hideClientResults() {
      if (!clientResults) return;
      clientResults.hidden = true;
      clientSearch.setAttribute('aria-expanded', 'false');
    }

    function renderClientResults(query = '') {
      if (!clientResults) return;
      const clients = getDB().clients.filter(c => safeLow(c.name).includes(safeLow(query)));
      clientResults.replaceChildren();
      if (clients.length === 0) {
        const empty = document.createElement('p');
        empty.className = 'booking-client-empty';
        empty.textContent = query ? 'Nenhum cliente encontrado.' : 'Nenhum cliente cadastrado.';
        clientResults.append(empty);
      } else {
        clients.forEach(client => {
          const option = document.createElement('button');
          option.type = 'button';
          option.className = 'booking-client-option';
          option.setAttribute('role', 'option');
          option.textContent = client.name;
          option.onmousedown = event => event.preventDefault();
          option.addEventListener('click', () => {
            clientSelect.value = client.id;
            clientSearch.value = client.name;
            hideClientResults();
            renderClientCars();
          });
          clientResults.append(option);
        });
      }
      clientResults.hidden = false;
      clientSearch.setAttribute('aria-expanded', 'true');
    }

    function renderClientCars() {
      const cars = getDB().cars.filter(k => k.clientId === clientSelect.value);
      if (carSelect) {
        carSelect.innerHTML = cars.length
          ? '<option value="">Selecione o veículo</option>' + cars.map(k => `<option value="${escapeHTML(k.id)}">${escapeHTML(k.model)} (${escapeHTML(k.plate)})</option>`).join('')
          : `<option value="">${clientSelect.value ? 'Este cliente não possui veículos' : 'Selecione um cliente primeiro'}</option>`;
      }
    }

    if (clientSelect) {
      clientSelect.innerHTML = '<option value="">Selecione o cliente</option>' + getDB().clients.map(c => `<option value="${escapeHTML(c.id)}">${escapeHTML(c.name)}</option>`).join('');
      renderClientCars();
      if (clientSearch) {
        clientSearch.value = '';
        hideClientResults();
        clientSearch.onfocus = () => renderClientResults(clientSearch.value);
        clientSearch.oninput = () => {
          clientSelect.value = '';
          renderClientCars();
          renderClientResults(clientSearch.value);
        };
        clientSearch.onkeydown = event => {
          if (event.key === 'Escape') hideClientResults();
        };
        clientSearch.onblur = () => setTimeout(hideClientResults, 150);
      }
    }

    if (svcsContainer) {
      svcsContainer.classList.add('svc-checkboxes');
      svcsContainer.innerHTML = db.services.filter(s => s.active).map(s => `
        <label class="service-option">
          <span class="service-option-main"><input type="checkbox" name="svc" value="${escapeHTML(s.id)}"><span>${escapeHTML(s.name)}</span></span>
          <span class="service-option-price">${fmtMoney(s.price)}${Number.isFinite(Number(s.min)) ? ` · ${escapeHTML(s.min)} min` : ''}</span>
        </label>
      `).join('');
      svcsContainer.querySelectorAll('input[type="checkbox"]').forEach(chk => chk.addEventListener('change', calcTotal));
    }
    return calcTotal;
  }

  function fillBookingForm(b) {
    document.getElementById('bk-id').value = b ? b.id : '';
    const clientSearch = document.getElementById('bk-client-search');
    document.getElementById('bk-client').value = b ? b.clientId : '';
    if (clientSearch) {
      const client = getDB().clients.find(item => item.id === (b && b.clientId));
      clientSearch.value = client ? client.name : '';
    }
    document.getElementById('bk-car').innerHTML = '<option value="">Selecione o cliente primeiro</option>';
    if (b && document.getElementById('bk-client').value) {
      const car = getDB().cars.find(item => item.id === b.carId);
      const clientCars = getDB().cars.filter(item => item.clientId === b.clientId);
      document.getElementById('bk-car').innerHTML = '<option value="">Selecione o veículo</option>' + clientCars.map(item => `<option value="${escapeHTML(item.id)}">${escapeHTML(item.model)} (${escapeHTML(item.plate)})</option>`).join('');
      if (car) document.getElementById('bk-car').value = car.id;
    }
    document.getElementById('bk-date').value = b ? b.date : '';
    document.getElementById('bk-slot').value = b ? b.slot : '';

    document.querySelectorAll('#services-checkboxes input[type="checkbox"]').forEach(chk => {
      chk.checked = b ? (b.services || []).includes(chk.value) : false;
    });
  }

  // ==========================================================================
  // 3. MÓDULO: CLIENTES
  // ==========================================================================
  function initClients() {
    const container = document.getElementById('clients-table-container'); if (!container) return;
    const viewList = document.getElementById('view-list'), viewForm = document.getElementById('view-form'), form = document.getElementById('form-client'), inputSearch = document.getElementById('input-search');
    const phoneInput = document.getElementById('client-phone');
    const cpfInput = document.getElementById('client-cpf');

    if (phoneInput) {
      phoneInput.type = 'tel';
      phoneInput.maxLength = 15;
      phoneInput.inputMode = 'numeric';
      phoneInput.placeholder = '(11) 99999-0000';
      phoneInput.oninput = () => {
        phoneInput.value = formatPhone(phoneInput.value);
        const digits = phoneDigits(phoneInput.value);
        phoneInput.setCustomValidity(digits.length === 10 || digits.length === 11
          ? '' : 'Informe um telefone com DDD e 8 ou 9 dígitos.');
      };
    }
    if (cpfInput) {
      cpfInput.type = 'text';
      cpfInput.maxLength = 14;
      cpfInput.inputMode = 'numeric';
      cpfInput.placeholder = '000.000.000-00';
      cpfInput.oninput = () => {
        const caret = cpfInput.selectionStart || 0;
        const digitsBeforeCaret = cpfInput.value.slice(0, caret).replace(/\D/g, '').length;
        const formatted = maskCPF(cpfInput.value);
        cpfInput.value = formatted;
        let nextCaret = 0;
        let digitCount = 0;
        while (nextCaret < formatted.length && digitCount < digitsBeforeCaret) {
          if (/\d/.test(formatted[nextCaret])) digitCount++;
          nextCaret++;
        }
        cpfInput.setSelectionRange(nextCaret, nextCaret);
        cpfInput.setCustomValidity(validCPF(cpfInput.value)
          ? '' : 'Informe um CPF válido com 11 dígitos.');
      };
    }

    function render(q = '') {
      const db = getDB(), query = safeLow(q); const clients = db.clients.filter(c => safeLow(c.name).includes(query) || safeLow(c.cpf).includes(query));
      if (clients.length === 0) { container.innerHTML = `<div class="empty" style="padding: 32px; border: 1.5px dashed var(--line); border-radius: 6px; text-align: center; margin-top: 16px;"><p class="q" style="font-size: 1.5rem;">Nenhum cliente cadastrado.</p><button class="btn sm" type="button" onclick="document.getElementById('btn-add-client').click()">Novo cliente</button></div>`; return; }
      container.innerHTML = `<div class="tbl"><div class="trow thead" style="grid-template-columns: 1.5fr 1fr 1.4fr auto;"><div>Cliente</div><div>Telefone</div><div>Carros</div><div>Ações</div></div>${clients.map(c => `
        <div class="trow" style="grid-template-columns: 1.5fr 1fr 1.4fr auto;">
          <div data-l="Cliente"><b>${escapeHTML(c.name)}</b><div class="small">${escapeHTML(c.email)}</div></div>
          <div data-l="Telefone">${escapeHTML(c.phone)}</div><div data-l="Carros"><span class="small">Gerenciado em Carros</span></div>
          <div data-l="Ações"><div class="acts"><button type="button" class="btn ghost sm" data-edit-c="${c.id}">Editar</button><button type="button" class="btn danger sm" data-del-c="${c.id}">Remover</button></div></div>
        </div>`).join('')}</div>`;
      container.querySelectorAll('[data-edit-c]').forEach(btn => btn.onclick = () => openForm(getDB().clients.find(x => x.id === btn.dataset.editC)));
      container.querySelectorAll('[data-del-c]').forEach(btn => btn.onclick = () => { if (confirm('Remover cliente?')) { const db = getDB(); db.clients = db.clients.filter(x => x.id !== btn.dataset.delC); saveDB(db); render(inputSearch ? inputSearch.value : ''); } });
    }

    function openForm(c = null) {
      if (form) form.reset();
      if (cpfInput) cpfInput.setCustomValidity('');
      if (phoneInput) phoneInput.setCustomValidity('');
      document.getElementById('form-title').textContent = c ? 'Editar cliente' : 'Novo cliente';
      if(c) { document.getElementById('client-id').value = c.id; document.getElementById('client-name').value = c.name; document.getElementById('client-cpf').value = maskCPF(c.cpf); cpfInput.setCustomValidity(validCPF(cpfInput.value) ? '' : 'Informe um CPF válido com 11 dígitos.'); document.getElementById('client-phone').value = c.phone; document.getElementById('client-email').value = c.email; } else { document.getElementById('client-id').value = ''; }
      viewList.classList.add('hide'); viewForm.classList.remove('hide');
    }

    document.getElementById('btn-add-client').onclick = () => openForm();
    document.getElementById('btn-cancel-client').onclick = () => { viewForm.classList.add('hide'); viewList.classList.remove('hide'); };
    if (inputSearch) inputSearch.oninput = () => render(inputSearch.value);
    
    if (form) form.onsubmit = e => {
      e.preventDefault(); const db = getDB(); const id = document.getElementById('client-id').value;
      const phone = phoneInput ? formatPhone(phoneInput.value) : '';
      if (phoneInput && phoneDigits(phone).length !== 10 && phoneDigits(phone).length !== 11) {
        phoneInput.setCustomValidity('Informe um telefone com DDD e 8 ou 9 dígitos.');
        phoneInput.reportValidity();
        return;
      }
      const cpf = cpfInput ? cpfInput.value.replace(/\D/g, '') : '';
      if (cpfInput && !validCPF(cpf)) {
        cpfInput.setCustomValidity('Informe um CPF válido com 11 dígitos.');
        cpfInput.reportValidity();
        return;
      }
      const data = { name: document.getElementById('client-name').value.trim(), cpf, phone, email: document.getElementById('client-email').value.trim() };
      if (id) { const idx = db.clients.findIndex(x => x.id === id); if (idx !== -1) db.clients[idx] = { ...db.clients[idx], ...data }; } else { db.clients.push({ id: 'c' + (++db.seq), ...data }); }
      saveDB(db); viewForm.classList.add('hide'); viewList.classList.remove('hide'); render(inputSearch ? inputSearch.value : '');
    };
    render();
  }

  // ==========================================================================
  // 4. MÓDULO: CARROS
  // ==========================================================================
  function initCars() {
    const container = document.getElementById('cars-table-container'); if (!container) return;
    const viewList = document.getElementById('view-list'), viewForm = document.getElementById('view-form'), form = document.getElementById('form-car'), inputSearch = document.getElementById('input-search');
    const plateInput = document.getElementById('car-plate');

    if (plateInput) {
      plateInput.maxLength = 7;
      plateInput.inputMode = 'text';
      plateInput.autocomplete = 'off';
      plateInput.placeholder = 'ABC1D23';
      plateInput.pattern = '[A-Z]{3}[0-9][A-Z][0-9]{2}';
      plateInput.oninput = () => {
        plateInput.value = plateValue(plateInput.value);
        plateInput.setCustomValidity(!plateInput.value || validPlate(plateInput.value)
          ? '' : 'Informe uma placa Mercosul válida, no formato ABC1D23.');
      };
    }

    function render(q = '') {
      const db = getDB(); const cars = db.cars.filter(k => safeLow(k.model).includes(safeLow(q)) || safeLow(k.plate).includes(safeLow(q)));
      if (cars.length === 0) { container.innerHTML = `<div class="empty" style="padding: 32px; border: 1.5px dashed var(--line); border-radius: 6px; text-align: center; margin-top: 16px;"><p class="q" style="font-size: 1.5rem;">Nenhum carro cadastrado.</p><button class="btn sm" type="button" onclick="document.getElementById('btn-add-car').click()">Novo carro</button></div>`; return; }
      container.innerHTML = `<div class="tbl"><div class="trow thead" style="grid-template-columns: 1.4fr .8fr 1.2fr auto;"><div>Carro</div><div>Placa</div><div>Cliente</div><div>Ações</div></div>${cars.map(k => {
        const client = db.clients.find(c => c.id === k.clientId);
        return `<div class="trow" style="grid-template-columns: 1.4fr .8fr 1.2fr auto;"><div data-l="Carro"><b>${escapeHTML(k.model)}</b><div class="small">${escapeHTML(k.color)}</div></div><div data-l="Placa">${escapeHTML(k.plate)}</div><div data-l="Cliente">${escapeHTML(client ? client.name : 'Removido')}</div><div data-l="Ações"><div class="acts"><button type="button" class="btn ghost sm" data-edit-k="${k.id}">Editar</button><button type="button" class="btn danger sm" data-del-k="${k.id}">Remover</button></div></div></div>`;
      }).join('')}</div>`;
      container.querySelectorAll('[data-edit-k]').forEach(btn => btn.onclick = () => openForm(getDB().cars.find(x => x.id === btn.dataset.editK)));
      container.querySelectorAll('[data-del-k]').forEach(btn => btn.onclick = () => { if (confirm('Remover veículo?')) { const db = getDB(); db.cars = db.cars.filter(x => x.id !== btn.dataset.delK); saveDB(db); render(inputSearch ? inputSearch.value : ''); } });
    }

    function openForm(k = null) {
      if (form) form.reset(); const db = getDB(), cs = document.getElementById('car-client');
      if (cs) cs.innerHTML = '<option value="">Selecione o cliente</option>' + db.clients.map(c => `<option value="${c.id}">${escapeHTML(c.name)}</option>`).join('');
      if (k) { document.getElementById('form-title').textContent = 'Editar carro'; document.getElementById('car-id').value = k.id; cs.value = k.clientId; document.getElementById('car-model').value = k.model; document.getElementById('car-color').value = k.color; document.getElementById('car-plate').value = plateValue(k.plate); } else { document.getElementById('form-title').textContent = 'Novo carro'; document.getElementById('car-id').value = ''; }
      viewList.classList.add('hide'); viewForm.classList.remove('hide');
    }

    document.getElementById('btn-add-car').onclick = () => openForm();
    document.getElementById('btn-cancel-car').onclick = () => { viewForm.classList.add('hide'); viewList.classList.remove('hide'); };
    if (inputSearch) inputSearch.oninput = () => render(inputSearch.value);
    
    if (form) form.onsubmit = e => {
      e.preventDefault(); const db = getDB(); const id = document.getElementById('car-id').value;
      const plate = plateInput ? plateValue(plateInput.value) : '';
      if (plateInput && !validPlate(plate)) {
        plateInput.setCustomValidity('Informe uma placa Mercosul válida, no formato ABC1D23.');
        plateInput.reportValidity();
        return;
      }
      const data = { clientId: document.getElementById('car-client').value, model: document.getElementById('car-model').value.trim(), color: document.getElementById('car-color').value.trim(), plate };
      if (id) { const idx = db.cars.findIndex(x => x.id === id); if (idx !== -1) db.cars[idx] = { ...db.cars[idx], ...data }; } else { db.cars.push({ id: 'k' + (++db.seq), ...data }); }
      saveDB(db); viewForm.classList.add('hide'); viewList.classList.remove('hide'); render(inputSearch ? inputSearch.value : '');
    };
    render();
  }

  // ==========================================================================
  // 5. MÓDULO: AGENDAMENTOS E FILA DE ATENDIMENTOS
  // ==========================================================================
  function initBookingsQueue() {
    const isBooking = document.getElementById('bookings-table-container');
    const isQueue = document.getElementById('queues-container');
    if (!isBooking && !isQueue) return;

    const viewList = document.getElementById('view-list'), viewForm = document.getElementById('view-form'), form = document.getElementById('form-booking'), inputSearch = document.getElementById('input-search'), formError = document.getElementById('form-error');

    function renderBookings(q = '') {
      if (!isBooking) return;
      const db = getDB(); const query = safeLow(q);
      const list = db.bookings.filter(b => { const c = db.clients.find(x => x.id === b.clientId); return safeLow(c ? c.name : '').includes(query); });

      if (list.length === 0) {
        isBooking.innerHTML = `<div class="empty" style="padding: 32px; border: 1.5px dashed var(--line); border-radius: 6px; text-align: center; margin-top: 16px;"><p class="q" style="font-size: 1.5rem;">Nenhum agendamento.</p><button class="btn sm" type="button" onclick="document.getElementById('btn-add-booking').click()">Novo agendamento</button></div>`; return;
      }

      isBooking.innerHTML = `<div class="tbl"><div class="trow thead" style="grid-template-columns: 1.2fr 1.2fr 1.3fr 1.2fr .7fr auto;"><div>Cliente</div><div>Carro</div><div>Serviço</div><div>Data/Hora</div><div>Preço</div><div>Ações</div></div>${list.map(b => {
        const client = db.clients.find(c => c.id === b.clientId), car = db.cars.find(k => k.id === b.carId);
        const svcs = (b.services || []).map(sid => { const s = db.services.find(x => x.id === sid); return s ? s.name : ''; }).filter(Boolean).join(', ');
        const totalPrice = (b.services || []).reduce((acc, sid) => { const s = db.services.find(x => x.id === sid); return acc + (s ? s.price : 0); }, 0);
        return `<div class="trow" style="grid-template-columns: 1.2fr 1.2fr 1.3fr 1.2fr .7fr auto;"><div data-l="Cliente"><b>${escapeHTML(client ? client.name : 'Removido')}</b></div><div data-l="Carro">${escapeHTML(car ? `${car.model} (${car.plate})` : 'Removido')}</div><div data-l="Serviço">${escapeHTML(svcs || 'Nenhum')}</div><div data-l="Data">${b.date} às ${b.slot}</div><div data-l="Preço"><b>${fmtMoney(totalPrice)}</b></div><div data-l="Ações"><div class="acts"><button type="button" class="btn ghost sm" data-edit-b="${b.id}">Editar</button>${b.status === 'agendado' ? `<button type="button" class="btn danger sm" data-cancel-b="${b.id}">Cancelar</button>` : ''}</div></div></div>`;
      }).join('')}</div>`;
      isBooking.querySelectorAll('[data-edit-b]').forEach(btn => btn.onclick = () => openForm(getDB().bookings.find(x => x.id === btn.dataset.editB)));
      isBooking.querySelectorAll('[data-cancel-b]').forEach(btn => btn.onclick = () => { if (confirm('Cancelar este agendamento?')) { const db = getDB(); const b = db.bookings.find(x => x.id === btn.dataset.cancelB); if (b) b.status = 'cancelado'; saveDB(db); renderBookings(inputSearch ? inputSearch.value : ''); } });
    }

    function renderQueue() {
      if (!isQueue) return;
      const db = getDB();
      const activeBookings = db.bookings.filter(b => bookingStatus(b) !== 'cancelado');
      const inProgress = activeBookings.filter(b => bookingStatus(b) === 'andamento');
      const waiting = activeBookings.filter(b => bookingStatus(b) === 'agendado');
      const done = activeBookings.filter(b => bookingStatus(b) === 'concluido');
      function cardHTML(b, type) {
        const client = db.clients.find(c => c.id === b.clientId), car = db.cars.find(k => k.id === b.carId);
        const svcs = (b.services || []).map(sid => { const s = db.services.find(x => x.id === sid); return s ? s.name : ''; }).filter(Boolean).join(', ');
        const totalPrice = (b.services || []).reduce((acc, sid) => { const s = db.services.find(x => x.id === sid); return acc + (s ? s.price : 0); }, 0);
        const action = type === 'run'
          ? `<button type="button" class="btn" data-finish="${escapeHTML(b.id)}">Concluir atendimento</button>`
          : type === 'wait'
            ? `<button type="button" class="btn" data-start="${escapeHTML(b.id)}">Iniciar atendimento</button>`
            : '';
        return `<article class="atc ${type === 'run' ? 'run' : ''}"><div><b>${escapeHTML(client ? client.name : 'Removido')}</b><div class="small">${escapeHTML(b.date || '')}</div></div><div>${escapeHTML(car ? `${car.model} (${car.plate})` : 'Removido')}<div class="small" style="color:var(--primary); font-weight:600;">${escapeHTML(svcs || 'Sem serviço')}</div></div><div class="at-t"><span>Hora</span><b>${escapeHTML(b.slot || '')}</b><span>Total</span><b style="color:var(--lamp);">${fmtMoney(totalPrice)}</b></div><div class="acts"><a class="btn ghost sm" href="painel-agendamentos.jsp">Editar agendamento</a>${action}</div></article>`;
      }
      const group = (title, items, type) => `<div class="grp"><h3>${title}</h3>${items.length ? items.map(b => cardHTML(b, type)).join('') : '<p class="empty">Nenhum atendimento nesta etapa.</p>'}</div>`;
      isQueue.innerHTML = group('Em andamento', inProgress, 'run')
        + group('Aguardando', waiting, 'wait')
        + group('Concluídos', done, 'done');
      isQueue.querySelectorAll('[data-start]').forEach(btn => btn.onclick = () => {
        const db = getDB();
        const booking = db.bookings.find(item => item.id === btn.dataset.start);
        if (booking) {
          booking.status = 'andamento';
          saveDB(db);
          renderQueue();
        }
      });
      isQueue.querySelectorAll('[data-finish]').forEach(btn => btn.onclick = () => {
        const db = getDB();
        const booking = db.bookings.find(item => item.id === btn.dataset.finish);
        if (booking) {
          booking.status = 'concluido';
          saveDB(db);
          renderQueue();
        }
      });
    }

    function openForm(b = null) {
      if (form) form.reset(); if (formError) formError.textContent = '';
      const calcTotalFn = setupBookingForm(); // Sempre reconstrói os serviços ao abrir o form
      fillBookingForm(b); calcTotalFn();
      viewList.classList.add('hide'); viewForm.classList.remove('hide');
    }

    const btnAdd = document.getElementById('btn-add-booking'); if (btnAdd) btnAdd.onclick = () => openForm();
    const btnCancel = document.getElementById('btn-cancel-booking'); if (btnCancel) btnCancel.onclick = () => { viewForm.classList.add('hide'); viewList.classList.remove('hide'); };
    if (inputSearch) inputSearch.oninput = () => renderBookings(inputSearch.value);

    if (form) form.onsubmit = e => {
      e.preventDefault(); const db = getDB(); const id = document.getElementById('bk-id').value;
      const clientId = document.getElementById('bk-client').value;
      const carId = document.getElementById('bk-car').value;
      if (!clientId) {
        if (formError) formError.textContent = 'Pesquise e selecione um cliente.';
        document.getElementById('bk-client-search').focus();
        return;
      }
      if (!carId) {
        if (formError) formError.textContent = 'Selecione um veículo do cliente.';
        document.getElementById('bk-car').focus();
        return;
      }
      const selectedSvcs = Array.from(document.querySelectorAll('input[name="svc"]:checked')).map(i => i.value);
      if (selectedSvcs.length === 0) { if (formError) formError.textContent = 'Escolha pelo menos 1 serviço.'; return; }
      const data = { clientId, carId, date: document.getElementById('bk-date').value, slot: document.getElementById('bk-slot').value, services: selectedSvcs };
      if (id) { const idx = db.bookings.findIndex(x => x.id === id); if (idx !== -1) db.bookings[idx] = { ...db.bookings[idx], ...data }; } else { db.bookings.push({ id: 'b' + (++db.seq), status: 'agendado', pay: null, ...data }); }
      saveDB(db); viewForm.classList.add('hide'); viewList.classList.remove('hide'); 
      if (isBooking) renderBookings(inputSearch ? inputSearch.value : ''); else renderQueue();
    };
    if (isBooking) renderBookings(); else renderQueue();
  }

  function bookingStatus(booking) {
    const status = safeLow(booking.status).replace(/[\s-]+/g, '_');
    if (['cancelado', 'cancelada', 'canceled', 'cancelled'].includes(status)) return 'cancelado';
    if (['andamento', 'em_andamento', 'em_lavagem', 'in_progress'].includes(status)) return 'andamento';
    if (['concluido', 'concluida', 'finalizado', 'finalizada', 'entregue', 'completed', 'done'].includes(status)) return 'concluido';
    return 'agendado';
  }

  // ==========================================================================
  // 6. MÓDULO: PAGAMENTOS
  // ==========================================================================
  function initPayments() {
    const container = document.getElementById('payments-container');
    if (!container) return;

    const pendingTotal = document.getElementById('sum-pending');
    const receivedTotal = document.getElementById('sum-received');
    const methods = [
      ['pix', 'Pix'],
      ['dinheiro', 'Dinheiro'],
      ['credito', 'Cartão de crédito'],
      ['debito', 'Cartão de débito']
    ];

    function paid(booking) {
      const payment = booking.pay;
      return Boolean(payment && (payment.status === 'pago' || payment.status === 'paid'));
    }

    function render() {
      const db = getDB();
      const bookings = db.bookings.filter(booking => bookingStatus(booking) !== 'cancelado');
      const amount = booking => (booking.services || []).reduce((total, serviceId) => {
        const service = db.services.find(item => item.id === serviceId);
        return total + (service ? Number(service.price) || 0 : 0);
      }, 0);
      const received = bookings.filter(paid).reduce((sum, booking) => sum + amount(booking), 0);
      const pending = bookings.filter(booking => !paid(booking)).reduce((sum, booking) => sum + amount(booking), 0);

      if (pendingTotal) pendingTotal.textContent = fmtMoney(pending);
      if (receivedTotal) receivedTotal.textContent = fmtMoney(received);

      if (bookings.length === 0) {
        container.innerHTML = '<div class="empty"><p class="q">Ainda não há pagamentos.</p><p>Crie um agendamento para que ele apareça aqui.</p><a class="btn sm" href="painel-agendamentos.jsp">Ir para agendamentos</a></div>';
        return;
      }

      const columns = '1.2fr 1.2fr 1.5fr .9fr .8fr 1fr auto';
      const rows = bookings.map(booking => {
        const client = db.clients.find(item => item.id === booking.clientId);
        const car = db.cars.find(item => item.id === booking.carId);
        const serviceNames = (booking.services || [])
          .map(id => db.services.find(item => item.id === id))
          .filter(Boolean)
          .map(service => service.name)
          .join(', ');
        const bookingAmount = amount(booking);
        const payment = booking.pay;
        const method = methods.find(([key]) => key === (payment && payment.method));
        const paymentStatus = paid(booking)
          ? `<span class="badge pago">Pago${method ? ` — ${method[1]}` : ''}</span>`
          : '<span class="badge agendado">Pendente</span>';
        const action = paid(booking)
          ? ''
          : `<form class="payment-form" data-payment-form="${escapeHTML(booking.id)}"><label class="hide" for="payment-method-${escapeHTML(booking.id)}">Forma de pagamento</label><select id="payment-method-${escapeHTML(booking.id)}" name="method" required><option value="">Forma de pagamento</option>${methods.map(([key, label]) => `<option value="${key}">${label}</option>`).join('')}</select><button type="submit" class="btn sm">Registrar</button></form>`;
        return `<div class="trow" style="grid-template-columns:${columns}"><div data-l="Cliente"><b>${escapeHTML(client ? client.name : 'Removido')}</b></div><div data-l="Veículo">${escapeHTML(car ? `${car.model} (${car.plate})` : 'Removido')}</div><div data-l="Serviços">${escapeHTML(serviceNames || 'Sem serviços')}</div><div data-l="Data/hora">${escapeHTML(booking.date || '')} ${escapeHTML(booking.slot || '')}</div><div data-l="Valor"><b>${fmtMoney(bookingAmount)}</b></div><div data-l="Pagamento">${paymentStatus}</div><div data-l="Ação">${action || '—'}</div></div>`;
      });

      container.innerHTML = `<div class="tbl"><div class="trow thead" style="grid-template-columns:${columns}"><div>Cliente</div><div>Veículo</div><div>Serviços</div><div>Data/hora</div><div>Valor</div><div>Pagamento</div><div>Ação</div></div>${rows.join('')}</div>`;
      container.querySelectorAll('[data-payment-form]').forEach(form => {
        form.addEventListener('submit', event => {
          event.preventDefault();
          const bookingId = form.dataset.paymentForm;
          const method = new FormData(form).get('method');
          if (!methods.some(([key]) => key === method)) {
            form.querySelector('select').reportValidity();
            return;
          }
          const latestDb = getDB();
          const booking = latestDb.bookings.find(item => item.id === bookingId);
          if (!booking) {
            render();
            return;
          }
          booking.pay = { status: 'pago', method, paidAt: new Date().toISOString() };
          saveDB(latestDb);
          render();
        });
      });
    }

    render();
  }

  // ==========================================================================
  // 6. MÓDULO: SERVIÇOS E PREÇOS
  // ==========================================================================
  function initServices() {
    const container = document.getElementById('services-table-container'); if (!container) return;
    const viewList = document.getElementById('view-list'), viewForm = document.getElementById('view-form'), form = document.getElementById('form-service');
    function render() {
      const db = getDB(); container.innerHTML = `<div class="tbl"><div class="trow thead" style="grid-template-columns: 1.8fr .7fr .7fr .7fr auto;"><div>Serviço</div><div>Duração</div><div>Preço</div><div>Status</div><div>Ações</div></div>${db.services.map(s => `<div class="trow" style="grid-template-columns: 1.8fr .7fr .7fr .7fr auto;"><div data-l="Serviço"><b>${escapeHTML(s.name)}</b><div class="small">${escapeHTML(s.desc)}</div></div><div data-l="Duração">${s.min} min</div><div data-l="Preço"><b>${fmtMoney(s.price)}</b></div><div data-l="Status"><span class="badge ${s.active ? 'pago' : 'cancelado'}">${s.active ? 'Ativo' : 'Inativo'}</span></div><div data-l="Ações"><div class="acts"><button type="button" class="btn ghost sm" data-edit-sv="${s.id}">Editar</button><button type="button" class="btn danger sm" data-tog-sv="${s.id}">${s.active ? 'Desativar' : 'Ativar'}</button></div></div></div>`).join('')}</div>`;
      container.querySelectorAll('[data-edit-sv]').forEach(btn => btn.onclick = () => openForm(getDB().services.find(x => x.id === btn.dataset.editSv)));
      container.querySelectorAll('[data-tog-sv]').forEach(btn => btn.onclick = () => { const db = getDB(); const s = db.services.find(x => x.id === btn.dataset.togSv); if (s) { s.active = !s.active; saveDB(db); render(); } });
    }
    function openForm(s = null) {
      if (form) form.reset(); document.getElementById('form-title').textContent = s ? 'Editar Serviço' : 'Novo Serviço';
      if (s) { document.getElementById('svc-id').value = s.id; document.getElementById('svc-name').value = s.name; document.getElementById('svc-desc').value = s.desc; document.getElementById('svc-min').value = s.min; document.getElementById('svc-price').value = s.price; } else { document.getElementById('svc-id').value = ''; }
      viewList.classList.add('hide'); viewForm.classList.remove('hide');
    }
    document.getElementById('btn-add-service').onclick = () => openForm();
    document.getElementById('btn-cancel-service').onclick = () => { viewForm.classList.add('hide'); viewList.classList.remove('hide'); };
    if (form) form.onsubmit = e => {
      e.preventDefault(); const db = getDB(); const id = document.getElementById('svc-id').value; const data = { name: document.getElementById('svc-name').value.trim(), desc: document.getElementById('svc-desc').value.trim(), min: parseInt(document.getElementById('svc-min').value, 10), price: parseFloat(document.getElementById('svc-price').value) };
      if (id) { const idx = db.services.findIndex(x => x.id === id); if (idx !== -1) db.services[idx] = { ...db.services[idx], ...data }; } else { db.services.push({ id: 'sv' + (++db.seq), active: true, ...data }); } saveDB(db); viewForm.classList.add('hide'); viewList.classList.remove('hide'); render();
    };
    render();
  }

  // ==========================================================================
  // 7. MÓDULO: COLABORADORES
  // ==========================================================================
  function initCollab() {
    const container = document.getElementById('collab-table-container'); if (!container) return;
    const viewList = document.getElementById('view-list'), viewForm = document.getElementById('view-form'), form = document.getElementById('form-collab');
    function render() {
      const db = getDB(); container.innerHTML = `<div class="tbl"><div class="trow thead" style="grid-template-columns: 1.6fr 1fr auto;"><div>Colaborador</div><div>Acesso</div><div>Ações</div></div>${db.staff.map(s => `<div class="trow" style="grid-template-columns: 1.6fr 1fr auto;"><div data-l="Colaborador"><b>${escapeHTML(s.name)}</b><div class="small">${escapeHTML(s.email)}</div></div><div data-l="Acesso"><span class="role ${s.role}">${s.role === 'admin' ? 'Administrador' : 'Atendente'}</span></div><div data-l="Ações"><div class="acts"><button type="button" class="btn ghost sm" data-edit-s="${s.id}">Editar</button><button type="button" class="btn danger sm" data-del-s="${s.id}">Remover</button></div></div></div>`).join('')}</div>`;
      container.querySelectorAll('[data-edit-s]').forEach(btn => btn.onclick = () => openForm(getDB().staff.find(x => x.id === btn.dataset.editS)));
      container.querySelectorAll('[data-del-s]').forEach(btn => btn.onclick = () => { const db = getDB(); if (db.staff.length <= 1) { alert('Não pode remover o único colaborador.'); return; } if (confirm('Remover?')) { db.staff = db.staff.filter(x => x.id !== btn.dataset.delS); saveDB(db); render(); } });
    }
    function openForm(s = null) {
      if (form) form.reset(); document.getElementById('form-title').textContent = s ? 'Editar Colaborador' : 'Novo Colaborador';
      if (s) { document.getElementById('collab-id').value = s.id; document.getElementById('collab-name').value = s.name; document.getElementById('collab-email').value = s.email; document.getElementById('collab-role').value = s.role; } else { document.getElementById('collab-id').value = ''; }
      viewList.classList.add('hide'); viewForm.classList.remove('hide');
    }
    document.getElementById('btn-add-collab').onclick = () => openForm();
    document.getElementById('btn-cancel-collab').onclick = () => { viewForm.classList.add('hide'); viewList.classList.remove('hide'); };
    if (form) form.onsubmit = e => {
      e.preventDefault(); const db = getDB(); const id = document.getElementById('collab-id').value; const data = { name: document.getElementById('collab-name').value.trim(), email: document.getElementById('collab-email').value.trim(), role: document.getElementById('collab-role').value };
      if (id) { const idx = db.staff.findIndex(x => x.id === id); if (idx !== -1) db.staff[idx] = { ...db.staff[idx], ...data }; } else { db.staff.push({ id: 's' + (++db.seq), ...data }); } saveDB(db); viewForm.classList.add('hide'); viewList.classList.remove('hide'); render();
    };
    render();
  }

  // ==========================================================================
  // INICIALIZAÇÃO
  // ==========================================================================
  function initAll() { initClients(); initCars(); initBookingsQueue(); initPayments(); initCollab(); initServices(); }
  if (document.readyState === 'loading') { document.addEventListener('DOMContentLoaded', initAll); } else { initAll(); }
})();