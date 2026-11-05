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

    feedback.textContent = "A integração com a API REST ainda não está disponível. O agendamento não foi enviado nem salvo.";
    feedback.classList.add("error");
  });

  updateSummary();
}

const createdBookings = document.querySelector("#created-bookings");
if (createdBookings) {
  const message = document.createElement("p");
  message.className = "booking-feedback";
  message.textContent = "Os agendamentos serão carregados pela API REST.";
  createdBookings.append(message);
}
