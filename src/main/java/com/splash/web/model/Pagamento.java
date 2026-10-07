package com.splash.web.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import com.splash.web.model.enums.FormaPagamento;
import com.splash.web.model.enums.StatusPagamento;

public class Pagamento extends EntidadeBase {

    private final BigDecimal valor;
    private FormaPagamento formaPagamento;
    private StatusPagamento status;
    private LocalDateTime dataPagamento;

    /** Novo pagamento nasce PENDENTE. */
    public Pagamento(BigDecimal valor, FormaPagamento formaPagamento) {
        this(valor, formaPagamento, StatusPagamento.PENDENTE, null);
    }

    /* Construtor completo, usado pelo DAO ao reconstruir um pagamento do banco. */
    public Pagamento(BigDecimal valor, FormaPagamento formaPagamento,
                     StatusPagamento status, LocalDateTime dataPagamento) {
        this.valor = Validacao.valorMonetario(valor, "Valor");
        this.formaPagamento = Validacao.obrigatorio(formaPagamento, "Forma de pagamento");
        this.status = Validacao.obrigatorio(status, "Status do pagamento");
        if (status == StatusPagamento.PAGO && dataPagamento == null) {
            throw new IllegalArgumentException("Pagamento com status PAGO precisa de data de pagamento.");
        }
        this.dataPagamento = dataPagamento;
    }

    public BigDecimal getValor() {
        return valor;
    }

    public FormaPagamento getFormaPagamento() {
        return formaPagamento;
    }

    public StatusPagamento getStatus() {
        return status;
    }

    /** Nula enquanto o pagamento não foi confirmado. */
    public LocalDateTime getDataPagamento() {
        return dataPagamento;
    }

    public boolean isPago() {
        return status == StatusPagamento.PAGO;
    }

    public void alterarFormaPagamento(FormaPagamento nova) {
        if (status != StatusPagamento.PENDENTE) {
            throw new IllegalStateException("A forma de pagamento só pode ser alterada enquanto o pagamento está PENDENTE.");
        }
        this.formaPagamento = Validacao.obrigatorio(nova, "Forma de pagamento");
    }

    public void confirmar(LocalDateTime agora) {
        Validacao.obrigatorio(agora, "Data do pagamento");
        mudarStatus(StatusPagamento.PAGO);
        this.dataPagamento = agora;
    }

    public void cancelar() {
        mudarStatus(StatusPagamento.CANCELADO);
    }

    private void mudarStatus(StatusPagamento novo) {
        if (!status.podeIrPara(novo)) {
            throw new IllegalStateException("Não é possível mudar o pagamento de " + status + " para " + novo + ".");
        }
        this.status = novo;
    }
}
