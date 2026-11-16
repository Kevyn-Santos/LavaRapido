
package com.splash.web.model.enums;

/**
 * Ciclo de vida do atendimento:
 * AGUARDANDO -> EM_LAVAGEM -> FINALIZADO
 */
public enum StatusAtendimento {

    AGUARDANDO,
    EM_LAVAGEM,
    FINALIZADO;

    public boolean podeIrPara(StatusAtendimento novo) {
        return switch (this) {
            case AGUARDANDO -> novo == EM_LAVAGEM;
            case EM_LAVAGEM -> novo == FINALIZADO;
            case FINALIZADO -> false;
        };
    }
}
