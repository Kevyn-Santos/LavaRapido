package com.splash.web.model;

import java.math.BigDecimal;

/**
 * Serviço contratado dentro de um agendamento tabela agendamento_servico.
 * Guarda o valor praticado na hora da contratação, então uma mudança futura
 * no preço do Servico não altera agendamentos antigos. Imutável.
 * */
public class ItemAgendamento {

    private final Servico servico;
    private final BigDecimal valorPraticado;

    /** Usa o preço atual do serviço. */
    public ItemAgendamento(Servico servico) {
        this(servico, Validacao.obrigatorio(servico, "Serviço").getPreco());
    }

    /** Usado também ao reconstruir o item a partir do banco. */
    public ItemAgendamento(Servico servico, BigDecimal valorPraticado) {
        this.servico = Validacao.obrigatorio(servico, "Serviço");
        this.valorPraticado = Validacao.valorMonetario(valorPraticado, "Valor praticado");
    }

    public Servico getServico() {
        return servico;
    }

    public BigDecimal getValorPraticado() {
        return valorPraticado;
    }
}
