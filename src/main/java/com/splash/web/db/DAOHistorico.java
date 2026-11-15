
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
                    a.criado_por_tipo,
                    criador.nome AS nome_criador,
                    cliente.nome AS nome_cliente,

                    v.id_veiculo,
                    v.placa,
                    CONCAT(v.marca, ' ', v.modelo) AS veiculo,

                    COALESCE(sv.servicos, '') AS servicos,
                    COALESCE(sv.total, 0) AS total_servicos,

                    at.status AS status_atendimento,
                    at.data_inicio,
                    at.data_fim,
                    responsavel.nome AS nome_responsavel,
                    COALESCE(lavadores.nomes, '') AS nomes_lavadores,

                    p.status_pagamento,
                    p.forma_pagamento,
                    p.valor AS valor_pagamento

                FROM agendamento a

                JOIN veiculo v
                    ON v.id_veiculo = a.id_veiculo

                JOIN cliente cliente
                    ON cliente.id_cliente = v.id_cliente

                LEFT JOIN colaborador criador
                    ON criador.id_colaborador = a.id_colaborador_criador

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

                LEFT JOIN colaborador responsavel
                    ON responsavel.id_colaborador = at.id_colaborador_responsavel

                LEFT JOIN (
                    SELECT ca.id_atendimento,
                           GROUP_CONCAT(c.nome ORDER BY c.nome SEPARATOR ', ') AS nomes
                    FROM colaborador_atendimento ca
                    JOIN colaborador c ON c.id_colaborador = ca.id_colaborador
                    GROUP BY ca.id_atendimento
                ) lavadores ON lavadores.id_atendimento = at.id_atendimento

                LEFT JOIN pagamento p
                    ON p.id_agendamento = a.id_agendamento

                WHERE v.id_cliente = ?

                ORDER BY a.id_agendamento DESC
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

                    String tipoCriador = result.getString("criado_por_tipo");
                    String nomeCriador = result.getString("nome_criador");
                    String autoria = "Não registrado";
                    if ("CLIENTE".equals(tipoCriador)) {
                        autoria = "Cliente — " + result.getString("nome_cliente");
                    } else if ("ATENDENTE".equals(tipoCriador)
                            || "ADMINISTRADOR".equals(tipoCriador)) {
                        String perfil = "ATENDENTE".equals(tipoCriador) ? "Atendente" : "Administrador";
                        autoria = perfil + " — " + (nomeCriador == null ? "Não identificado" : nomeCriador);
                    }
                    registro.put("criadoPor", autoria);
                    registro.put("responsavelAtendimento",
                            result.getString("nome_responsavel"));
                    registro.put("lavadores", result.getString("nomes_lavadores"));

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
