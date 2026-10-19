package com.splash.web.model.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * DTO de leitura de um pagamento (listagem do admin): junta cliente, veículo e agendamento.
 * Só carrega dados: nunca é usado para gravar.
 */
public record PagamentoView(int id, int idAgendamento, String cliente, String placa, LocalDate data,
        String horario, BigDecimal valor, String forma, String status) {
    // Getters no padrão JavaBean para a EL das JSPs (${pagamento.forma})
    public int getId() { return id; }
    public int getIdAgendamento() { return idAgendamento; }
    public String getCliente() { return cliente; }
    public String getPlaca() { return placa; }
    public LocalDate getData() { return data; }
    public String getHorario() { return horario; }
    public BigDecimal getValor() { return valor; }
    public String getForma() { return forma; }
    public String getStatus() { return status; }
}
