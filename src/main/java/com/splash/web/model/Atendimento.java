package com.splash.web.model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import com.splash.web.model.enums.FormaPagamento;
import com.splash.web.model.enums.StatusAgendamento;
import com.splash.web.model.enums.StatusAtendimento;

public class Atendimento extends EntidadeBase {

    private final Agendamento agendamento;
    private StatusAtendimento status;
    private LocalDateTime dataInicio;
    private LocalDateTime dataFim;
    private final List<Colaborador> colaboradores = new ArrayList<>();
    private Pagamento pagamento;

    /* Novo atendimento só pode ser aberto para um agendamento AGENDADO e nasce AGUARDANDO. */
    public Atendimento(Agendamento agendamento) {
        this(exigirAgendamentoAtivo(agendamento), StatusAtendimento.AGUARDANDO, null, null, List.of(), null);
    }

    /** Construtor completo usado pelo DAO ao reconstruir um atendimento do banco. */
    public Atendimento(Agendamento agendamento, StatusAtendimento status,
                       LocalDateTime dataInicio, LocalDateTime dataFim,
                       List<Colaborador> colaboradores, Pagamento pagamento) {
        this.agendamento = Validacao.obrigatorio(agendamento, "Agendamento");
        this.status = Validacao.obrigatorio(status, "Status do atendimento");
        if (dataInicio != null && dataFim != null && dataFim.isBefore(dataInicio)) {
            throw new IllegalArgumentException("A data de fim não pode ser anterior à data de início.");
        }
        this.dataInicio = dataInicio;
        this.dataFim = dataFim;
        Validacao.obrigatorio(colaboradores, "Colaboradores").forEach(this::incluirColaborador);
        this.pagamento = pagamento;
    }

    //consultas 

    public Agendamento getAgendamento() {
        return agendamento;
    }

    public StatusAtendimento getStatus() {
        return status;
    }

    public LocalDateTime getDataInicio() {
        return dataInicio;
    }

    public LocalDateTime getDataFim() {
        return dataFim;
    }

    public List<Colaborador> getColaboradores() {
        return Collections.unmodifiableList(colaboradores);
    }

    /**Nulo enquanto nenhum pagamento foi gerado. */
    public Pagamento getPagamento() {
        return pagamento;
    }

    public boolean temPagamento() {
        return pagamento != null;
    }

    // comportamento

    public void atribuirColaborador(Colaborador colaborador) {
        if (status == StatusAtendimento.ENTREGUE) {
            throw new IllegalStateException("Não é possível atribuir colaboradores a um atendimento já ENTREGUE.");
        }
        incluirColaborador(colaborador);
    }

    public void iniciarLavagem(LocalDateTime agora) {
        Validacao.obrigatorio(agora, "Momento do início");
        mudarStatus(StatusAtendimento.EM_LAVAGEM);
        this.dataInicio = agora;
    }

    public void finalizar(LocalDateTime agora) {
        Validacao.obrigatorio(agora, "Momento da finalização");
        if (dataInicio != null && agora.isBefore(dataInicio)) {
            throw new IllegalArgumentException("A finalização não pode ser anterior ao início da lavagem.");
        }
        mudarStatus(StatusAtendimento.FINALIZADO);
        this.dataFim = agora;
    }

    /** Ao entregar o veícul o agendamento correspondente é concluído. */
    public void entregar() {
        mudarStatus(StatusAtendimento.ENTREGUE);
        if (agendamento.getStatus() == StatusAgendamento.AGENDADO) {
            agendamento.concluir();
        }
    }

    /** Gera o pagamento PENDENTE com o total do agendamento Só pode existir um por atendimento. */
    public Pagamento gerarPagamento(FormaPagamento forma) {
        if (pagamento != null) {
            throw new IllegalStateException("Este atendimento já possui pagamento.");
        }
        this.pagamento = new Pagamento(agendamento.calcularTotal(), forma);
        return pagamento;
    }

    // internos 

    private void incluirColaborador(Colaborador colaborador) {
        Validacao.obrigatorio(colaborador, "Colaborador");
        boolean duplicado = colaboradores.stream().anyMatch(c -> mesmoColaborador(c, colaborador));
        if (duplicado) {
            throw new IllegalArgumentException("Este colaborador já está atribuído ao atendimento.");
        }
        colaboradores.add(colaborador);
    }

    private static boolean mesmoColaborador(Colaborador a, Colaborador b) {
        return a == b || (a.getId() != null && a.getId().equals(b.getId()));
    }

    private void mudarStatus(StatusAtendimento novo) {
        if (!status.podeIrPara(novo)) {
            throw new IllegalStateException("Não é possível mudar o atendimento de " + status + " para " + novo + ".");
        }
        this.status = novo;
    }

    private static Agendamento exigirAgendamentoAtivo(Agendamento agendamento) {
        Validacao.obrigatorio(agendamento, "Agendamento");
        if (agendamento.getStatus() != StatusAgendamento.AGENDADO) {
            throw new IllegalStateException("Só é possível abrir um atendimento para um agendamento com status AGENDADO.");
        }
        return agendamento;
    }
}
