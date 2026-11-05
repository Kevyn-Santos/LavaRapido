(() => {
    const name = document.getElementById('collaborator-name');
    const initials = document.getElementById('collaborator-initials');
    const greeting = document.getElementById('dashboard-greeting');
    const date = document.getElementById('dashboard-date');
    const now = new Date();
    const hour = now.getHours();
    const collaboratorName = name ? name.textContent.trim() : '';

    if (initials) {
      const nameParts = collaboratorName.split(/\s+/).filter(Boolean);
      initials.textContent = [nameParts[0], nameParts[nameParts.length - 1]]
        .filter(Boolean)
        .map(part => part.charAt(0).toLocaleUpperCase('pt-BR'))
        .join('');
    }

    if (greeting) {
      greeting.textContent = hour < 12 ? 'Bom dia' : hour < 18 ? 'Boa tarde' : 'Boa noite';
    }

    if (date) {
      const formattedDate = new Intl.DateTimeFormat('pt-BR', {
        weekday: 'long',
        day: 'numeric',
        month: 'long'
      }).format(now);
      date.textContent = formattedDate.replace(/(^|[\s-])\p{L}/gu, value => value.toLocaleUpperCase('pt-BR'));
    }
  })();