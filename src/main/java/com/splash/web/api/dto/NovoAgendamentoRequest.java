package com.splash.web.api.dto;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

/** Corpo de {@code POST /api/v1/agendamentos}. */
public record NovoAgendamentoRequest(int idVeiculo, LocalDate data, LocalTime horario, List<Integer> idsServicos) {
}
