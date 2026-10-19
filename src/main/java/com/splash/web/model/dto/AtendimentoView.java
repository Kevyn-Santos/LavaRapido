package com.splash.web.model.dto;

import java.time.LocalDate;

/**
 * DTO de leitura de um atendimento (listagem do admin): junta cliente, veículo, agendamento e os
 * colaboradores (GROUP_CONCAT). Só carrega dados: nunca é usado para gravar.
 */
public record AtendimentoView(int id, int idAgendamento, String cliente, String placa, LocalDate data,
        String horario, String status, String statusAgendamento, String colaboradores,
        String idsColaboradores) {
    // Getters no padrão JavaBean para a EL das JSPs (${atendimento.cliente})
    public int getId() { return id; }
    public int getIdAgendamento() { return idAgendamento; }
    public String getCliente() { return cliente; }
    public String getPlaca() { return placa; }
    public LocalDate getData() { return data; }
    public String getHorario() { return horario; }
    public String getStatus() { return status; }
    public String getStatusAgendamento() { return statusAgendamento; }
    public String getColaboradores() { return colaboradores; }
    public String getIdsColaboradores() { return idsColaboradores; }
}
