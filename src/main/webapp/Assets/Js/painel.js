(function () {
  'use strict';

  function safeLow(str) { return String(str || '').toLowerCase().trim(); }
  function escapeHTML(str) { return String(str || '').replace(/[&<>"']/g, m => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[m])); }
  function fmtMoney(v) { return Number(v || 0).toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' }); }
  function maskCPF(v) {
    let d = String(v || '').replace(/\D/g, '').slice(0, 11);
    if (d.length > 9) return d.slice(0, 3) + '.' + d.slice(3, 6) + '.' + d.slice(6, 9) + '-' + d.slice(9);
    if (d.length > 6) return d.slice(0, 3) + '.' + d.slice(3, 6) + '.' + d.slice(6);
    if (d.length > 3) return d.slice(0, 3) + '.' + d.slice(3);
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
  function validPlate(v) {
    return /^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$/.test(
      plateValue(v)
    );
  }
  const modules = [
    { container: 'clients-table-container', form: 'form-client', add: 'btn-add-client', cancel: 'btn-cancel-client' },
    { container: 'cars-table-container', form: 'form-car', add: 'btn-add-car', cancel: 'btn-cancel-car' },
    { container: 'bookings-table-container', form: 'form-booking', add: 'btn-add-booking', cancel: 'btn-cancel-booking' },
    { container: 'services-table-container', form: 'form-service', add: 'btn-add-service', cancel: 'btn-cancel-service' },
    { container: 'collab-table-container', form: 'form-collab', add: 'btn-add-collab', cancel: 'btn-cancel-collab' },
    { container: 'queues-container' },
    { container: 'payments-container' }
  ];

  function showFormMessage(form, message) {
    let feedback = form.querySelector('[role="alert"]');
    if (!feedback) {
      feedback = document.createElement('p');
      feedback.className = 'err';
      feedback.setAttribute('role', 'alert');
      form.append(feedback);
    }
    feedback.textContent = message;
  }

  function setupClientMasks() {
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
  }

  function setupPlateMask() {
    const plateInput = document.getElementById('car-plate');
    if (!plateInput) return;

    plateInput.maxLength = 7;
    plateInput.oninput = () => {
      plateInput.value = plateValue(plateInput.value);
      plateInput.setCustomValidity(validPlate(plateInput.value)
        ? '' : 'Informe uma placa válida no formato ABC1D23.');
    };
  }

  function setupForm(module) {
    if (!module.form) return;

    const form = document.getElementById(module.form);
    const list = document.getElementById('view-list');
    const formView = document.getElementById('view-form');
    const addButton = document.getElementById(module.add);
    const cancelButton = document.getElementById(module.cancel);
    if (!form || !list || !formView) return;

    if (addButton) {
      addButton.addEventListener('click', () => {
        form.reset();
        formView.querySelectorAll('[role="alert"]').forEach(message => { message.textContent = ''; });
        [form.querySelector('#client-cpf'), form.querySelector('#client-phone'), form.querySelector('#car-plate')]
          .filter(Boolean)
          .forEach(input => input.setCustomValidity(''));
        list.classList.add('hide');
        formView.classList.remove('hide');
      });
    }
    if (cancelButton) {
      cancelButton.addEventListener('click', () => {
        formView.classList.add('hide');
        list.classList.remove('hide');
      });
    }
    form.addEventListener('submit', event => {
      const cpfInput = document.getElementById('client-cpf');
      const phoneInput = document.getElementById('client-phone');
      const plateInput = document.getElementById('car-plate');
      if (cpfInput && !validCPF(cpfInput.value)) {
        cpfInput.setCustomValidity('Informe um CPF válido com 11 dígitos.');
        cpfInput.reportValidity();
        event.preventDefault();
        return;
      }
      if (phoneInput && ![10, 11].includes(phoneDigits(phoneInput.value).length)) {
        phoneInput.setCustomValidity('Informe um telefone com DDD e 8 ou 9 dígitos.');
        phoneInput.reportValidity();
        event.preventDefault();
        return;
      }
      if (plateInput && !validPlate(plateValue(plateInput.value))) {
        plateInput.setCustomValidity('Informe uma placa válida no formato ABC1D23.');
        plateInput.reportValidity();
        event.preventDefault();
        return;
      }
      if (!form.reportValidity()) {
        event.preventDefault();
        return;
      }
      // válido: segue envio nativo do form (POST) pra servlet no atributo action.
    });
  }

  function init() {
    setupClientMasks();
    setupPlateMask();
    modules.forEach(module => setupForm(module));
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
