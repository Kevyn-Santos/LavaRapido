package com.splash.web.model.dto;

/**
 * DTO de leitura do cliente autenticado (login). Só carrega dados: nunca é usado para gravar.
 */
public record ClienteView(int id, String nome, String email) {
    // Getters no padrão JavaBean para a EL das JSPs (${cliente.nome})
    public int getId() { return id; }
    public String getNome() { return nome; }
    public String getEmail() { return email; }
}
