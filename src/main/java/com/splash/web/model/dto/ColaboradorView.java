package com.splash.web.model.dto;

/**
 * DTO de leitura de um colaborador (login e listagem do admin). Só carrega dados: nunca é usado para gravar.
 * nivelAcesso fica como String porque é gravado assim na sessão (ver WebSupport.colaboradorId).
 */
public record ColaboradorView(int id, String nome, String cargo, String nivelAcesso, String email) {
    // Getters no padrão JavaBean para a EL das JSPs (${colaborador.nivelAcesso})
    public int getId() { return id; }
    public String getNome() { return nome; }
    public String getCargo() { return cargo; }
    public String getNivelAcesso() { return nivelAcesso; }
    public String getEmail() { return email; }
}
