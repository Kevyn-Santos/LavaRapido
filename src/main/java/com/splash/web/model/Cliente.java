package com.splash.web.model;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class Cliente extends Pessoa {

    private int id_cliente;
    private String cpf;
    private String telefone;
    private final List<Veiculo> veiculos = new ArrayList<>();

    public Cliente(String nome, String cpf, String telefone, String email, String senhaHash) {
        super(nome, email, senhaHash);
        this.cpf = Validacao.cpf(cpf);
        this.telefone = Validacao.telefone(telefone);
    }

    public Cliente() {
        super();
    }

    /* Reconstrói um cliente vindo do banco: os dados já foram validados na gravação, então não são revalidados.
       Um registro fora do padrão no banco não deve derrubar a leitura. Para dados novos, use o construtor completo ou os setters. */
    public static Cliente carregar(int id, String nome, String cpf, String telefone, String email) {
        Cliente cliente = new Cliente();
        cliente.carregarDadosPessoa(nome, email);
        cliente.setId(id);
        cliente.id_cliente = id;
        cliente.cpf = cpf;
        cliente.telefone = telefone;
        return cliente;
    }

    public int getId_cliente() {
        return id_cliente;
    }

    public void setId_cliente(int id) {
        this.id_cliente = id;
    }

    public void setCPF(String cpf) {
        this.cpf = Validacao.cpf(cpf);
    }

    public String getCpf() {
        return cpf;
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
