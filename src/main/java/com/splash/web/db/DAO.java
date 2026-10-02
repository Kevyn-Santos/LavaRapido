package com.splash.web.db;
/*
+ Importa a conexão, modelo, sql
+ Crie a função desejada colocando o modelo como parametro
+ Crie um SQL correspondente para a tabela(String sql).
+ Em um try:
    Crie a conexão,
    Crie um stmt com a query SQL
    defina o valor dos campos com: stmt.set_Tipo_de_Dado(id_param, value_param)
    Execute a operação com stmt.executeUpdate();

    para recuperação de valores adicione:
     + 'ResultSet rs = stmt.executequery()' para armazenar os resultados de resposta.
     + a criação de collections apropriados para os tipos de retorno
     + inclua os valores na collection
     + Retorne a collection
+ Pegue as exceptions com um catch.

Stmt é um container assim como request, ele armazena todas as informações passadas e executa todas de uma vez
 */


import com.splash.web.model.Cliente;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DAO {

    public void insertUsuario(Cliente cliente) throws SQLException {
        String sql = "INSERT INTO cliente (nome, cpf, telefone, email, senha_hash) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, cliente.getName());
            stmt.setString(2, cliente.getCpf());
            stmt.setString(3, cliente.getTelefone());
            stmt.setString(4, cliente.getEmail());
            stmt.setString(5, cliente.getSenha());
            stmt.executeUpdate();
        } catch (SQLException e) {
            throw new SQLException(e);
        }
    }

    public List<Cliente> getUsuarios() throws SQLException {
        String sql = "SELECT id_cliente, nome, cpf, telefone, email FROM cliente";
        List<Cliente> listaclientes = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Cliente client = new Cliente();
                client.setId_cliente(rs.getInt("id_cliente"));
                client.setName(rs.getString("nome"));
                client.setCpf(rs.getString("cpf"));
                client.setTelefone(rs.getString("telefone"));
                client.setEmail(rs.getString("email"));
                listaclientes.add(client);
            }
        }
        return listaclientes;
    }

}
