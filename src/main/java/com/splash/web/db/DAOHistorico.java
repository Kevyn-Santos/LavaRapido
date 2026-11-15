
package com.splash.web.db;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class DAOHistorico {

    public List<Map<String, Object>> pesquisarClientes(String pesquisa)
            throws SQLException {

        List<Map<String, Object>> clientes = new ArrayList<>();

        if (pesquisa == null || pesquisa.isBlank()) {
            return clientes;
        }

        String termo = pesquisa.trim();
        Integer id = null;

        try {
            id = Integer.valueOf(termo);
        } catch (NumberFormatException ignored) {
            // Pesquisa por nome.
        }

        String sql = """
                SELECT
                    c.id_cliente,
                    c.nome,
                    c.email,
                    c.telefone,
                    c.ativo,
                    (SELECT COUNT(*)
                     FROM veiculo v
                     WHERE v.id_cliente = c.id_cliente)
                        AS total_veiculos,
                    (SELECT COUNT(*)
                     FROM agendamento a
                     JOIN veiculo v
                       ON v.id_veiculo = a.id_veiculo
                     WHERE v.id_cliente = c.id_cliente)
                        AS total_agendamentos
                FROM cliente c
                WHERE c.id_cliente = ?
                OR c.nome COLLATE utf8mb4_unicode_ci
                LIKE ? COLLATE utf8mb4_unicode_ci
                ORDER BY c.id_cliente DESC
                LIMIT 50
                """;

        try (Connection connection = DatabaseConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, id == null ? -1 : id);
            statement.setString(2, "%" + termo.toLowerCase() + "%");

            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    Map<String, Object> cliente = new LinkedHashMap<>();

                    cliente.put("id", result.getInt("id_cliente"));
                    cliente.put("nome", result.getString("nome"));
                    cliente.put("email", result.getString("email"));
                    cliente.put("telefone", result.getString("telefone"));
                    cliente.put("ativo", result.getBoolean("ativo"));
                    cliente.put("totalVeiculos",
                            result.getInt("total_veiculos"));
                    cliente.put("totalAgendamentos",
                            result.getInt("total_agendamentos"));

                    clientes.add(cliente);
                }
            }
        }

        return clientes;
    }

    public List<Map<String, Object>> listarHistoricoCliente(int idCliente)
            throws SQLException {

        if (idCliente <= 0) {
            throw new IllegalArgumentException("Cliente inválido.");
        }

        String sql = """
                SELECT
                    a.id_agendamento,
                    a.data,
                    a.horario,
                    a.status AS status_agendamento,

                    v.id_veiculo,
                    v.placa,
                    CONCAT(v.marca, ' ', v.modelo) AS veiculo,

                    COALESCE(sv.servicos, '') AS servicos,
                    COALESCE(sv.total, 0) AS total_servicos,

                    at.status AS status_atendimento,
                    at.data_inicio,
                    at.data_fim,

                    p.status_pagamento,
                    p.forma_pagamento,
                    p.valor AS valor_pagamento

                FROM agendamento a

                JOIN veiculo v
                    ON v.id_veiculo = a.id_veiculo

                LEFT JOIN (
                    SELECT
                        ags.id_agendamento,
                        GROUP_CONCAT(
                            s.nome ORDER BY s.nome SEPARATOR ', '
                        ) AS servicos,
                        SUM(ags.valor_praticado) AS total
                    FROM agendamento_servico ags
                    JOIN servico s
                        ON s.id_servico = ags.id_servico
                    GROUP BY ags.id_agendamento
                ) sv
                    ON sv.id_agendamento = a.id_agendamento

                LEFT JOIN atendimento at
                    ON at.id_agendamento = a.id_agendamento

                LEFT JOIN pagamento p
                    ON p.id_agendamento = a.id_agendamento

                WHERE v.id_cliente = ?

                ORDER BY
                    a.data DESC,
                    a.horario DESC,
                    a.id_agendamento DESC
                """;

        List<Map<String, Object>> historico = new ArrayList<>();

        try (Connection connection = DatabaseConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, idCliente);

            try (ResultSet result = statement.executeQuery()) {

                while (result.next()) {

                    Map<String, Object> registro = new LinkedHashMap<>();

                    registro.put("id", result.getInt("id_agendamento"));
                    registro.put("data", result.getDate("data"));
                    registro.put("horario", result.getString("horario"));

                    registro.put("statusAgendamento",
                            result.getString("status_agendamento"));

                    registro.put("idVeiculo", result.getInt("id_veiculo"));
                    registro.put("veiculo", result.getString("veiculo"));
                    registro.put("placa", result.getString("placa"));

                    registro.put("servicos", result.getString("servicos"));
                    registro.put("totalServicos",
                            result.getBigDecimal("total_servicos"));

                    registro.put("statusAtendimento",
                            result.getString("status_atendimento"));
                    registro.put("dataInicio",
                            result.getTimestamp("data_inicio"));
                    registro.put("dataFim",
                            result.getTimestamp("data_fim"));

                    registro.put("statusPagamento",
                            result.getString("status_pagamento"));
                    registro.put("formaPagamento",
                            result.getString("forma_pagamento"));
                    registro.put("valorPagamento",
                            result.getBigDecimal("valor_pagamento"));

                    historico.add(registro);
                }
            }
        }

        return historico;
    }

}
