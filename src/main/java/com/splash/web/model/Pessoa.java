package com.splash.web.model;

/**
 * Dados comuns a quem acessa o sistema Cliente e Colaborador.*/
public abstract class Pessoa extends EntidadeBase {

    private String nome;
    private String email;
    private String senhaHash;

    protected Pessoa(String nome, String email, String senhaHash) {
        setNome(nome);
        setEmail(email);
        setSenhaHash(senhaHash);
    }

    public String getNome() {
        return nome;
    }

    public final void setNome(String nome) {
        this.nome = Validacao.textoObrigatorio(nome, "Nome", 100);
    }

    public String getEmail() {
        return email;
    }

    public final void setEmail(String email) {
        this.email = Validacao.email(email);
    }

    public String getSenhaHash() {
        return senhaHash;
    }

    public final void setSenhaHash(String senhaHash) {
        this.senhaHash = Validacao.textoObrigatorio(senhaHash, "Senha (hash)", 255);
    }
}
