package com.splash.web.db;

import com.splash.web.model.GradeHorarios;
import com.splash.web.model.dto.AgendamentoView;
import com.splash.web.model.dto.ServicoView;
import java.util.Map;
import java.util.LinkedHashMap;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * DAO que realiza o CRUD na tabela {@code agendamento}
 *
 * <p>
 * As transações que partem do agendamento ({@code criar} e {@code cancelar})
 * ficam inteiras aqui,
 * mesmo gravando em {@code agendamento_servico}, {@code atendimento} e
 * {@code pagamento}.
 * </p>
 */
public class DAOAgendamento {

    /*--------------------------------------
    Listagem de agendamentos
    --------------------------------------*/
    /*
     * "SELECT a.id_agendamento, v.id_veiculo, v.placa, CONCAT(v.marca, ' ', v.modelo) AS veiculo, "
     * +
     * "a.data, a.horario, a.status, COALESCE(SUM(ags.valor_praticado), 0) AS total, "
     * +
     * "MAX(p.status_pagamento) AS status_pagamento, MAX(p.forma_pagamento) AS forma_pagamento "
     * + "FROM agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo "
     * +
     * "LEFT JOIN agendamento_servico ags ON ags.id_agendamento = a.id_agendamento "
     * + "LEFT JOIN pagamento p ON p.id_agendamento = a.id_agendamento "
     * +
     * "WHERE v.id_cliente = ? GROUP BY a.id_agendamento ORDER BY a.data DESC, a.horario DESC"
     * ;
     */

    /**
     * Lista todos os agendamentos para o painel administrativo.
     */
    public List<Map<String, Object>> listarTodos() throws SQLException {

        String sql = """
                SELECT
                    a.id_agendamento,
                    c.nome AS cliente,
                    v.placa,
                    CONCAT(v.marca, ' ', v.modelo) AS veiculo,
                    a.data,
                    a.horario,
                    a.status,
                    COALESCE(ags.total, 0) AS total,
                    COALESCE(ags.servicos, '') AS servicos,
                    p.status_pagamento
                FROM agendamento a
                JOIN veiculo v
                    ON v.id_veiculo = a.id_veiculo
                JOIN cliente c
                    ON c.id_cliente = v.id_cliente
                LEFT JOIN (
                    SELECT
                        ags.id_agendamento,
                        SUM(ags.valor_praticado) AS total,
                        GROUP_CONCAT(
                            s.nome ORDER BY s.nome SEPARATOR ', '
                        ) AS servicos
                    FROM agendamento_servico ags
                    JOIN servico s
                        ON s.id_servico = ags.id_servico
                    GROUP BY ags.id_agendamento
                ) ags
                    ON ags.id_agendamento = a.id_agendamento
                LEFT JOIN pagamento p
                    ON p.id_agendamento = a.id_agendamento
                ORDER BY a.id_agendamento DESC
                """;

        List<Map<String, Object>> agendamentos = new ArrayList<>();

        try (Connection connection = DatabaseConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet result = statement.executeQuery()) {

            while (result.next()) {

                Map<String, Object> agendamento = new LinkedHashMap<>();

                agendamento.put("id", result.getInt("id_agendamento"));
                agendamento.put("cliente", result.getString("cliente"));
                agendamento.put("placa", result.getString("placa"));
                agendamento.put("veiculo", result.getString("veiculo"));
                agendamento.put("data", result.getDate("data").toLocalDate());
                agendamento.put("horario", result.getString("horario"));
                agendamento.put("status", result.getString("status"));
                agendamento.put("total", result.getBigDecimal("total"));
                agendamento.put("servicos", result.getString("servicos"));
                agendamento.put("statusPagamento",
                        result.getString("status_pagamento"));

                agendamentos.add(agendamento);
            }
        }

        return agendamentos;
    }

