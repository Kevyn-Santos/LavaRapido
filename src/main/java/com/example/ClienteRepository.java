package com.example;

import java.sql.SQLException;

final class ClienteRepository {

    private ClienteRepository() {
    }

    static void cadastrar(String nome, String cpf, String telefone, String email, String senha)
            throws SQLException {
        LavaRapidoRepository.cadastrarCliente(nome, cpf, telefone, email, senha);
    }

    static LavaRapidoRepository.Cliente autenticar(String email, String senha) throws SQLException {
        return LavaRapidoRepository.autenticarCliente(email, senha);
    }
}
