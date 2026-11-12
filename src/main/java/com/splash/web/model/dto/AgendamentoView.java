package com.splash.web.model.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/**
 * DTO de leitura de um agendamento do cliente: junta veículo, total dos serviços (SUM) e pagamento.
 * Só carrega dados: nunca é usado para gravar.
 */
public record AgendamentoView(int id_agendamento, int id_veiculo, List<Integer> id_servico, String placa, String veiculo, LocalDate data, String horario,
        String status, BigDecimal total, String statusPagamento, String formaPagamento) {
    // Getters no padrão JavaBean para a EL das JSPs (${agendamento.total})
    public int getIdAgendamento() { return id_agendamento; }
    public int getidVeiculo() { return id_veiculo; }
    public List<Integer> getIdServico() { return id_servico; }
    public String getPlaca() { return placa; }
    public String getVeiculo() { return veiculo; }
    public LocalDate getData() { return data; }
    public String getHorario() { return horario; }
    public String getStatus() { return status; }
    public BigDecimal getTotal() { return total; }
    public String getStatusPagamento() { return statusPagamento; }
    public String getFormaPagamento() { return formaPagamento; }
}