    /** Horários da grade já ocupados na data (agendamentos não cancelados). */
    public List<LocalTime> horariosOcupados(LocalDate data) throws SQLException {
        String sql = "SELECT horario FROM agendamento WHERE data = ? AND status <> 'CANCELADO'";
        List<LocalTime> ocupados = new ArrayList<>();
        try (Connection connection = DatabaseConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setDate(1, Date.valueOf(data));
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    ocupados.add(result.getTime("horario").toLocalTime());
                }
            }
        }
        return ocupados;
    }

    /**
     * Horários livres da grade na data. Data passada: lista vazia; hoje: só os horários que ainda
     * não passaram.
     */
    public List<LocalTime> horariosLivres(LocalDate data) throws SQLException {
        LocalDate hoje = LocalDate.now();
        if (data.isBefore(hoje)) {
            return new ArrayList<>();
        }
        List<LocalTime> livres = GradeHorarios.todos();
        livres.removeAll(horariosOcupados(data));
        if (data.equals(hoje)) {
            LocalTime agora = LocalTime.now();
            livres.removeIf(horario -> !horario.isAfter(agora));
        }
        return livres;
    }

    public List<Map<String, Object>> listarAgendamentosHoje()
            throws SQLException {

        String sql = """
                SELECT
                    a.id_agendamento,
                    a.data,
                    a.horario,
                    a.status AS status_agendamento,

                    c.nome AS cliente,

                    CONCAT(v.marca, ' ', v.modelo) AS veiculo,
                    v.placa,

                    at.id_atendimento,
                    at.status AS status_atendimento,

                    p.id_pagamento,
                    p.status_pagamento,
                    p.forma_pagamento,
                    p.valor AS valor_total,

                    COALESCE(
                        GROUP_CONCAT(
                            s.nome ORDER BY s.nome SEPARATOR ', '
                        ),
                        ''
                    ) AS servicos

                FROM agendamento a

                JOIN veiculo v
                    ON v.id_veiculo = a.id_veiculo

                JOIN cliente c
                    ON c.id_cliente = v.id_cliente

                LEFT JOIN atendimento at
                    ON at.id_agendamento = a.id_agendamento

                LEFT JOIN pagamento p
                    ON p.id_agendamento = a.id_agendamento

                LEFT JOIN agendamento_servico ags
                    ON ags.id_agendamento = a.id_agendamento

                LEFT JOIN servico s
                    ON s.id_servico = ags.id_servico

                WHERE a.data = ?
                  AND a.status = 'AGENDADO'

                GROUP BY
                    a.id_agendamento,
                    a.data,
                    a.horario,
                    a.status,
                    c.nome,
                    v.marca,
                    v.modelo,
                    v.placa,
                    at.id_atendimento,
                    at.status,
                    p.id_pagamento,
                    p.status_pagamento,
                    p.forma_pagamento,
                    p.valor

                ORDER BY
                    a.horario ASC,
                    a.id_agendamento ASC
                """;

        List<Map<String, Object>> agendamentos = new ArrayList<>();

        try (Connection connection = DatabaseConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setDate(
                    1,
                    Date.valueOf(LocalDate.now()));

            try (ResultSet result = statement.executeQuery()) {

                while (result.next()) {

                    Map<String, Object> item = new LinkedHashMap<>();

                    // Agendamento
                    item.put(
                            "id",
                            result.getInt("id_agendamento"));

                    item.put(
                            "data",
                            result.getDate("data").toLocalDate());

                    item.put(
                            "horario",
                            result.getString("horario"));

                    item.put(
                            "statusAgendamento",
                            result.getString("status_agendamento"));

                    // Cliente e veículo
                    item.put(
                            "cliente",
                            result.getString("cliente"));

                    item.put(
                            "veiculo",
                            result.getString("veiculo"));

                    item.put(
                            "placa",
                            result.getString("placa"));

                    // Serviços
                    item.put(
                            "servicos",
                            result.getString("servicos"));

                    // Atendimento
                    item.put(
                            "idAtendimento",
                            result.getObject("id_atendimento"));

                    item.put(
                            "statusAtendimento",
                            result.getString("status_atendimento"));

                    // Pagamento
                    item.put(
                            "idPagamento",
                            result.getObject("id_pagamento"));

                    item.put(
                            "statusPagamento",
                            result.getString("status_pagamento"));

                    item.put(
                            "formaPagamento",
                            result.getString("forma_pagamento"));

                    item.put(
                            "valorTotal",
                            result.getBigDecimal("valor_total"));

                    agendamentos.add(item);
                }
            }
        }

        return agendamentos;
    }

    public List<AgendamentoView> listarPorCliente(int idCliente) throws SQLException {


        String sql = "SELECT a.id_agendamento, v.id_veiculo, GROUP_CONCAT(DISTINCT s.id_servico) as servicos, "
                +
                "GROUP_CONCAT(DISTINCT CONCAT(s.id_servico, ':', ags.valor_praticado, ':', s.nome) ORDER BY s.id_servico SEPARATOR '\n') AS servicos_detalhe, v.placa, CONCAT(v.marca, ' ', v.modelo) AS veiculo, "
                +
                "a.data, a.horario, a.status, COALESCE(SUM(ags.valor_praticado), 0) AS total,  MAX(p.status_pagamento) AS status_pagamento, MAX(p.forma_pagamento) AS forma_pagamento, MAX(at.status) AS status_atendimento "
                +
                "FROM agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo LEFT JOIN agendamento_servico ags ON ags.id_agendamento = a.id_agendamento "
                +
                "LEFT JOIN servico s ON s.id_servico = ags.id_servico " +
                "LEFT JOIN pagamento p ON p.id_agendamento = a.id_agendamento " +
                "LEFT JOIN atendimento at ON at.id_agendamento = a.id_agendamento " +
                "WHERE v.id_cliente = ? GROUP BY a.id_agendamento ORDER BY a.data DESC, a.horario DESC;";
        List<AgendamentoView> agendamentos = new ArrayList<>();
        try (Connection connection = DatabaseConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, idCliente);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    // GROUP_CONCAT devolve "1,3,5" (ou null se o agendamento não tem serviços)
                    List<Integer> idsServicos = new ArrayList<>();
                    String servicosConcat = result.getString("servicos");
                    if (servicosConcat != null && !servicosConcat.isBlank()) {
                        for (String idServico : servicosConcat.split(",")) {
                            idsServicos.add(Integer.parseInt(idServico.trim()));
                        }
                    }
                    // "id:valor:nome" por linha; o nome fica por último porque pode conter ':'
                    List<ServicoView> servicos = new ArrayList<>();
                    String detalhe = result.getString("servicos_detalhe");
                    if (detalhe != null && !detalhe.isBlank()) {
                        for (String linha : detalhe.split("\n")) {
                            String[] partes = linha.split(":", 3);
                            if (partes.length == 3) {
                                servicos.add(new ServicoView(Integer.parseInt(partes[0].trim()), partes[2], null,
                                        new BigDecimal(partes[1].trim())));
                            }
                        }
                    }
                    agendamentos.add(new AgendamentoView(result.getInt("id_agendamento"), result.getInt("id_veiculo"),
                            idsServicos,
                            result.getString("placa"), result.getString("veiculo"),
                            result.getDate("data").toLocalDate(), result.getString("horario"),
                            result.getString("status"), result.getBigDecimal("total"),
                            result.getString("status_pagamento"), result.getString("forma_pagamento"), result.getString("status_atendimento"),
                            servicos));
                }
            }
        }
        return agendamentos;
    }

    /*--------------------------------------
    Inserção de agendamentos
    --------------------------------------*/


    /**
     * Compatibilidade com os fluxos existentes enquanto os servlets e a API
     * passam a informar explicitamente a autoria do agendamento.
     * Não inventa a origem de registros criados por chamadas antigas.
     */
    public void criar(int idCliente, int idVeiculo, LocalDate data, String horario,
            List<Integer> idsServicos) throws SQLException {
        criar(idCliente, idVeiculo, data, horario, idsServicos, null, null);
    }

    /**
     * Cria o agendamento e registra a origem informada pelo fluxo autenticado.
     * CLIENTE não possui colaborador criador; ATENDENTE e ADMINISTRADOR exigem
     * o ID do colaborador autenticado. A identificação deve vir da sessão,
     * nunca de um parâmetro arbitrário enviado pelo navegador.
     */
    public void criar(int idCliente, int idVeiculo, LocalDate data, String horario,
            List<Integer> idsServicos, String criadoPorTipo, Integer idColaboradorCriador)
            throws SQLException {
        if (criadoPorTipo == null) {
            if (idColaboradorCriador != null) {
                throw new IllegalArgumentException("Colaborador criador sem tipo de origem.");
            }
        } else if ("CLIENTE".equals(criadoPorTipo)) {
            if (idColaboradorCriador != null) {
                throw new IllegalArgumentException("Agendamento de cliente não pode ter colaborador criador.");
            }
        } else if ("ATENDENTE".equals(criadoPorTipo)
                || "ADMINISTRADOR".equals(criadoPorTipo)) {
            if (idColaboradorCriador == null || idColaboradorCriador <= 0) {
                throw new IllegalArgumentException("Informe o colaborador que criou o agendamento.");
            }
        } else {
            throw new IllegalArgumentException("Tipo de criador do agendamento inválido.");
        }

        // Regras de horário: grade, não passado e um agendamento por horário (checado na transação)
        LocalTime horarioAgendado = GradeHorarios.interpretar(horario);
        LocalDate hoje = LocalDate.now();
        if (data.isBefore(hoje) || (data.equals(hoje) && !horarioAgendado.isAfter(LocalTime.now()))) {
            throw new IllegalArgumentException("Não é possível agendar em data ou horário que já passou.");
        }

        Set<Integer> servicosUnicos = new LinkedHashSet<>(idsServicos);
        if (servicosUnicos.isEmpty() || servicosUnicos.size() != idsServicos.size()) {
            throw new IllegalArgumentException("Selecione ao menos um serviço, sem repetições.");
        }

        String verifyVehicle = """
                SELECT 1
                FROM veiculo v
                JOIN cliente c
                    ON c.id_cliente = v.id_cliente
                WHERE v.id_veiculo = ?
                  AND v.id_cliente = ?
                  AND v.ativo = TRUE
                  AND c.ativo = TRUE
                """;
        String getPrice = """
                SELECT preco
                FROM servico
                WHERE id_servico = ?
                  AND ativo = TRUE
                """;
        String insertAppointment = """
                INSERT INTO agendamento
                    (id_veiculo, data, horario, criado_por_tipo, id_colaborador_criador)
                VALUES (?, ?, ?, ?, ?)
                """;
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
                            throw new IllegalArgumentException(
                                    "Veículo não encontrado, inativo ou vinculado a um cliente inativo.");
                        }
                    }
                }

                // FOR UPDATE trava o intervalo: duas reservas simultâneas do mesmo horário se serializam
                try (PreparedStatement statement = connection.prepareStatement(
                        "SELECT 1 FROM agendamento WHERE data = ? AND horario = ? AND status <> 'CANCELADO' FOR UPDATE")) {
                    statement.setDate(1, Date.valueOf(data));
                    statement.setTime(2, Time.valueOf(horarioAgendado));
                    try (ResultSet result = statement.executeQuery()) {
                        if (result.next()) {
                            throw new IllegalArgumentException("Horário indisponível.");
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
                                throw new IllegalArgumentException(
                                        "Um dos serviços selecionados não existe ou está inativo.");
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
                    statement.setTime(3, Time.valueOf(horarioAgendado));
                    statement.setString(4, criadoPorTipo);
                    if (idColaboradorCriador == null) {
                        statement.setNull(5, java.sql.Types.INTEGER);
                    } else {
                        statement.setInt(5, idColaboradorCriador);
                    }
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

    public boolean cancelarAdministrativo(int idAgendamento) throws SQLException {

        String sqlAgendamento = """
                UPDATE agendamento
                SET status = 'CANCELADO'
                WHERE id_agendamento = ?
                  AND status = 'AGENDADO'

                  AND EXISTS (
                      SELECT 1
                      FROM atendimento
                      WHERE atendimento.id_agendamento =
                            agendamento.id_agendamento
                        AND atendimento.status = 'AGUARDANDO'
                  )

                  AND NOT EXISTS (
                      SELECT 1
                      FROM pagamento
                      WHERE pagamento.id_agendamento =
                            agendamento.id_agendamento
                        AND status_pagamento = 'PAGO'
                  )
                """;

        String sqlPagamento = """
                UPDATE pagamento
                SET status_pagamento = 'CANCELADO'
                WHERE id_agendamento = ?
                  AND status_pagamento = 'PENDENTE'
                """;

        try (Connection connection = DatabaseConnection.getConnection()) {
            connection.setAutoCommit(false);

            try {
                boolean cancelado;

                try (PreparedStatement statement = connection.prepareStatement(sqlAgendamento)) {

                    statement.setInt(1, idAgendamento);
                    cancelado = statement.executeUpdate() == 1;
                }

                if (cancelado) {
                    try (PreparedStatement statement = connection.prepareStatement(sqlPagamento)) {

                        statement.setInt(1, idAgendamento);
                        statement.executeUpdate();
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
}
