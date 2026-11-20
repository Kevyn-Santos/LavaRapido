package com.splash.web.model.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/**
 * DTO de leitura de um agendamento do cliente: junta veículo, total dos serviços (SUM) e pagamento.
 * {@code servicos} traz cada serviço do agendamento com o nome e o <b>valor praticado</b> na época (campo
 * {@code preco} do {@link ServicoView}, não o preço atual do catálogo; {@code descricao} vem null).
 * Só carrega dados: nunca é usado para gravar.
 */
public record AgendamentoView(int id_agendamento, int id_veiculo, List<Integer> id_servico, String placa, String veiculo, LocalDate data, String horario,
        String status, BigDecimal total, String statusPagamento, String formaPagamento, String statusAtendimento,
        List<ServicoView> servicos) {
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
    /** Etapa da lavagem (AGUARDANDO, EM_LAVAGEM, FINALIZADO, ENTREGUE); null se o agendamento não tem atendimento. */
    public String getStatusAtendimento() { return statusAtendimento; }
    /** Serviços do agendamento (id, nome e valor praticado); lista vazia se não houver. */
    public List<ServicoView> getServicos() { return servicos; }
}
