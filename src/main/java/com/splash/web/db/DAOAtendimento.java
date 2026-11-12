package com.splash.web.db;

import com.splash.web.model.dto.AtendimentoView;
import com.splash.web.model.enums.StatusAtendimento;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;

/**
 * DAO que realiza o CRUD na tabela {@code atendimento}
 */
public class DAOAtendimento {

    /*--------------------------------------
    Listagem de atendimentos
    --------------------------------------*/

    public List<AtendimentoView> listar() throws SQLException {
        String sql = "SELECT at.id_atendimento, a.id_agendamento, c.nome AS cliente, v.placa, "
                + "a.data, a.horario, at.status, a.status AS status_agendamento, "
                + "COALESCE(GROUP_CONCAT(col.nome ORDER BY col.nome SEPARATOR ', '), '') AS colaboradores, "
                + "COALESCE(GROUP_CONCAT(ca.id_colaborador ORDER BY ca.id_colaborador), '') AS ids_colaboradores "
                + "FROM atendimento at JOIN agendamento a ON a.id_agendamento = at.id_agendamento "
                + "JOIN veiculo v ON v.id_veiculo = a.id_veiculo "
                + "JOIN cliente c ON c.id_cliente = v.id_cliente "
                + "LEFT JOIN colaborador_atendimento ca ON ca.id_atendimento = at.id_atendimento "
                + "LEFT JOIN colaborador col ON col.id_colaborador = ca.id_colaborador "
                + "GROUP BY at.id_atendimento ORDER BY at.id_atendimento DESC";
        List<AtendimentoView> atendimentos = new ArrayList<>();
        try (Connection connection = DatabaseConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet result = statement.executeQuery()) {
            while (result.next()) {
                atendimentos.add(new AtendimentoView(result.getInt("id_atendimento"),
                        result.getInt("id_agendamento"), result.getString("cliente"),
                        result.getString("placa"), result.getDate("data").toLocalDate(),
                        result.getString("horario"), result.getString("status"),
                        result.getString("status_agendamento"),
                        result.getString("colaboradores"), result.getString("ids_colaboradores")));
            }
        }
        return atendimentos;
    }

    public boolean iniciarAtendimento(
            int idAtendimento,
            List<Integer> idsColaboradores) throws SQLException {

        if (idAtendimento <= 0
                || idsColaboradores == null
                || idsColaboradores.isEmpty()) {
            throw new IllegalArgumentException(
                    "Selecione pelo menos um lavador.");
        }

        LinkedHashSet<Integer> idsUnicos = new LinkedHashSet<>(idsColaboradores);

        if (idsUnicos.size() != idsColaboradores.size()
                || idsUnicos.stream().anyMatch(
                        id -> id == null || id <= 0)) {
            throw new IllegalArgumentException(
                    "Lista de lavadores inválida.");
        }

        String sqlIniciar = """
                UPDATE atendimento at
                JOIN agendamento a
                    ON a.id_agendamento = at.id_agendamento
                SET
                    at.status = 'EM_LAVAGEM',
                    at.data_inicio = CURRENT_TIMESTAMP
                WHERE at.id_atendimento = ?
                  AND at.status = 'AGUARDANDO'
                  AND a.status = 'AGENDADO'
                  AND a.data = CURRENT_DATE()
                """;

        String sqlValidar = """
                SELECT 1
                FROM colaborador
                WHERE id_colaborador = ?
                  AND ativo = TRUE
                  AND nivel_acesso = 'OPERACIONAL'
                """;

        String sqlVincular = """
                INSERT INTO colaborador_atendimento
                    (id_colaborador, id_atendimento)
                SELECT ?, ?
                WHERE NOT EXISTS (
                    SELECT 1
                    FROM colaborador_atendimento
                    WHERE id_colaborador = ?
                      AND id_atendimento = ?
                )
                """;

        try (Connection connection = DatabaseConnection.getConnection()) {

            connection.setAutoCommit(false);

            try {
                try (PreparedStatement statement = connection.prepareStatement(sqlIniciar)) {

                    statement.setInt(1, idAtendimento);

                    if (statement.executeUpdate() != 1) {
                        connection.rollback();
                        return false;
                    }
                }

                try (PreparedStatement validar = connection.prepareStatement(sqlValidar);
                        PreparedStatement vincular = connection.prepareStatement(sqlVincular)) {

                    for (Integer idColaborador : idsUnicos) {

                        validar.setInt(1, idColaborador);

                        try (ResultSet resultado = validar.executeQuery()) {

                            if (!resultado.next()) {
                                throw new IllegalArgumentException(
                                        "Lavador inválido ou inativo.");
                            }
                        }

                        vincular.setInt(1, idColaborador);
                        vincular.setInt(2, idAtendimento);
                        vincular.setInt(3, idColaborador);
                        vincular.setInt(4, idAtendimento);

                        vincular.executeUpdate();
                    }
                }

                connection.commit();
                return true;

            } catch (SQLException | RuntimeException exception) {
                connection.rollback();
                throw exception;

            } finally {
                connection.setAutoCommit(true);
            }
        }
    }

