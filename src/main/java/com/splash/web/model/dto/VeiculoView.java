package com.splash.web.model.dto;

/**
 * DTO de leitura de um veículo do cliente. Só carrega dados: nunca é usado para gravar.
 */
public record VeiculoView(int id, String placa, String marca, String modelo, String cor) {
    // Getters no padrão JavaBean para a EL das JSPs (${veiculo.placa})
    public int getId() { return id; }
    public String getPlaca() { return placa; }
    public String getMarca() { return marca; }
    public String getModelo() { return modelo; }
    public String getCor() { return cor; }
}
