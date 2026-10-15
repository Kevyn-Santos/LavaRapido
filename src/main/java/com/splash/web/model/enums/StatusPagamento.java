package com.splash.web.model.enums;

 /* Ciclo de vida do pagamentoPENDENTE -> PAGO | CANCELADO (estados finais).*/
public enum StatusPagamento {
    PENDENTE,
    PAGO,
    CANCELADO;

    public boolean podeIrPara(StatusPagamento novo) {
        return switch (this) {
            case PENDENTE -> novo == PAGO || novo == CANCELADO;
            case PAGO, CANCELADO -> false;
        };
    }
}
