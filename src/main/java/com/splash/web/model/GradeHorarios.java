package com.splash.web.model;

import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

/**
 * Grade de horários de agendamento: de 06:00 a 17:30, de 30 em 30 minutos (24 horários; 18:00 é o
 * fechamento). Há um agendamento por horário. Usada por {@code DAOAgendamento} e pela API
 * ({@code GET /api/v1/horarios}). Registro: miscelaneous/horarios-api-mobile.md.
 */
public final class GradeHorarios {

    public static final LocalTime ABERTURA = LocalTime.of(6, 0);
    public static final LocalTime ULTIMO = LocalTime.of(17, 30);
    public static final int INTERVALO_MINUTOS = 30;

    /** Formato {@code HH:mm} usado na API. */
    public static final DateTimeFormatter FORMATO = DateTimeFormatter.ofPattern("HH:mm");

    private GradeHorarios() {
    }

    /** Todos os horários da grade, em ordem. */
    public static List<LocalTime> todos() {
        List<LocalTime> horarios = new ArrayList<>();
        for (LocalTime h = ABERTURA; !h.isAfter(ULTIMO); h = h.plusMinutes(INTERVALO_MINUTOS)) {
            horarios.add(h);
        }
        return horarios;
    }

    public static boolean valido(LocalTime horario) {
        return !horario.isBefore(ABERTURA) && !horario.isAfter(ULTIMO)
                && horario.getSecond() == 0 && horario.getNano() == 0
                && horario.getMinute() % INTERVALO_MINUTOS == 0;
    }

    /**
     * Converte {@code HH:mm} (ou {@code HH:mm:ss}, como o MySQL devolve) em {@link LocalTime}.
     *
     * @throws IllegalArgumentException se o texto não for um horário ou estiver fora da grade
     */
    public static LocalTime interpretar(String texto) {
        LocalTime horario;
        try {
            horario = LocalTime.parse(texto == null ? "" : texto.trim());
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("Horário inválido. Use o formato HH:mm.");
        }
        if (!valido(horario)) {
            throw new IllegalArgumentException("Horário fora da grade (06:00 a 17:30, de 30 em 30 minutos).");
        }
        return horario;
    }
}