    /*--------------------------------------
    Inserção de atendimentos
    --------------------------------------*/

    // O atendimento é criado junto do agendamento, dentro de DAOAgendamento.criar

    /*--------------------------------------
    Update de atendimentos
    --------------------------------------*/

    public void atualizar(int idAtendimento, String status, List<Integer> idsColaboradores)
            throws SQLException {
        String select = "SELECT at.status, a.status AS status_agendamento "
                + "FROM atendimento at JOIN agendamento a ON a.id_agendamento = at.id_agendamento "
                + "WHERE at.id_atendimento = ? FOR UPDATE";
        String sql = "UPDATE atendimento SET status = ?, "
                + "data_inicio = CASE WHEN ? = 'EM_LAVAGEM' AND data_inicio IS NULL "
                + "THEN CURRENT_TIMESTAMP ELSE data_inicio END, "
                + "data_fim = CASE WHEN ? IN ('FINALIZADO', 'ENTREGUE') AND data_fim IS NULL "
                + "THEN CURRENT_TIMESTAMP ELSE data_fim END WHERE id_atendimento = ?";
        try (Connection connection = DatabaseConnection.getConnection()) {
            connection.setAutoCommit(false);
            try {
                try (PreparedStatement statement = connection.prepareStatement(select)) {
                    statement.setInt(1, idAtendimento);
                    try (ResultSet result = statement.executeQuery()) {
                        if (!result.next()) {
                            throw new IllegalArgumentException("Atendimento não encontrado.");
                        }
                        StatusAtendimento atual = StatusAtendimento.valueOf(result.getString("status"));
                        StatusAtendimento proximo = StatusAtendimento.valueOf(status);
                        String statusAgendamento = result.getString("status_agendamento");
                        // Manter o mesmo status é permitido: o admin usa isso para trocar só os
                        // colaboradores
                        if ("CANCELADO".equals(statusAgendamento) || (atual != proximo && !atual.podeIrPara(proximo))) {
                            throw new IllegalArgumentException(
                                    "Atendimento cancelado ou transição de status não permitida.");
                        }
                    }
                }
                try (PreparedStatement statement = connection.prepareStatement(sql)) {
                    statement.setString(1, status);
                    statement.setString(2, status);
                    statement.setString(3, status);
                    statement.setInt(4, idAtendimento);
                    if (statement.executeUpdate() != 1) {
                        throw new IllegalArgumentException("Atendimento não encontrado.");
                    }
                }
                if ("FINALIZADO".equals(status) || "ENTREGUE".equals(status)) {
                    try (PreparedStatement statement = connection.prepareStatement(
                            "UPDATE agendamento SET status = 'CONCLUIDO' WHERE id_agendamento = "
                                    + "(SELECT id_agendamento FROM atendimento WHERE id_atendimento = ?)")) {
                        statement.setInt(1, idAtendimento);
                        statement.executeUpdate();
                    }
                }
                String inserirColaborador = """
                            INSERT INTO colaborador_atendimento
                                (id_colaborador, id_atendimento)
                            SELECT c.id_colaborador, ?
                            FROM colaborador c
                            WHERE c.id_colaborador = ?
                            AND c.ativo = TRUE
                            AND c.nivel_acesso = 'OPERACIONAL'
                            AND NOT EXISTS (
                            SELECT 1
                            FROM colaborador_atendimento ca
                            WHERE ca.id_colaborador = c.id_colaborador
                                AND ca.id_atendimento = ?
                        )
                        """;

                try (PreparedStatement statement = connection.prepareStatement(inserirColaborador)) {

                    for (int idColaborador : new LinkedHashSet<>(idsColaboradores)) {

                        statement.setInt(1, idAtendimento);
                        statement.setInt(2, idColaborador);
                        statement.setInt(3, idAtendimento);

                        statement.executeUpdate();
                    }
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
    Remoção de atendimentos
    --------------------------------------*/
    public void remover(int idAtendimento) throws SQLException {
        String sql = "DELETE FROM atendimento WHERE id_atendimento = ?";
        try (Connection connection = DatabaseConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, idAtendimento);
            if (statement.executeUpdate() != 1) {
                throw new IllegalArgumentException("Atendimento não encontrado.");
            }
        }
    }
}
