package com.splash.web.model;

public class Cliente {
    private int id_cliente;
    private String name;
    private String telefone;
    private String email;
    private String senha;
    private String cpf;

    public int getId_cliente() {
        return id_cliente;
    }

    public void setId_cliente(int id) {
        this.id_cliente = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String nome) {
        this.name = nome;
    }

    public String getTelefone() {
        return telefone;
    }

    public void setTelefone(String telefone) {
        this.telefone = telefone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getSenha() {
        return senha;
    }

    public void setSenha(String senha) {
        this.senha = senha;
    }

    public String getCpf() {
        return cpf;
    }

    public void setCpf(String cpf) {
        this.cpf = cpf;
    }


}
