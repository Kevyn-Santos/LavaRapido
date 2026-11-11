package com.splash.web.db;

import com.splash.web.model.dto.VeiculoView;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO que realiza o CRUD na tabela {@code veiculo}
 */
public class DAOVeiculo {

    /*--------------------------------------
    Listagem de veículos
    --------------------------------------*/

    public List<VeiculoView> listarPorCliente(int idCliente) throws SQLException {
        String sql = """
                SELECT id_veiculo, placa, marca, modelo, cor
                FROM veiculo
                WHERE id_cliente = ?
                  AND ativo = TRUE
                ORDER BY placa
                """;
        List<VeiculoView> veiculos = new ArrayList<>();
        try (Connection connection = DatabaseConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, idCliente);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    veiculos.add(new VeiculoView(result.getInt("id_veiculo"), result.getString("placa"),
                            result.getString("marca"), result.getString("modelo"), result.getString("cor")));
                }
            }
        }
        return veiculos;
    }

    /*--------------------------------------
    Inserção de veículos
    --------------------------------------*/

    public void inserir(int idCliente, String placa, String marca, String modelo, String cor)
            throws SQLException {
        String sql = """
                INSERT INTO veiculo (id_cliente, placa, marca, modelo, cor)
                SELECT id_cliente, ?, ?, ?, ?
                FROM cliente
                WHERE id_cliente = ?
                  AND ativo = TRUE
                """;
        try (Connection connection = DatabaseConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, placa.trim().toUpperCase());
            statement.setString(2, marca.trim());
            statement.setString(3, modelo.trim());
            statement.setString(4, cor == null || cor.isBlank() ? null : cor.trim());
            statement.setInt(5, idCliente);

            if (statement.executeUpdate() != 1) {
                throw new IllegalArgumentException(
                        "Cliente não encontrado ou inativo.");
            }
        }
    }

    /*--------------------------------------
    Update de veículos
    --------------------------------------*/

    // Nenhuma operação de update de veículo ainda

    public boolean atualizar(int idCliente, int idVeiculo,
            String placa, String marca, String modelo, String cor)
            throws SQLException {

        String sql = """
                UPDATE veiculo v
                JOIN cliente c
                    ON c.id_cliente = v.id_cliente
                SET v.placa = ?,
                    v.marca = ?,
                    v.modelo = ?,
                    v.cor = ?
                WHERE v.id_veiculo = ?
                  AND v.id_cliente = ?
                  AND v.ativo = TRUE
                  AND c.ativo = TRUE
                """;

        try (Connection connection = DatabaseConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, placa);
            statement.setString(2, marca);
            statement.setString(3, modelo);
            statement.setString(4, cor.isBlank() ? null : cor);
            statement.setInt(5, idVeiculo);
            statement.setInt(6, idCliente);

            return statement.executeUpdate() == 1;
        }
    }

    /*--------------------------------------
    Remoção de veículos
    --------------------------------------*/

    public boolean remover(int idCliente, int idVeiculo) throws SQLException {

        if (idCliente <= 0 || idVeiculo <= 0) {
            throw new IllegalArgumentException(
                    "Cliente ou veículo inválido.");
        }

        String sql = """
                UPDATE veiculo
                SET ativo = FALSE,
                    excluido_em = CURRENT_TIMESTAMP
                WHERE id_cliente = ?
                  AND id_veiculo = ?
                  AND ativo = TRUE
                """;

        try (Connection connection = DatabaseConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, idCliente);
            statement.setInt(2, idVeiculo);

            return statement.executeUpdate() == 1;
        }
    }
}
