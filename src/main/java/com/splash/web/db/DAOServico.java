package com.splash.web.db;

import com.splash.web.model.dto.ServicoView;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO que realiza o CRUD na tabela {@code servico}
 */
public class DAOServico {

    /*--------------------------------------
    Listagem de serviços
    --------------------------------------*/

    public List<ServicoView> listar() throws SQLException {
        String sql = "SELECT id_servico, nome, descricao, preco FROM servico ORDER BY nome";
        List<ServicoView> servicos = new ArrayList<>();
        try (Connection connection = DatabaseConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet result = statement.executeQuery()) {
            while (result.next()) {
                servicos.add(new ServicoView(result.getInt("id_servico"), result.getString("nome"),
                        result.getString("descricao"), result.getBigDecimal("preco")));
            }
        }
        return servicos;
    }

    /*--------------------------------------
    Inserção e update de serviços
    --------------------------------------*/

    // Faz INSERT quando idServico é nulo e UPDATE caso contrário
    public void salvar(Integer idServico, String nome, String descricao, BigDecimal preco)
            throws SQLException {
        boolean atualizar = idServico != null;
        String sql = atualizar
                ? "UPDATE servico SET nome = ?, descricao = ?, preco = ? WHERE id_servico = ?"
                : "INSERT INTO servico (nome, descricao, preco) VALUES (?, ?, ?)";
        try (Connection connection = DatabaseConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, nome.trim());
            statement.setString(2, descricao == null || descricao.isBlank() ? null : descricao.trim());
            statement.setBigDecimal(3, preco);
            if (atualizar) {
                statement.setInt(4, idServico);
            }
            if (statement.executeUpdate() != 1) {
                throw new SQLException("O serviço não foi encontrado para atualização.");
            }
        }
    }

    /*--------------------------------------
    Remoção de serviços
    --------------------------------------*/

    public boolean remover(int idServico) throws SQLException {
        String sql = "DELETE FROM servico WHERE id_servico = ?";
        try (Connection connection = DatabaseConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, idServico);
            return statement.executeUpdate() == 1;
        }
    }
}
