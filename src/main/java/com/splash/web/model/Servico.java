package com.splash.web.model;

import java.math.BigDecimal;

public class Servico extends EntidadeBase {

    private String nome;
    private String descricao;
    private BigDecimal preco;

    public Servico(String nome, String descricao, BigDecimal preco) {
        setNome(nome);
        setDescricao(descricao);
        setPreco(preco);
    }

    public String getNome() {
        return nome;
    }

    public final void setNome(String nome) {
        this.nome = Validacao.textoObrigatorio(nome, "Nome do serviço", 100);
    }

    /** Opcional: pode ser nula. */
    public String getDescricao() {
        return descricao;
    }

    public final void setDescricao(String descricao) {
        this.descricao = Validacao.textoOpcional(descricao, "Descrição", 255);
    }

    public BigDecimal getPreco() {
        return preco;
    }

    public final void setPreco(BigDecimal preco) {
        this.preco = Validacao.valorMonetario(preco, "Preço");
    }
}
