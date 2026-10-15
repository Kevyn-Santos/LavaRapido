package com.splash.web.model.enums;

/* Ciclo de vida do agendamento AGENDADO -> CANCELADO | CONCLUIDO*/
public enum StatusAgendamento {
    AGENDADO,
    CANCELADO,
    CONCLUIDO;

    public boolean podeIrPara(StatusAgendamento novo) {
        return switch (this) {
            case AGENDADO -> novo == CANCELADO || novo == CONCLUIDO;
            case CANCELADO, CONCLUIDO -> false;
        };
    }
}
