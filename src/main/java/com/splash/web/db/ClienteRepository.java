package com.splash.web.db;

import com.splash.web.model.dto.ClienteView;

import java.sql.SQLException;

public final class ClienteRepository {

    private ClienteRepository() {
    }

    static void cadastrar(String nome, String cpf, String telefone, String email, String senha)
            throws SQLException {
        LavaRapidoRepository.cadastrarCliente(nome, cpf, telefone, email, senha);
    }

    public static ClienteView autenticar(String email, String senha) throws SQLException {
        return LavaRapidoRepository.autenticarCliente(email, senha);
    }
}
