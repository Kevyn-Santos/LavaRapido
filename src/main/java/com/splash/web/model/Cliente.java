package com.splash.web.model;

<<<<<<< HEAD
public class Cliente {
    private int id_cliente;
    private String name;
=======
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class Cliente extends Pessoa {

    private final String cpf;
>>>>>>> cf40a05 (feat: adiciona modelos do domínio)
    private String telefone;
    private final List<Veiculo> veiculos = new ArrayList<>();

<<<<<<< HEAD
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
=======
    public Cliente(String nome, String cpf, String telefone, String email, String senhaHash) {
        super(nome, email, senhaHash);
        this.cpf = Validacao.cpf(cpf);
        this.telefone = Validacao.telefone(telefone);
    }

    public String getCpf() {
        return cpf;
>>>>>>> cf40a05 (feat: adiciona modelos do domínio)
    }

    public String getTelefone() {
        return telefone;
    }

    public void setTelefone(String telefone) {
        this.telefone = Validacao.telefone(telefone);
    }

    /* Único caminho para criar um Veiculo garante que todo veículo pertence a um cliente e aparece na lista dele.*/
    public Veiculo cadastrarVeiculo(String placa, String marca, String modelo, String cor) {
        if (possuiVeiculoComPlaca(placa)) {
            throw new IllegalArgumentException("Este cliente já possui um veículo com essa placa.");
        }
        Veiculo veiculo = new Veiculo(this, placa, marca, modelo, cor);
        veiculos.add(veiculo);
        return veiculo;
    }

    public boolean possuiVeiculoComPlaca(String placa) {
        String normalizada = Validacao.placa(placa);
        return veiculos.stream().anyMatch(v -> v.getPlaca().equals(normalizada));
    }

    public List<Veiculo> getVeiculos() {
        return Collections.unmodifiableList(veiculos);
    }
}
