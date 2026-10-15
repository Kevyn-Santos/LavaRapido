package com.splash.web.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import com.splash.web.model.enums.StatusAgendamento;

public class Agendamento extends EntidadeBase {

    private final Veiculo veiculo;
    private LocalDate data;
    private LocalTime horario;
    private StatusAgendamento status;
    private final List<ItemAgendamento> itens = new ArrayList<>();

    /*Novo agendamento nasce AGENDADO e sem servicos. */
    public Agendamento(Veiculo veiculo, LocalDate data, LocalTime horario) {
        this(veiculo, data, horario, StatusAgendamento.AGENDADO, List.of());
    }

    
    public Agendamento(Veiculo veiculo, LocalDate data, LocalTime horario,
                       StatusAgendamento status, List<ItemAgendamento> itens) {
        this.veiculo = Validacao.obrigatorio(veiculo, "Veículo");
        this.data = Validacao.obrigatorio(data, "Data");
        this.horario = Validacao.obrigatorio(horario, "Horário");
        this.status = Validacao.obrigatorio(status, "Status");
        Validacao.obrigatorio(itens, "Itens").forEach(this::incluirItem);
    }

    //consultas 

    public Veiculo getVeiculo() {
        return veiculo;
    }

    public LocalDate getData() {
        return data;
    }

    public LocalTime getHorario() {
        return horario;
    }

    public StatusAgendamento getStatus() {
        return status;
    }

    public List<ItemAgendamento> getItens() {
        return Collections.unmodifiableList(itens);
    }

    public BigDecimal calcularTotal() {
        return itens.stream()
                .map(ItemAgendamento::getValorPraticado)
                .reduce(BigDecimal.ZERO.setScale(2), BigDecimal::add);
    }

    /* A regra "não agendar no passado" fica para o service que informa o "agora". */
    public boolean estaNoPassado(LocalDateTime agora) {
        return LocalDateTime.of(data, horario).isBefore(Validacao.obrigatorio(agora, "Momento atual"));
    }

    //comportamento 

    public void adicionarServico(Servico servico) {
        exigirAgendado("adicionar serviços");
        incluirItem(new ItemAgendamento(servico));
    }

    public void adicionarServico(Servico servico, BigDecimal valorPraticado) {
        exigirAgendado("adicionar serviços");
        incluirItem(new ItemAgendamento(servico, valorPraticado));
    }

    public void removerServico(Servico servico) {
        exigirAgendado("remover serviços");
        Validacao.obrigatorio(servico, "Serviço");
        boolean removido = itens.removeIf(i -> mesmoServico(i.getServico(), servico));
        if (!removido) {
            throw new IllegalArgumentException("O serviço não faz parte deste agendamento.");
        }
    }

    public void reagendar(LocalDate novaData, LocalTime novoHorario) {
        exigirAgendado("reagendar");
        this.data = Validacao.obrigatorio(novaData, "Data");
        this.horario = Validacao.obrigatorio(novoHorario, "Horário");
    }

    public void cancelar() {
        mudarStatus(StatusAgendamento.CANCELADO);
    }

    public void concluir() {
        mudarStatus(StatusAgendamento.CONCLUIDO);
    }

    //internos 

    private void incluirItem(ItemAgendamento item) {
        Validacao.obrigatorio(item, "Item");
        boolean duplicado = itens.stream().anyMatch(i -> mesmoServico(i.getServico(), item.getServico()));
        if (duplicado) {
            throw new IllegalArgumentException("Este serviço já foi adicionado ao agendamento.");
        }
        itens.add(item);
    }

    private static boolean mesmoServico(Servico a, Servico b) {
        return a == b || (a.getId() != null && a.getId().equals(b.getId()));
    }

    private void mudarStatus(StatusAgendamento novo) {
        if (!status.podeIrPara(novo)) {
            throw new IllegalStateException("Não é possível mudar o agendamento de " + status + " para " + novo + ".");
        }
        this.status = novo;
    }

    private void exigirAgendado(String acao) {
        if (status != StatusAgendamento.AGENDADO) {
            throw new IllegalStateException("Só é possível " + acao + " em agendamentos com status AGENDADO.");
        }
    }
}
