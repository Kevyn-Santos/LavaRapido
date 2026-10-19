package com.splash.web.model.dto;

import java.math.BigDecimal;

/**
 * DTO de leitura de um serviço do catálogo. Só carrega dados: nunca é usado para gravar.
 */
public record ServicoView(int id, String nome, String descricao, BigDecimal preco) {
    // Getters no padrão JavaBean para a EL das JSPs (${servico.id})
    public int getId() { return id; }
    public String getNome() { return nome; }
    public String getDescricao() { return descricao; }
    public BigDecimal getPreco() { return preco; }
}
