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
        String sql = "SELECT id_veiculo, placa, marca, modelo, cor FROM veiculo "
                + "WHERE id_cliente = ? ORDER BY placa";
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
        String sql = "INSERT INTO veiculo (id_cliente, placa, marca, modelo, cor) VALUES (?, ?, ?, ?, ?)";
        try (Connection connection = DatabaseConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, idCliente);
            statement.setString(2, placa.trim().toUpperCase());
            statement.setString(3, marca.trim());
            statement.setString(4, modelo.trim());
            statement.setString(5, cor == null || cor.isBlank() ? null : cor.trim());
            statement.executeUpdate();
        }
    }

    /*--------------------------------------
    Update de veículos
    --------------------------------------*/

    // Nenhuma operação de update de veículo ainda

    /*--------------------------------------
    Remoção de veículos
    --------------------------------------*/

    public boolean remover(int idCliente, int idVeiculo) throws SQLException {
        String sql = "DELETE FROM veiculo WHERE id_cliente = ? AND id_veiculo = ?";
        try (Connection connection = DatabaseConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, idCliente);
            statement.setInt(2, idVeiculo);
            return statement.executeUpdate() == 1;
        }
    }
}
