package com.splash.web.db;

import com.splash.web.model.dto.AgendamentoView;
import com.splash.web.model.dto.ServicoView;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * DAO que realiza o CRUD na tabela {@code agendamento}
 *
 * <p>As transações que partem do agendamento ({@code criar} e {@code cancelar}) ficam inteiras aqui,
 * mesmo gravando em {@code agendamento_servico}, {@code atendimento} e {@code pagamento}.</p>
 */
public class DAOAgendamento {

    /*--------------------------------------
    Listagem de agendamentos
    --------------------------------------*/

    public List<AgendamentoView> listarPorCliente(int idCliente) throws SQLException {
        String sql = "SELECT a.id_agendamento, v.placa, CONCAT(v.marca, ' ', v.modelo) AS veiculo, "
                + "a.data, a.horario, a.status, COALESCE(SUM(ags.valor_praticado), 0) AS total, "
                + "MAX(p.status_pagamento) AS status_pagamento, MAX(p.forma_pagamento) AS forma_pagamento "
                + "FROM agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo "
                + "LEFT JOIN agendamento_servico ags ON ags.id_agendamento = a.id_agendamento "
                + "LEFT JOIN pagamento p ON p.id_agendamento = a.id_agendamento "
                + "WHERE v.id_cliente = ? GROUP BY a.id_agendamento ORDER BY a.data DESC, a.horario DESC";
        List<AgendamentoView> agendamentos = new ArrayList<>();
        try (Connection connection = DatabaseConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, idCliente);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    agendamentos.add(new AgendamentoView(result.getInt("id_agendamento"),
                            result.getString("placa"), result.getString("veiculo"),
                            result.getDate("data").toLocalDate(), result.getString("horario"),
                            result.getString("status"), result.getBigDecimal("total"),
                            result.getString("status_pagamento"), result.getString("forma_pagamento")));
                }
            }
        }
        return agendamentos;
    }

    /*--------------------------------------
    Inserção de agendamentos
    --------------------------------------*/

    public void criar(int idCliente, int idVeiculo, LocalDate data, String horario,
            List<Integer> idsServicos) throws SQLException {
        Set<Integer> servicosUnicos = new LinkedHashSet<>(idsServicos);
        if (servicosUnicos.isEmpty() || servicosUnicos.size() != idsServicos.size()) {
            throw new IllegalArgumentException("Selecione ao menos um serviço, sem repetições.");
        }

        String verifyVehicle = "SELECT 1 FROM veiculo WHERE id_veiculo = ? AND id_cliente = ?";
        String getPrice = "SELECT preco FROM servico WHERE id_servico = ?";
        String insertAppointment = "INSERT INTO agendamento (id_veiculo, data, horario) VALUES (?, ?, ?)";
        String insertService = "INSERT INTO agendamento_servico "
                + "(id_agendamento, id_servico, valor_praticado) VALUES (?, ?, ?)";
        String insertAttendance = "INSERT INTO atendimento (id_agendamento) VALUES (?)";
        String insertPayment = "INSERT INTO pagamento (id_agendamento, valor) VALUES (?, ?)";

        try (Connection connection = DatabaseConnection.getConnection()) {
            connection.setAutoCommit(false);
            try {
                try (PreparedStatement statement = connection.prepareStatement(verifyVehicle)) {
                    statement.setInt(1, idVeiculo);
                    statement.setInt(2, idCliente);
                    try (ResultSet result = statement.executeQuery()) {
                        if (!result.next()) {
                            throw new IllegalArgumentException("O veículo selecionado não pertence à sua conta.");
                        }
                    }
                }

                List<ServicoView> selecionados = new ArrayList<>();
                BigDecimal total = BigDecimal.ZERO;
                try (PreparedStatement statement = connection.prepareStatement(getPrice)) {
                    for (int idServico : servicosUnicos) {
                        statement.setInt(1, idServico);
                        try (ResultSet result = statement.executeQuery()) {
                            if (!result.next()) {
                                throw new IllegalArgumentException("Um dos serviços selecionados não existe.");
                            }
                            BigDecimal preco = result.getBigDecimal("preco");
                            selecionados.add(new ServicoView(idServico, null, null, preco));
                            total = total.add(preco);
                        }
                    }
                }

                int idAgendamento;
                try (PreparedStatement statement = connection.prepareStatement(insertAppointment,
                        Statement.RETURN_GENERATED_KEYS)) {
                    statement.setInt(1, idVeiculo);
                    statement.setDate(2, Date.valueOf(data));
                    statement.setString(3, horario);
                    statement.executeUpdate();
                    try (ResultSet keys = statement.getGeneratedKeys()) {
                        if (!keys.next()) {
                            throw new SQLException("Não foi possível obter o identificador do agendamento.");
                        }
                        idAgendamento = keys.getInt(1);
                    }
                }

                try (PreparedStatement statement = connection.prepareStatement(insertService)) {
                    for (ServicoView servico : selecionados) {
                        statement.setInt(1, idAgendamento);
                        statement.setInt(2, servico.id());
                        statement.setBigDecimal(3, servico.preco());
                        statement.addBatch();
                    }
                    statement.executeBatch();
                }
                try (PreparedStatement statement = connection.prepareStatement(insertAttendance)) {
                    statement.setInt(1, idAgendamento);
                    statement.executeUpdate();
                }
                try (PreparedStatement statement = connection.prepareStatement(insertPayment)) {
                    statement.setInt(1, idAgendamento);
                    statement.setBigDecimal(2, total);
                    statement.executeUpdate();
                }
                connection.commit();
            } catch (SQLException | RuntimeException exception) {
                connection.rollback();
                throw exception;
            } finally {
                connection.setAutoCommit(true);
            }
        }
    }

    /*--------------------------------------
    Update de agendamentos
    --------------------------------------*/

    public boolean cancelar(int idCliente, int idAgendamento) throws SQLException {
        String sql = "UPDATE agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo "
                + "SET a.status = 'CANCELADO' WHERE a.id_agendamento = ? AND v.id_cliente = ? "
                + "AND a.status = 'AGENDADO'";
        try (Connection connection = DatabaseConnection.getConnection()) {
            connection.setAutoCommit(false);
            try {
                boolean cancelado;
                try (PreparedStatement statement = connection.prepareStatement(sql)) {
                    statement.setInt(1, idAgendamento);
                    statement.setInt(2, idCliente);
                    cancelado = statement.executeUpdate() == 1;
                }
                if (cancelado) {
                    try (PreparedStatement payment = connection.prepareStatement(
                            "UPDATE pagamento SET status_pagamento = 'CANCELADO' "
                                    + "WHERE id_agendamento = ? AND status_pagamento = 'PENDENTE'")) {
                        payment.setInt(1, idAgendamento);
                        payment.executeUpdate();
                    }
                }
                connection.commit();
                return cancelado;
            } catch (SQLException | RuntimeException exception) {
                connection.rollback();
                throw exception;
            } finally {
                connection.setAutoCommit(true);
            }
        }
    }

    /*--------------------------------------
    Remoção de agendamentos
    --------------------------------------*/

    // Nenhuma operação de remoção de agendamento ainda (cancelar só troca o status)
}
