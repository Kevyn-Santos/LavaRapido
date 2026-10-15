package com.splash.web.model;

public class Veiculo extends EntidadeBase {

    private final Cliente cliente;
    private String placa;
    private String marca;
    private String modelo;
    private String cor;

    /** Construtor restrito ao pacote: use Cliente.cadastrarVeiculo(...). */
    Veiculo(Cliente cliente, String placa, String marca, String modelo, String cor) {
        this.cliente = Validacao.obrigatorio(cliente, "Cliente");
        setPlaca(placa);
        setMarca(marca);
        setModelo(modelo);
        setCor(cor);
    }

    public Cliente getCliente() {
        return cliente;
    }

    public String getPlaca() {
        return placa;
    }

    public final void setPlaca(String placa) {
        this.placa = Validacao.placa(placa);
    }

    public String getMarca() {
        return marca;
    }

    public final void setMarca(String marca) {
        this.marca = Validacao.textoObrigatorio(marca, "Marca", 60);
    }

    public String getModelo() {
        return modelo;
    }

    public final void setModelo(String modelo) {
        this.modelo = Validacao.textoObrigatorio(modelo, "Modelo", 60);
    }

    /** Opcional: pode ser nula. */
    public String getCor() {
        return cor;
    }

    public final void setCor(String cor) {
        this.cor = Validacao.textoOpcional(cor, "Cor", 30);
    }

    public String getDescricao() {
        return marca + " " + modelo + " (" + placa + ")";
    }
}
