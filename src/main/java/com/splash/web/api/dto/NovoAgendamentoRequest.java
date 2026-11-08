package com.splash.web.api.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

/** Corpo de {@code POST /api/v1/agendamentos}. */
public record NovoAgendamentoRequest(
        int idagendamento, int idVeiculo,
        LocalDate data, LocalTime horario,
        List<Integer> idsServicos,
        BigDecimal total,
        String statusPagamento, String formaPagamento
        ) {
}
