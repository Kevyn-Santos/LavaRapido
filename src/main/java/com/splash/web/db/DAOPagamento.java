package com.splash.web.db;

import com.splash.web.model.dto.PagamentoView;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO que realiza o CRUD na tabela {@code pagamento}
 */
public class DAOPagamento {

    /*--------------------------------------
    Listagem de pagamentos
    --------------------------------------*/

    public List<PagamentoView> listar() throws SQLException {
        String sql = "SELECT p.id_pagamento, p.id_agendamento, c.nome AS cliente, v.placa, "
                + "a.data, a.horario, p.valor, p.forma_pagamento, p.status_pagamento "
                + "FROM pagamento p JOIN agendamento a ON a.id_agendamento = p.id_agendamento "
                + "JOIN veiculo v ON v.id_veiculo = a.id_veiculo "
                + "JOIN cliente c ON c.id_cliente = v.id_cliente "
                + "ORDER BY a.data DESC, a.horario DESC";
        List<PagamentoView> pagamentos = new ArrayList<>();
        try (Connection connection = DatabaseConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet result = statement.executeQuery()) {
            while (result.next()) {
                Date data = result.getDate("data");
                pagamentos.add(new PagamentoView(result.getInt("id_pagamento"),
                        result.getInt("id_agendamento"), result.getString("cliente"),
                        result.getString("placa"), data.toLocalDate(), result.getString("horario"),
                        result.getBigDecimal("valor"), result.getString("forma_pagamento"),
                        result.getString("status_pagamento")));
            }
        }
        return pagamentos;
    }

    /*--------------------------------------
    Inserção de pagamentos
    --------------------------------------*/

    // O pagamento é criado junto do agendamento, dentro de DAOAgendamento.criar

    /*--------------------------------------
    Update de pagamentos
    --------------------------------------*/

    public void atualizar(int idPagamento, String status, String forma) throws SQLException {
        String sql = "UPDATE pagamento SET status_pagamento = ?, "
                + "forma_pagamento = CASE WHEN ? = 'PAGO' THEN ? ELSE forma_pagamento END, "
                + "data_pagamento = CASE WHEN ? = 'PAGO' THEN CURRENT_TIMESTAMP ELSE data_pagamento END "
                + "WHERE id_pagamento = ? AND status_pagamento <> 'CANCELADO'";
        try (Connection connection = DatabaseConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, status);
            statement.setString(2, status);
            statement.setString(3, forma);
            statement.setString(4, status);
            statement.setInt(5, idPagamento);
            if (statement.executeUpdate() != 1) {
                throw new IllegalArgumentException("Pagamento não encontrado ou já cancelado.");
            }
        }
    }

    /*--------------------------------------
    Remoção de pagamentos
    --------------------------------------*/

    // Nenhuma operação de remoção de pagamento ainda (cancelar o agendamento cancela o pagamento)
}
