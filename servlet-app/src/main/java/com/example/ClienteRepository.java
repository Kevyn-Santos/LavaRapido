package com.example;

import java.sql.SQLException;

final class ClienteRepository {

    private ClienteRepository() {
    }

    static void cadastrar(String nome, String cpf, String telefone, String email, String senha)
            throws SQLException {
        LavaRapidoRepository.cadastrarCliente(nome, cpf, telefone, email, senha);
    }

    static LavaRapidoRepository.Cliente obterPorId(int idCliente) throws SQLException {
        return LavaRapidoRepository.obterClientePorId(idCliente);
    }

    static void atualizar(int idCliente, String nome, String telefone, String email, String novaSenha)
            throws SQLException {
        LavaRapidoRepository.atualizarCliente(idCliente, nome, telefone, email, novaSenha);
    }

    static boolean excluir(int idCliente, String senha) throws SQLException {
        return LavaRapidoRepository.excluirCliente(idCliente, senha);
    }

    static boolean possuiAgendamentoPendente(int idCliente) throws SQLException {
        return LavaRapidoRepository.clientePossuiAgendamentoPendente(idCliente);
    }

    static LavaRapidoRepository.Cliente autenticar(String email, String senha) throws SQLException {
        return LavaRapidoRepository.autenticarCliente(email, senha);
    }
}
