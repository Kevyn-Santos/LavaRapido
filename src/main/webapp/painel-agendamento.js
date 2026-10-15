const STORAGE_KEY = "fastSplashAgendamentos";
const form = document.querySelector("#booking-form");

if (form) {
  const client = document.querySelector("#booking-client");
  const date = document.querySelector("#booking-date");
  const time = document.querySelector("#booking-time");
  const services = [...form.querySelectorAll('input[name="svc"]')];
  const summaryClient = document.querySelector("#summary-client");
  const summaryServices = document.querySelector("#summary-services");
  const summaryPrice = document.querySelector("#summary-price");
  const summaryDate = document.querySelector("#summary-date");
  const summaryTime = document.querySelector("#summary-time");
  const feedback = document.querySelector("#booking-feedback");
  const createButton = document.querySelector("#create-booking");
  const money = new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" });
  const today = new Date();
  const localToday = new Date(today.getTime() - today.getTimezoneOffset() * 60000)
    .toISOString()
    .slice(0, 10);
  date.min = localToday;

  const selectedServices = () => services
    .filter((service) => service.checked)
    .map((service) => ({
      label: service.dataset.label,
      price: Number(service.dataset.price),
    }));

  const formattedDate = (value) => {
    if (!value) return "Escolha o dia";
    const [year, month, day] = value.split("-").map(Number);
    return new Intl.DateTimeFormat("pt-BR").format(new Date(year, month - 1, day));
  };

  const updateSummary = () => {
    const selectedClient = client.selectedOptions[0];
    const chosenServices = selectedServices();
    const total = chosenServices.reduce((sum, service) => sum + service.price, 0);

    summaryClient.textContent = selectedClient.dataset.name || "Nome do cliente";
    summaryServices.textContent = chosenServices.length
      ? chosenServices.map((service) => service.label).join(" + ")
      : "Selecione um ou mais serviços";
    summaryPrice.textContent = `Total - ${money.format(total)}`;
    summaryDate.textContent = formattedDate(date.value);
    summaryTime.textContent = time.value || "Escolha o horário";
  };

  const handleFormChange = () => {
    updateSummary();
    createButton.disabled = false;
    createButton.textContent = "Criar agendamento";
    feedback.textContent = "";
    feedback.classList.remove("error");
  };
  form.addEventListener("input", handleFormChange);
  form.addEventListener("change", handleFormChange);

  createButton.addEventListener("click", () => {
    if (!form.reportValidity()) return;

    const chosenServices = selectedServices();
    if (!chosenServices.length) {
      feedback.textContent = "Selecione pelo menos um serviço para continuar.";
      feedback.classList.add("error");
      services[0].focus();
      return;
    }

    const selectedClient = client.selectedOptions[0];
    const booking = {
      id: `${Date.now()}-${Math.random().toString(36).slice(2)}`,
      client: selectedClient.dataset.name,
      car: selectedClient.dataset.car,
      services: chosenServices,
      total: chosenServices.reduce((sum, service) => sum + service.price, 0),
      date: date.value,
      time: time.value,
      status: "Agendado",
    };

    try {
      const saved = JSON.parse(localStorage.getItem(STORAGE_KEY) || "[]");
      if (!Array.isArray(saved)) throw new Error("Dados de agendamento inválidos.");
      saved.push(booking);
      localStorage.setItem(STORAGE_KEY, JSON.stringify(saved));
      feedback.textContent = "Agendamento criado. Ele já aparece na página de agendamentos.";
      feedback.classList.remove("error");
      createButton.textContent = "Agendamento criado";
      createButton.disabled = true;
    } catch (error) {
      feedback.textContent = `Não foi possível salvar o agendamento: ${error.message}`;
      feedback.classList.add("error");
    }
  });

  updateSummary();
}

const createdBookings = document.querySelector("#created-bookings");
if (createdBookings) {
  try {
    const saved = JSON.parse(localStorage.getItem(STORAGE_KEY) || "[]");
    if (!Array.isArray(saved)) throw new Error("Dados de agendamento inválidos.");

    for (const booking of saved) {
      if (!booking || typeof booking.client !== "string" ||
          typeof booking.date !== "string" || typeof booking.time !== "string" ||
          !Array.isArray(booking.services)) {
        throw new Error("Há um agendamento salvo com dados incompletos.");
      }

      const card = document.createElement("article");
      card.className = "booking-card";

      const clientDetails = document.createElement("div");
      clientDetails.className = "booking-client";
      const clientName = document.createElement("b");
      clientName.textContent = booking.client;
      const car = document.createElement("span");
      car.textContent = booking.car || "";
      clientDetails.append(clientName, car);

      const serviceDetails = document.createElement("div");
      serviceDetails.className = "booking-service";
      const serviceNames = document.createElement("b");
      serviceNames.textContent = booking.services.map((service) => service.label).join(" + ");
      const price = document.createElement("span");
      price.textContent = `${new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(booking.total)} — ${booking.status || "Agendado"}`;
      serviceDetails.append(serviceNames, price);

      const dateTime = document.createElement("div");
      dateTime.className = "booking-client";
      const dateLabel = document.createElement("b");
      const [year, month, day] = booking.date.split("-").map(Number);
      dateLabel.textContent = new Intl.DateTimeFormat("pt-BR").format(new Date(year, month - 1, day));
      const timeLabel = document.createElement("span");
      timeLabel.textContent = booking.time;
      dateTime.append(dateLabel, timeLabel);

      card.append(clientDetails, serviceDetails, dateTime);
      createdBookings.append(card);
    }
  } catch (error) {
    const message = document.createElement("p");
    message.className = "booking-feedback";
    message.classList.add("error");
    message.textContent = `Não foi possível carregar os agendamentos criados: ${error.message}`;
    createdBookings.append(message);
  }
}
